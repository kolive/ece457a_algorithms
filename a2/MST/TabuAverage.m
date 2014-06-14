% TabuLength is the length of the Tabu list. Told in assignment to use 5, 10, 15, 25, 50
% NumIterations is the maximum number of iterations. Not sure about this one, I just used 15 since it seemed like a nice number
% NumRuns is the number of times you want to run TabuSearch. What gets returned at the end is an average of the BestSolnCost from all the runs.
function [AvgCost] = TabuAverage(TabuLength, NumIterations, NumRuns)
  load Units100.mat
  CostSum = 0;

  for i = 1:NumRuns
    [BestSoln, BestSolnCost] = TabuSearch(Graph, TabuLength, NumIterations, 'GenInitialST', 'GetBestNeighbourST');
    CostSum = CostSum + BestSolnCost;
  end

  AvgCost = CostSum / NumRuns;
end
