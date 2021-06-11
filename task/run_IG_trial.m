function [chosen, chose_to_reveal, turndur, noresponse, rewout, sumcost, outcome, points, pounds] =...
    run_IG_trial(sched,buttons,timings,total_points,total_pounds, trind, EYETRACKING, FEEDBACK)

% run_IG_trial(sched,buttons,timings)
%
% runs trial of information gathering experiment
%

% v1 - LH 01/03/2013

%% some constants - these could be changed to input arguments in future versions

WRITECOSTS = 1; %display written costs on each card when available?
CHOSECOLOUR=[0.3 0.3 0.3];

%% load in info from input arguments

%trial schedule
if numel(sched)>1
    error('sched should be just a single-trial structure');
end
nT          = sched.nTurns;
nO          = sched.nOpt;
nA          = sched.nAttr;
FB          = sched.feedback;   % whether or not this is a feedback trial
cost        = sched.cost;       % cost for each turn, matrix dims nT * nO * nA; nan if unavailable
reward      = sched.reward;     % reward/punishment on each option, dims nO * 1 
probability = sched.Prob;       % probabilities
magnitude   = sched.Magn;       % magnitudes
value       = sched.Val;        % magnitude/probability each stimulus
stim        = sched.stim;       % picture file at each location, nO * nA
rewloc      = sched.rewloc;     % locations in which to display information about reward, 2(x,y) * nO
ruleloc     = sched.ruleloc;    % locations in which to display information about rule, 2(x,y) * nO
rulestrloc  = sched.rulestrloc; % locations in which to display information about rule, 2(x,y) * nO
uncovered   = zeros(2,2);       % whether the options start out uncovered or not, nO * nA (1/0)
canrespond  = sched.canrespond; % whether the subject is allowed to choose at each turn, nT * 1
availstim   = sched.availstim;  % stimulus to display when option can be uncovered
unavailstim = sched.unavailstim;% stimulus to display when option cannot be uncovered
turnedstim  = sched.turnedstim; %
loc         = sched.loc;        % locations of stimuli in pixels, 2(x,y) * nO * nA 
selr        = sched.selr;       % selection rectangle height and width for each option 4(x,y,h,w) * nO
try coststim= sched.coststim;end% cost stimulus for each turn, cell array dims nT * nO * nA; nan if unavailable
try rewstim = sched.rewstim; end% reward stimulus for each option, cell array dims nO *1
points      = total_points;     % points earned so far
pounds      = total_pounds;     % pounds earned so far
% TODO check dimensions of inputs

optkey      = buttons.opt;      % active buttons for each option, nO*1
pickey      = buttons.pic;      % active buttons for each picture, nO*nA

ITItime     = timings.ITItime;  % duration of ITI
starttrial  = timings.starttrial;
firstcue    = timings.firstcue;
postcue1    = timings.postcue1(trind);
secondcue   = timings.secondcue;
postcue2    = timings.postcue2(trind);
thirdcue    = timings.thirdcue;
fourthcue   = timings.fourthcue;
choicetime  = timings.choicetime;%time allowed for response, can be single number or nT * 1
if numel(choicetime)==1
    choicetime = repmat(choicetime,nT+1,1);
end
selecttime  = timings.selecttime;%time for which selected option is presented, with other options covered
uncovertime = timings.uncovertime;%time for which selected option is presented, with all other options covered
ruletime    = timings.ruletime; % time for which rule is presented
feedbacktime1 = timings.feedbacktime1;
feedbacktime2 = timings.feedbacktime2;

chosen = nan;
chose_to_reveal = nan;
seen_cues = nan;
turndur = nan;
noresponse = nan;
sumcost = nan;
rewout = nan;

%% 1. present intertrial interval

if ITItime>0
    cG = 1; cgsetsprite(cG);
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,1,0);
    end
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    present_graphic(cG,ITItime,sprintf('TRIALID %d %d %d',trind,1,0));
end

%% 2. present decision phase, until decision is made (or timeout occurs)

chosen = 0;
noresponse = 0;
sumcost = 0;
turndur = nan(nT,1);

turn = 1; %current turn

%beginning of trial screen; all cues are covered
if starttrial>0
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    for p = 1:numel(stim)
        loadpict_mod(unavailstim,cG,loc(1,p),loc(2,p));
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,2,0);
    end
    present_graphic(cG,starttrial,sprintf('TRIALID %d %d %d',trind,2,0));
