function [a, b, p] = sa_run(runs)
  agg_sol_cost = 0;
  agg_best_sol = 100;
  agg_sol_costs = [];
  for i=1:runs
    [sol_cost, best_sol, all_sol_costs, total_iter] = saTweaking('audio2.wav', 'audio2.tag', 50);
    if (total_iter < 500)
      continue;
    end

    agg_sol_cost = agg_sol_cost + sol_cost;
    if (sol_cost < agg_best_sol)
      agg_best_sol = sol_cost;
    end
    agg_sol_costs = [agg_sol_costs; all_sol_costs(1:500)];
  end

  a = agg_sol_cost / runs;
  b = agg_best_sol;
  p = sum(agg_sol_costs) / runs;
  plot(p);
end
