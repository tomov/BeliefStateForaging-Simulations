function [b_tr1, b_tr2, V_tr1, V_tr2, pre_RPE_tr1, pre_RPE_tr2, post_RPE_tr1, post_RPE_tr2] = analytical_beliefTD(x, do_plot, distr, distr_params, d_dist, frac_pr_tr1)

    % plot stuff for belief-TD model
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

% TODO dedupe w/ analytical_TD

% track 1/2 non-probe TD value = Q(d0, RUN) = E[ r_t gamma^(t - t0) ]
%                              = integral f(d | no rew by d0) * gamma^((d - d0)/speed) * r * d_d
%
for i = 1:length(d)
    % P(rew at d | no rew by d_i)
    % note difference from hazard
    f_cond = f(i:end) ./ (1 - F(i));
    
    g = gamma .^ ((d(i:end) - d(i)) / speed);
    rew = 1;
    V(i) = sum(f_cond .* g .* rew .* d_dist);
end
V(V > 1) = 1; % TODO hack b/c of numerical approximation, values towards the tail get distorted
V(isnan(V)) = 1; % TODO hack for tail of distr


% track 1 belief state = P(probe | no rew by d) = 0
%b_tr1 = zeros(size(F));
b_tr1 = frac_pr_tr1 ./ (frac_pr + (1 - F) * (1 - frac_pr_tr1));

% track 2 belief state = P(probe | no rew by d) 
%              = P(no rew by d | probe) P(probe) / (P(no rew by d | probe) P(probe) + P(no rew by d | non probe) P(non probe))
%              = 1 * frac_pr / (1 * frac_pr + (1 - P(rew by d | non probe)) * (1 - frac_pr))
%              = 1 * frac_pr / (1 * frac_pr + CDF(d) * (1 - frac_pr))
b_tr2 = frac_pr ./ (frac_pr + (1 - F) * (1 - frac_pr));

% plot for different fractions of probe trials
fpr = [0.01 5 10 20 40] / 100;
for i = 1:length(fpr)
    leg{i} = sprintf('%.2f%% omissions', fpr(i));
    b_tr2_more(i,:) = fpr(i) ./ (fpr(i) + (1 - F) * (1 - fpr(i)));
end


V_tr1 = (1 - b_tr1) .* V;
V_tr2 = (1 - b_tr2) .* V;


% TODO dedupe w/ analytical_TD


% post-reward RPEs
post_RPE_tr1 = 1 - V_tr1;
post_RPE_tr2 = 1 - V_tr2;

% pre-reward RPEs
pre_RPE_tr1 = V_tr1(2:end) * gamma^(d_dist / speed) - V_tr1(1:end-1);
pre_RPE_tr1 = [V_tr1(1) pre_RPE_tr1];
pre_RPE_tr2 = V_tr2(2:end) * gamma^(d_dist / speed) - V_tr2(1:end-1);
pre_RPE_tr2 = [V_tr2(1) pre_RPE_tr2];

save shit.mat


if do_plot
    figure; % for debugging

    subplot(6,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');
    xlim([1 100]);

    subplot(6,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    xlim([1 100]);
    
    subplot(6,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');
    xlim([1 100]);

    subplot(6,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');
    xlim([1 100]);
    
    subplot(6,2,5);
    plot(d, b_tr1);
    title('Belief state, track 1');
    xlabel('distance');
    ylabel('P(probe | no rew yet)');
    xlim([1 100]);

    subplot(6,2,6);
    plot(d, b_tr2);
    title('Belief state, track 2');
    xlabel('distance');
    ylabel('P(probe | no rew yet)');
    xlim([1 100]);


    subplot(6,2,7);
    plot(d, V_tr1);
    title('Value, track 1');
    xlabel('distance');
    ylabel('h');
    xlim([1 100]);

    subplot(6,2,8);
    plot(d, V_tr2);
    title('Value, track 2');
    xlabel('distance');
    ylabel('h');
    xlim([1 100]);

    subplot(6,2,9);
    plot(d, post_RPE_tr1);
    title('Post-reward RPE, track 1');
    xlabel('distance');
    ylabel('1 - h');
    xlim([1 100]);
    
    subplot(6,2,10);
    plot(d, post_RPE_tr2);
    title('Post-reward RPE, track 2');
    xlabel('distance');
    ylabel('1 - h');
    xlim([1 100]);
    
    subplot(6,2,11);
    plot(d, pre_RPE_tr1);
    title('Pre-reward RPE, track 1');
    xlabel('distance');
    ylabel('h''');
    xlim([1 100]);

    subplot(6,2,12);
    plot(d, pre_RPE_tr2);
    title('Pre-reward RPE, track 2');
    xlabel('distance');
    ylabel('h''');
    xlim([1 100]);











    figure('pos', [1632         639         560         504]); % for Nao

    %{
    subplot(5,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');
    xlim([1 400]);
    ylim([0 max(f)*1.2]);

    subplot(5,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    xlim([1 400]);
    ylim([0 max(f)*1.2]);
    
    subplot(5,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');
    xlim([1 400]);
    ylim([0 1]);

    subplot(5,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');
    xlim([1 400]);
    ylim([0 1]);
    %}


    subplot(3,2,5-4);
    plot(d, b_tr1);
    title('Belief state, track 1');
    xlabel('distance');
    ylabel('P(probe | no rew yet)');
    xlim([1 400]);
    ylim([-0.1 1]);

    subplot(3,2,6-4);
    plot(d, b_tr2);
    title('Belief state, track 2');
    xlabel('distance');
    ylabel('P(probe | no rew yet)');
    xlim([1 400]);
    ylim([-0.1 1]);


    subplot(3,2,7-4);
    plot(d, V_tr1);
    title('Value, track 1');
    xlabel('distance');
    ylabel('Q');
    xlim([1 400]);
    ylim([0 1]);

    subplot(3,2,8-4);
    plot(d, V_tr2);
    title('Value, track 2');
    xlabel('distance');
    ylabel('Q');
    xlim([1 400]);
    ylim([0 1]);

    subplot(3,2,9-4);
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

    subplot(3,2,10-4);
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
    
    mtit('Belief-TD', 'fontsize',16,'color',[0 0 0], 'xoff',-.035,'yoff',.015);






    figure('pos', [1000 1082 789 256]);

    subplot(1,2,1);
    cmap = [0.5 0.5 1; ...
            1 0.5 0; ...
            0.5 1 0];
    colormap(cmap);
    hold on;
    plot(d, 1 - b_tr2_more(1,:), 'color', cmap(1,:));
    plot(d, 1 - b_tr2_more(3,:), 'color', cmap(2,:));
    title('Belief state');
    xlabel('distance');
    ylabel('P(reward | no rew yet)');
    legend({'track 1', 'track 2'});
    xlim([1 400]);
    ylim([-0.1 1]);


    subplot(1,2,2);
    plot(d, 1 - b_tr2_more);
    title('Belief state');
    xlabel('distance');
    ylabel('P(reward | no rew yet)');
    legend(leg);
    xlim([1 400]);
    ylim([-0.1 1]);


end
