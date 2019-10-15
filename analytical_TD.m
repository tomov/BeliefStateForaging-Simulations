function [V_tr1, V_tr2, pre_RPE_tr1, pre_RPE_tr2, post_RPE_tr1, post_RPE_tr2] = analytical_TD(x, do_plot, distr, distr_params, d_dist, frac_pr_tr1, gamma, speed)


    % plot stuff for TD model
    %
    % x(1) = mean rew dist
    % x(2) = std rew dist
    % x(3) = mean ITI
    % x(4) = fraction track 2 (probe and non-probe)
    % x(5) = fraction probe (of track 2)
    % x(6) = (optional) min rew dist
    % x(7) = (optional) max rew dist

% TODO dedupe w/ analytical_optimal


n_tr1 = 1 - x(4); % fraction of track 1 trials
n_tr2 = x(4); % fraction of track 2 trials
frac_pr = x(5); % fraction probe
n_tr2_npr = x(4) * (1 - x(5)); % fraction of track 2 non-probe trials
n_tr2_pr = x(4) * x(5); % fraction of track 2 probe trials

meanITI = x(3);
mu = x(1); % mean of rew dist
sigma = x(2); % std of rew dist

if length(x) <= 5
    min_dist = 20;
    max_dist = 500;
else
    min_dist = x(6);
    max_dist = x(7);
end

if ~is_arg('gamma')
    gamma = 0.95; % TD discount rate
end
if ~is_arg('speed')
    speed = 5; % AU per second
end

if ~exist('distr', 'var')
    distr = 'norm'; % what kind of reward distribution to use
end
if ~exist('distr_params', 'var')
    distr_params = [];
end
if ~exist('d_dist', 'var')
    d_dist = 10; % accuracy of numerical approximation TODO this matters a lot for the magnitude of the hazard RPEs; must investigate
end
if ~exist('frac_pr_tr1', 'var')
    frac_pr_tr1 = 0.01; % assume almost 100%
end
[pdf, cdf, rnd, mea] = get_distr(distr, min_dist, mu, max_dist, sigma, distr_params);


d = 1:d_dist:max(1000, max_dist); % distances

f = pdf(d); % track 1 reward distance PDF = P(rew at d) = track 2 non-probe PDF
F = cdf(d); % track 1 reward distance CDF = P(rew before d) = track 2 non-probe CDF


% track 1 TD value = Q(d0, RUN) = E[ r_t gamma^(t - t0) ]
%                  = integral f(d | no rew by d0) * gamma^((d - d0)/speed) * r * d_d
%
for i = 1:length(d)
    % P(rew at d | no rew by d_i)
    % note difference from hazard
    %f_cond = f(i:end) ./ (1 - F(i));
    f_cond = f(i:end) * (1 - frac_pr_tr1) ./ (1 - F(i));

    g = gamma .^ ((d(i:end) - d(i)) / speed);
    rew = 1;
    V_tr1(i) = sum(f_cond .* g .* rew .* d_dist);
end
V_tr1(V_tr1 > 1) = nanmax(V_tr1); % TODO hack b/c of numerical approximation, values towards the tail get distorted
V_tr1(isnan(V_tr1)) = nanmax(V_tr1); % TODO hack for tail of distr


% track 2 TD value
% same idea as track 1 except accounting for frac_pr
%
for i = 1:length(d)
    % P(rew at d | no rew by d_i)
    % note difference from hazard; this is (almost) a proper PDF, with the exception of the frac_pr missing probability mass
    f_cond = f(i:end) * (1 - frac_pr) ./ (1 - F(i));
    % note: to make model-based and consistent w/ belief state, just do:
    %f_cond = f(i:end) * (1 - frac_pr) ./ (1 - F(i) * (1 - frac_pr));
    % TODO look into it
    
    g = gamma .^ ((d(i:end) - d(i)) / speed);
    rew = 1;
    V_tr2(i) = sum(f_cond .* g .* rew .* d_dist);
end
V_tr2(V_tr2 > 1) = nanmax(V_tr2); % TODO hack b/c of numerical approximation, values towards the tail get distorted
V_tr2(isnan(V_tr2)) = nanmax(V_tr2); % TODO hack for tail of distr


% TODO dedupe w/ analytical_hazard


% post-reward RPEs
post_RPE_tr1 = 1 - V_tr1;
post_RPE_tr2 = 1 - V_tr2;

% pre-reward RPEs
pre_RPE_tr1 = V_tr1(2:end) * gamma^(d_dist / speed) - V_tr1(1:end-1);
pre_RPE_tr1 = [V_tr1(1) pre_RPE_tr1];
pre_RPE_tr2 = V_tr2(2:end) * gamma^(d_dist / speed) - V_tr2(1:end-1);
pre_RPE_tr2 = [V_tr2(1) pre_RPE_tr2];



