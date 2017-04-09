function PREPROC = apfmri_structural_5_segment(subject_dir)

% What this function runs segmentation and save the deformation parameters 
% for later use
%
% :Usage:
% ::
%
%    PREPROC = apfmri_structural_5_segment(subject_dir);
%
% :Input:
% 
% - subject_dir               the subject directory
%
%
% :Things should be in your path:
%  - segment_rhesus_job.mat (segment_job matlabbatch for rhesus monkey)
%  - wisconsin atlas: gm_priors_ohsu+uw.nii
%                     wm_priors_ohsu+uw.nii
%                     csf_priors_ohsu+uw.nii
% 
% :Output(PREPROC):
% ::
%    PREPROC.wor_anat_files
%    PREPROC.norm_parameter_file (_seg_sn.mat in /SPGR)
%    PREPROC.segment_matlabbatch
%    PREPROC.norm_matlabbatch
%    run spm_check_registration.m for PREPROC.wor_anat_files
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

PREPROC.wor_anat_files = prepend_a_letter(PREPROC.or_anat_files, 1, 'w');
[d, f] = fileparts(PREPROC.or_anat_files{1});
PREPROC.norm_parameter_file = fullfile(d, [f '_seg_sn.mat']);

% Segmentation for anatomical image (uses ohsu + uw priors; McLaren et al. 2009)
load(which('segment_rhesus_job_spm8.mat'));

% load template files 
for i = 1:numel(segment_job.spatial{1}.preproc.opts.tpm)
    segment_job.spatial{1}.preproc.opts.tpm{i} = which(segment_job.spatial{1}.preproc.opts.tpm{i});
end

segment_job.spatial{1}.preproc.data = PREPROC.or_anat_files;

PREPROC.segment_matlabbatch = segment_job;

% Normalization for anatomical image
load(which('writenorm_rhesus_job_spm8.mat'));

writenorm_job.spatial{1}.normalise{1}.write.subj.matname = {PREPROC.norm_parameter_file};
writenorm_job.spatial{1}.normalise{1}.write.subj.resample = PREPROC.or_anat_files;
writenorm_job.spatial{1}.normalise{1}.write.roptions.vox = [.5 .5 .5];

PREPROC.norm_matlabbatch = writenorm_job;

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

spm('defaults','fmri');
spm_jobman('initcfg');

% spm_jobman('run', {segment_job});
spm_jobman('run', {segment_job writenorm_job});

if spm_check_version('matlab', '8') == 0 %spm8
    spm_check_registration(char(cat(1,{which('wisconsin_rhesus_atlas.nii')}, PREPROC.wor_anat_files)));
elseif spm_check_version('matlab', '9') == 0 %spm12
    spm_check_registration(which('wisconsin_rhesus_atlas.nii'), PREPROC.wor_anat_files);
end

end

