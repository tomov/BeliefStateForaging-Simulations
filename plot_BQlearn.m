% plot result of BQlearn
% copy of plot_Qlearn

figure;

subplot(2,1,1);

hold on;

h = bar(rewards * 4);
h.FaceAlpha = 0.3;
plot(W(:,1), '-o', 'color', 'green');
if ~pavlovian
    plot(W(:,2), '-o', 'color', 'red');
end
xlabel('state');
title('weights');
if pavlovian
    legend({'rewards', 'w'})
else
    legend({'rewards', 'w(:,run)', 'w(:,stop)'})
end

plot([10.5 10.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
if isfield(env, 'track')
%    plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
end

yh = max([h.YData W(:)'])*1.1;
yh = 3.5;
yl = -1.5;
text(4, yh - 0.1, [names{1}, ' rewarded']);
text(14, yh - 0.1, [names{1}, ' omission']);
if isfield(env, 'track')
    %text(14, yh - 0.1, names{2});
end
text(env.ITI-0.1, yh - 0.5, 'ITI');

ylim([yl yh]);



subplot(2,1,2);

hold on;

h = bar(posts);
h.FaceAlpha = 0.3;
plot(pres, '-o');
xlabel('state');
title('RPEs');
legend({'post-reward', 'pre-reward'})

plot([10.5 10.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
if isfield(env, 'track')
%    plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
end

yh = max(posts(:))*1.1;
yl = min(pres(:))*1.1;
text(4, yh - 0.1, [names{1}, ' rewarded']);
text(14, yh - 0.1, [names{1}, ' omission']);
if isfield(env, 'track')
%    text(14, yh - 0.05, names{2});
end

if length(post_RPEs) == env.nO
    text(env.obs(env.ITI)-0.1, yh - 0.05, 'ITI');
else
    text(env.ITI-0.1, yh - 0.05, 'ITI');
end

ylim([yl yh]);




figure;

subplot(1,2,1);

imagesc(B{1});
xlabel('time');
ylabel('state');
title('belief state dynamics, rewarded');

subplot(1,2,2);

imagesc(B{2});
xlabel('time');
ylabel('state');
title('belief state dynamics, omission');