end

%first cue is shown
if firstcue>0
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    for p = 1:numel(stim)
        if isnan(cost(turn,p))
            loadpict_mod(unavailstim,cG,loc(1,p),loc(2,p));
        else
            loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
        end
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,3,0);
    end
    present_graphic(cG,firstcue,sprintf('TRIALID %d %d %d',trind,3,0));
end

%jitter after first cue
if postcue1>0
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    for p = 1:numel(stim)
        if isnan(cost(turn,p))
            loadpict_mod(unavailstim,cG,loc(1,p),loc(2,p));
        else
            loadpict_mod(turnedstim,cG,loc(1,p),loc(2,p));
        end
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,4,0);
    end
    present_graphic(cG,postcue1,sprintf('TRIALID %d %d %d',trind,4,0));
end 

%second cue is shown
if secondcue>0
    turn=turn+1;
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    for p = 1:numel(stim)
        if ~isnan(cost(1,p))
            loadpict_mod(turnedstim,cG,loc(1,p),loc(2,p));
        elseif isnan(cost(turn,p))
            loadpict_mod(unavailstim,cG,loc(1,p),loc(2,p));
        else
            loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
        end
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,5,0);
    end
    present_graphic(cG,secondcue,sprintf('TRIALID %d %d %d',trind,5,0));
end

%jitter after second cue
if postcue2>0
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    for p = 1:numel(stim)
        if or(~isnan(cost(turn,p)),~isnan(cost(turn-1,p)))
            loadpict_mod(turnedstim,cG,loc(1,p),loc(2,p));
        elseif isnan(cost(turn,p))
            loadpict_mod(unavailstim,cG,loc(1,p),loc(2,p));
        end
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,6,0);
    end
    present_graphic(cG,postcue2,sprintf('TRIALID %d %d %d',trind,6,0));
    turn=turn+1;
end