if do_plot
    figure; % for debugging

    subplot(5,2,1);
    plot(d, f, 'linewidth', 2);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');
    ylim([0 0.05]);
    xlim([1 100]);

    subplot(5,2,2);
    plot(d, f * (1 - frac_pr), 'linewidth', 2);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    ylim([0 0.05]);
    xlim([1 100]);
    
    subplot(5,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');
    xlim([1 100]);

    subplot(5,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');
    xlim([1 100]);

    subplot(5,2,5);
    plot(d, V_tr1);
    title('Value, track 1');
    xlabel('distance');
    ylabel('h');
    xlim([1 100]);

    subplot(5,2,6);
    plot(d, V_tr2);
    title('Value, track 2');
    xlabel('distance');
    ylabel('h');
    xlim([1 100]);

    subplot(5,2,7);
    plot(d, post_RPE_tr1);
    title('Post-reward RPE, track 1');
    xlabel('distance');
    ylabel('1 - h');
    xlim([1 100]);
    
    subplot(5,2,8);
    plot(d, post_RPE_tr2);
    title('Post-reward RPE, track 2');
    xlabel('distance');
    ylabel('1 - h');
    xlim([1 100]);
    
    subplot(5,2,9);
    plot(d, pre_RPE_tr1);
    title('Pre-reward RPE, track 1');
    xlabel('distance');
    ylabel('h''');
    xlim([1 100]);

    subplot(5,2,10);
    plot(d, pre_RPE_tr2);
    title('Pre-reward RPE, track 2');
    xlabel('distance');
    ylabel('h''');
    xlim([1 100]);










    figure('pos', [1067         346         560         291]); % for Nao

    subplot(4,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');
    xlim([1 400]);
    ylim([0 max(f)*1.2]);

    subplot(4,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    xlim([1 400]);
    ylim([0 max(f)*1.2]);
    
    subplot(4,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');
    xlim([1 400]);
    ylim([0 1]);

    subplot(4,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');
    xlim([1 400]);
    ylim([0 1]);

    subplot(2,2,5-4);
    plot(d, V_tr1);
    title('Value, track 1');
    xlabel('distance');
    ylabel('Q');
    xlim([1 400]);
    ylim([0 1]);

    subplot(2,2,6-4);
    plot(d, V_tr2);
    title('Value, track 2');
    xlabel('distance');
    ylabel('Q');
    xlim([1 400]);
    ylim([0 1]);

    %{
    subplot(2,2,7-4);
    title('RPE, track 1');
    hold on;
    plot(d, pre_RPE_tr1, 'color', [0 0 0]);
    assert(d_dist == 10, 'sorry it''s hardcoded; below too');
    for i = 5:2:30
        plot([d(i-1) d(i) d(i+1)], [pre_RPE_tr1(i-1) post_RPE_tr1(i) pre_RPE_tr1(i+1)], 'color', [1-(i-1)/29 (i-1)/29 1]);
    end
    xlabel('distance');
    ylabel('RPE');
    xlim([1 400]);
    ylim([-0.2 1]);

    subplot(2,2,8-4);
    title('RPE, track 2');
    hold on;
    plot(d, pre_RPE_tr2, 'color', [0 0 0]);
    for i = 5:2:30
        plot([d(i-1) d(i) d(i+1)], [pre_RPE_tr2(i-1) post_RPE_tr2(i) pre_RPE_tr2(i+1)], 'color', [1-(i-1)/29 (i-1)/29 1]);
    end
    xlabel('distance');
    ylabel('RPE');
    xlim([1 400]);
    ylim([-0.2 1]);
    %}

    mtit('TD', 'fontsize',16,'color',[0 0 0], 'xoff',-.02,'yoff',.015);








    figure('pos', [108 420 560 420]);

    cmap = [0.5 0.5 1; ...
            1 0.5 0; ...
            0.5 1 0];

    subplot(2,2,1);
    colormap(cmap);
    hold on;
    plot(d, V_tr1, 'color', cmap(1,:), 'linewidth', 2);
    plot(d, V_tr2, 'color', cmap(2,:), 'linewidth', 2);
    title('Value');
    xlabel('distance');
    ylabel('Q(stay)');
    legend({'track 1', 'track 2'});
    xlim([1 max_dist * 1.2]);
    %ylim([-0.1 1]);


    subplot(2,2,3);
    colormap(cmap);
    hold on;
    plot(d, pre_RPE_tr1, 'color', cmap(1,:), 'linewidth', 2);
    plot(d, pre_RPE_tr2, 'color', cmap(2,:), 'linewidth', 2);
    title('pre-reward RPE');
    xlabel('distance');
    ylabel('RPE');
    legend({'track 1', 'track 2'});
    xlim([2 max_dist * 1.2]);
    %ylim([-0.1 1]);

    subplot(2,2,4);
    colormap(cmap);
    hold on;
    plot(d, post_RPE_tr1, 'color', cmap(1,:), 'linewidth', 2);
    plot(d, post_RPE_tr2, 'color', cmap(2,:), 'linewidth', 2);
    title('post-reward RPE');
    xlabel('distance');
    ylabel('RPE');
    legend({'track 1', 'track 2'});
    xlim([2 max_dist * 1.2]);
    %ylim([-0.1 1]);
    
    mtit('CSC-TD', 'fontsize',16,'color',[0 0 0], 'xoff',-.02,'yoff',.015);
end
