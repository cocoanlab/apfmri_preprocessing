result_dir = '/Volumes/habenula/monkeynas/APFmri/Imaging/result_images';

%% TR12, not whole brain

behavioral_datdir = '/Volumes/habenula/monkeynas/APFmri/Behavioral/maple_170517_TR12';
subject_code2 = 'maple_170517_TR12';
subject_dir = '/Volumes/habenula/monkeynas/APFmri/Imaging/maple_170517_TR12';

% behavioral_datdir = fullfile(fileparts(fileparts(subject_dir)), 'Behavioral', subject_code);
clear dat;
k = 0;
for i = [1 2 3 4] %[4 5 6] % run number

    k = k + 1;
    datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code2, i)), 'char');
    load(datfiles);

    PREPROC = save_load_PREPROC(subject_dir, 'load');

%     dat{k} = fmri_data_rhesus(PREPROC.o_func_files{i});
    dat{k} = fmri_data_rhesus(PREPROC.swrao_func_files{i});
    % dat{k} = preprocess(dat{k}, 'smooth', 3);  % smooth
    dat{k} = preprocess(dat{k}, 'hpfilter', 125, 1.2); % high-pass filter

%     for j = 7:10
%         idx = out.stim_intensity_mA==j;
%         new_onsets = out.onsets(idx);
%         event_regressor = onsets2fmridesign({[new_onsets' out.duration*ones(size(new_onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
%         out.event_regressor(:,j-6) = event_regressor(:,1);
%     end
    %out.event_regressor = onsets2fmridesign({[out.onsets' out.duration*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1), 'parametric_standard', {out.stim_intensity_mA'});
        
    event_regressor = onsets2fmridesign({[(out.onsets)' 5*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
    % dat{k}.X = out.event_regressor(:,1:2);
    dat{k}.X = event_regressor(:,1);
    dat{k}.covariates = [PREPROC.nuisance.mvmt_covariates{i} PREPROC.nuisance.mvmt_covariates{i}.^2 ...
        [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})] [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})].^2];
    dat{k}.covariates = [dat{k}.covariates PREPROC.nuisance.spike_covariates{i}];

%     dat{k}.covariates = [dat{k}.covariates spikes(:,any(spikes))];
    linear_trend = scale(1:size(dat{k}.covariates,1))';
    dat{k}.covariates = [dat{k}.covariates linear_trend];
end

%%
clear dat_new;
dat_new = dat{1};

for i = 2:numel(dat)
    dat_new.dat = [dat_new.dat dat{i}.dat];
    dat_new.X = [dat_new.X; dat{i}.X];
end

dat_new.covariates = [];

% col_size = [];
col_size = 1;
for i = 1:numel(dat)
    col_size(i+1) = size(dat{i}.covariates,2);
end

dat_new.covariates = zeros(size(dat_new.X,1),sum(col_size)-1);

image_num = 585;

for i = 1:numel(dat)
    dat_new.covariates((image_num*(i-1)+1):image_num*i, sum(col_size(1:i)):(sum(col_size(1:i+1))-1)) = dat{i}.covariates;
end

dat_new.covariates = [dat_new.covariates blkdiag(ones(image_num,1),ones(image_num,1), ones(image_num,1), ones(image_num,1))];

dat_new.X = [dat_new.X dat_new.covariates(:,1:(end-1))];

%% 14(Both quick and no-quick). Regression and threshold 
stats = regress(dat_new, .01, 'unc');

%%
j= 1;
stats1 = stats;
stats1.b.dat = stats.b.dat(:,j);
stats1.b.sig = stats.b.sig(:,j);
stats1.b.p = stats.b.p(:,j);
stats1.b.ste = stats.b.ste(:,j);

% visualization without thresholding
b_dat = fmri_data(stats1.b);
% orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})

b_dat.dat = b_dat.dat .* stats1.b.sig;
% orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})
orthviews_rhesus(b_dat)

