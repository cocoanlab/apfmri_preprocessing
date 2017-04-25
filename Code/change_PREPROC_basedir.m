function PREPROC = change_PREPROC_basedir(new_subject_dir, PREPROC)

% PREPROC = change_PREPROC_basedir(new_subject_dir, PREPROC)

old_subject_dir = PREPROC.subject_dir;
f = fields(PREPROC);

for i = 1:numel(f)
    clear temp_field temp_field_new;
    str_n = length(old_subject_dir);
    eval(['temp_field = PREPROC.' f{i} ';']);
    
    if iscell(temp_field)
        
        for j = 1:numel(temp_field)
            
            if iscell(temp_field{j})
                for k = 1:numel(temp_field{j})
                    try
                        start_n = strfind(temp_field{j}{k}, old_subject_dir);
                        end_n = start_n+str_n-1;
                        
                        temp_field{j}{k}(start_n:end_n) = [];
                        temp_field_new{j}{k} = fullfile(new_subject_dir, temp_field{j}{k});
                    catch
                    end
                end
            else
                try
                    start_n = strfind(temp_field{j}, old_subject_dir);
                    end_n = start_n+str_n-1;
                    
                    temp_field{j}(start_n:end_n) = [];
                    temp_field_new{j} = fullfile(new_subject_dir, temp_field{j});
                catch
                end
            end
        end
        
    else
        try
            start_n = strfind(temp_field, old_subject_dir);
            end_n = start_n+str_n-1;
            
            temp_field(start_n:end_n) = [];
            temp_field_new = fullfile(new_subject_dir, temp_field);
        catch
        end
    end
    
    try
        eval(['PREPROC.' f{i} ' = temp_field_new;']);
    catch
    end
end


end