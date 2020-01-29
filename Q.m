% episodic and continuous Q learning

frac_pr = 0.2;

alpha = 0.1;
eps = 0.1;
gamma = 0.9;

episodic = false;

ntrials = 100000;

Q = zeros(env.nO, env.nA);

cnt = zeros(1, env.nO);
visits = zeros(1, env.nO);

for n = 1:ntrials
     env = init_env_1(frac_pr);

     o_prev = env.o; % TODO agent

     %fprintf('\n\n----------------------- n = %d\n\n', n);

     while env.s ~= env.ITI || o_prev == env.obs(env.ITI)
         o_prev = env.o;

         % observe
         o = env.o;

         % choose action
         [~, a] = max(Q(o,:));
         if rand < eps % eps greedy
             a = randsample([1:a-1 a+1:env.nA], 1);
         end

         % take action
         [env, ~, o_new, r] = next_env_1(env, a);

         % pick best next action (for update)
         [~, a_new] = max(Q(o_new, :));

         % TD update
         if ~episodic || o ~= env.obs(env.ITI) % if episodic, don't accrue value in ITI
             RPE = r + gamma * Q(o_new, a_new) - Q(o,a);
             Q(o,a) = Q(o,a) + alpha * RPE;
         end

         % bookkeeping
         if r > 0
             cnt(o) = cnt(o) + 1;
         end
         visits(o) = visits(o) + 1;

         %fprintf('a, o = %d, %d\n', a, o);
         %visits

     end
end
