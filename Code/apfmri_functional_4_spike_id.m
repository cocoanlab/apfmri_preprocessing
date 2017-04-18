function PREPROC = apfmri_functional_4_spike_id(subject_dir, session_num)

% This function detects outliers (spikes) based on Mahalanobis distance 
% and rmssd.
%
% :Usage:
% ::
%    PREPROC = apfmri_functional_4_spike_id(subject_dir, session_num);
%
%
% :Input:
% 
% - subject_dir     the subject directory
% - session_number  the number of session, e.g., session_number = 1
%
%
% :Output(PREPROC):
% ::
%    PREPROC.nuisance.spike_covariates
%    PREPROC.qcdir
%    create /qc_images directory in subject_dir
%    save qc_spike_plot.png in qcdir.
%    save qc_spike_diary.txt in qcir.
%
% ..
%     Author and copyright information:
%
%     Copyright (C) Apr 2017  Choong-Wan Woo
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

print_header('Spike and outlier detection', '');
PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

PREPROC.qcdir = fullfile(subject_dir, 'qc_images');
if ~exist(PREPROC.qcdir, 'dir'), mkdir(PREPROC.qcdir); end

%% DETECT OUTLIERS using canlab tools
dat = fmri_data(char(PREPROC.o_func_files{session_num}), PREPROC.implicit_mask_file);

if numel(session_num) == 1
    dat.images_per_session = size(dat.dat,2);
elseif numel(session_num) > 1
    for i = session_num
        [d,f] = fileparts(PREPROC.o_func_files{i});
        load(fullfile(d, [f '.mat']))
        dat.images_per_session(i) = size(mat,3);
    end
end

dat.images_per_session(dat.images_per_session == 0) = [];

diary(fullfile(PREPROC.qcdir, 'qc_spike_diary.txt'));
dat = preprocess(dat, 'outliers', 'plot');  % Spike detect and globals by slice
    
subplot(5, 1, 5);
dat = preprocess(dat, 'outliers_rmssd', 'plot');  % RMSSD Spike detect
diary off;    
sz = get(0, 'screensize'); % Wani added two lines to make this visible (but it depends on the size of the monitor)
set(gcf, 'Position', [sz(3)*.02 sz(4)*.05 sz(3) *.45 sz(4)*.85]);
drawnow;

qcspikefilename = fullfile(PREPROC.qcdir, 'qc_spike_plot.png'); % Scott added some lines to actually save the spike images
saveas(gcf,qcspikefilename);
            
if numel(session_num) == 1
    PREPROC.nuisance.spike_covariates{session_num} = dat.covariates; % the first one is global signal, that I don't need.
else
    PREPROC.nuisance.spike_covariates = dat.covariates; % the first one is global signal, that I don't need.
end

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

end