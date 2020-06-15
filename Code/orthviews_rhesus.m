 function orthviews_rhesus(image_obj, varargin)

% Orthview (SPM) wrapper for rhesus monkey:
%   This uses canlab image_vector (or fmri_data, statistic_image) objects.
%
% :Usage:
% ::
%
%    orthviews_rhesus(image_obj, varargin)
%
% :Optional Inputs:
% 
%   **posneg:**
%        input generates orthviews using solid colors.
%
%   **largest_region:**
%        to center the orthviews on the largest region in the image
%
%   **overlay**
% 
%   **unique**
%
% for more options, see 'orthviews'

%overlay = which('SPM8_colin27T1_seg.img');
%overlay = which('wisconsin_rhesus_atlas.nii');
overlay = which('NMT_SS.nii');

ovidx = find(strcmp(varargin, 'overlay'), 1);
if ~isempty(ovidx)
    overlay = varargin{ovidx+1};
    varargin([ovidx, ovidx+1]) = [];
end

orthviews(image_obj, 'overlay', overlay, varargin);

end % function



