function obj = fmri_data_rhesus(image_names, maskinput, varargin)

% fmri_data wrapper for rhesus monkey:
%   This uses canlab fmri_data objects.
%
% :Usage:
% ::
%
%    dat = fmri_data_rhesus(image_names);
%
% :Optional Inputs:
% ::
%    please see fmri_data for more information


if nargin < 2 || isempty(maskinput)
    maskinput = which('brainmask_rhesus.nii');
end

obj = fmri_data(image_names, maskinput, varargin);

end