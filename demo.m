clear;

distr{1} = 'norm';
x{1} = [140 80 8 0.7 0.2 20 300]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(1).mus = [];
distr_params(1).sigmas = [];
distr_params(1).w = [];

distr{2} = 'unif';
x{2} = [140 80 8 0.7 0.2 20 300]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(2).mus = [];
distr_params(2).sigmas = [];
distr_params(2).w = [];

distr{3} = 'mixnorm';
x{3} = [140 80 8 0.7 0.2 20 300]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(3).mus = [50 150 250];
distr_params(3).sigmas = [10 10 10];
distr_params(3).w = [1 1 1];

distr{4} = 'mixnorm';
x{4} = [140 80 8 0.7 0.2 20 350]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(4).mus = [50 150 250];
distr_params(4).sigmas = [10 10 10];
distr_params(4).w = [1 2 4];

distr{5} = 'mixnorm';
x{5} = [140 80 8 0.7 0.2 20 350]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(5).mus = [50 150 250];
distr_params(5).sigmas = [10 10 10];
distr_params(5).w = [3 2 1];

distr{6} = 'mixnorm';
x{6} = [140 80 8 0.7 0.2 20 300]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(6).mus = [100 250];
distr_params(6).sigmas = [20 20 20];
distr_params(6).w = [1 1];

distr{7} = 'mixnorm';
x{7} = [140 80 8 0.7 0.2 20 300]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(7).mus = [100 250];
distr_params(7).sigmas = [20 20 20];
distr_params(7).w = [1 2];

distr{8} = 'mixnorm';
x{8} = [140 80 8 0.7 0.2 20 300]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(8).mus = [100 250];
distr_params(8).sigmas = [20 20 20];
distr_params(8).w = [2 1];

distr{9} = 'mixnorm';
x{9} = [140 80 8 0.7 0.2 50 350]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(9).mus = [50 350];
distr_params(9).sigmas = [50 50];
distr_params(9).w = [1 1];


gamma = 0.60;
d_dist = 0.1;
frac_pr_tr1 = 0.01;
speed = 13;

% discretized version
%
distr{10} = 'mixnorm';
x{10} = [speed*4 speed*1 8 0.5 0.2 10 150]; % mu, sigma, ITI, frac tr2, frac probe, min, max
distr_params(10).mus = speed * [2 3 4 5 6]; % centers in seconds
distr_params(10).sigmas = 0.1 * ones(size(distr_params(10).mus));
distr_params(10).w = normpdf(distr_params(10).mus, x{10}(1), x{10}(2));
% comment out to un-discretize
distr{10} = 'norm';
distr_params(10).mus = [];
distr_params(10).sigmas = [];
distr_params(10).w = [];

do_plot = true;

for i = 10:10 % 1:length(distr)
    %analytical_optimal(x{i}, do_plot, distr{i}, distr_params(i), d_dist, frac_pr_tr1, gamma, speed);

    analytical_TD(x{i}, do_plot, distr{i}, distr_params(i), d_dist, frac_pr_tr1, gamma, speed);
    %analytical_hazard(x{i}, do_plot, distr{i}, distr_params(i), d_dist, frac_pr_tr1, gamma, speed);
    %analytical_beliefTD(x{i}, do_plot, distr{i}, distr_params(i), d_dist, frac_pr_tr1, gamma, speed);
end
