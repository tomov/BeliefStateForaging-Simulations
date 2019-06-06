function cost = cost_beliefStateForaging(x)

    %[simResults, i] = simulation_beliefStateForaging(x);
    [simResults, i] = formula_beliefStateForaging(x, false);

    cost = simResults(i,2) / simResults(1,2);% + abs(0.9 - simResults(i,3));
    cost = cost * 1000000;
