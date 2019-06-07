function cost = cost_beliefStateForaging(x)

    %[simResults, i] = simulation_beliefStateForaging(x);
    [simResults, i] = formula_beliefStateForaging(x, false);

    cost = simResults(1,2) / simResults(i,2) + abs(0.9 - simResults(i,3)); % peaks and 90%
    %cost = simResults(1,2) / simResults(i,2); % peaks only
    %cost = abs(0.9 - simResults(i,3)); % 90% only

    if simResults(1,2) > simResults(i,2)
        cost = cost + 1000;
    end


    cost = cost * 1000000;