b_dat.fullpath = fullfile(result_dir, 'maple_170517_TR12_r4567_p01unc.nii');
write(b_dat);

%% TR14 whole brain

behavioral_datdir = '/Volumes/habenula/monkeynas/APFmri/Behavioral/maple_170517_TR14';
subject_code2 = 'maple_170517_TR14';
subject_dir = '/Volumes/habenula/monkeynas/APFmri/Imaging/maple_170517_TR14';

% behavioral_datdir = fullfile(fileparts(fileparts(subject_dir)), 'Behavioral', subject_code);
clear dat;
k = 0;
for i = [1 2 3] %[4 5 6] % run number

    k = k + 1;
    datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code2, i)), 'char');
    load(datfiles);

    PREPROC = save_load_PREPROC(subject_dir, 'load');

%     dat{k} = fmri_data_rhesus(PREPROC.o_func_files{i});
    dat{k} = fmri_data_rhesus(PREPROC.swrao_func_files{i});
    % dat{k} = preprocess(dat{k}, 'smooth', 3);  % smooth
    dat{k} = preprocess(dat{k}, 'hpfilter', 125, 1.2); % high-pass filter

%     for j = 7:10
%         idx = out.stim_intensity_mA==j;
%         new_onsets = out.onsets(idx);
%         event_regressor = onsets2fmridesign({[new_onsets' out.duration*ones(size(new_onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
%         out.event_regressor(:,j-6) = event_regressor(:,1);
%     end
    %out.event_regressor = onsets2fmridesign({[out.onsets' out.duration*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1), 'parametric_standard', {out.stim_intensity_mA'});
        
    event_regressor = onsets2fmridesign({[(out.onsets)' 5*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
    % dat{k}.X = out.event_regressor(:,1:2);
    dat{k}.X = event_regressor(:,1);
    dat{k}.covariates = [PREPROC.nuisance.mvmt_covariates{i} PREPROC.nuisance.mvmt_covariates{i}.^2 ...
        [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})] [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})].^2];
    dat{k}.covariates = [dat{k}.covariates PREPROC.nuisance.spike_covariates{i}];

%     dat{k}.covariates = [dat{k}.covariates spikes(:,any(spikes))];
    linear_trend = scale(1:size(dat{k}.covariates,1))';
    dat{k}.covariates = [dat{k}.covariates linear_trend];
end

%%
clear dat_new;
dat_new = dat{1};

for i = 2:numel(dat)
    dat_new.dat = [dat_new.dat dat{i}.dat];
    dat_new.X = [dat_new.X; dat{i}.X];
end

dat_new.covariates = [];

% col_size = [];
col_size = 1;
for i = 1:numel(dat)
    col_size(i+1) = size(dat{i}.covariates,2);
end

dat_new.covariates = zeros(size(dat_new.X,1),sum(col_size)-1);

image_num = 515;

for i = 1:numel(dat)
    dat_new.covariates((image_num*(i-1)+1):image_num*i, sum(col_size(1:i)):(sum(col_size(1:i+1))-1)) = dat{i}.covariates;
end

dat_new.covariates = [dat_new.covariates blkdiag(ones(image_num,1),ones(image_num,1), ones(image_num,1))];

dat_new.X = [dat_new.X dat_new.covariates(:,1:(end-1))];

%% 14(Both quick and no-quick). Regression and threshold 
stats = regress(dat_new, .01, 'unc');

%%
j= 1;
stats1 = stats;
stats1.b.dat = stats.b.dat(:,j);
stats1.b.sig = stats.b.sig(:,j);
stats1.b.p = stats.b.p(:,j);
stats1.b.ste = stats.b.ste(:,j);

% visualization without thresholding
b_dat = fmri_data(stats1.b);
% orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})

b_dat.dat = b_dat.dat .* stats1.b.sig;
% orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})
orthviews_rhesus(b_dat);

