%% INFORMATION GATHERING TASK MAIN TRIALS

SEEDVAL=floor(rem(now*10000,1)*10000); %use clock for seed

% v1 - LH 01/03/2013
rand('seed',SEEDVAL); % reseed random number generator
complete = 0;

%% EXPERIMENTAL SETUP

%constants - check these before every run
EYETRACKING     = 0;        % eyetracking?
EXPCONTROL      = 0;        % wait for experimenter input at various points in expt.?
DISPLAY         = 1;        % 0 for window, 1 for whole screen (see config_display, below)
MRI             = 0;        % 0 for behavioral, 1 for fMRI
NUM_TRIALS      = 40;       % per run
RUNS            = 5;        % number of runs
FEEDBACK        = 0;         %0: feedback is shown on 50% of trials (MRI); 1: feedback is shown all the time
    
% set cue meanings
probabilities=[0.1 0.3 0.5 0.7 0.9];
magnitudes=[10 30 50 70 90];

% rootdir - change for each computer
%rootdir = 'C:\Users\stimpc2\Desktop\Paula\info_gathering_human';

rootdir = '/Users/paulak/Documents/MSc/RSA_3D/Paula/info_gathering_human';



%% 1. ask for subject ID and setup logfile

lfOK = 0; %logfile check flag

while ~lfOK
    subjID = input('Subject ID: ','s');
    runno = str2double(input('Run: ','s'));

    TD_stamp = [strrep(datestr(now,2),'/','-') '-' strrep(datestr(now,13),':','-')]
    outfile = sprintf('%s\\data\\logfiles\\%s_main_%0.0f_%s.mat',rootdir,subjID,runno,TD_stamp);
    if runno>1 %load in previous logfile, containing number of points won so far etc.
        previous_outfile = sprintf('%s\\data\\logfiles\\%s_main_%0.0f_*.mat',rootdir,subjID,runno-1);
        dd = dir(previous_outfile);
        if isempty(dd)
            error('Couldn''t find previous logfile');
        else
            previous_outfile = sprintf('%s\\data\\logfiles\\%s',rootdir,dd(end).name); %load in most recent file
        end
        tmp = load(previous_outfile);
        total_points = tmp.total_points;
        total_pounds = tmp.total_pounds; 
        sched = tmp.sched;
        first_cue_timings = tmp.first_cue_timings;
        second_cue_timings = tmp.second_cue_timings;
    end
    cogent_logfile = sprintf('%s\\data\\logfiles\\%s_main_%0.0f%s.log',rootdir,subjID,runno,TD_stamp);
    
    lfOK = ~exist(outfile,'file')||strcmp(subjID,'test');
    if ~lfOK
        error('logfile already exists for subject %s!\n',subjID);
    end
    config_log(cogent_logfile);
end

if EYETRACKING
    if EXPCONTROL
        fprintf('EXPERIMENTER: Check eyetracker is accurately calibrated\n');
        pause;
    end
    if Eyelink( 'Initialize' ) ~= 0; return; end % open a connection to the eyetracker PC
    ELfname = [subjID num2str(runno)];
    Eyelink( 'Openfile', ELfname )                % open a file, ELfname, on the eyetracker PC
end

if isempty(subjID);
    error('Empty subjID');
end
clear lfOK

%ALLOCATE CUES TO STIMULI
%cuefile = sprintf('%s\\Cue_Order\\cue_order_MRI_%s.mat',rootdir,subjID);
cuefile = sprintf('%s//Cue_Order//cue_order_MRI_%s.mat', rootdir,subjID);
load(cuefile);

