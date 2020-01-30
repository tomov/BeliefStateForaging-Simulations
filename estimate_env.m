function env = estimate_env(init_fn, next_fn)

    % estimate transition, observation, and probabilities P(s',o,r|s,a)

    env = init_fn();

    % estimate observation distribution
    % P(s',o,r|s,a) 
    cnt = zeros(env.nS, env.nA, env.nS, env.nO, env.nR); % (s,a,s',o,r) counts
    cnt_marg = zeros(env.nS, env.nA); % (s,a) counts, to normalize

    niter = 10000;

    % simulate niter trials
    for it = 1:niter
        env = init_fn();

        % simulate trial
        % keep running to traverse whole state space
        % notice this assumes domain knowledge (that running is the way to go)
        % defer general T estimation to future work
        s_prev = env.s;
        while env.s ~= env.ITI || s_prev == env.ITI
            s_prev = env.s;

            % see what happens for each action
            for a = 1:2
                [~, s_new, o, r] = next_fn(env, a);

                cnt(env.s, a, s_new, o, r+1) = cnt(env.s, a, s_new, o, r+1) + 1;
                cnt_marg(env.s, a) = cnt_marg(env.s, a) + 1;
            end

            env = next_fn(env, 1); % keep running
        end
    end

    % from counts to probabilities
    % P(s,a,s',o,r) = P(s',o,r|s,a)
    P = zeros(size(cnt));
    for s = 1:env.nS
        for a = 1:env.nA
            P(s,a,:,:,:) = cnt(s,a,:,:,:) / cnt_marg(s,a);
        end
    end


    % get T, O, and R as marginals of P(s',o,r|s,a)
    T = zeros(env.nS, env.nA, env.nS);
    O = zeros(env.nS, env.nA, env.nS);
    R = zeros(env.nS, env.nA, env.nS);
    for s = 1:env.nS
        for a = 1:env.nA
            for s_new = 1:env.nS
                % T(s,a,s') = P(s'|s,a)
                % marginalize over r and o
                T(s,a,s_new) = nansum(nansum(P(s,a,s_new,:,:)));

                % O(s,a,s') = argmax o P(o|s,a,s')
                % marginalize over r
                % notice that P(o|s,a,s')  = P(s',o|s,a) / P(s'|s,a)
                P_o = nansum(squeeze(P(s,a,s_new,:,:)), 2) / T(s,a,s_new);
                if nansum(P_o) < 1e-8
                    o = NaN;
                else
                    [~,o] = max(P_o);
                end
                O(s,a,s_new) = o;

                % R(s,a,s') = E[reward] over P(r|s,a,s')
                % marginalize over o
                % notice that P(r|s,a,s') = P(s',r|s,a) / P(s'|s,a)
                r = nansum(squeeze(P(s,a,s_new,:,:)), 1) / T(s,a,s_new) * [0 1]';
                R(s,a,s_new) = r;
            end
        end
    end

    env.T = T;
    env.R = R;
    env.O = O;
    env.P = P;
