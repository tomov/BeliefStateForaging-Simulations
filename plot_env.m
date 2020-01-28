figure;


for a = 1:env.nA
    % plot T
    subplot(3, env.nA, a);
    E = squeeze(env.T(:,a,:));
    plot_graph(E, env);
    if a == 1
        ylabel('T');
    end
    title(env.actions{a});

    % plot O
    subplot(3, env.nA, 2+a);
    E = squeeze(env.O(:,a,:));
    plot_graph(E, env);
    if a == 1
        ylabel('O');
    end

    % plot R
    subplot(3, env.nA, 4+a);
    E = squeeze(env.R(:,a,:));
    plot_graph(E, env);
    if a == 1
        ylabel('R');
    end

end
