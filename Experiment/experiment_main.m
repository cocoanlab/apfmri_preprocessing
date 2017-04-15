cd('C:\Users\user\Documents\My Experiments\cocoanlab\apfmri');

run('experiment_pathdef.m');

%% run the experiment
% change this for different subject
subject_dir = 'C:\Users\user\Documents\My Experiments\cocoanlab\apfmri\data\maple_170412';

out = apfmri_trigger_main(subject_dir);
