
frac_pr = 0.2;


alpha = 0.1;
eps = 0.1;

ntrials = 100;

cnt = zeros(1, env.nO);

for n = 1:ntrials
     env = init_env_1(frac_pr);

     o = env.o;
     [~, a] = max(agent.Q(o,:));
     if rand < eps % eps greedy
         a = randsample([1:a-1 a+1:env.nA], 1);
     end

     [env, ~, o_new, r] = next_env_1(env, a);

     [~, a_new] = max(Q(o_new, :));
     Q(o,a) = Q(o,a) + alpha * (r + gamma * Q(o_new, a_new) - Q(o,a));

     if r > 0
         cnt(o) = cnt(o) + 1;
     end
end
