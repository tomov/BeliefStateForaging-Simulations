
%[frac_tr1, frac_pr, ITI_len, init_fn, next_fn, plot_fn] = init_params('clara_task_1');

env = estimate_env(init_fn, next_fn);

figure;


for a = 1:env.nA
    % plot T
    subplot(3, env.nA, a);
    E = squeeze(env.T(:,a,:));
    plot_fn(E, env);
    xlabel('transitions');
    title(env.actions{a});

    % plot O
    subplot(3, env.nA, 2+a);
    E = squeeze(env.O(:,a,:));
    plot_fn(E, env);
    xlabel('observations');

    % plot R
    subplot(3, env.nA, 4+a);
    E = squeeze(env.R(:,a,:));
    plot_fn(E, env);
    xlabel('rewards');

end
