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

for i = 1:1 % 1:length(distr)
    %{
    analytical_TD(x{i}, true, distr{i}, distr_params(i));
    analytical_hazard(x{i}, true, distr{i}, distr_params(i));
    analytical_optimal(x{i}, true, distr{i}, distr_params(i));
    %}
    analytical_beliefTD(x{i}, true, distr{i}, distr_params(i));
end
