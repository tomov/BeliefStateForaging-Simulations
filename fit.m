% x(1) = mean rew dist
% x(2) = std rew dist
% x(3) = mean ITI
% x(4) = fraction track 2 (probe and non-probe)
% x(5) = fraction probe (of track 2)

x0 = [120 40 8 0.5 0.3];
lb = [50 5 1 0.2 0.1];
ub = [250 250 20 0.7 0.9];

options = optimset('Display','off');
[x] = fmincon(@cost_beliefStateForaging,x0,[],[],[],[],lb,ub,[],options);

save fit.mat
