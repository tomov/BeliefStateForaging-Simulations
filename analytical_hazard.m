function analytical_hazard(x, do_plot, distr, distr_params)

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

gamma = 0.95; % TD discount rate

speed = 5; % AU per second

d_dist = 10; % accuracy of numerical approximation TODO this matters a lot for the magnitude of the hazard RPEs; must investigate
track2maxRun = [1:d_dist:600]; % distances to try for how far mouse is willing to run on track 2 before quiting

if ~exist('distr', 'var')
    distr = 'norm'; % what kind of reward distribution to use
end
if ~exist('distr_params', 'var')
    distr_params = [];
end
[pdf, cdf, rnd, mea] = get_distr(distr, min_dist, mu, max_dist, sigma, distr_params);


d = 1:d_dist:600; % distances

f = pdf(d); % track 1 reward distance PDF = P(rew at d) = track 2 non-probe PDF
F = cdf(d); % track 1 reward distance CDF = P(rew before d) = track 2 non-probe CDF

% track 1 hazard rate = P(rew at d | no rew by d) = f(d) / (1 - F(d))
h_tr1 = f ./ (1 - F);

% track 2 hazard rate = P(rew at d | no rew by d) = f(d) / (1 - F(d))
% note we scale by P(non probe)
% think of it as P(probe) of the probability mass being concentrated on a delta f'n at infinity, or somewhere outside the domain 
h_tr2 = f * (1 - frac_pr) ./ (1 - F * (1 - frac_pr));


% assume reward expectation = value = hazard
% rescaled for vizualization TODO how did Sam/Clara rescale?
V_tr1 = h_tr1 / max(h_tr1);
V_tr2 = h_tr2 / max(h_tr2);


% post-reward RPEs
post_RPE_tr1 = 1 - V_tr1;
post_RPE_tr2 = 1 - V_tr2;

% pre-reward RPEs
pre_RPE_tr1 = V_tr1(2:end) * gamma^(d_dist / speed) - V_tr1(1:end-1);
pre_RPE_tr1 = [V_tr1(1) pre_RPE_tr1];
pre_RPE_tr2 = V_tr2(2:end) * gamma^(d_dist / speed) - V_tr2(1:end-1);
pre_RPE_tr2 = [V_tr2(1) pre_RPE_tr2];


if do_plot
    %{
    figure; % for debugging

    subplot(5,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');

    subplot(5,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    
    subplot(5,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');

    subplot(5,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');

    subplot(5,2,5);
    plot(d, h_tr1);
    title('Hazard rate, track 1');
    xlabel('distance');
    ylabel('h');

    subplot(5,2,6);
    plot(d, h_tr2);
    title('Hazard rate, track 2');
    xlabel('distance');
    ylabel('h');

    subplot(5,2,7);
    plot(d, post_RPE_tr1);
    title('Hazard post-reward RPE, track 1');
    xlabel('distance');
    ylabel('1 - h');
    
    subplot(5,2,8);
    plot(d, post_RPE_tr2);
    title('Hazard post-reward RPE, track 2');
    xlabel('distance');
    ylabel('1 - h');
    
    subplot(5,2,9);
    plot(d, pre_RPE_tr1);
    title('Hazard pre-reward RPE, track 1');
    xlabel('distance');
    ylabel('h''');

    subplot(5,2,10);
    plot(d, pre_RPE_tr2);
    title('Hazard pre-reward RPE, track 2');
    xlabel('distance');
    ylabel('h''');

    %}










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
    
    mtit('Hazard', 'fontsize',16,'color',[0 0 0], 'xoff',-.035,'yoff',.015);
end
