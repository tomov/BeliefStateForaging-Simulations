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

distr = 'norm'; % what kind of reward distribution to use

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
        sigmas = [10 10 10];
        w = [3 2 1];
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

    d(iSim,:) = stop_dist; % (stop) distances
    avg_R(iSim,:) = total_rew / total_time; % average reward (both tracks), given that agent always stops at stop distance
    tr2(iSim,:) = frac_rew_npr; % fraction of rewarded track 2 trials, given that agent always stops at stop distance
end

f = pdf(d); % track 1 reward distance PDF = P(rew at d) = track 2 non-probe PDF
F = cdf(d); % track 1 reward distance CDF = P(rew before d) = track 2 non-probe CDF

% track 2 belief state = P(probe | no rew by d) 
%              = P(no rew by d | probe) P(probe) / (P(no rew by d | probe) P(probe) + P(no rew by d | non probe) P(non probe))
%              = 1 * frac_pr / (1 * frac_pr + (1 - P(rew by d | non probe)) * (1 - frac_pr))
%              = 1 * frac_pr / (1 * frac_pr + CDF(d) * (1 - frac_pr))
b = frac_pr ./ (frac_pr + (1 - F) * (1 - frac_pr));


% track 2 hazard rate = P(rew at d | no rew by d) = f(d) / (1 - F(d))
% note we scale by P(non probe)
% think of it as P(probe) of the probability mass being concentrated on a delta f'n at infinity, or somewhere outside the domain 
h = f * (1 - frac_pr) ./ (1 - F * (1 - frac_pr));

% track 2 TD value = Q(d0, RUN) = E[ r_t gamma^(t - t0) ]
%                  = integral f(d | no rew by d0) * gamma^((d - d0)/speed) * r * d_d
%
for i = 1:length(track2maxRun)
    % P(rew at d | no rew by d_i)
    % note difference from hazard; this is (almost) a proper PDF, with the exception of the frac_pr missing probability mass
    f_cond = f(i:end) * (1 - frac_pr) ./ (1 - F(i) * (1 - frac_pr));
    
    g = gamma .^ ((d(i:end) - d(i)) / speed);

    rew = 1;

    V(i) = sum(f_cond .* g .* rew .* d_dist);
end


if do_plot
    figure; 

    subplot(6,1,1);
    plot(d, avg_R);
    title('Expected reward given policy');
    xlabel('Stop distance');
    ylabel('Expected reward');
    
    subplot(6,1,2);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF');

    
    subplot(6,1,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF');

    subplot(6,1,4);
    plot(d, b);
    xlabel('distance');
    ylabel('P(probe | no rew by distance)');
    title('Belief state (track 2)');

    subplot(6,1,5);
    plot(d, h);
    xlabel('distance');
    ylabel('f(distance | no rew by distance)');
    title('Hazard rate (track 2)');

    subplot(6,1,6);
    plot(d, V);
    xlabel('distance');
    ylabel('Q(distance, RUN | no rew by distance)');
    title('Value (track 2)');

end

[~,i] = max(avg_R);

simResults = table(d, avg_R, tr2, f, F, b, h);