while ~chosen&~noresponse
    cG = 1;cgsetsprite(cG); %current graphic
    %a. draw picture
    if turn==3
        for p = 1:numel(stim)
            if ~isnan(cost(turn-1,p))|~isnan(cost(turn-2,p))
                loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
            else                            %picture is covered and available
                loadpict_mod(availstim,cG,loc(1,p),loc(2,p));
                if exist('coststim','var')    %overlay cost stimulus?
                    loadpict_mod(coststim{turn,p},cG,loc(1,p),loc(2,p));
                elseif WRITECOSTS
                    cgrect(loc(1,p),loc(2,p),80,40,[0 0 0]);
                    setforecolour(1,0,0);
                    preparestring(sprintf('%0.0f',cost(turn,p)),cG,loc(1,p),loc(2,p));
                    setforecolour(1,1,1);
                end
            end
        end
    elseif turn==4
        for p = 1:numel(stim)
            if ~isnan(cost(turn-3,p))|~isnan(cost(turn-2,p))
                loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
            elseif p==chose_to_reveal(turn-1)
                loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
            else                            %picture is covered and available
                loadpict_mod(availstim,cG,loc(1,p),loc(2,p));
                if exist('coststim','var')    %overlay cost stimulus?
                    loadpict_mod(coststim{t,p},cG,loc(1,p),loc(2,p));
                elseif WRITECOSTS
                    cgrect(loc(1,p),loc(2,p),80,40,[0 0 0]);
                    setforecolour(1,0,0);
                    preparestring(sprintf('%0.0f',cost(turn,p)),cG,loc(1,p),loc(2,p));
                    setforecolour(1,1,1);
                end
            end
        end
    else
        for p = 1:numel(stim)
            loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
        end
    end
    
    %b. calculate permissable responses
    if turn<=nT
        availpic = squeeze(~isnan(cost(turn,:,:)))&~uncovered; %1 if available to uncover on this turn, 0 if not
        if canrespond(turn) %allowed to make choice, as well as uncover, on this turn
            hotkeys = [optkey; pickey(availpic(:))];
        else             %only allowed to uncover on this turn
            hotkeys = pickey(availpic(:))';
        end
    else %all information has been uncovered - final turn
        hotkeys = optkey;
    end
    
        
    %c. present picture and await response
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,7,turn);
    end
    if turn==4
        points=points-3;
    elseif turn==5
        points=points-6;
    end
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    [choseopt,turndur(turn),noresponse] = present_graphic_with_response(cG,choicetime(turn),hotkeys,sprintf('TRIALID %d %d %d',trind,7,turn));
    
    
    %d. calculate what to do next
    if any(choseopt==optkey)                %MADE CHOICE...
        chose_to_reveal(turn) = nan;
        chosen=find(choseopt==optkey);          %break from loop    
    elseif any(choseopt==pickey(:))         %UNCOVERED PICTURE...
        chose_to_reveal(turn) = find(choseopt==pickey);
        uncovered(choseopt==pickey(:))=1;       %turn over picture in next turn
        sumcost = sumcost + cost(turn,find(choseopt==pickey(:)));%add cost to sumcost
    elseif ~noresponse                      %MADE UNIDENTIFIED RESPONSE
        error('bug in code - response should either be noresponse, chose option, or turned over picture');
    end
    
    % present chosen cue
    if turn==3&&any(choseopt==pickey(:))&&thirdcue>0
        for p = 1:numel(stim)
            if ~isnan(cost(turn-1,p))|~isnan(cost(turn-2,p))
                loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
            elseif chose_to_reveal(turn)==p             %draw uncovered stimulus at current location
                loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
            else                            %picture is covered and available
                loadpict_mod(unavailstim,cG,loc(1,p),loc(2,p));
            end
        end
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    if EYETRACKING
            Eyelink('message','TRIALID %d %d %d',trind,8,0);
        end
        present_graphic(cG,thirdcue,sprintf('TRIALID %d %d %d',trind,8,0));
    elseif turn==4&&any(choseopt==pickey(:))&&fourthcue>0
        for p = 1:numel(stim)
            if ~isnan(cost(turn-2,p))|~isnan(cost(turn-3,p))
                loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
            elseif p==chose_to_reveal(turn-1)
                loadpict_mod(turnedstim, cG, loc(1,p), loc(2,p));
            else           %draw uncovered stimulus at current location
                loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
            end
        end
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    if EYETRACKING
            Eyelink('message','TRIALID %d %d %d',trind,9,0);
        end
        present_graphic(cG,fourthcue,sprintf('TRIALID %d %d %d',trind,9,0));
    end
    turn=turn+1;                                  %move onto next turn
end

%% 3. present selected option

if selecttime>0&&~noresponse
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    cgrect(selr(1,chosen),selr(2,chosen),selr(3,chosen),selr(4,chosen),CHOSECOLOUR);  %chosen card background
    for p = 1:numel(stim)
        loadpict_mod(turnedstim,cG,loc(1,p),loc(2,p));
    end

    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,10,0);
    end
    present_graphic(cG,selecttime,sprintf('TRIALID %d %d %d',trind,10,0));
end

if uncovertime>0&&~noresponse&&FEEDBACK
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    cgrect(selr(1,chosen),selr(2,chosen),selr(3,chosen),selr(4,chosen),CHOSECOLOUR);  %chosen card background
    if FEEDBACK
        for p = 1:numel(stim)
            loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
        end
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,11,0);
    end
    present_graphic(cG,uncovertime,sprintf('TRIALID %d %d %d',trind,11,0));
end

%% 4. do rule-based calculations and present, if required

%calculate reward strings
rewstr = cell(nO,1);
for o = 1:nO
    if isnan(reward(o))
        rewstr{o} = 'Quits';
    else
        rewstr{o} = sprintf('%0.0f points',reward(o));
    end
end

%present
if ruletime>0&&~noresponse&&FEEDBACK
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    cgrect(selr(1,chosen),selr(2,chosen),selr(3,chosen),selr(4,chosen),CHOSECOLOUR);  %chosen card background
    if FEEDBACK
        for p = 1:numel(stim)
            loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
        end
    end
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,12,0);
    end
    present_graphic(cG,ruletime*0.1,sprintf('TRIALID %d %d %d',trind,12,0));
end

