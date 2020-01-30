function [env, s, o, r] = next_env_2_1(env, a)

    % update environment after taking action
    % compute next state, observation, and reward
    % track 1+2, but continues along track after reward instead of going into ITI -- this is to simulate Clara's task

    % copied from next_env_2

    r = 0;
    assert(a == 1 || a == 2);

    if env.s == env.ITI
        % trial start

        if rand() < 1 - 1.0/env.ITI_len % expectation of geometric distribution
            % self-transition to simulate expo ITIs
            nexts = [env.ITI env.ITI];
            rews = [0 0];

        elseif env.omission
            % start of omission trial
            nexts = [env.first_om(env.track) env.first_om(env.track)];
            rews = [0 0];
        else
            % start of rewarded trial
            nexts = [env.first_rew(env.track) env.first_rew(env.track)];
            rews = [0 0];
        end

    else
        % mid trial

        if env.omission
            % middle of omission trial

            if env.s == env.last_om(env.track)
                % end of track => go to ITI
                nexts = [env.ITI env.ITI];
                rews = [0 0];
            else
                % next state (if you keep running)
                nexts = [env.s+1 env.ITI];
                rews = [0 0];
            end

        else
            % middle of rewarded trial

            if env.s+1 == env.rewloc
                % if next state is rewarding, and if keep running, give reward and go to ITI
                % if stop, just go to ITI
                % notice this means we never really reach the state with the reward
                % I prefer this to the alternative, b/c then we must reward for running *and* stopping, but then stopping becomes rewarding sometimes which is weird
                assert(env.s ~= env.last_rew(env.track)); % don't put reward after last state
                nexts = [env.s+1 env.ITI];
                rews = [1 0];
            elseif env.s == env.last_rew(env.track)
                % end of track => go to ITI
                nexts = [env.ITI env.ITI];
                rews = [0 0];
            else
                % next state (if running)
                nexts = [env.s+1 env.ITI];
                rews = [0 0];
            end
        end
    end

    s = nexts(a);
    r = rews(a);
    o = env.obs(s);
    env.s = s;
    env.o = o;
    env.r = r;

    assert(env.s >= 1 && env.s <= env.nS);

