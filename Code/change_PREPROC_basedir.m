function PREPROC = change_PREPROC_basedir(new_subject_dir, PREPROC)

% PREPROC = change_PREPROC_basedir(new_subject_dir, PREPROC)

old_subject_dir = PREPROC.subject_dir;
f = fields(PREPROC);

for i = 1:numel(f)
    str_n = length(old_subject_dir);
    eval(['temp_field = PREPROC.' f{i} ';']);

    start_n = strfind(temp_field{i}, old_subject_dir);
    end_n = start_n+str_n-1;
    
    temp_field{i}(start_n:end_n) = [];
    temp_field_new{i} = fullfile(new_subject_dir, temp_field{i});
    
    PREPROC.f{i} = temp_field_new{i};
end


end