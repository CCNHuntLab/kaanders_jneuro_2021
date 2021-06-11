function sched = generate_schedule(nTr, first_cue_loc, second_cue_loc, probability_order, magnitude_order, probabilities, magnitudes, stims);

i=1;
block=1;
FB=zeros(nTr,1);
FB(round(nTr/2)+1:end)=1;
FB=shuffle(FB);
while i<=nTr
    % v1 - LH 01/03/2013
    SEEDVAL=floor(rem(now*10000,1)*10000); %use clock for seed
    rand('seed',SEEDVAL); % reseed random number generator
    complete = 0;
    
    sched(i).nTurns     = 4;
    sched(i).nOpt       = 2;
    sched(i).nAttr      = 2;
    
    sched(i).feedback   = FB(i);
    
    %ensure each cue is presented at top and bottom equal amount of times
    locs=[1 2 3 4];
    locs=locs(locs~=first_cue_loc(i)&locs~=second_cue_loc(i));
    sched(i).order = [first_cue_loc(i), second_cue_loc(i), locs(1), locs(2)];
    sched(i).cost = nan(4,2,2);
    sched(i).cost(1,first_cue_loc(i)) = 0;
    sched(i).cost(2,second_cue_loc(i)) = 0;
    sched(i).cost(3,:)      = 3;
    sched(i).cost(4,:)      = 6;
    
    stim(1,1)=stims(1,1,i);
    stim(1,2)=stims(1,2,i);   
    stim(2,1)=stims(2,1,i);
    stim(2,2)=stims(2,2,i);

    sched(i).Val(1)=stim(1,1);
    sched(i).Val(2)=stim(1,2);
    sched(i).Val(3)=stim(2,1);
    sched(i).Val(4)=stim(2,2);
    
    if stim(1,1)<1
        sched(i).stim{1,1} = probability_order{find(probabilities==stim(1,1))};
        sched(i).stim{1,2} = magnitude_order{find(magnitudes==stim(2,1))};
        sched(i).stim{2,1} = probability_order{find(probabilities==stim(1,2))};
        sched(i).stim{2,2} = magnitude_order{find(magnitudes==stim(2,2))};
        sched(i).Prob(1)=stim(1,1);
        sched(i).Prob(2)=stim(1,2);
        sched(i).Magn(1)=stim(2,1);
        sched(i).Magn(2)=stim(2,2);
    else
        sched(i).stim{1,1} = magnitude_order{find(magnitudes==stim(1,1))};
        sched(i).stim{1,2} = probability_order{find(probabilities==stim(2,1))};
        sched(i).stim{2,1} = magnitude_order{find(magnitudes==stim(1,2))};
        sched(i).stim{2,2} = probability_order{find(probabilities==stim(2,2))};   
        sched(i).Prob(1)=stim(2,1);
        sched(i).Prob(2)=stim(2,2);
        sched(i).Magn(1)=stim(1,1);
        sched(i).Magn(2)=stim(1,2);
    end
    
    sched(i).uncovered  = zeros(2,2);
    sched(i).canrespond = [0; 0; 1; 1];
    sched(i).availstim  = 'images/yellowback.jpg';
    sched(i).unavailstim= 'images/greyback.jpg';
    sched(i).turnedstim = 'images/greyback.jpg';
        
    %compute winnings
    x=rand(1);
    if x<sched(i).Prob(1)
        sched(i).reward(1) = sched(i).Magn(1);%left option won
    else
        sched(i).reward(1) = 0; %left option lost
    end

    % coin-flip for right option
    x=rand(1);
    if x<sched(i).Prob(2)
        sched(i).reward(2) = sched(i).Magn(2);%right option won
    else
        sched(i).reward(2) = 0; %right option lost
    end

    %sched(i).rule       = 'win points';
    sched(i).rulecode   = 1;
    
    if rem(i,40)==0
        block=block+1;
    end
    
    i=i+1; % next trial
end

