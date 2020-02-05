function [env, s, o, r] = next_env_0(env, a)

    % update environment after taking action
    % compute next state, observation, and reward
    % track 2 only

    r = 0;
    assert(a == 1); % force to be Pavlovian

    if env.s == env.ITI
        % trial start

        if env.started && rand() < 1 - 1.0/env.ITI_len % expectation of geometric distribution
            % self-transition to simulate expo ITIs
            % notice we do this only at end of trial, that is, the order is ISI->ITI
            nexts = [env.ITI];
            obs = [1];
            rews = [0];

        elseif ~env.started
            % start of trial
            env.started = true;
            nexts = [env.first];
            obs = [2]; % odor
            rews = [0];
        else
            % trial is ending (started was true, and ITI is done)
            env.ended = true;
            nexts = [env.ITI];
            obs = [1];
            rews = [0];
        end

    else
        % mid trial

        if env.s+1 == env.ISI_len
            % if next state is end of ISI, and if keep running, give reward (unless omission) and go to ITI
            % notice this means we never really reach the state with the reward -- see next_env_1 for justification; might change here th
            nexts = [env.ITI];
            obs = [1];
            if env.omission
                rews = [0];
            else
                rews = [1]; % reward
            end
        elseif env.s == env.last
            % end of track 
            assert(false); % this should never happen -- trial always ends  
            nexts = [NaN];
            obs = [NaN]; 
            rews = [NaN];
        else
            % next state (if running)
            nexts = [env.s+1 env.ITI];
            obs = [1]; 
            rews = [0];
        end
    end

    s = nexts(a);
    r = rews(a);
    o = obs(a);
    env.s = s;
    env.o = o;
    env.r = r;

    assert(env.s >= 1 && env.s <= env.nS);
    assert(env.o >= 1 && env.o <= env.nO);

