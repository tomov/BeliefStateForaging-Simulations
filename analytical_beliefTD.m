function analytical_beliefTD(x, do_plot, distr)

    % plot stuff for belief-TD model
    %
    % x(1) = mean rew dist
    % x(2) = std rew dist
    % x(3) = mean ITI
    % x(4) = fraction track 2 (probe and non-probe)
    % x(5) = fraction probe (of track 2)

% TODO dedupe w/ analytical_optimal


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

d_dist = 10; % accuracy of numerical approximation TODO this matters a lot for the magnitude of the hazard RPEs; must investigate
track2maxRun = [1:d_dist:600]; % distances to try for how far mouse is willing to run on track 2 before quiting

if ~exist('distr', 'var')
    distr = 'norm'; % what kind of reward distribution to use
end
[pdf, cdf, rnd, mea] = get_distr(distr, min_dist, mu, max_dist, sigma);


d = 1:d_dist:600; % distances

f = pdf(d); % track 1 reward distance PDF = P(rew at d) = track 2 non-probe PDF
F = cdf(d); % track 1 reward distance CDF = P(rew before d) = track 2 non-probe CDF

% TODO dedupe w/ analytical_TD

% track 1/2 non-probe TD value = Q(d0, RUN) = E[ r_t gamma^(t - t0) ]
%                              = integral f(d | no rew by d0) * gamma^((d - d0)/speed) * r * d_d
%
for i = 1:length(track2maxRun)
    % P(rew at d | no rew by d_i)
    % note difference from hazard
    f_cond = f(i:end) ./ (1 - F(i));
    
    g = gamma .^ ((d(i:end) - d(i)) / speed);
    rew = 1;
    V(i) = sum(f_cond .* g .* rew .* d_dist);
end


% track 1 belief state = P(probe | no rew by d) = 0
b_tr1 = 0 ./ (1 - F);

% track 2 belief state = P(probe | no rew by d) 
%              = P(no rew by d | probe) P(probe) / (P(no rew by d | probe) P(probe) + P(no rew by d | non probe) P(non probe))
%              = 1 * frac_pr / (1 * frac_pr + (1 - P(rew by d | non probe)) * (1 - frac_pr))
%              = 1 * frac_pr / (1 * frac_pr + CDF(d) * (1 - frac_pr))
b_tr2 = frac_pr ./ (frac_pr + (1 - F) * (1 - frac_pr));


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



if do_plot
    figure; % for debugging

    subplot(6,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');

    subplot(6,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    
    subplot(6,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');

    subplot(6,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');
    
    subplot(6,2,5);
    plot(d, b_tr1);
    title('Belief state, track 1');
    xlabel('distance');
    ylabel('P(probe | no rew by distance)');

    subplot(6,2,6);
    plot(d, b_tr2);
    title('Belief state, track 2');
    xlabel('distance');
    ylabel('P(probe | no rew by distance)');


    subplot(6,2,7);
    plot(d, V_tr1);
    title('Value, track 1');
    xlabel('distance');
    ylabel('h');

    subplot(6,2,8);
    plot(d, V_tr2);
    title('Value, track 2');
    xlabel('distance');
    ylabel('h');

    subplot(6,2,9);
    plot(d, post_RPE_tr1);
    title('Post-reward RPE, track 1');
    xlabel('distance');
    ylabel('1 - h');
    
    subplot(6,2,10);
    plot(d, post_RPE_tr2);
    title('Post-reward RPE, track 2');
    xlabel('distance');
    ylabel('1 - h');
    
    subplot(6,2,11);
    plot(d, pre_RPE_tr1);
    title('Pre-reward RPE, track 1');
    xlabel('distance');
    ylabel('h''');

    subplot(6,2,12);
    plot(d, pre_RPE_tr2);
    title('Pre-reward RPE, track 2');
    xlabel('distance');
    ylabel('h''');










    figure; % for Nao

    subplot(5,2,1);
    plot(d, f);
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 1');
    ylim([0 max(f)*1.2]);

    subplot(5,2,2);
    plot(d, f * (1 - frac_pr));
    xlabel('distance');
    ylabel('probability density');
    title('Reward location PDF, track 2');
    ylim([0 max(f)*1.2]);
    
    subplot(5,2,3);
    plot(d, F);
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 1');
    ylim([0 1]);

    subplot(5,2,4);
    plot(d, F * (1 - frac_pr));
    xlabel('distance');
    ylabel('cumulative density');
    title('Reward location CDF, track 2');
    ylim([0 1]);


    subplot(5,2,5);
    plot(d, b_tr1);
    title('Belief state, track 1');
    xlabel('distance');
    ylabel('P(probe | no rew by distance)');
    ylim([0 1]);

    subplot(5,2,6);
    plot(d, b_tr2);
    title('Belief state, track 2');
    xlabel('distance');
    ylabel('P(probe | no rew by distance)');
    ylim([0 1]);


    subplot(5,2,7);
    plot(d, V_tr1);
    title('Value, track 1');
    xlabel('distance');
    ylabel('V');
    xlim([1 400]);
    ylim([0 1]);

    subplot(5,2,8);
    plot(d, V_tr2);
    title('Value, track 2');
    xlabel('distance');
    ylabel('V');
    xlim([1 400]);
    ylim([0 1]);

    subplot(5,2,9);
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

    subplot(5,2,10);
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
    
end
