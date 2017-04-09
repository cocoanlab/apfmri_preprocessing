function PREPROC = apfmri_functional_3_reorient(subject_dir, session_n)

% This function reorient the functional images using the reorientation
% matrix you've got from the structural image (using PREPROC.str_reorient_mat).
%
% :Usage:
% ::
%    PREPROC = apfmri_functional_3_reorient(subject_dir, session_num);
%
%
% :Input:
% 
% - subject_dir     the subject directory, which should contain dicom data
%                   within the '/Functional/dicom/r##' directory 
%                   (e.g., subject_dir/Functional/dicom/r01)
% - session_number  the number of session, e.g., session_number = 1
%
%
% :Output(PREPROC):
% ::
%    PREPROC.o_func_files
%    PERPROC.func_preproc_descript
%    and run spm_check_registration
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

PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

%% REORIENT
load(PREPROC.str_reorient_mat);

print_header('Reorient', 'functional images');
for session_num = session_n
    str = sprintf('Working on session %02d', session_num);
    disp(str);
    PREPROC.o_func_files(session_num) = apfmri_reorient(PREPROC.func_files(session_num),  M);
end

PERPROC.func_preproc_descript = char({'o:reorientation';'a:slice timing';...
    'r:realignment';'w:normalization';'s:smoothing'});

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

%% spm_check_registration

if session_n > 1
    session_num = session_n(1);
end

if spm_check_version('matlab', '8') == 0 %spm8
    
    spm_check_registration(char(cat(1,{which('wisconsin_rhesus_atlas.nii')}, {[PREPROC.o_func_files{session_num} ',1']})));
    
elseif spm_check_version('matlab', '9') == 0 %spm12
    
    spm_check_registration(which('wisconsin_rhesus_atlas.nii'), [PREPROC.o_func_files{session_num} ',1']);
end


end