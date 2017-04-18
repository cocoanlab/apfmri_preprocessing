function PREPROC = apfmri_functional_6_motion_correction(subject_dir, session_num)

% This function does motion correction (realignment) on a single run functional 
% image data.
%
% :Usage:
% ::
%      apfmri_functional_6_motion_correction(subject_dir, session_num)
%
%
% :Input:
% 
% - subject_dir             the subject directory
% - session_num             the session number, e.g., 1
%
% :Output(PREPROC):
% ::
%   PREPROC.realign_job
%   PREPROC.rao_func_files
%   PREPROC.mvmt_param_files
%   PREPROC.nuisance.mvmt_covariates
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

print_header('Motion correction (realignment)', '');

PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

% DEFAULT
def = spm_get_defaults('realign');
matlabbatch = {};
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions = def.estimate;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions = def.write;
    
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0; % do not register to mean (twice as long)
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 0; % do not mask (will set data to zero at edges!)
    
matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = spm_image_list(char(PREPROC.ao_func_files{session_num}),1);

if numel(session_num) == 1
    PREPROC.realign_job{session_num} = matlabbatch{1};
else
    PREPROC.realign_job = matlabbatch{1};
end

for i = session_num
    rao_func_files = prepend_a_letter(PREPROC.ao_func_files(i), 1, 'r');
    PREPROC.rao_func_files{i} = rao_func_files{1};
end

% RUN

spm('defaults','fmri');
spm_jobman('initcfg');
spm_jobman('run', {matlabbatch});

if numel(session_num) == 1
    [d, f] = fileparts(PREPROC.ao_func_files{session_num});
    PREPROC.mvmt_param_files{session_num} = fullfile(d, ['rp_' f '.txt']);
    PREPROC.nuisance.mvmt_covariates{session_num} = textread(PREPROC.mvmt_param_files{session_num});
else
    [d, f] = fileparts(PREPROC.ao_func_files{min(session_num)});
    PREPROC.mvmt_param_files{min(session_num)} = fullfile(d, ['rp_' f '.txt']);
    temp_mvmt = textread(PREPROC.mvmt_param_files{min(session_num)});
    
    for i = session_num
        [d,f] = fileparts(PREPROC.rao_func_files{i});
        load(fullfile(d, [f '.mat']))
        images_per_session = size(mat,3);
        PREPROC.nuisance.mvmt_covariates{i} = temp_mvmt(1:images_per_session,:);
        temp_mvmt(1:images_per_session,:) = [];
    end
    
end

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

end
