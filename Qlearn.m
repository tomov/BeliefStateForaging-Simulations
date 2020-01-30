% episodic and continuous Q learning

frac_tr1 = 0.7;
frac_pr = [0 0.2];

alpha = 0.1;
eps = 0.1;
gamma = 0.9;

episodic = false;

ntrials = 100000;

Q = rand(env.nO, env.nA) * 0.000001; % to break ties initially

rewards = zeros(1, env.nO);
visits = zeros(1, env.nO);

pre_RPEs = zeros(1, env.nO);
pre_RPE_cnts = zeros(1, env.nO);
post_RPEs = zeros(1, env.nO);
post_RPE_cnts = zeros(1, env.nO);

for n = 1:ntrials
     env = init_env_2(frac_tr1, frac_pr);

     o_prev = env.o; % TODO agent

     %fprintf('\n\n----------------------- n = %d, track = %d, om = %d, rewloc = %d\n\n', n, env.track, env.omission, env.rewloc);

     while env.s ~= env.ITI || o_prev == env.obs(env.ITI)
         o_prev = env.o;

         % observe
         o = env.o;

         % choose action
         [~, a] = max(Q(o,:));
         if rand < eps % eps greedy
             a = randsample([1:a-1 a+1:env.nA], 1);
         end

         %fprintf('   o = %d, a = %d\n', o, a);

         % take action
         [env, ~, o_new, r] = next_env_2(env, a);

         %fprintf('         o_new = %d, r = %d\n', o_new, r);

         % pick best next action (for update)
         [~, a_new] = max(Q(o_new, :));

         % TD update
         RPE = r + gamma * Q(o_new, a_new) - Q(o,a);
         if ~episodic || o ~= env.obs(env.ITI) % if episodic, don't accrue value in ITI
             Q(o,a) = Q(o,a) + alpha * RPE;
         end

         % bookkeeping
         if r > 0
             rewards(o) = rewards(o) + 1;
         end
         visits(o) = visits(o) + 1;

         if r > 0
             post_RPEs(o) = post_RPEs(o) + RPE;
             post_RPE_cnts(o) = post_RPE_cnts(o) + 1;
         else
             pre_RPEs(o) = pre_RPEs(o) + RPE;
             pre_RPE_cnts(o) = pre_RPE_cnts(o) + 1;
         end

         %visits

     end
end

visits = visits / sum(visits);
rewards = rewards / sum(rewards);

posts = post_RPEs ./ post_RPE_cnts;
pres = pre_RPEs ./ pre_RPE_cnts;
