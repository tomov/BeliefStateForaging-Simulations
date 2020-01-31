% belief state Q learning

% copy pasted from Q.m

[frac_tr1, frac_pr, ITI_len, init_fn, next_fn, plot_fn, names] = init_params('clara_task_2');


episodic = true;
pavlovian = true;


alpha = 0.1;
eps = 0.1;
gamma = 0.9;

ntrials = 10000;

env = estimate_env(init_fn, next_fn);

% estimate model
P = env.P;

W = zeros(env.nS, env.nA); % belief state weights for each action 

rewards = zeros(1, env.nO);
visits = zeros(1, env.nO);

pre_RPEs = zeros(1, env.nO);
pre_RPE_cnts = zeros(1, env.nO);
post_RPEs = zeros(1, env.nO);
post_RPE_cnts = zeros(1, env.nO);

for n = 1:ntrials
     env = init_fn();

     o_prev = env.o; % TODO agent

     % initial belief = ITI
     b = zeros(env.nS, 1);
     b(env.ITI) = 1;

     if env.omission
         B{2} = nan(env.nS, env.nS);
     else
         B{1} = nan(env.nS, env.nS);
     end

     %fprintf('\n\n----------------------- n = %d\n\n', n);

     t = 1;
     while env.s ~= env.ITI || o_prev == env.obs(env.ITI)
         o_prev = env.o;

         % observe (redundant here; belief state already updated)
         o = env.o;

         % choose action
         [~, a] = max(W' * b);
         if rand < eps % eps greedy
             a = randsample([1:a-1 a+1:env.nA], 1);
         end

         if pavlovian
             a = 1; % always run
         end

        % fprintf('in s, o = %d, %d; a = %d; b = [%s]\n', env.s, env.o, a, sprintf('%d,', b));

         % take action
         [env, ~, o_new, r] = next_fn(env, a);

         % update belief state
         b_new = zeros(env.nS, 1);
         for s_new = 1:env.nS
             p = squeeze(P(:, a, s_new, o_new, r+1)); % P(s',o,r|s,a) for all s
             p(isnan(p)) = 0; % treat NaN as 0, b/c it should never happen anyways
             b_new(s_new) = p' * b;
         end
         b_new = b_new / sum(b_new);
         if any(isnan(b_new))
             nthoeu
         end

        % fprintf('   o_new = %d, r = %d; b_new = [%s]\n', o_new, r, sprintf('%d,', b_new));
         b = b_new;

         % pick best next action (for update)
         [~, a_new] = max(W' * b_new);

         % compute RPE
         RPE = r + gamma * (W(:,a_new)' * b_new) - W(:,a)' * b;
         if isnan(RPE) || isinf(RPE)
             ansoetu
         end

         % TD update
         if ~episodic || o ~= env.obs(env.ITI) % if episodic, don't accrue value in ITI
             W(:,a) = W(:,a) + alpha * RPE * b;
         end
         if any(isnan(W(:)))
             natheou
         end

         % bookkeeping
         if r > 0
             rewards(o) = rewards(o) + 1;
         end
         visits(o) = visits(o) + 1;

         if n > ntrials * 0.9
             if r > 0
                 post_RPEs(o) = post_RPEs(o) + RPE;
                 post_RPE_cnts(o) = post_RPE_cnts(o) + 1;
             else
                 pre_RPEs(o) = pre_RPEs(o) + RPE;
                 pre_RPE_cnts(o) = pre_RPE_cnts(o) + 1;
             end
         end

        % fprintf('a, o = %d, %d\n', a, o);

         if env.omission
             B{2}(:,t) = b;
         else
             B{1}(:,t) = b;
         end
         t = t + 1;
     end
     if env.omission
         B{2}(:,t) = b_new;
     else
         B{1}(:,t) = b_new;
     end
end


visits = visits / sum(visits);
rewards = rewards / sum(rewards) * (1 - frac_pr);

posts = post_RPEs ./ post_RPE_cnts;
pres = pre_RPEs ./ pre_RPE_cnts;

pdf = rewards;
survival = frac_pr + cumsum(pdf, 2, 'reverse'); % notice it's off-by-on, that is, P(T>=t), b/c we're discrete
hazard = pdf ./ survival;
hazard_posts = 1 - hazard; % TODO fix for track 2
hazard_posts(isnan(posts)) = NaN;

plot_BQlearn
