function [first_cue, first_cue_loc, second_cue_loc, stims, second_cue]=...
    make_blocks(probabilities,magnitudes)

SEEDVAL=floor(rem(now*10000,1)*10000); %use clock for seed

% v1 - LH 01/03/2013
rand('seed',SEEDVAL); % reseed random number generator
complete = 0;

%each cue occurs 16 times per block and is the first card to be revealed 
x=1;
cues=[0.1,0.3,0.5,0.7,0.9,10,30,50,70,90]; %first cue
cues_loc=[1,1,1,1,1,1,1,1,1,1]; %location of first cue
while x<4
    cues=[cues,0.1,0.3,0.5,0.7,0.9,10,30,50,70,90];
    x=x+1;
    cues_loc=[cues_loc,x,x,x,x,x,x,x,x,x,x];
end
timings = repmat(1:5,1,8); %bins from 1 to 5 for timing
timings = timings(randperm(40));
secondcuetimings = timings(randperm(40));

secondprobvec = repmat([0.1 0.3 0.5 0.7 0.9],1,2);
secondmagsvec = repmat([10 30 50 70 90],1,2);

x=1;
while x<=5
    new_cues(:,1)=cues;
    new_cues(:,2)=cues_loc;
    if mod(x,2)
        new_cues(:,3)=[repmat([0 1],1,10) repmat([1 0],1,10)];
    else
        new_cues(:,3)=[repmat([1 0],1,10) repmat([0 1],1,10)];
    end
    new_cues(:,4) = mod(timings+x,5)+1;
    
    %now counterbalance the second cue so that we have equal numbers of these also:
    new_cues(new_cues(:,1)<1&new_cues(:,3)==0,5) = secondprobvec(randperm(10)); %attribute trials, probability
    new_cues(new_cues(:,1)>1&new_cues(:,3)==0,5) = secondmagsvec(randperm(10)); %attribute trials, magnitudes
    new_cues(new_cues(:,1)<1&new_cues(:,3)==1,5) = secondmagsvec(randperm(10)); %attribute trials, probability
    new_cues(new_cues(:,1)>1&new_cues(:,3)==1,5) = secondprobvec(randperm(10)); %attribute trials, magnitudes
    
    new_cues(:,6) = mod(secondcuetimings+x,5)+1; %timing of second cue
    
    new_cues=new_cues(randperm(40),:);
    first_cue(x,:,1)=new_cues(:,1); %this gives me the first cue to be revealed
    first_cue(x,:,2)=new_cues(:,2); %this gives me the location of the first cue
    first_cue(x,:,3)=new_cues(:,3); %attribute (0) or option (1) trial
    first_cue(x,:,4)=new_cues(:,4); %which bin for stimulus duration? (1 = short timing, 5 = long timing)
    
    second_cue(x,:,1)=new_cues(:,5); %this gives me the second cue to be revealed
    second_cue(x,:,2)=new_cues(:,6); %which bin for stimulus duration? (1 = short timing, 5 = long timing)
    x=x+1;
end

