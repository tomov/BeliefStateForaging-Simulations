% belief state Q learning

% copy pasted from Q.m

frac_pr = 0.2;


alpha = 0.1;
eps = 0.1;
gamma = 0.9;

episodic = true;

ntrials = 1;

W = zeros(env.nS, env.nA); % belief state weights for each action 

cnt = zeros(1, env.nO);
visits = zeros(1, env.nO);

% estimate model
env = estimate_env_1(frac_pr);
P = env.P;

for n = 1:ntrials
     env = init_env_1(frac_pr);

     o_prev = env.o; % TODO agent

     % initial belief = ITI
     b = zeros(env.nS, 1);
     b(env.ITI) = 1;

     %fprintf('\n\n----------------------- n = %d\n\n', n);

     while env.s ~= env.ITI || o_prev == env.obs(env.ITI)
         o_prev = env.o;

         % observe (redundant here; belief state already updated)
         o = env.o;

         % choose action
         [~, a] = max(W' * b);
         if rand < eps % eps greedy
             a = randsample([1:a-1 a+1:env.nA], 1);
         end

         fprintf('in s, o = %d, %d; a = %d; b = [%s]\n', env.s, env.o, a, sprintf('%d,', b));

         % take action
         [env, ~, o_new, r] = next_env_1(env, a);

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

         fprintf('   o_new = %d, r = %d; b_new = [%s]\n', o_new, r, sprintf('%d,', b_new));
         b = b_new;

         % pick best next action (for update)
         [~, a_new] = max(W' * b_new);

         if ~episodic || o ~= env.obs(env.ITI) % if episodic, don't accrue value in ITI
             RPE = r + gamma * (W(:,a_new)' * b_new + W(:,a)' * b);
             W(:,a) = W(:,a) + alpha * RPE * b;
         end

         if r > 0
             cnt(o) = cnt(o) + 1;
         end
         visits(o) = visits(o) + 1;

         fprintf('a, o = %d, %d\n', a, o);
         visits

     end
end
