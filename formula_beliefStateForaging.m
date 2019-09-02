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


n_tr1 = 1 - x(4); % fraction of track 1 trials
n_tr2_npr = x(4) * (1 - x(5)); % fraction of track 2 non-probe trials
n_tr2_pr = x(4) * x(5); % fraction of track 2 probe trials

meanITI = x(3);
mu = x(1); % mean of rew dist
sigma = x(2); % std of rew dist

min_dist = 20;
max_dist = 500;

speed = 5; % AU per second

track2maxRun = [10:10:600]; % distances to try for how far mouse is willing to run on track 2 before quiting

distr = 'mixnorm'; % what kind of reward distribution to use

switch distr
    case 'norm'
        pdf = @(d) rewdist_norm_pdf(d, min_dist, mu, max_dist, sigma);
        cdf = @(d) rewdist_norm_cdf(d, min_dist, mu, max_dist, sigma);
        rnd = @() rewdist_norm_rnd(min_dist, mu, max_dist, sigma);
        mea = @(maxd) rewdist_norm_mu(min_dist, mu, maxd, sigma);

    case 'unif'
        pdf = @(d) rewdist_unif_pdf(d, min_dist, max_dist);
        cdf = @(d) rewdist_unif_cdf(d, min_dist, max_dist);
        rnd = @() rewdist_unif_rnd(min_dist, max_dist);
        mea = @(maxd) rewdist_unif_mu(min_dist, maxd);

    case 'mixnorm'
        mus = [50 140 250];
        sigmas = [20 20 20];
        w = [1 2 3];
        pdf = @(d) rewdist_mixnorm_pdf(d, min_dist, mus, max_dist, sigmas, w);
        cdf = @(d) rewdist_mixnorm_cdf(d, min_dist, mus, max_dist, sigmas, w);
        rnd = @() rewdist_mixnorm_rnd(min_dist, mus, max_dist, sigmas, w);
        mea = @(maxd) rewdist_mixnorm_mu(min_dist, mus, maxd, sigmas, w);

    otherwise
        assert(false);
end



for iSim = 1:length(track2maxRun)
    
    stop_dist = track2maxRun(iSim); % how far to run on track 2

    %frac_rew_npr = rewdist_norm_cdf(stop_dist, min_dist, mu, max_dist, sigma); % fraction of rewarded track 2 non-probe trials (i.e. that have reward before stop_dist)

    %mu_tr1 = rewdist_norm_mu(min_dist, mu, max_dist, sigma); % mean reward distance for track 1
    %mu_tr2_npr_rew = rewdist_norm_mu(min_dist, mu, min(max_dist, stop_dist), sigma); % mean reward distance for track 2 rewarded trials; stop distance taken into account

    %frac_rew_npr = rewdist_unif_cdf(stop_dist, min_dist, max_dist); % fraction of rewarded track 2 non-probe trials (i.e. that have reward before stop_dist)
    %mu_tr1 = rewdist_unif_mu(min_dist, max_dist); % mean reward distance for track 1
    %mu_tr2_npr_rew = rewdist_unif_mu(min_dist, min(max_dist, stop_dist)); % mean reward distance for track 2 rewarded trials; stop distance taken into account

    frac_rew_npr = cdf(stop_dist); % fraction of rewarded track 2 non-probe trials (i.e. that have reward before stop_dist)
    mu_tr1 = mea(max_dist); % mean reward distance for track 1
    mu_tr2_npr_rew = mea(min(max_dist, stop_dist)); % mean reward distance for track 2 rewarded trials; stop distance taken into account


    % total reward = track 1 + track 2
    total_rew = 1 * n_tr1 + 1 * frac_rew_npr * n_tr2_npr;

    % total time = ITIs + track 1 times + ...
    total_time = meanITI + (mu_tr1 / speed) * n_tr1;
    total_time = total_time + (mu_tr2_npr_rew / speed) * frac_rew_npr * n_tr2_npr; %  ... +  track 2 rewarded times 
    total_time = total_time + (1 + stop_dist / speed) * ((1 - frac_rew_npr) * n_tr2_npr + n_tr2_pr); % ... + track 2 non-rewarded times, accounting for the 1-second stop time

    simResults(iSim,1) = stop_dist;
    simResults(iSim,2) = total_rew / total_time;
    simResults(iSim,3) = frac_rew_npr;
end

simResults(:,4) = pdf(simResults(:,1));


if do_plot
    %display(simResults)
    figure; 

    subplot(2,1,1);
    plot(simResults(:,1),simResults(:,2));
    title('Expected reward given policy');
    xlabel('Stop distance');
    ylabel('Expected reward');
    
    subplot(2,1,2);
    plot(simResults(:,1),simResults(:,4));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF');

end

[~,i] = max(simResults(:,2));
