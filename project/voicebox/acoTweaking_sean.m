%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle. Maybe we should
%  make per-parameter granularity? Change the pheremone deposit (only best ant?) to
%  what's been shown in the slides.
%  Example usage: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, solution]=acoTweaking(wavfilename, tagfilename, qgranularity, figh, animate)
    
    if(nargin < 3)
        qgranularity = 10;
    end

    if(nargin < 4)
        figh(1) = figure;
        figh(2) = figure;
        figh(3) = figure;
    end
    
    iterationmax = 50;
    numberOfAnts = 10;
    numberOfLevels = 7;
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
    nchildren(nodeCount, :) = [-1 -1 -1 -1 -1];

    
    %generates the children identifiers, 5 for the first level since of is
    %whole numbers from 1 to 5
    [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, 1, 5); 
    
    %we need to generate all the first layer nodes (of)
    [nodes, nodevals] = generateNodes(1, levelId, nodes, nchildren, nodevals, y, fs, duration, giventags);
    visited(1) = 1; %mark the root node's children as generated
    
    iterationcount = 1;
    a = 1.0; % How much you look at the pheremones
    b = 0.6; % How much you look at the score
    evaporateFactor = 0.9; % How much the pheremones evaporate per ant
    topscore = 1000;
    %for the pheremone update, we have to keep track of the best and
    %worst function. Only the best ant gets it's function updated
    scalingParameter = 2; % because that's what it was in the notes
    paths = ones(numberOfAnts, numberOfLevels) * -1; % each row is an ant, each column is a level
    bestPath = ones(numberOfAnts, numberOfLevels) * -1;
    worstscore = 1000;
    bestAnt = -1;
    
    while(iterationcount < iterationmax)
       iteration = iterationcount %printing out and giving a different name
       topscore
       bestAnt = -1;
       
       if(iterationcount > 1)
           specialB = b;
       else
           specialB = 0;
       end
    
       %an ant starts looking for food starting from home
       ants(1, :) = ones(1, numberOfAnts)
       
       
       %traverse the graph, one level per parameter
       for levelId=1:numberOfLevels
           aid = 0;
           levelId
           for curId=ants
               aid = aid + 1;
               %select the next step based on ACO calculations
           
               %calculate the transition probability of each child
               x = 1;
               % p is the probability array
               p(1,:) = zeros(1,qgranularity);
               for i=nchildren(curId, :)
                   if(i ~= 0)
                       % equation take from slides
                       p(1,x) = (nodes(i, 3)^a) * ((1/nodes(i,1))^specialB);
                   else
                       p(1,x) = 0;
                   end
                   x = x + 1;
               end
               x = 1;
               psum = sum(p);
               for i=nchildren(curId, :)
                   if(i ~= 0)
                       p(1,x) = (p(1,x)/psum(1));
                   end
                   x = x + 1;
               end

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
                 visited(next) = 1;
               end
               ants(1, aid) = next;
               paths(aid,levelId) = next; % save the path
           end
           ants
           
           %evaporate pheromones
           for i=1:size(nodes,1)
               nodes(i,3) = nodes(i,3) * evaporateFactor;
           end
           
           for z=ants
               if(topscore > nodes(z, 2))
                   topscore = nodes(z, 2);
                   top = nodevals(z);
               elseif(worstscore < nodes(z,2))
                   worstscore = nodes(z, 2);
               end
           end
           
           % Update the pheremones % This iteration could totally be vectorized
           bestPath = paths(bestAnt,:);
           for antIndex=1:size(bestPath,1)
               % If it isn't an empty path
               if(bestPath(antIndex,1) > -1)
                   for node = bestPath(antIndex,:)
                       nodes(node,3) = scalingParameter * topscore / worstscore;
                   end
               end
               bestPath = ones(numberOfAnts, numberOfLevels) * -1;
           end
       end
       iterationcount = iterationcount + 1;
    end
    
    topscore
    runvadDirect(y, fs, duration,giventags, figh, top);
    
end

function [nodes, nodevals] = generateNodes(parentId, levelId, nodes, nchildren, nodevals, y, fs, duration, giventags)

    x = 1;
    s = size(nchildren(parentId, :), 2);
    maxopt = -1;
    for i = nchildren(parentId, :)
        nodevals(i) = nodevals(parentId);
        
        %set the quantized value based on the parent and the levelId
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
        
        opt = runVadBatchDirect(y, fs, duration, giventags, nodevals(i));
        cost = opt - nodes(parentId, 2);
        nodes(i, :) = [opt, opt, 1]; %normalize the cost to between 1 and 201
        
    end
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