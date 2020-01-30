function plot_graph_2(E, env)

    % helper method to plot the MDP for env 2
    % copied from plot_graph_1


    c = zeros(1, env.nS);
    c(env.first_rew(1):env.last_rew(1)) = 1;
    c(env.first_om(1):env.last_om(1)) = 2;
    c(env.first_rew(2):env.last_rew(2)) = 3;
    c(env.first_om(2):env.last_om(2)) = 4;
    c(env.ITI) = 5;
    cm = jet(5);

    x = zeros(1, env.nS);
    x(env.first_rew(1):env.last_rew(1)) = 1:2:20; % TODO hardcoded
    x(env.first_om(1):env.last_om(1)) = 1:2:20;
    x(env.first_rew(2):env.last_rew(2)) = 1:2:20; % TODO hardcoded
    x(env.first_om(2):env.last_om(2)) = 1:2:20;
    x(env.ITI) = 0;

    y = zeros(1, env.nS);
    y(env.first_rew(1):env.last_rew(1)) = 1;
    y(env.first_om(1):env.last_om(1)) = 2;
    y(env.first_rew(2):env.last_rew(2)) = -1;
    y(env.first_om(2):env.last_om(2)) = -2;
    y(env.ITI) = 0;


    E(isnan(E)) = 0;
    G = digraph(E);
    h = plot(G, 'EdgeLabel',G.Edges.Weight);

    set(h, 'XData', x);
    set(h, 'YData', y);
    for i = 1:env.nS
        highlight(h, i, 'NodeColor', cm(c(i),:), 'MarkerSize', 14);
    end
    labelnode(h, 1:env.nS, '');

    for i = 1:env.nS
        text(h.XData(i), h.YData(i)  , num2str(i), 'FontSize', 10, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    end

    text(-2, 1, 'track 1: rewarded');
    text(-2, 2, 'track 1: omission');
    text(-2, 0, 'ITI');
    text(-2, -1, 'track 2: rewarded');
    text(-2, -2, 'track 2: omission');

    xlim([-3 22]);
