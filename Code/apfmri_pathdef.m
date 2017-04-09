function apfmri_pathdef(scriptdir)

% This function adds necessary toolboxes to the current path. 
% 
% :Usage:
% ::
%         apfmri_path_def(scriptdir);
%
% :Input:
% ::
%         scriptdir      The directory that contains all the scripts you
%                        need to run this preprocessing pipeline
%
% * Required external toolboxes
%     1. spm8 (r6313 version) with the updated slice time correction
%         functions for multi-band sequence 
%         see https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=ind1407&L=spm&D=0&P=795113
%     2. dicm2nii toolbox (http://www.mathworks.com/matlabcentral/fileexchange/42997)
%         The "dicm2nii" toolbox has been used to convert the dicom to nifti. 
%         The main function has been modified to get some header info as an output.
%     3. Canlab tools: I'm using some toolboxes from Tor Wager's lab (where 
%         I did my PhD). One key tool is the "CanlabCore" toolbox
%         (https://github.com/canlab/CanlabCore), and the other one is 
%         the "Preprocess" tool (https://github.com/canlab/preprocess).
%         Basically the current preproc pipeline is quite similar to Canlab's
%         preproc pipeline. I recommend downloading these toolboxes directly 
%         from the github website.
%     4. Standard template: This preproc pipeline is currently using the
%         Wisconsin rhesus monkey atlas based on 112 rhesus monkeys.
%         Coordinates are based on the distance (in mm) from anterior anterior
%         commissure (which is set to [0 0 0]). 
%         For more information about the atlas, see McLaren et al., 2010, 
%         NeuroImage, A Population-Average MRI-Based Atlas Collection of
%         the Rhesus Macaque, and http://brainmap.wisc.edu/monkey.html
%
% The external toolboxes are currently saved in the "External" directory, 
% and the atlas is saved in "Wisconsin_atlas", but you should be able to 
% change the paths, if you want.
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


analysis_path = fullfile(scriptdir, 'Code');
toolbox_path = fullfile(scriptdir, 'External');
atlas_path = fullfile(scriptdir, 'Wisconsin_atlas');

addpath(genpath(analysis_path));
addpath(genpath(toolbox_path));
addpath(genpath(atlas_path));

end
