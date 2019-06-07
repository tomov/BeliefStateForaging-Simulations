% x(1) = mean rew dist
% x(2) = std rew dist
% x(3) = mean ITI
% x(4) = fraction track 2 (probe and non-probe)
% x(5) = fraction probe (of track 2)

x0 = [120 40 8 0.5 0.3]; % initial condition
lb = [50 5 1 0.5 0.1]; % lower bounds
ub = [250 250 8 0.7 0.3]; % upper bounds

%options = optimset('Display','off');
[x] = fmincon(@cost_beliefStateForaging,x0,[],[],[],[],lb,ub,[]);

save fit.mat

[simResults, i] = formula_beliefStateForaging(x, true);
simResults(i,:)
x
