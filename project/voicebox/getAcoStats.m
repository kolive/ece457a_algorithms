function [minFit1, minFit2, stag1, stag2, stagFit1, stagFit2, solNum1, solNum2, graphSol1, graphSol2, table1, table2]=getAcoStats()
    
    iterationList = 1:10:101;
    fitEff = zeros(2,20);
    stagIter = zeros(2,20);
    bestFit = zeros(2,20);
    bestScores_1 = zeros(20,size(iterationList,2));
    bestScores_2 = zeros(20,size(iterationList,2));
    solutionNum = zeros(2,20);

    for i=1:20
        statcount = i
        [bestScores_1(i,:), solutionNum(1,i), fitEff(1,i), stagIter(1,i)] = acoTweaking_sean('audio2.wav', 'audio2.tag', 7, iterationList, 6);
        [bestScores_2(i,:), solutionNum(2,i), fitEff(2,i), stagIter(2,i)] = acoTweaking_sean2('audio2.wav', 'audio2.tag', 8, iterationList, 6);
        bestFit(1,i) = min(bestScores_1(i,:));
        %bestFit(2,i) = min(bestScores_2(i,:));
    end
    
    % the minimum fitness after 1000
    minFit1 = min(fitEff(1,:));
    minFit2 = min(fitEff(2,:));
    % the average stagnation fitness
    stagFit1 = mean(bestFit(1,:));
    stagFit2 = mean(bestFit(2,:));
    % average number of iterations before stagnation
    stag1 = mean(stagIter(1,:));
    stag2 = mean(stagIter(2,:));
    % average number of solutions examined per iteration
    solNum1 = mean(solutionNum(1,i) ./ 100);
    solNum2 = mean(solutionNum(2,i) ./ 100);
    % for the graph, the average solution (iterations are implied)
    graphSol1 = mean(bestScores_1);
    graphSol2 = mean(bestScores_2);
    % for the table
    table1 = [(1:10:101)', solutionNum(1,i)', graph_Sol1'];
    table2 = [(1:10:101)', solutionNum(2,i)', graph_Sol2'];
end