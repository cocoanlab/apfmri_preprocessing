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

% brainmask_rhesus.nii is somewhat blurred...
% brainmask_rhesus2.nii deleted all the values below zero in brainmask.nii


% need NMT in https://github.com/jms290/NMT
if isempty(varargin);
    image_names = which('NMT_brainmask.nii');
    maskinput = which('NMT_brainmask.nii');
end

if nargin < 2 || isempty(maskinput)
    maskinput = which('NMT_brainmask.nii');
end

obj = fmri_data(image_names, maskinput, varargin);

end