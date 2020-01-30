function env = init_env_1(frac_pr)

    % initialize interactive environment
    % track 2 only

    env.actions = {'run', 'stop'};

    % state constants
    env.first_rew = 1;
    env.last_rew = 10;
    env.first_om = 11;
    env.last_om = 20;
    env.ITI = 21;

    env.obs = [1:10 1:10 11]; % S->O mapping

    env.nS = 21; % # states
    env.nA = 2; % # actions
    env.nO = max(env.obs); % # observations
    env.nR = 2; % # rewards (a kind of observation)

    % initial state
    env.s = env.ITI; % start at ITI
    env.o = env.obs(env.s);

    % reward location
    env.rewloc = round(normrnd(5,1));
    %env.rewloc = randi(6) + 2;
    env.rewloc = min(env.rewloc, 8);
    env.rewloc = max(env.rewloc, 2);

    % omission trial?
    env.omission = rand() < frac_pr;

