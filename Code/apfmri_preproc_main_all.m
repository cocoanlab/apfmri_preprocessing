%% 1. BASIC SETTING

scriptdir = '/Users/cnir/Documents/cocoanlab/github/apfmri_preprocessing'; % CNIR MRI setting
% scriptdir = '/Users/clinpsywoo/github/apfmri_preprocessing'; % Wani's computer setting
apfmri_pathdef(scriptdir);

%% Subject directory, and create some data directories for you

basedir = '/Users/cnir/Documents/cocoanlab/animal_fMRI/Imaging'; % CNIR MRI setting
% basedir = '/Volumes/Wani_8T/data/APFmri/Imaging'; % Wani's computer setting
subject_code = 'mango_170419';
subject_dir = apfmri_structural_0_make_directories(subject_code, basedir);

% or directly provide subject_dir
% subject_dir = '/Users/clinpsywoo/cocoanlab_data/APFmri/mango_170405';

%% PREPROC: RUN THESE ON STRUCTURAL SCANS DURING RUN 1 (AFTER STRUCTURAL SCAN)

%% 2(QUICK). DICOM TO NIFTI: STRUCTURAL ===================================

apfmri_structural_1_dicom2nifti(subject_dir);

%% 3(QUICK). DICOM TO NIFTI: FUNCTIONAL -- to get reference ===============

session_num = 1:5;
disdaq = 5;

% session_num = 1:8;
% disdaq = [5 5 5 5 5 4 5 5]; % you can put different numbers of disdaq

apfmri_functional_1_dicom2nifti(subject_dir, session_num, disdaq);

%% 4(QUICK). save implicit mask and mean functional image =================

session_num = 1:5;
apfmri_functional_2_implicitmask_savemean(subject_dir, session_num);


%% 5(QUICK). COREGISTRATION TO FUNCTIONAL

apfmri_structural_2_coregistration(subject_dir);

%% 4(QUICK). REORIENTATION ================================================

apfmri_structural_3_reorientation(subject_dir)


%% 5(QUICK). SAVE REORIENTATION MATRIX
apfmri_structural_4_save_reorientation_mat(subject_dir);


%% 6. SEGMENTATION AND SAVING WARPING MATRIX FOR LATER ====================

apfmri_structural_5_segment(subject_dir);


%% 7(QUICK). DICOM TO NIFTI: FUNCTIONAL (RUN2) ============================
session_num = 1:5;
disdaq = 5;

apfmri_functional_1_dicom2nifti(subject_dir, session_num, disdaq);


%% 8(QUICK). Reorientation ================================================
% session_num = 1:2;
apfmri_functional_3_reorient(subject_dir, session_num);


%% 9(QUICK). Detect spikes, outliers ======================================
 
apfmri_functional_4_spike_id(subject_dir, session_num);
 

%% 10. SLICE TIME CORRECTION ==============================================

% apfmri_functional_5_slice_timing(subject_dir, session_num, 'TR', 1.2, 'MBF', 2, 'acq', 'interleaved_TD');

%% OPTIONAL: you can directly get slice timing info from dicom file
dicom_img = filenames(fullfile(subject_dir, 'Functional', 'dicom', 'r01*', '*IMA'));
hdr = dicominfo(dicom_img{1});
slice_time = hdr.Private_0019_1029;

apfmri_functional_5_slice_timing(subject_dir, session_num, 'TR', 1.4, 'MBF', 2, 'acq', 'interleaved_TD', 'slice_time', slice_time);

%% 11. MOTION CORRECTION ==================================================

apfmri_functional_6_motion_correction(subject_dir, session_num);


%% 12. Normalization ======================================================

apfmri_functional_7_normalization(subject_dir, session_num);


%% 13. Smoothing 

apfmri_functional_8_smooth(subject_dir, session_num);

%% 14. Move files

apfmri_functional_9_move_clean_files(subject_dir, session_num, 'move_only');


%% 13(QUICK). Regression

% basedir = '/Volumes/Wani_8T/data/APFmri/maple_170412/';
% behavioral_datdir = fullfile(fileparts(subject_dir), 'Behavioral');
behavioral_datdir = '/Users/cnir/Documents/cocoanlab/animal_fMRI/Behavioral/mango_170419';

i = 3; % run number
datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code, i)), 'char');
load(datfiles);

PREPROC = save_load_PREPROC(subject_dir, 'load');

PREPROC.TR = 1.4;

dat = fmri_data_rhesus(PREPROC.o_func_files{i});
dat = preprocess(dat, 'smooth', 3);  % smooth
dat = preprocess(dat, 'hpfilter', 125, PREPROC.TR); % high-pass filter

% disdaq = 5;
% img_n = out.img_number-disdaq;
% duration = 4; % in seconds
% 
out.event_regressor = onsets2fmridesign({[out.onsets' out.duration*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1), 'parametric_standard', {out.stim_intensity_mA'});

dat.X = out.event_regressor(:,1:2);
dat.covariates = PREPROC.nuisance.spike_covariates{i};
linear_trend = scale(1:size(dat.covariates,1),1)';
dat.covariates = [dat.covariates linear_trend]; % linear trend


%% 13-2 (Using all the session data). Regression 

behavioral_datdir = fullfile(fileparts(fileparts(subject_dir)), 'Behavioral', subject_code);

i = 1; % run number
datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code, i)), 'char');
load(datfiles);

PREPROC = save_load_PREPROC(subject_dir, 'load');

dat = fmri_data_rhesus(PREPROC.swrao_func_files{i});
dat = preprocess(dat, 'hpfilter', 125, PREPROC.TR); % high-pass filter

% disdaq = 5;
% img_n = out.img_number-disdaq;
% duration = 4;
% 
% out.event_regressor = onsets2fmridesign([(out.onsets+out.init)' duration*ones(size(out.onsets'))], out.TR, img_n*out.TR, spm_hrf(1));

dat.X = out.event_regressor(:,1);
dat.covariates = [PREPROC.nuisance.mvmt_covariates{i} PREPROC.nuisance.mvmt_covariates{i}.^2 ...
    [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})] [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})].^2];

spikes = PREPROC.nuisance.spike_covariates((img_n*(i-1)+1):(img_n*i),:);

dat.covariates = [dat.covariates spikes(:,any(spikes))];

linear_trend = scale(1:size(dat.covariates,1),1)';
dat.covariates = [dat.covariates linear_trend]; % linear trend



%% 14(Both quick and no-quick). Regression and threshold 
stats = regress(dat, .01, 'unc');

j = 1;
stats.b.dat = stats.b.dat(:,j);
stats.b.sig = stats.b.sig(:,j);
stats.b.p = stats.b.p(:,j);
stats.b.ste = stats.b.ste(:,j);

% visualization without thresholding
b_dat = fmri_data(stats.b);
orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})

%% visualization with thresholding

b_dat.dat = b_dat.dat .* stats.b.sig;
orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})
% orthviews_rhesus(b_dat)


