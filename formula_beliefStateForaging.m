function [simResults, i] = formula_beliefStateForaging(x)

    % [simResults, i] = formula_beliefStateForaging([120 40 8 0.5 0.3])
    %
    % x(1) = mean rew dist
    % x(2) = std rew dist
    % x(3) = mean ITI
    % x(4) = fraction track 2 (probe and non-probe)
    % x(5) = fraction probe (of track 2)


n = 100000; % total # of trials
n_tr1 = round(n * (1 - x(4))); % # of track 1 trials
n_tr2_npr = round(n * x(4) * (1 - x(5))); % # of track 2 non-probe trials
n_tr2_pr = round(n * x(4) * x(5)); % # of track 2 probe trials

meanITI = x(3);
mu = x(1); % mean of rew dist
sigma = x(2); % std of rew dist

speed = 5; % AU per second

track2maxRun = [10:10:300]; % distances to try for how far mouse is willing to run on track 2 before quiting


for iSim = 1:length(track2maxRun)
    
    stop_dist = track2maxRun(iSim); % how far to run on track 2

    frac_rew_npr = normcdf(stop_dist, mu, sigma); % fraction of rewarded track 2 non-probe trials (i.e. that have reward before stop_dist)

    % mean of truncated gaussian -- see Moments: one-sided truncation (upper tail) https://en.wikipedia.org/wiki/Truncated_normal_distribution 
    beta = (stop_dist - mu) / sigma;
    mu_stop_dist = mu - sigma * normpdf(beta) / normcdf(beta);

    % total reward = track 1 + track 2
    total_rew = 1 * n_tr1 + 1 * frac_rew_npr * n_tr2_npr;

    % total time = ITIs + track 1 times + ...
    total_time = n * meanITI + (mu / speed) * n_tr1;
    total_time = total_time + (mu_stop_dist/ speed) * frac_rew_npr * n_tr2_npr; %  ... +  track 2 rewarded times 
    total_time = total_time + stop_dist / speed * ((1 - frac_rew_npr) * n_tr2_npr + n_tr2_pr); % ... + track 2 non-rewarded times

    simResults(iSim,1) = iSim;
    simResults(iSim,2) = total_rew / total_time;
    simResults(iSim,3) = frac_rew_npr;
end

display(simResults)
figure;
plot(simResults(:,1),simResults(:,2))

[~,i] = max(simResults(:,2));
