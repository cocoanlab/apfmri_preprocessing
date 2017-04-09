function PREPROC = apfmri_functional_7_normalization(subject_dir, session_num)

% This function does reorientation and normalization for the functional image 
% for one run. 
%
% :Usage:
% ::
%    apfmri_functional_7_normalization(subject_dir, session_num)
%
%
% :Input:
% 
% - subject_dir     the subject directory
% - session_number  the number of session, e.g., session_number = 1
%
% :Output(PREPROC):
% :: 
%    PREPROC.wrao_func_files
%    PREPROC.func_norm_matlabbatch 
%    run spm_check_registration with PREPROC.wrao_func_files
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


print_header('Normalization', 'Functional images');

PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

load(which('writenorm_rhesus_job_spm8.mat'));

writenorm_job.spatial{1}.normalise{1}.write.subj.matname = {PREPROC.norm_parameter_file};
writenorm_job.spatial{1}.normalise{1}.write.subj.resample = spm_image_list(char(PREPROC.rao_func_files(session_num)),1);
writenorm_job.spatial{1}.normalise{1}.write.roptions.vox = [];

PREPROC.func_norm_matlabbatch = writenorm_job;

for i = session_num
    wrao_func_files = prepend_a_letter(PREPROC.rao_func_files(i), 1, 'w');
    PREPROC.wrao_func_files{i} = wrao_func_files{1};
end

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run', {writenorm_job});

% display
if spm_check_version('matlab', '8') == 0 %spm8
    
    spm_check_registration(char(cat(1,{which('wisconsin_rhesus_atlas.nii')}, {[PREPROC.wrao_func_files{min(session_num)} ',1']})));
    
elseif spm_check_version('matlab', '9') == 0 %spm12
    
    spm_check_registration(which('wisconsin_rhesus_atlas.nii'), [PREPROC.wrao_func_files{min(session_num)} ',1']);
end

end
