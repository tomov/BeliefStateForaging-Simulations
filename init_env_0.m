function env = init_env_0(frac_pr, ITI_len, sigma)

    % initialize interactive environment
    % task 2 from starkweather 2017 (can become task 1 if frac_pr = 0) 
    % copy of init_env_0

    env.actions = {'run', 'stop'};

    % state constants
    env.first = 1;
    env.last = 14;
    env.ITI = 15;

    env.ITI_len = ITI_len;

    env.nS = 15; % # states
    env.nA = 1; % # actions
    env.nO = 2; % # observations (1 = odor off, 2 = odor on)
    env.nR = 2; % # rewards (a kind of observation: 1 = no rew, 2 = rew)

    % initial state
    env.s = env.ITI; % start at ITI
    env.o = 1;

    % reward location
    w = zeros(1,13);
    w(6:12) = normpdf([2:8], 5, sigma);
    env.ISI_len = randsample(1:13, 1, true, w);

    % omission trial?
    env.omission = rand() < frac_pr;