for x=1:5
    for y=1:40
        first_cue_loc(((x-1)*40) + y)=first_cue(x,y,2);
        if first_cue(x,y,2)==1
            stim(1,1)=first_cue(x,y,1);
            if first_cue(x,y,1)<1
                if first_cue(x,y,3)==1 % option trial
                    stim(2,1)=second_cue(x,y,1);
                    stim(1,2)=randsample(probabilities,1);
                    stim(2,2)=randsample(magnitudes,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,2)=randsample(probabilities,1);
                        %stim(2,1)=randsample(magnitudes,1);
                        stim(2,2)=randsample(magnitudes,1);
                    end
                else %attribute trial
                    stim(1,2)=second_cue(x,y,1);
                    stim(2,1)=randsample(magnitudes,1);
                    stim(2,2)=randsample(magnitudes,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        %stim(1,2)=randsample(probabilities,1);
                        stim(2,1)=randsample(magnitudes,1);
                        stim(2,2)=randsample(magnitudes,1);
                    end
                end
            else
                if first_cue(x,y,3)==1 %option trial
                    stim(2,1)=second_cue(x,y,1);
                    stim(1,2)=randsample(magnitudes,1);
                    stim(2,2)=randsample(probabilities,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2) %removes trials where all 4 are the same
                        stim(1,2)=randsample(magnitudes,1);
                        %stim(2,1)=randsample(probabilities,1);
                        stim(2,2)=randsample(probabilities,1);
                    end
                else %attribute trial
                    stim(1,2)=second_cue(x,y,1);
                    stim(2,1)=randsample(probabilities,1);
                    stim(2,2)=randsample(probabilities,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2) %removes trials where all 4 are the same
                        %stim(1,2)=randsample(magnitudes,1);
                        stim(2,1)=randsample(probabilities,1);
                        stim(2,2)=randsample(probabilities,1);
                    end
                end
            end
            
            if first_cue(x,y,3)==0
                second_cue_loc(((x-1)*40) + y)=2;
            else
                second_cue_loc(((x-1)*40) + y)=3;
            end
            
        elseif first_cue(x,y,2)==2
            stim(1,2)=first_cue(x,y,1);
            if first_cue(x,y,1)<1
                if first_cue(x,y,3) == 1 %option trial
                    stim(1,1)=randsample(probabilities,1);
                    stim(2,1)=randsample(magnitudes,1);
                    stim(2,2)=second_cue(x,y,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(probabilities,1);
                        stim(2,1)=randsample(magnitudes,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                else
                    stim(1,1)=second_cue(x,y,1);
                    stim(2,1)=randsample(magnitudes,1);
                    stim(2,2)=randsample(magnitudes,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        %stim(1,1)=randsample(probabilities,1);
                        stim(2,1)=randsample(magnitudes,1);
                        stim(2,2)=randsample(magnitudes,1);
                    end
                end
            else
                if first_cue(x,y,3) == 1 %option trial
                    stim(1,1)=randsample(magnitudes,1);
                    stim(2,1)=randsample(probabilities,1);
                    stim(2,2)=second_cue(x,y,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(magnitudes,1);
                        stim(2,1)=randsample(probabilities,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                else
                    stim(1,1)=second_cue(x,y,1);
                    stim(2,1)=randsample(probabilities,1);
                    stim(2,2)=randsample(probabilities,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        %stim(1,1)=randsample(probabilities,1);
                        stim(2,1)=randsample(probabilities,1);
                        stim(2,2)=randsample(probabilities,1);
                    end
                end
            end
            
            if first_cue(x,y,3)==0
                second_cue_loc(((x-1)*40) + y)=1;
            else
                second_cue_loc(((x-1)*40) + y)=4;
            end
            
        elseif first_cue(x,y,2)==3
            stim(2,1)=first_cue(x,y,1);
            if first_cue(x,y,1)<1
                
                if first_cue(x,y,3) == 1 %option trial
                    stim(1,1)=second_cue(x,y,1);
                    stim(1,2)=randsample(magnitudes,1);
                    stim(2,2)=randsample(probabilities,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        %stim(1,1)=randsample(probabilities,1);
                        stim(1,2)=randsample(magnitudes,1);
                        stim(2,2)=randsample(probabilities,1);
                    end
                else
                    stim(1,1)=randsample(magnitudes,1);
                    stim(1,2)=randsample(magnitudes,1);
                    stim(2,2)=second_cue(x,y,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(magnitudes,1);
                        stim(1,2)=randsample(magnitudes,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                end
                
            else
                if first_cue(x,y,3) == 1 %option trial
                    stim(1,1)=second_cue(x,y,1);
                    stim(1,2)=randsample(probabilities,1);
                    stim(2,2)=randsample(magnitudes,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        %stim(1,1)=randsample(probabilities,1);
                        stim(1,2)=randsample(probabilities,1);
                        stim(2,2)=randsample(magnitudes,1);
                    end
                else
                    stim(1,1)=randsample(probabilities,1);
                    stim(1,2)=randsample(probabilities,1);
                    stim(2,2)=second_cue(x,y,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(probabilities,1);
                        stim(1,2)=randsample(probabilities,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                end
            end
            
            if first_cue(x,y,3)==0
                second_cue_loc(((x-1)*40) + y)=4;
            else
                second_cue_loc(((x-1)*40) + y)=1;
            end
        else
            stim(2,2)=first_cue(x,y,1);
            
            if first_cue(x,y,1)<1
                if first_cue(x,y,3) == 1 %option trial
                    stim(1,1)=randsample(magnitudes,1);
                    stim(1,2)=second_cue(x,y,1);
                    stim(2,1)=randsample(probabilities,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(magnitudes,1);
                        stim(2,1)=randsample(probabilities,1);
                        %stim(2,2)=randsample(probabilities,1);
                    end
                else
                    stim(1,1)=randsample(magnitudes,1);
                    stim(1,2)=randsample(magnitudes,1);
                    stim(2,1)=second_cue(x,y,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(magnitudes,1);
                        stim(1,2)=randsample(magnitudes,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                end
            else
                if first_cue(x,y,3) == 1 %option trial
                    stim(1,1)=randsample(probabilities,1);;
                    stim(1,2)=second_cue(x,y,1);
                    stim(2,1)=randsample(magnitudes,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(probabilities,1);
                        stim(2,1)=randsample(magnitudes,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                else
                    stim(1,1)=randsample(probabilities,1);
                    stim(1,2)=randsample(probabilities,1);
                    stim(2,1)=second_cue(x,y,1);
                    while stim(1,1)==stim(1,2) & stim(2,1)==stim(2,2)
                        stim(1,1)=randsample(probabilities,1);
                        stim(1,2)=randsample(probabilities,1);
                        %stim(2,2)=randsample(magnitudes,1);
                    end
                end
            end
            
            if first_cue(x,y,3)==0
                second_cue_loc(((x-1)*40) + y)=3;
            else
                second_cue_loc(((x-1)*40) + y)=2;
            end
        end
        stims(:,:,((x-1)*40) + y)=stim;
    end
end



    

        

        
                
               	
         
                
