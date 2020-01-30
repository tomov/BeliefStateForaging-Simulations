function env = init_env_2(frac_tr1, frac_pr)

    % initialize interactive environment
    % track 1+2
    % frac_pr = fraction probes for [tr1 tr2]

    % states:
    % 1..10 = tr1 rew
    % 11..20 = tr1 om
    % 21..30 = tr2 rew
    % 31..40 = tr2 om
    % 41 = ITI

    env.actions = {'run', 'stop'};

    % state constants [tr1 tr2]
    env.first_rew = [1 21];
    env.last_rew = [10 30];
    env.first_om = [11 31];
    env.last_om = [20 40];
    env.ITI = 41;

    % observations:
    % 1..10 = tr1
    % 11..20 = tr2
    % 21 = ITI
    env.obs = [1:10 1:10 11:20 11:20 21]; % S->O mapping

    env.nS = 41; % # states
    env.nA = 2; % # actions
    env.nO = max(env.obs); % # observations
    env.nR = 2; % # rewards (a kind of observation)

    % initial state
    env.s = env.ITI; % start at ITI
    env.o = env.obs(env.s);

    % track
    env.track = double(rand() < (1 - frac_tr1)) + 1;

    % reward location
    rewloc = round(normrnd(5,1));
    %rewloc = randi(6) + 2;
    rewloc = min(env.rewloc, 8);
    rewloc = max(env.rewloc, 2);
    env.rewloc = rewloc + env.first_rew(env.track) - 1;

    % omission trial?
    env.omission = rand() < frac_pr(env.track);

