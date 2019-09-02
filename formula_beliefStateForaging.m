function [simResults, i] = formula_beliefStateForaging(x, do_plot)

    % example:
    % [simResults, i] = formula_beliefStateForaging([120 40 8 0.5 0.3], true)
    % [simResults, i] = formula_beliefStateForaging([140 80 8 0.7 0.2], true)
    %
    % x(1) = mean rew dist
    % x(2) = std rew dist
    % x(3) = mean ITI
    % x(4) = fraction track 2 (probe and non-probe)
    % x(5) = fraction probe (of track 2)


n = 1; % total # of trials TODO remove -- it's fractions now; it's a precise answer
n_tr1 = n * (1 - x(4)); % # of track 1 trials
n_tr2_npr = n * x(4) * (1 - x(5)); % # of track 2 non-probe trials
n_tr2_pr = n * x(4) * x(5); % # of track 2 probe trials

meanITI = x(3);
mu = x(1); % mean of rew dist
sigma = x(2); % std of rew dist

min_dist = 20;
max_dist = 500;

speed = 5; % AU per second

track2maxRun = [10:10:600]; % distances to try for how far mouse is willing to run on track 2 before quiting


for iSim = 1:length(track2maxRun)
    
    stop_dist = track2maxRun(iSim); % how far to run on track 2

    frac_rew_npr = rewdist_norm_cdf(stop_dist, min_dist, mu, max_dist, sigma); % fraction of rewarded track 2 non-probe trials (i.e. that have reward before stop_dist)

    mu_tr1 = rewdist_norm_mu(min_dist, mu, max_dist, sigma); % mean reward distance for track 1
    mu_tr2_npr_rew = rewdist_norm_mu(min_dist, mu, min(max_dist, stop_dist), sigma); % mean reward distance for track 2 rewarded trials; stop distance taken into account

    mu_tr2_npr_rew


    % total reward = track 1 + track 2
    total_rew = 1 * n_tr1 + 1 * frac_rew_npr * n_tr2_npr;

    % total time = ITIs + track 1 times + ...
    total_time = n * meanITI + (mu_tr1 / speed) * n_tr1;
    total_time = total_time + (mu_tr2_npr_rew / speed) * frac_rew_npr * n_tr2_npr; %  ... +  track 2 rewarded times 
    total_time = total_time + (1 + stop_dist / speed) * ((1 - frac_rew_npr) * n_tr2_npr + n_tr2_pr); % ... + track 2 non-rewarded times, accounting for the 1-second stop time

    simResults(iSim,1) = stop_dist;
    simResults(iSim,2) = total_rew / total_time;
    simResults(iSim,3) = frac_rew_npr;
end


if do_plot
    %display(simResults)
    figure;
    plot(simResults(:,1),simResults(:,2));
end

[~,i] = max(simResults(:,2));
