%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle. Maybe we should
%  make per-parameter granularity? Change the pheremone deposit (only best ant?) to
%  what's been shown in the slides.
%  Example usage: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fBest, numberOfSolutions, fitEff, nodes, nchildren, nodevals, nodeCount, visited]=acoTweakingDirect2(y, fs, giventags, a, b, evaporateFactor, pdeposit, numberOfAnts, iterationmax, qgranularity, nodes, nchildren, nodevals, nodeCount, visited)
    
    numberOfLevels = 7;
    explorationIterations = 1;
    duration = size(y,1)/fs;
    if(isequal(nodes,[0,0]))
        firstLevelSize = 5;
        %generate the nest node, let's use the default soln
        nest = genInitialSolution();

        %initialize root
        levelId = 1;
        nodeCount = 1;
        nodes = zeros(100,3);
        nodes(nodeCount, :) = [0, runVadBatch2Direct(y, fs, duration,giventags, nest), 1]
        visited = ones(1,100) * -1;
        %nodevals = zeros(1,100);
        clearvars nodevals
        nodevals(nodeCount) = nest;
        nchildren = ones(1, firstLevelSize) * -1; % make null children (to specify amount), may not be necessary?


        %generates the children identifiers, 5 for the first level since of is
        %whole numbers from 1 to 5
        [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, 1, firstLevelSize); 

        %we need to generate all the first layer nodes (of)
        [nodes, nodevals] = generateNodes(1, levelId, nodes, nchildren, nodevals, y, fs, duration, giventags);
        visited(1) = 1; %mark the root node's children as visited
    else
        not_initialising = 1
        % re-initialized the pheremones
        nodes(:,3) = 1;
    end
    
    %stat stuff
    numberOfSolutions = 0;
    fitEff = -1;
    
    % initialization stuff
    iterationcount = 1;
    topscore = -1;
    ants = ones(1, numberOfAnts);
    % p is the probability array
    p = zeros(1,qgranularity);
    fBest = 1000;

    while(iterationcount < iterationmax)
       acoiteration = iterationcount %printing out and giving a different name

       if(iterationcount > explorationIterations)
           specialB = b;
       else
           specialB = 0;
       end

       %an ant starts looking for food starting from home
       ants = ones(1, numberOfAnts);

       %traverse the graph, one level per parameter
       for levelId=1:numberOfLevels
           aid = 0;
           for curId=ants
               aid = aid + 1;
               %select the next step based on ACO calculations

               %calculate the transition probability of each child
               x = 1;
               % p is the probability array
               p(1,:) = zeros(1,qgranularity);
               for i=nchildren(curId, nchildren(curId,:) ~= 0)
                   % equation take from slides
                   p(1,x) = (nodes(i, 3)^a) * ((1/nodes(i,1))^specialB);
                   x = x + 1;
               end
               x = 1;
               p = p ./ sum(p);

               % Roulette wheel selection of next node to visit
               for i=2:size(p,2)
                   if(i ~= 0)
                       p(1,i) = (p(1,i-1) + p(1,i));
                   end
               end
               choose = rand;
               next = nchildren(curId, 1);
               for i=2:size(p,2)
                   if(choose < p(1,i) && choose >= p(1,i-1))
                       next = nchildren(curId, i);
                   end
               end

               %if the next step hasn't yet been visited, generate it's
               %children
               if(visited(next) == -1)
                 %generates the children identifiers
                 [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, next, qgranularity); 
                 %generates child nodes
                 [nodes, nodevals] = generateNodes(next, levelId, nodes, nchildren, nodevals, y, fs, duration, giventags);
                 numberOfSolutions = numberOfSolutions + qgranularity;
                 if(numberOfSolutions > 500 && fitEff == -1)
                     fitEff = fBest
                     %return
                 end
                 visited(next) = 1;
               end
               ants(1, aid) = next;
               nodes(curId, 3) = nodes(curId, 3) + pdeposit;
           end     

       end

       %evaporate pheromones
       nodes(:,3) = nodes(:,3) * evaporateFactor;

       % Find the best and worst score, where the best score is the one
       % with the lowest value
       topscore = min(nodes(ants,2));
       if(fBest > topscore)
           fBest = topscore;
       end
       iterationcount = iterationcount + 1;
    end
end

function [nodes, nodevals] = generateNodes(parentId, levelId, nodes, nchildren, nodevals, y, fs, duration, giventags)
    childs = nchildren(parentId, :);
    s = size(childs, 2);
    %nodevals = [nodevals; zeros(s,1)]; % not sure this saves time
    x = 1;
    for i = childs
        %set the quantized value based on the parent and the levelId
        nodevals(i) = nodevals(parentId);
        
        if(levelId == 1)
            %of level
            nodevals(i).of = x;
        elseif(levelId == 2)
            nodevals(i).ts = 0.001 + ((duration/2)/s)*x;
        elseif(levelId == 3)
            nodevals(i).tn = 0.001 + ((duration/2)/s)*x;
        elseif(levelId == 4)
            nodevals(i).ti = 10e-3 + ((10e-2 - 10e-3)/s)*x;
        elseif(levelId == 5)
            nodevals(i).gx = 10 + ((1000 - 10)/s)*x;
        elseif(levelId == 6)
            nodevals(i).xn = (1.995262/s)*x;
        end
            
        x = x + 1;
        
        %opt = runVadBatchDirect(y, fs, duration, giventags, nodevals(i));
        %cost = opt - nodes(parentId, 2); % not used anymore
        %nodes(i, :) = [opt, opt, 1]; %normalize the cost to between 1 and 201
        
    end
    opt = runVadBatch2Direct( y, fs, duration, giventags, nodevals(childs) );
    nodes(childs, :) = [opt', opt', ones(s,1)]; %normalize the cost to between 1 and 201
end

function [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, startId, nodeId, qgranularity)
    x = 1;
    for i=(startId+1):(startId+qgranularity)
        nchildren(nodeId, x) = i;
        visited(i) = -1;
        x = x + 1;
        nodeCount = i;
    end
    
end
