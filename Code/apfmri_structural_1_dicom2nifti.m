function PREPROC = apfmri_structural_1_dicom2nifti(subject_dir)

% This function saves the dicom files into nifti files in the Structural 
% image directory (subject_dir/Structural/SPGR). 
%
% :Usage:
% ::
%    PREPROC = apfmri_structural_dicom2nifti(subject_dir);
%
%
% :Input:
% 
% - subject_dir     the subject directory, which should contain dicom data
%                   within the 'dicom' directory (subject_dir/Structural/dicom)
%
%   ** This function will create and save PREPROC in PREPROC.mat in subject_dir
%
% :Output(PREPROC):
%
%   PREPROC.anat_files (in nifti)
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

outdir = fullfile(subject_dir, 'Structural', 'SPGR');
datdir = fullfile(subject_dir, 'Structural', 'dicom');

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

[~, h] = dicm2nii(filenames(fullfile(datdir, '*IMA')), outdir, 4);
f = fields(h);

PREPROC.subject_dir = subject_dir;
PREPROC.anat_files = {fullfile(outdir, [f{1} '.nii'])};

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

end