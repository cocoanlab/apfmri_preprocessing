function PREPROC = apfmri_functional_8_smooth(subject_dir, session_num, varargin)

% This function does smoothing on the functional image for one run. 
%
% :Usage:
% ::
%    apfmri_functional_8_smooth(subject_dir, session_num)
%
%
% :Input:
% ::
%
% - subject_dir     the subject directory
% - session_number  the number of session, e.g., session_number = 1
%
% :Optional Input:
% ::
%    'fwhm', 3      full-width half max for the smoothing kernel
%
%
% :Output(PREPROC):
% :: 
%     PREPROC.swrao_func_files
%     PREPROC.smoothing_job 
%     save 'swra_func_files.png' in qcdir
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

print_header('Smoothing', ':functional images');

fwhm = 5; % default fwhm

for i = 1:numel(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            case {'fwhm'} % in seconds
                fwhm = varargin{i+1};
        end
    end
end


PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

matlabbatch = {};
matlabbatch{1}.spm.spatial.smooth = spm_get_defaults('smooth');
matlabbatch{1}.spm.spatial.smooth.dtype = 0; % data type; 0 = same as before
matlabbatch{1}.spm.spatial.smooth.im = 0; % implicit mask; 0 = no
matlabbatch{1}.spm.spatial.smooth.fwhm = repmat(fwhm, 1, 3); % override whatever the defaults were with this
matlabbatch{1}.spm.spatial.smooth.data = spm_image_list(char(PREPROC.wrao_func_files(session_num)), 1); % individual cells for each volume
  
% Save the job
PREPROC.smoothing_job = matlabbatch;

for i = session_num
    swrao_func_files = prepend_a_letter(PREPROC.wrao_func_files(i), 1, 's');
    PREPROC.swrao_func_files{i} = swrao_func_files{1};
end

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

canlab_preproc_show_montage(char(PREPROC.swrao_func_files{session_num}), fullfile(PREPROC.qcdir, 'swra_func_files.png'));

end