b_dat.fullpath = fullfile(result_dir, 'maple_170517_TR14_r123_p01unc.nii');
write(b_dat);

%% surface coil whole-brain

behavioral_datdir = '/Volumes/habenula/monkeynas/APFmri/Behavioral/maple_170517_surface';
subject_code2 = 'maple_170517_surface';
subject_dir = '/Volumes/habenula/monkeynas/APFmri/Imaging/maple_170517_surface';

% behavioral_datdir = fullfile(fileparts(fileparts(subject_dir)), 'Behavioral', subject_code);
clear dat;
k = 0;
for i = [1 2] %[4 5 6] % run number

    k = k + 1;
    datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code2, i)), 'char');
    load(datfiles);

    PREPROC = save_load_PREPROC(subject_dir, 'load');

%     dat{k} = fmri_data_rhesus(PREPROC.o_func_files{i});
    dat{k} = fmri_data_rhesus(PREPROC.swrao_func_files{i});
    % dat{k} = preprocess(dat{k}, 'smooth', 3);  % smooth
    dat{k} = preprocess(dat{k}, 'hpfilter', 125, 1.2); % high-pass filter

%     for j = 7:10
%         idx = out.stim_intensity_mA==j;
%         new_onsets = out.onsets(idx);
%         event_regressor = onsets2fmridesign({[new_onsets' out.duration*ones(size(new_onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
%         out.event_regressor(:,j-6) = event_regressor(:,1);
%     end
    %out.event_regressor = onsets2fmridesign({[out.onsets' out.duration*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1), 'parametric_standard', {out.stim_intensity_mA'});
        
    event_regressor = onsets2fmridesign({[(out.onsets)' 5*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
    % dat{k}.X = out.event_regressor(:,1:2);
    dat{k}.X = event_regressor(:,1);
    dat{k}.covariates = [PREPROC.nuisance.mvmt_covariates{i} PREPROC.nuisance.mvmt_covariates{i}.^2 ...
        [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})] [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})].^2];
    dat{k}.covariates = [dat{k}.covariates PREPROC.nuisance.spike_covariates{i}];

%     dat{k}.covariates = [dat{k}.covariates spikes(:,any(spikes))];
    linear_trend = scale(1:size(dat{k}.covariates,1))';
    dat{k}.covariates = [dat{k}.covariates linear_trend];
end

%%
clear dat_new;
dat_new = dat{1};

for i = 2:numel(dat)
    dat_new.dat = [dat_new.dat dat{i}.dat];
    dat_new.X = [dat_new.X; dat{i}.X];
end

dat_new.covariates = [];

% col_size = [];
col_size = 1;
for i = 1:numel(dat)
    col_size(i+1) = size(dat{i}.covariates,2);
end

dat_new.covariates = zeros(size(dat_new.X,1),sum(col_size)-1);

image_num = 515;

for i = 1:numel(dat)
    dat_new.covariates((image_num*(i-1)+1):image_num*i, sum(col_size(1:i)):(sum(col_size(1:i+1))-1)) = dat{i}.covariates;
end

dat_new.covariates = [dat_new.covariates blkdiag(ones(image_num,1), ones(image_num,1))];

dat_new.X = [dat_new.X dat_new.covariates(:,1:(end-1))];

%% 14(Both quick and no-quick). Regression and threshold 
stats = regress(dat_new, .01, 'unc');

%%
j= 1;
stats1 = stats;
stats1.b.dat = stats.b.dat(:,j);
stats1.b.sig = stats.b.sig(:,j);
stats1.b.p = stats.b.p(:,j);
stats1.b.ste = stats.b.ste(:,j);

% visualization without thresholding
b_dat = fmri_data(stats1.b);
% orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})

b_dat.dat = b_dat.dat .* stats1.b.sig;
% orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})
orthviews_rhesus(b_dat)

b_dat.fullpath = fullfile(result_dir, 'maple_170517_surface_r89_p01unc.nii');
write(b_dat);

