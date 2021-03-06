function [h_tr1, h_tr2, V_tr1, V_tr2, pre_RPE_tr1, pre_RPE_tr2, post_RPE_tr1, post_RPE_tr2] = analytical_hazard(x, do_plot, distr, distr_params, d_dist, frac_pr_tr1, gamma, speed)


    % plot stuff for hazard rate model
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

if ~exist('gamma', 'var')
    gamma = 0.95; % TD discount rate
end
if ~exist('speed', 'var')
    speed = 5; % AU per second
end

track2maxRun = [1:d_dist:600]; % distances to try for how far mouse is willing to run on track 2 before quiting

if ~exist('distr', 'var')
    distr = 'norm'; % what kind of reward distribution to use
end
if ~exist('distr_params', 'var')
    distr_params = [];
end
if ~exist('frac_pr_tr1', 'var')
    frac_pr_tr1 = 0.01; % assume almost 100%
end
if ~exist('d_dist', 'var')
    d_dist = 10; % accuracy of numerical approximation TODO this matters a lot for the magnitude of the hazard RPEs; must investigate
end
[pdf, cdf, rnd, mea] = get_distr(distr, min_dist, mu, max_dist, sigma, distr_params);


d = 1:d_dist:max(1000, max_dist); % distances

f = pdf(d); % track 1 reward distance PDF = P(rew at d) = track 2 non-probe PDF
F = cdf(d); % track 1 reward distance CDF = P(rew before d) = track 2 non-probe CDF

% track 1 hazard rate = P(rew at d | no rew by d) = f(d) / (1 - F(d))
%h_tr1 = f ./ (1 - F);
h_tr1 = f * (1 - frac_pr_tr1) ./ (1 - F * (1 - frac_pr_tr1));

% track 2 hazard rate = P(rew at d | no rew by d) = f(d) / (1 - F(d))
% note we scale by P(non probe)
% think of it as P(probe) of the probability mass being concentrated on a delta f'n at infinity, or somewhere outside the domain 
h_tr2 = f * (1 - frac_pr) ./ (1 - F * (1 - frac_pr));

% plot for different fractions of probe trials
fpr = [0.01 5 10 20 40] / 100;
for i = 1:length(fpr)
    leg{i} = sprintf('%.2f%% omissions', fpr(i));
    h_tr2_more(i,:) = f * (1 - fpr(i)) ./ (1 - F * (1 - fpr(i)));
end


% assume reward expectation = value = hazard
% rescaled for vizualization TODO how did Sam/Clara rescale?
V_tr1 = h_tr1 / max([h_tr1 h_tr2]);
V_tr2 = h_tr2 / max([h_tr1 h_tr2]);
V_tr2_more = h_tr2_more / max(h_tr2_more(:));


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
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');
    xlim([1 100]);

    subplot(5,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
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
    plot(d, h_tr1);
    title('Hazard rate, track 1');
    xlabel('distance');
    ylabel('h');
    xlim([1 100]);

    subplot(5,2,6);
    plot(d, h_tr2);
    title('Hazard rate, track 2');
    xlabel('distance');
    ylabel('h');
    xlim([1 100]);

    subplot(5,2,7);
    plot(d, post_RPE_tr1);
    title('Hazard post-reward RPE, track 1');
    xlabel('distance');
    ylabel('1 - h');
    xlim([1 100]);
    
    subplot(5,2,8);
    plot(d, post_RPE_tr2);
    title('Hazard post-reward RPE, track 2');
    xlabel('distance');
    ylabel('1 - h');
    xlim([1 100]);
    
    subplot(5,2,9);
    subplot(5,2,9);
    plot(d, pre_RPE_tr1);
    title('Hazard pre-reward RPE, track 1');
    xlabel('distance');
    ylabel('h''');
    xlim([1 100]);

    subplot(5,2,10);
    plot(d, pre_RPE_tr2);
    title('Hazard pre-reward RPE, track 2');
    xlabel('distance');
    ylabel('h''');
    xlim([1 100]);











    figure('pos', [1628         349         560         288]); % for Nao

    %{
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
    %}

    subplot(2,2,5-4);
    plot(d, V_tr1);
    title('Hazard rate/value, track 1');
    xlabel('distance');
    ylabel('Q = h, rescaled');
    xlim([1 400]);
    ylim([0 1]);

    subplot(2,2,6-4);
    plot(d, V_tr2);
    title('Hazard rate/value, track 2');
    xlabel('distance');
    ylabel('Q = h, rescaled');
    xlim([1 400]);
    ylim([0 1]);

    %{
    subplot(2,2,7-4);
    title('Hazard RPE, track 1');
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
    title('Hazard RPE, track 2');
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
    
    mtit('Hazard', 'fontsize',16,'color',[0 0 0], 'xoff',-.035,'yoff',.015);











    figure('pos', [1000 1082 789 256]);

    subplot(1,2,1);
    cmap = [0.5 0.5 1; ...
            1 0.5 0; ...
            0.5 1 0];
    colormap(cmap);
    hold on;
    plot(d, 1 - V_tr2_more(1,:), 'color', cmap(1,:));
    plot(d, 1 - V_tr2_more(3,:), 'color', cmap(2,:));
    title('Hazard rate');
    xlabel('distance');
    ylabel('h');
    legend({'track 1', 'track 2'});
    xlim([1 400]);
    ylim([-0.1 1]);


    subplot(1,2,2);
    plot(d, V_tr2_more);
    title('Hazard rate');
    xlabel('distance');
    ylabel('h');
    legend(leg);
    xlim([1 400]);
    ylim([-0.1 1]);






    figure('pos', [772 419 560 420]);

    cmap = [0.5 0.5 1; ...
            1 0.5 0; ...
            0.5 1 0];

    subplot(2,2,1);
    colormap(cmap);
    hold on;
    plot(d, h_tr1, 'color', cmap(1,:), 'linewidth', 2);
    plot(d, h_tr2, 'color', cmap(2,:), 'linewidth', 2);
    title('Hazard');
    xlabel('distance');
    ylabel('f(reward|distance)');
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
    
    mtit('Hazard', 'fontsize',16,'color',[0 0 0], 'xoff',-.02,'yoff',.015);
end
