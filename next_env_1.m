function [env, s, o, r] = next_env_1(env, a)

    % update environment after taking action
    % compute next state, observation, and reward

    r = 0;
    assert(a == 1 || a == 2);

    if env.s == env.ITI
        % trial start
        % TODO self-transition to simulate expo ITIs

        if env.omission
            % start of omission trial
            nexts = [env.first_om env.first_om];
        else
            % start of rewarded trial
            nexts = [env.first_rew env.first_rew];
        end

    else
        % mid trial

        if env.omission

            if env.s == env.last_om
                % end of track => go to ITI
                nexts = [env.ITI env.ITI];
            else
                % next state (if you keep running)
                nexts = [env.s+1 env.ITI];
            end

        else
            % middle of rewarded trial

            if env.s == env.rewloc
                % if rewarded, go to ITI
                % notice we reward *after* reaching the state,
                % that is, once you execute an action in that state
                nexts = [env.ITI env.ITI];
                r = 1;
            elseif env.s == env.last_rew
                % end of track 
                assert(false); % this should never happen -- you always get rewarded on rewarded trials
                nexts = [NaN NaN];
            else
                % next state (if running)
                nexts = [env.s+1 env.ITI];
            end
        end
    end

    s = nexts(a);
    o = env.obs(s);
    env.s = s;
    env.o = o;
    env.r = r;

    assert(env.s >= 1 && env.s <= env.nS);

