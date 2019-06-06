% simulate mouse behavior in belief state foraging task to determine optimality
% last edits MB 6-5-19, 7pm

%% task variables we can vary:
meanITI = 8; % mean seconds for inter-trial interval (does not account for mouse taking longer than that to trigger new trial by stopping)
rewDistribution = [20 120 400 40]; % [min mean max std] - distribution for reward locations

% set of trials types: 1 = track 1, 2 = track 2 non-probes, 3 = track2 probe (no reward)
trialSet = [1 1 1 1 1 ...
    1 1 1 1 1 ...
    2 2 2 2 2 ...
    2 2 3 3 3];

%% distances to test:
track2maxRun = [10:10:300]; % distances to try for how far mouse is willing to run on track 2 before quiting

%% 'measured' mouse variables (also relevant is time it takes them to stop and initiate new trial, though this would just be factored into ITI for scope of this simulation)
speed = 5; % AU per second

%
stopTime = 1; % time mouse must be stopped to quit a trial

rewTotal = 0; % track rews earned throughout simulation
timeTotal = 0; % keep track of 'time elapsed' in simulated sessions
rewLocation = 0; % value drawn from probabilistic distribution on each trial - location of reward on a given trial
numSims = length(track2maxRun);
simResults = zeros(length(track2maxRun),2);

numTrials = 100000;

for iSim = 1:numSims
    
    rewTotal = 0; % reset at beginning of each simulation
    timeTotal = 0;
    trialIndx = 1;
    
    for iTrial = 1:numTrials
        
        track = trialSet(trialIndx);
        
        % draw reward location from pseudo-normal distribution        
        if track==1 || track==2
            rewLocation = rewDistribution(2) + rewDistribution(4) * randn(1);
            % loop until rewLocation is within the min/max of rewDistribution
            while rewLocation < rewDistribution(1) || rewLocation > rewDistribution(3)
                rewLocation = rewDistribution(2) + rewDistribution(4) * randn(1);
            end
        end
        
        % determine trial result and track changes in rewards and time
        switch track
            case 1
                rewTotal = rewTotal + 1;
                timeTotal = timeTotal + rewLocation/speed;
            case 2
                if rewLocation > track2maxRun(iSim)
                    timeTotal = timeTotal + track2maxRun(iSim)/speed + stopTime;
                    
                else
                    rewTotal = rewTotal + 1;
                    timeTotal = timeTotal + rewLocation/speed;
                end
            case 3
                timeTotal = timeTotal + track2maxRun(iSim)/speed + stopTime;
                
        end
        
        trialIndx = trialIndx + 1;
        if trialIndx > length(trialSet)
            trialIndx = 1;
        end
        
        timeTotal = timeTotal + meanITI;
        
    end
    
    simResults(iSim,:) = [track2maxRun(iSim) rewTotal/timeTotal];
    
end

display(simResults)
figure;
plot(simResults(:,1),simResults(:,2))

try
dist_maxRew = [simResults(find(simResults(:,2)==max(simResults(:,2)))-1,1) simResults(find(simResults(:,2)==max(simResults(:,2)))-1,2); ...
    simResults(find(simResults(:,2)==max(simResults(:,2))),1) simResults(find(simResults(:,2)==max(simResults(:,2))),2); ...
    simResults(find(simResults(:,2)==max(simResults(:,2)))+1,1) simResults(find(simResults(:,2)==max(simResults(:,2)))+1,2)];
catch
    dist_maxRew = [simResults(find(simResults(:,2)==max(simResults(:,2))),1) simResults(find(simResults(:,2)==max(simResults(:,2))),2)];
end
display(dist_maxRew)

% have it spit out what % trials would be lower distance