if feedbacktime1>0&&~noresponse&&FEEDBACK
    cG = 1;cgsetsprite(cG);
    if FEEDBACK
        money_bar(points,pounds,cG);
    else
        money(pounds,cG);
    end
    cgrect(selr(1,chosen),selr(2,chosen),selr(3,chosen),selr(4,chosen),CHOSECOLOUR);  %chosen card background
    for p = 1:numel(stim)
        loadpict_mod(stim{p},cG,loc(1,p),loc(2,p));
    end
    
    % present cue meanings
    if value(1)<1
        topleft_str=sprintf('%0.0f %% probability',value(1)*100);
        topright_str=sprintf('%0.0f %% probability',value(2)*100);
        bottomleft_str=sprintf('%0.0f reward',value(3));
        bottomright_str=sprintf('%0.0f reward',value(4));
    else
        bottomleft_str=sprintf('%0.0f %% probability',value(3)*100);
        bottomright_str=sprintf('%0.0f %% probability',value(4)*100);
        topleft_str=sprintf('%0.0f reward',value(1));
        topright_str=sprintf('%0.0f reward',value(2));
    end
    settextstyle('Arial',24);
    preparestring(topleft_str, cG, -250, 350);
    preparestring(topright_str, cG, 250, 350);
    preparestring(bottomleft_str, cG, -250, -250);
    preparestring(bottomright_str,cG,250, -250);
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,13,0);
    end
    present_graphic(cG,feedbacktime1,sprintf('TRIALID %d %d %d',trind,13,0));
end    

%% 5. calculate outcome and present, if required

%calculate outcome
if ~noresponse&&feedbacktime2>0&&FEEDBACK==0 % show choice, how much you paid, and reward outcome if FB==1
    if isnan(reward(chosen))
        coststr = '';
    else
        coststr = sprintf('You paid %0.0f points',sumcost);
    end
    rewout = reward(chosen);
    outcome = rewout-sumcost;
    points=points+rewout;
    if points>=300
        points=points-300;
        pounds=pounds+0.50;
    end
    
    cgrect(selr(1,chosen),selr(2,chosen),selr(3,chosen),selr(4,chosen),CHOSECOLOUR);  %chosen card background
        for p = 1:numel(stim) %uncovered stimuli
            if chosen==1
                loadpict_mod(turnedstim,cG,loc(1,1),loc(2,1));
                loadpict_mod(turnedstim,cG,loc(1,3),loc(2,3));
            else
                loadpict_mod(turnedstim,cG,loc(1,2),loc(2,2));
                loadpict_mod(turnedstim,cG,loc(1,4),loc(2,4));
            end
        end
    
    if isnan(reward(chosen))
        outstr = '';OScol = [0 0 0];
    else
        if FB
            outstr = sprintf('You won: %0.0f points',rewout); OScol = [0 1 0];
            if rewout==0
                OScol = [1 0 0];
            end
        else
            outstr = sprintf('You won: X points'); OScol = [1 1 1];
        end
    %elseif outcome<0
    %    outstr = sprintf('Overall loss: %0.0f points',outcome); OScol = [1 0 0];
    end
    settextstyle('Arial',24);
    setforecolour(1,0,0);preparestring(coststr,cG,0,15);
    setforecolour(OScol(1),OScol(2),OScol(3));
    preparestring(outstr,cG,0,-15);setforecolour(1,1,1);
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,14,0);
    end
    money(pounds,cG);
    present_graphic(cG,feedbacktime2,sprintf('TRIALID %d %d %d',trind,14,0));
else
    outcome = nan;
end

