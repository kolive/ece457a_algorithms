function [aRes1, aRes2, bRes1, bRes2, dRes, sRes]=acoParamHack()
    alpha_list = [0.5, 1, 1.5, 2];
    beta_list = [0.1 0.25 0.5 0.75 1];
    deposit_list = [0.3 0.5 0.7 0.9];
    scaling_list = [0.5 1 1.5 2];
    [y fs] = wavread('audio2.wav');
    giventags = dlmread('audio2.tag');
    
    aRes1 = zeros(5*size(alpha_list,2),3);
    aRes2 = zeros(5*size(alpha_list,2),3);
    bRes1 = zeros(5*size(beta_list,2),3);
    bRes2 = zeros(5*size(beta_list,2),3);
    dRes = zeros(5*size(deposit_list,2),3);
    sRes = zeros(5*size(scaling_list,2),3);
    
    qgranularity = 5;
    numberOfAnts = 3;
    a = 1;
    b = 1;
    evaporateFactor1 = 0.4;
    evaporateFactor2 = 0.9;
    pdeposit = 0.3;
    scale = 1.3;
    iterationmax = 50;
    tic;
    % get the graph
    [~, ~, ~, nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect2(y, fs, giventags, a, b, evaporateFactor2, pdeposit, numberOfAnts, iterationmax, qgranularity, [0,0]);
    
    itercount = 0;
    for j = alpha_list
        for i=1:3
            [aRes2(i+itercount,1), aRes2(i+itercount,2), aRes2(i+itercount,3), nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect2(y, fs, giventags, j, b, evaporateFactor2, pdeposit, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited);
            [aRes1(i+itercount,1), aRes1(i+itercount,2), aRes1(i+itercount,3), nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect(y, fs, giventags, j, b, evaporateFactor1, scale, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited);
        end
        itercount = itercount + 1;
    end
    itercount = 0;
    for j = beta_list
        for i=1:3
            [bRes2(i+itercount,1), bRes2(i+itercount,2), bRes2(i+itercount,3), nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect2(y, fs, giventags, a, j, evaporateFactor2, pdeposit, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited);
            [bRes1(i+itercount,1), bRes1(i+itercount,2), bRes1(i+itercount,3), nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect(y, fs, giventags, a, j, evaporateFactor1, scale, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited);
        end
        itercount = itercount + 1;
    end
    itercount = 0;
    for j = deposit_list
        for i=1:3
            [dRes(i+itercount,1), dRes(i+itercount,2), dRes(i+itercount,3), nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect2(y, fs, giventags, a, b, evaporateFactor2, j, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited);
        end
        itercount = itercount + 1;
    end
    itercount = 0;
    for j = scaling_list
        for i=1:3
            [sRes(i+itercount,1), sRes(i+itercount,2), sRes(i+itercount,3), nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect(y, fs, giventags, a, b, evaporateFactor1, j, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited);
        end
        itercount = itercount + 1;
    end
    reuntime = toc
    aRes1
end
