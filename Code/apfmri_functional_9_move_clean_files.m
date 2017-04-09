function PREPROC = apfmri_functional_9_move_clean_files(subject_dir, session_num)


print_header('Move functional files', ' ');

PREPROC = save_load_PREPROC(subject_dir, 'load'); % load PREPROC

raw_dir = fullfile(subject_dir, 'Functional', 'raw');
preproc_dir = fullfile(subject_dir, 'Functional', 'Preprocessed');
mkdir(preproc_dir);

for i = session_num
    [~, f1] = fileparts(PREPROC.swrao_func_files{i});
    [~, f2] = fileparts(PREPROC.wrao_func_files{i});
    [~, r] = fileparts(fileparts(PREPROC.swrao_func_files{i}));
    mkdir(fullfile(preproc_dir, r))
    
    movefile(PREPROC.swrao_func_files{i}, fullfile(preproc_dir, r, [f1 '.nii']));
    movefile(fullfile(raw_dir, r, [f1 '.mat']), fullfile(preproc_dir, r, [f1 '.mat']));
    
    PREPROC.swrao_func_files{i} = fullfile(preproc_dir, r, [f1 '.nii']);
    
    movefile(PREPROC.wrao_func_files{i}, fullfile(preproc_dir, r, [f2 '.nii']));
    movefile(fullfile(raw_dir, r, [f2 '.mat']), fullfile(preproc_dir, r, [f2 '.mat']));
    PREPROC.wrao_func_files{i} = fullfile(preproc_dir, r, [f2 '.nii']);
end

save_load_PREPROC(subject_dir, 'save', PREPROC); % save PREPROC

end