if ~noresponse&&feedbacktime2>0&&FEEDBACK==1
    if ~noresponse
        cG = 1;cgsetsprite(cG);
        %money_bar(points,pounds,cG);
        if isnan(reward(chosen))
            coststr = '';
        else
            coststr = sprintf('You paid %0.0f points',sumcost);
        end
        rewout = reward(chosen);
        outcome = rewout-sumcost;
        points=points+rewout;
        if points>=300
            points=points-300;
            pounds=pounds+0.50;
        end
        
        if isnan(reward(chosen))
            outstr = '';OScol = [0 0 0];
        else
            if outcome>0
                outstr = sprintf('You won: %0.0f points',rewout); OScol = [0 1 0];
                if rewout==0
                    OScol = [1 0 0];
                end
            elseif outcome<=0
                outstr = sprintf('Overall loss: %0.0f points',outcome); OScol = [1 0 0];
            end
        end
        
        cgrect(selr(1,chosen),selr(2,chosen),selr(3,chosen),selr(4,chosen),CHOSECOLOUR);  %chosen card background
        for p = 1:numel(stim) %uncovered stimuli
            if chosen==1
                loadpict_mod(stim{1},cG,loc(1,1),loc(2,1));
                loadpict_mod(stim{3},cG,loc(1,3),loc(2,3));
            else
                loadpict_mod(stim{2},cG,loc(1,2),loc(2,2));
                loadpict_mod(stim{4},cG,loc(1,4),loc(2,4));
            end
        end
        if exist('rewstim','var')
            for r = 1:numel(rewstim)
                if ~isempty(rewstim{r})
                    loadpict_mod(rewstim{r},cG,selr(1,r),selr(2,r));
                end
            end
        end
        
        % present cue meanings
        %
        
        % present cue meanings
        if value(1)<1
            topleft_str=sprintf('%0.0f %% probability',value(1)*100);
            topright_str=sprintf('%0.0f %% probability',value(2)*100);
            bottomleft_str=sprintf('%0.0f reward',value(3));
            bottomright_str=sprintf('%0.0f reward',value(4));
        else
            bottomleft_str=sprintf('%0.0f %% probability',value(3)*100);
            bottomright_str=sprintf('%0.0f %% probability',value(4)*100);
            topleft_str=sprintf('%0.0f reward',value(1));
            topright_str=sprintf('%0.0f reward',value(2));
        end
        settextstyle('Arial',24);
        if chosen==1
            preparestring(topleft_str, cG, -250, 350);
            preparestring(bottomleft_str, cG, -250, -250);
        else
            preparestring(topright_str, cG, 250, 350);
            preparestring(bottomright_str,cG,250, -250);
        end
        
        settextstyle('Arial',24);
        setforecolour(1,0,0);preparestring(coststr,cG,0,15);
        setforecolour(OScol(1),OScol(2),OScol(3));
        preparestring(outstr,cG,0,-15);setforecolour(1,1,1);
        settextstyle('Arial',40);
        money_bar(points,pounds,cG);
        
        if EYETRACKING
            Eyelink('message','TRIALID %d %d %d',trind,15,0);
        end
        present_graphic(cG,feedbacktime2,sprintf('TRIALID %d %d %d',trind,15,0));
    end
end

%% 6. present hurry up screen, if subject didn't respond
if noresponse
    chosen = nan;
    cG = 2;cgsetsprite(cG);
    
    settextstyle('Arial',40);preparestring('Too slow!',cG);
    
    if EYETRACKING
        Eyelink('message','TRIALID %d %d %d',trind,15,0);
    end
    
    present_graphic(cG,1000,sprintf('TRIALID %d %d %d',trind,15,0));
end


end %end of main function



%% STIMULUS PRESENTATION FUNCTION
function present_graphic(cG,presdur,logstring_out)

drawpict(cG);
logstring(logstring_out);
wait(presdur);
clearpict(cG);


end


%% RESPONSE PRESENTATION FUNCTION
function [choseopt,RT,noresponse] = present_graphic_with_response(cG,tmax,hotkeys,logstring_out)

hkvalid = hotkeys(hotkeys~=0);

drawpict(cG);
logstring(logstring_out);
clearpict(cG);

n=2;
tin = time;
while n>1 %sometimes waitkeydown will erroneously return two numbers rather than one.
    [choseopt,tout,n] = waitkeydown(tmax,hkvalid);
end
RT = tout - tin;

if isempty(choseopt) %no response
    noresponse = 1;
    choseopt = nan;
    RT = nan;
else
    noresponse = 0;
end
end

%% MONEY BAR
function money_bar(points,pounds,cG)

cgalign('l','c');
cgpencol(1,0,0);
cgrect(-300,-350, points*2, 30);
cgpencol(1,1,1);
cgrect(305,-350,2,30);
cgrect(-300,-350,2,30);
cgalign('c','c');
money = sprintf('£%0.2f',pounds);
settextstyle('Arial',40);
preparestring(money,cG,400,-350);

end

%% POUNDS
%% MONEY BAR
function money(pounds,cG)

cgalign('c','c');
money = sprintf('£%0.2f',pounds);
settextstyle('Arial',40);
preparestring(money,cG,400,-350);

end