%% PRACTICE BLOCK
if runno==0
    EYETRACKING_PRACTICE=0;
    %% 2. configure cogent

    config_mouse;
    config_keyboard;
    switch DISPLAY
        case 0 %window
            config_display(0,3,[0 0 0],[1 1 1],'Arial',40,5); %resolution:1280x1024
        case 1 %whole-screen
            config_display(1,3,[0 0 0],[1 1 1],'Arial',40,5); %resolution:1280x1024
    end

    start_cogent;logstring('Experiment started');
    keymap = getkeymap;

    %% 3. generate schedule, set timing and button info

    [first_cue, first_cue_loc, second_cue_loc, stim, second_cue]=...
       make_blocks(probabilities, magnitudes);
    sched = generate_schedule(NUM_TRIALS, first_cue_loc, second_cue_loc, probability_order, magnitude_order, probabilities, magnitudes, stim);
    

    timings.ITItime     = 1500;
    timings.starttrial  = 1000;
    timings.firstcue    = 2000;
    timings.secondcue   = 2000;
    timings.thirdcue    = 2000;
    timings.fourthcue   = 2000;
    timings.choicetime  = 100000;
    timings.selecttime  = 750;
    timings.uncovertime = 750;
    timings.ruletime    = 1750;
    timings.feedbacktime1 = 2000;
    timings.feedbacktime2 = 1500;
    timings.dwelltime   = 300;

    buttons.opt = [keymap.A; keymap.D];
    buttons.pic = [keymap.Pad7 keymap.Pad1; keymap.Pad9 keymap.Pad3];

    %% 4. preload pictures?

    %% 5. initialise variables

    %% 6. introduce expt.

    clearpict( 1 );
    preparestring( 'Practice will begin shortly', 1 )
    drawpict( 1 );
    wait(3000);
    clearpict( 1 );
    drawpict( 1 );

    %% 7. run task
    roundscores = [];
    total_points=150;
    total_pounds=0;

    for t = 1:10 %loop over trials
        %TODO move this into generate_schedule?
        schedt = sched(t);
        schedt.loc(:,1,1) = [-250 200];
        schedt.loc(:,1,2) = [-250 -100];
        schedt.loc(:,2,1) = [250  200];
        schedt.loc(:,2,2) = [250 -100];
        schedt.ruleloc(:,1)=[-250 -250];
        schedt.ruleloc(:,2)=[250  -250];
        schedt.rulestrloc(:,1)=[-250 50];
        schedt.rulestrloc(:,2)=[250  50];    
        schedt.rewloc(:,1)=[-250 -280];
        schedt.rewloc(:,2)=[250  -280];
        schedt.selr(:,1) =  [-250 50 270 640];
        schedt.selr(:,2) =  [250 50 270 640];

        % jitter timings
        timings.postcue1(t) = 1000*(4*rand());
        timings.postcue2(t) = 1000*(4*rand());
        
        [chosen(t), chose_to_reveal{t}, turndur{t}, noresponse(t), rewout(t), sumcost(t), outcome(t),total_points_out(t),total_pounds_out(t)] =...
            run_IG_trial(schedt,buttons,timings, total_points, total_pounds, t, EYETRACKING_PRACTICE, FEEDBACK);
        
        total_points=total_points_out(t);
        total_pounds=total_pounds_out(t);
        

    end
    clear chosen
    clear chose_to_reveal
    clear turndur
    clear noresponse
    clear rewout
    clear sumcost
    clear outcome
    clear total_points
    clear sched
    
    stop_cogent;
    return;
end



%% 2. configure cogent

config_mouse;
config_keyboard;
switch DISPLAY
    case 0 %window
        config_display(0,3,[0 0 0],[1 1 1],'Arial',40,5); %resolution:1280x1024
    case 1 %whole-screen
        config_display(1,3,[0 0 0],[1 1 1],'Arial',40,5); %resolution:1280x1024
end
% 

start_cogent;logstring('Experiment started');
keymap = getkeymap;

%% 3. generate schedule, set timing and button info

NUM_TRIALS=200;

if runno==1
    [first_cue, first_cue_loc, second_cue_loc, stim, second_cue]=...
        make_blocks(probabilities, magnitudes);
    for i = 1:5
        for j = 1:40
            first_cue_timings((i-1)*40+j) = 1000*((first_cue(i,j,4)-1)*0.8+rand*0.8);
            second_cue_timings((i-1)*40+j) = 1000*((second_cue(i,j,2)-1)*0.8+rand*0.8);
        end
    end
    
    sched = generate_schedule(NUM_TRIALS, first_cue_loc, second_cue_loc, probability_order, magnitude_order, probabilities, magnitudes, stim);
end

a=(runno-1)*40+1;
b=runno*40;

