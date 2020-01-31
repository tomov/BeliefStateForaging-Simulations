% plot result of Qlearn

figure;

subplot(2,1,1);

hold on;

h = bar(rewards * 4);
h.FaceAlpha = 0.3;
plot(Q(:,1), '-o', 'color', 'green');
if ~pavlovian
    plot(Q(:,2), '-o', 'color', 'red');
end
xlabel('observation');
title('Q values');
if pavlovian
    legend({'rewards', 'Q'})
else
    legend({'rewards', 'Q(:,run)', 'Q(:,stop)'})
end

plot([10.5 10.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
if isfield(env, 'track')
    plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
end

yh = max([h.YData Q(:)'])*1.1;
yh = 1.5;
text(4, yh - 0.1, names{1});
if isfield(env, 'track')
    text(14, yh - 0.1, names{2});
end
text(env.obs(env.ITI)-0.1, yh - 0.5, 'ITI');

ylim([-0.2 yh]);



subplot(2,1,2);

hold on;

h = bar(posts);
h.FaceAlpha = 0.3;
plot(pres, '-o');
xlabel('observation');
title('RPEs');
legend({'post-reward', 'pre-reward'})

plot([10.5 10.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
if isfield(env, 'track')
    plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
end

yh = max(posts(:))*1.1;
yl = min(pres(:))*1.1;
text(4, yh - 0.05, names{1});
if isfield(env, 'track')
    text(14, yh - 0.05, names{2});
end
text(env.obs(env.ITI)-0.1, yh - 0.05, 'ITI');

ylim([yl yh]);
