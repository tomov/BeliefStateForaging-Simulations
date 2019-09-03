function [simResults, i] = analytical_optimal(x, do_plot, distr)

    % average reward (across both tracks) for each stopping distance on track 2
    % picks optimal stopping distance based on that
    % compare with simulation_optimal.m
    %
    % example:
    % [simResults, i] = analytical_optimal([120 40 8 0.5 0.3], true)
    % [simResults, i] = analytical_optimal([140 80 8 0.7 0.2], true)
    %
    % x(1) = mean rew dist
    % x(2) = std rew dist
    % x(3) = mean ITI
    % x(4) = fraction track 2 (probe and non-probe)
    % x(5) = fraction probe (of track 2)


n_tr1 = 1 - x(4); % fraction of track 1 trials
n_tr2 = x(4); % fraction of track 2 trials
frac_pr = x(5); % fraction probe
n_tr2_npr = x(4) * (1 - x(5)); % fraction of track 2 non-probe trials
n_tr2_pr = x(4) * x(5); % fraction of track 2 probe trials

meanITI = x(3);
mu = x(1); % mean of rew dist
sigma = x(2); % std of rew dist

min_dist = 20;
max_dist = 500;

gamma = 0.95; % TD discount rate

speed = 5; % AU per second

d_dist = 1; % accuracy of numerical approximation
track2maxRun = [1:d_dist:600]; % distances to try for how far mouse is willing to run on track 2 before quiting

if ~exist('distr', 'var')
    distr = 'norm'; % what kind of reward distribution to use
end
[pdf, cdf, rnd, mea] = get_distr(distr, min_dist, mu, max_dist, sigma);


for iSim = 1:length(track2maxRun)
    
    stop_dist = track2maxRun(iSim); % how far to run on track 2

    frac_rew_npr = cdf(stop_dist); % fraction of rewarded track 2 non-probe trials (i.e. that have reward before stop_dist)
    mu_tr1 = mea(max_dist); % mean reward distance for track 1
    mu_tr2_npr_rew = mea(min(max_dist, stop_dist)); % mean reward distance for track 2 rewarded trials; stop distance taken into account


    % total reward = track 1 + track 2
    total_rew = 1 * n_tr1 + 1 * frac_rew_npr * n_tr2_npr;

    % total time = ITIs + track 1 times + ...
    total_time = meanITI + (mu_tr1 / speed) * n_tr1;
    total_time = total_time + (mu_tr2_npr_rew / speed) * frac_rew_npr * n_tr2_npr; %  ... +  track 2 rewarded times 
    total_time = total_time + (1 + stop_dist / speed) * ((1 - frac_rew_npr) * n_tr2_npr + n_tr2_pr); % ... + track 2 non-rewarded times, accounting for the 1-second stop time

    d(iSim,:) = stop_dist; % (stop) distances
    avg_R(iSim,:) = total_rew / total_time; % average reward (both tracks), given that agent always stops at stop distance
    tr2(iSim,:) = frac_rew_npr; % fraction of rewarded track 2 trials, given that agent always stops at stop distance
end

f = pdf(d); % track 1 reward distance PDF = P(rew at d) = track 2 non-probe PDF
F = cdf(d); % track 1 reward distance CDF = P(rew before d) = track 2 non-probe CDF


if do_plot
    figure; 

    subplot(3,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF');
    
    subplot(3,2,2);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF');

    subplot(3,1,2);
    plot(d, avg_R);
    title('Expected reward, given policy');
    xlabel('Stop distance');
    ylabel('Expected reward');
    
    subplot(3,1,3);
    plot(d, tr2);
    title('Fraction rewarded track 2 trials');
    xlabel('Stop distance');
    ylabel('P(rewarded)');
    

end

[~,i] = max(avg_R);

simResults = [d, avg_R, tr2, f, F];