timings.ITItime     = 1500;
timings.starttrial  = 1000;
timings.firstcue    = 2000;
timings.secondcue   = 2000;
timings.thirdcue    = 2000;
timings.fourthcue   = 2000;
timings.choicetime  = 5000;
timings.selecttime  = 750;
timings.uncovertime = 750;
timings.ruletime    = 1750;
timings.feedbacktime1 = 2000;
timings.feedbacktime2 = 1500;
timings.dwelltime   = 300;

buttons.opt = [keymap.A; keymap.D];
buttons.pic = [keymap.Pad7 keymap.Pad1; keymap.Pad9 keymap.Pad3];

%% 4. preload pictures?

%% 5. initialise variables

%% 6. introduce expt.

clearpict( 1 );
preparestring( 'Game will begin shortly', 1 )
drawpict( 1 );

if MRI %wait for 3 TRs (button 5 on OHBA scanner) before starting experiment
    TR_count = 0;
    while TR_count<=3
        n = 2;
        while n>1 %sometimes waitkeydown returns more than one number
            [keyout,~,n] = waitkeydown(inf,keymap.K5);
        end
        TR_count = TR_count + 1;
    end
else
    wait(3000);
end
clearpict( 1 );
drawpict( 1 );

%% 7. run task
roundscores = [];
if runno==1
    total_points=150;
    total_pounds=0;
end

if EYETRACKING
    Eyelink('StartRecording');
end

for t = a:b %loop over trials
    %TODO move this into generate_schedule?
    schedt = sched(t);
    schedt.loc(:,1,1) = [-250 200];
    schedt.loc(:,1,2) = [-250 -100];
    schedt.loc(:,2,1) = [250  200];
    schedt.loc(:,2,2) = [250 -100];
    schedt.ruleloc(:,1)=[-250 -250];
    schedt.ruleloc(:,2)=[250  -250];
    schedt.rulestrloc(:,1)=[-250 50];
    schedt.rulestrloc(:,2)=[250  50];    
    schedt.rewloc(:,1)=[-250 -280];
    schedt.rewloc(:,2)=[250  -280];
    schedt.selr(:,1) =  [-250 50 270 640];
    schedt.selr(:,2) =  [250 50 270 640];

    % jitter timings
    timings.postcue1(t) = first_cue_timings(t);
    timings.postcue2(t) = second_cue_timings(t);
    
    [chosen(t), chose_to_reveal{t}, turndur{t}, noresponse(t), rewout(t), sumcost(t), outcome(t),total_points_out(t),total_pounds_out(t)] =...
        run_IG_trial(schedt,buttons,timings, total_points, total_pounds, t, EYETRACKING, FEEDBACK);
    logkeys;
    
    total_points=total_points_out(t);
    total_pounds=total_pounds_out(t);

    save(outfile);
    
    if mod(t,40)==0
%         tmp = outcome(t-39:t); tmp(isnan(tmp))=[]; 
%         roundscores(end+1) = sum(tmp)/100; clear tmp;
%         clearpict( 1 );
%         if roundscores(end)>0
%             setforecolour(0,1,0);
%         else
%             setforecolour(1,0,0);
%         end
%         preparestring(sprintf('You have made a total of £%0.0f so far!',total_pounds),1);
%         drawpict( 1 );
%         setforecolour(1,1,1);
%         wait(3000);
%         if (200-t)>39
        clearpict( 1 );
        preparestring( 'Take a break! The experiment will restart shortly.', 1 );
        drawpict( 1 );
        wait(20000);
         clearpict( 1 );
%         preparestring( 'Whenever you''re ready, press any button to restart the experiment.', 1 );
%         drawpict( 1 );
%         waitkeydown(Inf);
%         clearpict( 1 );
%         drawpict( 1 );
%         end
    end
end

if EYETRACKING
    Eyelink('StopRecording');
end
    
%% 8. cleanup and save
complete = 1;
save(outfile);

%% 9. exit
cgshut;
stop_cogent;

%% 10. 
if EYETRACKING
    outfilePath = fullfile(rootdir,'data','EyelinkLogfiles',[ELfname '.edf']);
    eyelinkReceivedFile(runno) = Eyelink('ReceiveFile',ELfname,outfilePath)
    Eyelink('Shutdown');
end