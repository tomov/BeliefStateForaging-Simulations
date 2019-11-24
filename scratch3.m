%{
x = rand(100,1);
y = x + normrnd(0,1,[100,1]) * 0.2;

figure;
scatter(x, y);
xlabel('mPFC');
ylabel('VTA');
hold on;
plot([0 1], [0 1], 'linewidth', 2, 'color', [0 0 1]);

title('Post-reward RPE modulation');


figure;

subplot(1,2,1);
pie([230 87]);
legend({'Belief state', 'other'});
title({'VS-projecting', 'mPFC cells'});

subplot(1,2,2);
pie([32 129]);
legend({'Belief state', 'other'});
title({'non-VS-projecting', 'mPFC cells'});
%}


figure;

t = 1:100;
y = zeros(size(t));
y(20:40) = normpdf(-10:10, 0, 1);
plot(y, 'linewidth', 2);

ylim([0 1]);
