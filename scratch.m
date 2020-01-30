

figure;

subplot(2,1,1);

hold on;

h = bar(rewards);
h.FaceAlpha = 0.3;
plot(Q(:,1), '-o', 'color', 'green');
plot(Q(:,2), '-o', 'color', 'red');
xlabel('observation');
title('Q values');
legend({'rewards', 'run', 'stop'})

plot([10.5 10.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');

yl = max(Q(:))*1.1;
text(4, yl - 0.5, 'track 1');
text(14, yl - 0.5, 'track 2');
text(20.9, yl - 0.5, 'ITI');

ylim([-0.2 yl]);



subplot(2,1,2);

hold on;

h = bar(posts);
h.FaceAlpha = 0.3;
plot(pres, '-o');
xlabel('observation');
title('RPEs');
legend({'post-reward', 'pre-reward'})

plot([10.5 10.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');
plot([20.5 20.5], [-1 20], '--', 'color', [0.2 0.2 0.2], 'HandleVisibility','off');

yl = max(posts(:))*1.1;
text(4, yl - 0.05, 'track 1');
text(14, yl - 0.05, 'track 2');
text(20.9, yl - 0.05, 'ITI');

ylim([-0.2 yl]);
