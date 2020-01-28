frac_pr = 0.2;

env = init_env_1(frac_pr);

% estimate observation distribution
% P(s',o,r|s,a)
cnt = zeros(env.nS, env.nA, env.nS, env.nO, env.nR); % (s,a,s',o,r) counts
cnt_marg = zeros(env.nS, env.nA); % (s,a) counts, to normalize

niter = 1000;

% simulate niter trials
for it = 1:niter
    env = init_env_1(frac_pr);

    % simulate trial
    % keep running to traverse whole state space
    % notice this assumes domain knowledge
    % defer general T estimation to future work
    s_prev = env.s;
    while env.s ~= env.ITI || s_prev == env.ITI
        s_prev = env.s;

        % see what happens for each action
        for a = 1:2
            [~, s_new, o, r] = next_env_1(env, a);
            cnt(env.s, a, s_new, o, r+1) = cnt(env.s, a, s_new, o, r+1) + 1;
            cnt_marg(env.s, a) = cnt_marg(env.s, a) + 1;
        end

        env = next_env_1(env, 1); % keep running
    end
end

P = zeros(size(cnt));
for s = 1:env.nS
    for a = 1:env.nA
        P(s,a,:,:,:) = cnt(s,a,:,:,:) / cnt_marg(s,a);
    end
end
