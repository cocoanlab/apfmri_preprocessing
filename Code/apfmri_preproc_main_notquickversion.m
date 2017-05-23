%% 1. BASIC SETTING

% scriptdir = '/Users/cnir/Documents/cocoanlab/github/apfmri_preprocessing'; % CNIR MRI setting
% scriptdir = '/Users/clinpsywoo/github/apfmri_preprocessing'; % Wani's computer setting
scriptdir = '/Resources/github/cocoanlab/apfmri_preprocessing'; % habenula's computer setting
apfmri_pathdef(scriptdir);

%% Subject directory, and create some data directories for you

% basedir = '/Users/cnir/Documents/cocoanlab/animal_fMRI/Imaging'; % CNIR MRI setting
% basedir = '/Volumes/Wani_8T/data/APFmri/Imaging'; % Wani's computer setting
basedir = '/Volumes/habenula/monkeynas/APFmri/Imaging'; % Habenula's computer setting

subject_code = 'maple_170517_surface';
subject_dir = apfmri_structural_0_make_directories(subject_code, basedir);

% or directly provide subject_dir
% subject_dir = '/Users/clinpsywoo/cocoanlab_data/APFmri/mango_170405';

%% PREPROC: RUN THESE ON STRUCTURAL SCANS DURING RUN 1 (AFTER STRUCTURAL SCAN)

%% 2(QUICK). DICOM TO NIFTI: STRUCTURAL ===================================

apfmri_structural_1_dicom2nifti(subject_dir);

%% 3(QUICK). DICOM TO NIFTI: FUNCTIONAL -- to get reference ===============

session_num = 1:2;
disdaq = 5; % from behavioral data out.disdaq

% session_num = 1:8;
% disdaq = [5 5 5 5 5 4 5 5]; % you can put different numbers of disdaq

apfmri_functional_1_dicom2nifti(subject_dir, session_num, disdaq);

%% 4(QUICK). save implicit mask and mean functional image =================

%session_num = 1:2;
apfmri_functional_2_implicitmask_savemean(subject_dir, session_num);


%% 5(QUICK). COREGISTRATION TO FUNCTIONAL

apfmri_structural_2_coregistration(subject_dir);

%% 4(QUICK). REORIENTATION ================================================

apfmri_structural_3_reorientation(subject_dir)


%% 5(QUICK). SAVE REORIENTATION MATRIX
apfmri_structural_4_save_reorientation_mat(subject_dir);


%% 6. SEGMENTATION AND SAVING WARPING MATRIX FOR LATER ====================

apfmri_structural_5_segment(subject_dir);

% %% 7(QUICK). DICOM TO NIFTI: FUNCTIONAL (RUN2) ============================
% session_num = 4;
% disdaq = 5;
% 
% apfmri_functional_1_dicom2nifti(subject_dir, session_num, disdaq);


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


