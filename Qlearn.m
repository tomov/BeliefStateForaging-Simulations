% episodic and continuous Q learning

[frac_tr1, frac_pr, ITI_len, init_fn, next_fn, plot_fn, names] = init_params('clara_task_2_orig');


episodic = true;
reset = false;
pavlovian = true;

alpha = 0.1;
eps = 0.1;
gamma = 0.9;

ntrials = 10000;

env = init_fn();

Q = rand(env.nO, env.nA) * 0.000001; % to break ties initially

rewards = zeros(1, env.nO);
visits = zeros(1, env.nO);

pre_RPEs = zeros(1, env.nO);
pre_RPE_cnts = zeros(1, env.nO);
post_RPEs = zeros(1, env.nO);
post_RPE_cnts = zeros(1, env.nO);

for n = 1:ntrials
     env = init_fn();

     o_prev = env.o; % TODO agent

     %fprintf('\n\n----------------------- n = %d, track = %d, om = %d, rewloc = %d\n\n', n, env.track, env.omission, env.rewloc);

     got_reward = false; % for reset

     while env.s ~= env.ITI || o_prev == env.obs(env.ITI)
         o_prev = env.o;

         % observe
         o = env.o;

         % choose action
         [~, a] = max(Q(o,:));
         if rand < eps % eps greedy
             a = randsample([1:a-1 a+1:env.nA], 1);
         end

         if pavlovian
             a = 1; % always run
         end

         %fprintf('   o = %d, a = %d\n', o, a);

         % take action and observe outcome
         [env, ~, o_new, r] = next_fn(env, a);

         %fprintf('         o_new = %d, r = %d\n', o_new, r);

         % pick best next action (for update)
         [~, a_new] = max(Q(o_new, :));

         % compute RPE
         RPE = r + gamma * Q(o_new, a_new) - Q(o,a);

         if reset && got_reward
             RPE = 0;
         end

         % TD update
         if ~episodic || o ~= env.obs(env.ITI) % if episodic, don't accrue value in ITI
             Q(o,a) = Q(o,a) + alpha * RPE;
         end

         if r > 0
             assert(~got_reward);
             got_reward = true;
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

         %visits

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

plot_Qlearn
%scratch
