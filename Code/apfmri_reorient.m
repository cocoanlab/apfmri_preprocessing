function oimgs = apfmri_reorient(imgs, M)

% :Input:
% 
%  - imgs       image names in cell array

oimgs = prepend_a_letter(imgs, 1, 'o');

for i = 1:numel(imgs)
    copyfile(imgs{i}, oimgs{i});
end

P = char(oimgs{:});
P = expand_4d_filenames(P);

Mats = zeros(4,4,size(P,1));

for i=1:size(P,1)
    Mats(:,:,i) = spm_get_space(P(i,:));
end

%% Set new orientation

for i=1:size(P,1)
    spm_get_space(P(i,:), M*Mats(:,:,i));
end

% Show us again.
% canlab_preproc_montage_first_volumes(imgs)

% Bring up first image:
% spm_image('init', imgs{1}(1, :));
% drawnow
% try_snapnow_for_publish
end