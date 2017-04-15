function out = apfmri_trigger_main(savedir)

% make this into a function
% feature: randomize inter-trial intervals, administer 20 trials of
% electric stimulation, save all the timing, start trials by getting the
% signal from the scanner
% ask: run info, level of current (mA), image numbers
% output: data, timing, current, estimated BOLD regressor

try
    WaitSecs(0.05);
catch
    error('Psychtoolbox is not in your path. Please add the toolbox into your path.');
end

fprintf('\n');
out.MID = input('Monkey ID? ','s');
out.RunN = input('Run number? ','s');
out.current = input('What is the level of current (mA)? ');
out.TR = input('TR (in seconds)? ');
out.img_number = input('How many images? ');
out.date = date;

%% output filename
fname = fullfile(savedir, ['out_' out.MID '_sess' out.RunN '_' out.date '.mat']);

out.fname = fname;

if ~exist(savedir, 'dir')
    mkdir(savedir);
else
    if exist(fname, 'file')
        str = ['The Monkey ' out.MID ' session ' out.RunN ' data file already exists. Please check!'];
        warning(str);
        s = input('If it''s okay, press r. If you want to quit the program, press q: ', 's'); 
        if strcmp(s, 'r')
            
        elseif strcmp(s, 'q')
            error('You quit the program.');
        end
    end
end

%% generating stimulus time sequence

disdaq = 6;
iti = repmat([13 16 20 25], 1, 7);
iti = iti(randperm(numel(iti)));

onsets = [];

onsets(1) = 0;
for i = 1:(numel(iti)-1)
    onsets(i+1) = onsets(i)+iti(i);
end

disp('===============================================================');
fprintf('The least number of scans you need is %4d', round((onsets(end)+iti(end))/out.TR));
fprintf('\nThe number of scans you entered is %4d\n', out.img_number);
disp('===============================================================');

if onsets(end)+iti(end) > out.TR * out.img_number
    str = 'The length of the run is longer than your scan. Please check the number of scans.';
    error(str);
end

out.iti = iti;
out.onsets = onsets;
out.disdaq_in_secs = disdaq;

%out.event_regressor = onsets2fmridesign([out.onsets' ones(size(out.onsets'))], out.TR, out.img_number, spm_hrf(1));

% save data
save(fname, 'out');

%% Master-9 parameter setting
cmOff = 0;
cmFree = 1;
cmTrain = 2;
cmTrig = 3;
cmDC = 4;
cmGate = 5;
cmTwin=6;
csMonopolar=0;
csBipolar=1;
csRamp=2;

%% step 1: Connect the PC to Master-8 first. Connect return true on success connection.

Master9 = actxserver('AmpiLib.Master9'); %Create COM Automation server

if ~(Master9.Connect)
    h=errordlg('Can''t connect to Master9!','Error');
    uiwait(h);
    delete(Master9); %Close COM
    return;
end;
 
Master9.ChangeParadigm(1);            %switch to paradigm #1
Master9.ClearParadigm;                %clear present paradigm

%% step 2: Master-9 Channel setting

% channel #1: trigger
Master9.ChangeChannelMode(1, cmTrig);	

Master9.SetChannelDuration(1, 10); 
Master9.SetChannelDelay(1, 0); 
Master9.ConnectChannel(1, 2);

% channel #2: repeating triggers of 40ms stimulation
Master9.ChangeChannelMode(2, cmTrain);		
Master9.SetChannelDuration(2, 40e-3); 
Master9.SetChannelInterval(2, 100e-3);
Master9.SetChannelN(2, 40);
Master9.ConnectChannel(2, 3);

% channel #3: delivering eletric stimulation
Master9.ChangeChannelMode(3, cmTrain);		
Master9.SetChannelDuration(3, 5e-3); 
Master9.SetChannelInterval(3, 10e-3); 
Master9.SetChannelN(3, 4); 
%Master9.SetChannelShape(3,csBipolar);
Master9.SetChannelShape(3,csMonopolar);
%Master9.SetChannelShape(3,csRamp);


%% ready for scanning
disp('======================================');
disp('    Ready for scanning!!!!!');
disp('======================================');

% to sync with MRI scanner
while (1)
    [~,~,keyCode] = KbCheck;
    
    if keyCode(KbName('s'))==1
        break
    elseif keyCode(KbName('q'))==1
        error('You stopped the code');
    end
end

%% Deliver the electrical stimulations

for i = 1:numel(onsets)
    if i == 1
        WaitSecs(disdaq+3); % 8 seconds for disdaq, 3 seconds for baseline
    end
    
    Master9.Trigger(1);
    WaitSecs(iti(i));
    
end

% save data
save(fname, 'out');

end






