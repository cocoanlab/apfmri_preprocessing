function PREPROC = apfmri_structural_3_reorientation(subject_dir)

% This function prepares the reorientation and loads
% spm_check_registration. This function itself does not much, but you need
% to reorient the structural image manually. You can save the reorientation 
% matrix for the later use. 
%
% :Usage:
% :: 
%    apfmri_structural_3_reorientation(subject_dir)
%
%    ** see  apfmri_structural_4_save_reorientation_mat.m
%            apfmri_reorient.m
%
% :Output(PREPROC):
% ::
%    PREPROC.or_anat_files
%    run spm_check_registration

PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

PREPROC.or_anat_files = prepend_a_letter(PREPROC.r_anat_files, 1, 'o');

% copy first
copyfile(PREPROC.r_anat_files{1}, PREPROC.or_anat_files{1});

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

% spm_check_reg
spm_check_registration(char(cat(1,{which('wisconsin_rhesus_atlas.nii')}, PREPROC.or_anat_files)));

end