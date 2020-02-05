% belief state Q learning, custom for Starkweather 2017

% copy pasted from BQ.m

[frac_tr1, frac_pr, ITI_len, init_fn, next_fn, plot_fn, names] = init_params('clara_task_2_orig');


episodic = false;
pavlovian = true;


alpha = 0.1;
eps = 0.1;
gamma = 0.9;

ntrials = 10000;

env = estimate_env(init_fn, next_fn);

do_print = false;

% estimate model
P = env.P;

W = zeros(env.nS, env.nA); % belief state weights for each action 

rewards = zeros(1, env.nS);
visits = zeros(1, env.nS);

pre_RPEs = zeros(1, env.nS);
pre_RPE_cnts = zeros(1, env.nS);
post_RPEs = zeros(1, env.nS);
post_RPE_cnts = zeros(1, env.nS);

for n = 1:ntrials
     env = init_fn();

     % initial belief = ITI
     b = zeros(env.nS, 1);
     b(env.ITI) = 1;

     if env.omission
         B{2} = nan(env.nS, env.nS);
     else
         B{1} = nan(env.nS, env.nS);
     end

     if do_print, fprintf('\n\n----------------------- n = %d\n\n', n); end

     t = 1;
     while ~env.ended % a bit hacky
         % for bookkeeping only
         s = env.s;

         % observe (redundant here; belief state already updated)
         o = env.o;

         % choose action
         [~, a] = max(W' * b);
         if env.nA > 1 && rand < eps % eps greedy
             a = randsample([1:a-1 a+1:env.nA], 1);
         end

         if pavlovian
             a = 1; % always run
         end

         if do_print, fprintf('in s, o = %d, %d; a = %d; b = [%s]\n', env.s, env.o, a, sprintf('%.3f,', b)); end
         if do_print, fprintf('             w = [%s]\n', sprintf('%.3f,', W')); end

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

         if do_print, fprintf('   o_new = %d, r = %d; b_new = [%s]\n', o_new, r, sprintf('%.3f,', b_new)); end

         % pick best next action (for update)
         [~, a_new] = max(W' * b_new);

         % compute RPE
         RPE = r + gamma * (W(:,a_new)' * b_new) - W(:,a)' * b;
         if do_print, fprintf('   RPE = %f = %f + gamma * %f - %f\n', RPE,r,(W(:,a_new)' * b_new), W(:,a)' * b); end
         if isnan(RPE) || isinf(RPE) || any(W(:,a) > 1e2)
             ansoetu
         end

         % TD update
         W0 = W;
         assert(~episodic); % must be continuous, otherwise ITI value explodes, and so do all the rest
         if ~episodic || s ~= env.ITI % if episodic, don't accrue value in ITI
             W(:,a) = W(:,a) + alpha * RPE * b;
         end
         if any(isnan(W(:)))
             natheou
         end

         %{ 
         % to compare w/ clara's
         if r == 1
             fprintf('\n\n\n');
             fprintf('  RPE = %.4f\n', RPE);
             fprintf('  b = [%s]\n', sprintf('%.3f, ', b));
             fprintf('  w = [%s]\n', sprintf('%.3f, ', W0));
             fprintf('  b_new = [%s]\n', sprintf('%.3f, ', b_new));
             fprintf('  w_new = [%s]\n', sprintf('%.3f, ', W));
         end
         fprintf('  rpe = %.4f\n', RPE);
         %}

         if do_print, fprintf('             w_new = [%s]\n', sprintf('%.3f,', W')); end

         % move to next belief state
         b = b_new;

         % bookkeeping
         if r > 0
             rewards(s) = rewards(s) + 1;
         end
         visits(s) = visits(s) + 1;

         if n > ntrials * 0.9
             if r > 0
                 post_RPEs(s) = post_RPEs(s) + RPE;
                 post_RPE_cnts(s) = post_RPE_cnts(s) + 1;
             else
                 pre_RPEs(s) = pre_RPEs(s) + RPE;
                 pre_RPE_cnts(s) = pre_RPE_cnts(s) + 1;
             end
         end

         if do_print, fprintf('a, o = %d, %d\n', a, o); end

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

plot_BQ_0
