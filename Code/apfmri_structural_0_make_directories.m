function subject_dir = apfmri_structural_0_make_directories(subject_code, varargin)

% The function creates directories to save data
%
% :Usage:
% ::
%    subject_dir = apfmri_structural_0_make_directories(subject_code, [basedir if it's not fmri computer])
%

if isempty(varargin)
    basedir = '/Users/cnir/Documents/cocoanlab/animal_fMRI';
    subject_dir = fullfile(basedir, 'data', subject_code);
else
    subject_dir = fullfile(varargin{1}, subject_code);
end

Structural_dir = fullfile(subject_dir, 'Structural');
Functional_dir = fullfile(subject_dir, 'Functional');

mkdir(sprintf('%s/dicom', Structural_dir));

for i = 1:2
    mkdir(sprintf('%s/dicom/r%02d', Functional_dir, i));
end