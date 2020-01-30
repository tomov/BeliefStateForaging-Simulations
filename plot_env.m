
frac_tr1 = 0.5;
frac_pr = [0 0.2];
init_fn = @() init_env_2(frac_tr1, frac_pr);

%env = estimate_env(init_fn, @next_env_2);

figure;


for a = 1:env.nA
    % plot T
    subplot(3, env.nA, a);
    E = squeeze(env.T(:,a,:));
    plot_graph_2(E, env);
    xlabel('transitions');
    title(env.actions{a});

    % plot O
    subplot(3, env.nA, 2+a);
    E = squeeze(env.O(:,a,:));
    plot_graph_2(E, env);
    ylabel('observations');

    % plot R
    subplot(3, env.nA, 4+a);
    E = squeeze(env.R(:,a,:));
    plot_graph_2(E, env);
    ylabel('rewards');

end
