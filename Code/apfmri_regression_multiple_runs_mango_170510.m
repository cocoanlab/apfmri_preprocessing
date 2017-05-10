behavioral_datdir = '/Users/cnir/Documents/cocoanlab/animal_fMRI/Behavioral/mango_170510';
subject_code2 = 'Mango';

% behavioral_datdir = fullfile(fileparts(fileparts(subject_dir)), 'Behavioral', subject_code);
clear dat;
k = 0;
for i = 1:6 %[4 5 6] % run number

    k = k + 1;
    datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code2, i)), 'char');
    load(datfiles);

    PREPROC = save_load_PREPROC(subject_dir, 'load');

    dat{k} = fmri_data_rhesus(PREPROC.o_func_files{i});
%     dat{k} = fmri_data_rhesus(PREPROC.swrao_func_files{i});
    dat{k} = preprocess(dat{k}, 'smooth', 3);  % smooth
    dat{k} = preprocess(dat{k}, 'hpfilter', 180, 1.4); % high-pass filter

%     for j = 7:10
%         idx = out.stim_intensity_mA==j;
%         new_onsets = out.onsets(idx);
%         event_regressor = onsets2fmridesign({[new_onsets' out.duration*ones(size(new_onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
%         out.event_regressor(:,j-6) = event_regressor(:,1);
%     end
    %out.event_regressor = onsets2fmridesign({[out.onsets' out.duration*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1), 'parametric_standard', {out.stim_intensity_mA'});
        
    event_regressor = onsets2fmridesign({[(out.onsets+4)' 4*ones(size(out.onsets'))]}, out.TR, (out.img_number-out.disdaq)*out.TR, spm_hrf(1));
    % dat{k}.X = out.event_regressor(:,1:2);
    dat{k}.X = event_regressor(:,1);
%     dat{k}.covariates = [PREPROC.nuisance.mvmt_covariates{i} PREPROC.nuisance.mvmt_covariates{i}.^2 ...
%         [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})] [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})].^2];
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

image_num = 516;

for i = 1:numel(dat)
    dat_new.covariates((image_num*(i-1)+1):image_num*i, sum(col_size(1:i)):(sum(col_size(1:i+1))-1)) = dat{i}.covariates;
end

dat_new.covariates = [dat_new.covariates blkdiag(ones(image_num,1),ones(image_num,1),ones(image_num,1), ones(image_num,1),ones(image_num,1),ones(image_num,1))];

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
orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})
% orthviews_rhesus(b_dat)


%% RUN 1-2

behavioral_datdir = fullfile(fileparts(fileparts(subject_dir(1:end-4))), 'Behavioral', subject_code(1:end-4));
clear dat;
k = 0;
for i = 1:2 %run number

    k = k + 1;
    datfiles = filenames(fullfile(behavioral_datdir, sprintf('out_%s_sess%d_*mat', subject_code(1:end-4), i)), 'char');
    load(datfiles);

    PREPROC = save_load_PREPROC(subject_dir, 'load');

    dat{k} = fmri_data_rhesus(PREPROC.swrao_func_files{i});
    disdaq = 5;
    img_n = out.img_number-disdaq;
    duration = 4;

    out.event_regressor = onsets2fmridesign([(out.onsets+3)' duration*ones(size(out.onsets'))], out.TR, img_n*out.TR, spm_hrf(1));
        
    dat{k}.X = out.event_regressor(:,1);
    dat{k}.covariates = [PREPROC.nuisance.mvmt_covariates{i} PREPROC.nuisance.mvmt_covariates{i}.^2 ...
        [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})] [zeros(1,6); diff(PREPROC.nuisance.mvmt_covariates{i})].^2];

%     spikes = PREPROC.nuisance.spike_covariates((img_n*(i-1)+1):(img_n*i),:);

%     dat{k}.covariates = [dat{k}.covariates spikes(:,any(spikes))];
end

%%
dat_new = dat{1};

for i = 2:numel(dat)
    dat_new.dat = [dat_new.dat dat{i}.dat];
    dat_new.X = [dat_new.X; dat{i}.X];
end

dat_new.covariates = zeros(size(dat_new.X,1),24*numel(dat));

for i = 1:numel(dat)
    dat_new.covariates((515*(i-1)+1):(515*i),(24*(i-1)+1):(24*i)) = dat{i}.covariates;
end

dat_new.covariates = [dat_new.covariates PREPROC.nuisance.spike_covariates];

dat_new.covariates = [dat_new.covariates blkdiag(ones(515,1),ones(515,1))];

%% 14(Both quick and no-quick). Regression and threshold 
stats = regress(dat_new, .000001, 'unc');

stats.b.dat = stats.b.dat(:,1);
stats.b.sig = stats.b.sig(:,1);
stats.b.p = stats.b.p(:,1);
stats.b.ste = stats.b.ste(:,1);

% visualization without thresholding
b_dat = fmri_data(stats.b);
orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})

%% visualization with thresholding

b_dat.dat = b_dat.dat .* stats.b.sig;
orthviews(b_dat, 'overlay', PREPROC.or_anat_files{1})
orthviews_rhesus(b_dat)


