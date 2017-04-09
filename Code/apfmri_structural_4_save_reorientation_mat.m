function apfmri_structural_4_save_reorientation_mat(subject_dir)

% This function will save reorientation matrix for later reorientation of
% functional image data (assuming they don't move too much between
% structural and functional scans.. normally this is true because the rhesus 
% monkeys are anesthetized). 
%
% :Usage:
% ::
%       apfmri_structural_4_save_reorientation_mat(subject_dir)
% 
% :Input:
% ::
%       subject_dir       subject directory
%
% :Output(PREPROC):
% ::
%     PREPROC.str_reorient_mat
%     also saves "reorient_M_individual.mat" in subject_dir
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

M = spm_get_space(PREPROC.or_anat_files{1}) / (spm_get_space(PREPROC.r_anat_files{1}));

PREPROC.str_reorient_mat = fullfile(subject_dir, 'reorient_M_individual.mat');

save(PREPROC.str_reorient_mat, 'M');

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

end