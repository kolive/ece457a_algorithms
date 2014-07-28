%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle. Maybe we should
%  make per-parameter granularity? Change the pheremone deposit (only best ant?) to
%  what's been shown in the slides.
%  Example usage: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bestScoreList, solutionNum, fitEff, stagIter]=acoTweaking_sean(wavfilename, tagfilename, numberOfAnts, iterationList, qgranularity)
    
    numberOfLevels = 7;
    explorationIterations = 1;
    firstLevelSize = 5;
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);

    %generate the nest node, let's use the default soln
    nest = genInitialSolution();
    
    %we want to generate a graph where each level represents a design
    %variable
    
    %quantize the possible values of each variable
    
    %make the edge cost the difference in optimality between the previous
    %node and this one
    
    %what should the matrix look like?
    % initially all -1
    % when a node is visited, generate the children of that node and update
    % the indexes in graph
    % nodes(i,:) = [edgeCost, solutionCost, pheremoneLevel]
    % nodevals(i) = solution
    % children(i, :) = [quantization level cols with indexes to children]
    % visited(i, :) = [-1 if child nodes have been generated, 0 otherwise]
    
    %the first level is populated manually, contains of values
    % children for each of those nodes are initialized to -1
    %at each node, select one of the non-negative indexes to visit next
    %if that node has not been visited before, generate it's children
    %(check if a node has been visited by seeing if children(i,:) is not
    %-1's)
    
    %initialize root
    nodeCount = 1;
    levelId = 1;
    nodes(nodeCount, :) = [0, runVadBatchDirect(y, fs, duration,giventags, nest), 1];
    visited(nodeCount) = -1;
    nodevals(nodeCount) = nest;
    nchildren(nodeCount, :) = ones(1, firstLevelSize) * -1; % make null children (to specify amount), may not be necessary?

    
    %generates the children identifiers, 5 for the first level since of is
    %whole numbers from 1 to 5
    [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, 1, firstLevelSize); 
    
    %we need to generate all the first layer nodes (of)
    [nodes, nodevals] = generateNodes(1, levelId, nodes, nchildren, nodevals, y, fs, duration, giventags);
    visited(1) = 1; %mark the root node's children as generated
    
    % data collection stuff
    bestScoreList = zeros(1,size(iterationList,2));
    solutionNumList = zeros(1,size(iterationList,2));
    
    % initialization stuff
    iterationcount = 1;
    a = 1.0; % How much you look at the pheremones
    b = 0.6; % How much you look at the score
    evaporateFactor = 0.95; % How much the pheremones evaporate per ant
    topscore = -1;
    worstscore = -1;
    %for the pheremone update, we have to keep track of the best and
    %worst function. Only the best ant gets it's function updated
    scalingParameter = 0.5; % because that's what it was in the notes
    paths = ones(numberOfAnts, numberOfLevels) * -1; % each row is an ant, each column is a level
    bestAntsIndex = ones(1, numberOfAnts) * -1;
    numberOfSolutions = 1 + qgranularity;
    % p is the probability array
    p = zeros(1,qgranularity);
    f = 1; %for loop counter
    fBest = 1000;
    fTop = [0,0];

    for iterationmax=iterationList
        
        while(iterationcount < iterationmax)
           iteration = iterationcount %printing out and giving a different name

           if(iterationcount > explorationIterations)
               specialB = b;
           else
               specialB = 0;
           end

           %an ant starts looking for food starting from home
           ants(1, :) = ones(1, numberOfAnts);

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
                     visited(next) = 1;
                   end
                   ants(1, aid) = next;
                   paths(aid,levelId) = next; % save the path
               end     

           end
                      
           %evaporate pheromones
           nodes(:,3) = nodes(:,3) * evaporateFactor;

           % Find the best and worst score, where the best score is the one
           % with the lowest value
           topscore = min(nodes(ants,2));
           worstscore = max(nodes(ants,2));
           % Find where the best ants are
           bestAntsIndex = find(nodes(ants,2) == topscore);
           % Update the pheremones
           nodes(paths(bestAntsIndex,:),3) = nodes(paths(bestAntsIndex,:),3) + scalingParameter * worstscore / topscore;
           if(fBest > topscore)
               fBest = topscore;
               fTop = nodevals(paths(bestAntsIndex(1),end));
           end
           iterationcount = iterationcount + 1;
        end
        solutionNumList(f) = numberOfSolutions;
        bestScoreList(f) = fBest;
        f = f + 1;
    end
    fBest
    fTop
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
    opt = runVadBatchDirect( y, fs, duration, giventags, nodevals(childs) );
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
