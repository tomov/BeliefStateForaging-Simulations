function cost = cost_beliefStateForaging(x)

    [simResults, i] = simulation_beliefStateForaging(x);

    cost = simResults(i,2) / simResults(1,2);% + abs(0.9 - simResults(i,3));
