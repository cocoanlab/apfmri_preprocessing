function PREPROC = apfmri_functional_2_implicitmask_savemean(subject_dir, session_num)

% This function creates and saves implicit mask (top 95% of voxels above
% the mean value) and mean functional images (before any preprocessing) in 
% the subject direcotry. The mean functional images can be used for coregistration.
% If you want to use multiple run data, you can simply put multiple numbers
% in session_num. e.g., session_num = 1:10 (run1 to 10).
%
% :Usage:
% ::
%        apfmri_functional_2_implicitmask_savemean(subject_dir, session_num)
%
% :Input:
% ::
%    - subject_dir            subject directory
%    - session_num            the number of the session (e.g., 1 means run 1)
%
% :Output(PREPROC):
% ::
%    PREPROC.implicit_mask_file
%    PREPROC.mean_before_preproc
%    saves implicit_mask.nii and mean_func_before_preproc_image.nii in subject_dir
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
% ..

PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

[~, ~, ~, ~, outputname] = fmri_mask_thresh_canlab(char(PREPROC.func_files{session_num}),...
    fullfile(subject_dir, 'implicit_mask.nii'));

PREPROC.implicit_mask_file = outputname;

dat = fmri_data(char(PREPROC.func_files{session_num}), PREPROC.implicit_mask_file);
mdat = mean(dat);
mdat.fullpath = fullfile(subject_dir, 'mean_func_before_preproc_image.nii');
write(mdat);

PREPROC.mean_before_preproc = mdat.fullpath;

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

end