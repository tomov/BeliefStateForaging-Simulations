function plot_graph_0(E, env)

    % helper method to plot the MDP for env 1
    % copy of plot_graph_1


    c = zeros(1, env.nS);
    c(env.first:env.last) = 1;
    c(env.ITI) = 2;
    cm = jet(5);

    x = zeros(1, env.nS);
    x(env.first:env.last) = 1:2:28; % TODO hardcoded
    x(env.ITI) = 0;

    y = zeros(1, env.nS);
    y(env.first:env.last) = -1;
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

    text(-2, 0, 'ITI');
    text(-2, -1, 'trial');

    xlim([-3 30]);
