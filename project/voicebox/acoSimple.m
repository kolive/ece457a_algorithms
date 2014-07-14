%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle. Maybe we should
%  make per-parameter granularity?
%  Example usage: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, solution]=acoTweaking( qgranularity)
 

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
    % nodes(i,:) = [edgecost, solutioncost, plevel]
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
    nodes(nodeCount, :) = [0, runSimpleBatch([-3; -3]), 1];
    visited(nodeCount) = -1;
    nodevals(nodeCount, :) = [-3; -3];
    nchildren(1, :) = [1];
    %generates the children identifiers, 5 for the first level since of is
    %whole numbers from 1 to 5
    [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, 1, qgranularity); 
    
    %we need to generate all the first layer nodes (of)
    [nodes, nodevals] = generateNodes(1, levelId, nodes, nchildren, nodevals);
    visited(1) = 1; %mark the root node's children as generated
    
    
    iterationcount = 1;
    a = 1.0; % How much you look at the pheremones
    b = 0.9; % How much you look at the score
    evaporateFactor = 0.9; % How much the pheremones evaporate per ant
    topscore = 1000;
    while(iterationcount < 3)
       iteration = iterationcount
       topscore
    
       %an ant starts looking for foooooooooood
       % lets hardcode 20 ants
       ants(1, :) = ones(1, 2);
       
       %traverse the graph, one level per parameter
       for levelId=1:2
           ac = 0;
           levelId
           for curId=ants
               ac = ac + 1;
               %select the next step based on ACO calculations
           
               %calculate the transition probability of each child
               x = 1;
               % p is the probability array
               p(1,:) = zeros(1,qgranularity);
               for i=nchildren(curId, :)
                   if(i ~= 0)
                       % equation take from slides
                       p(1,x) = (nodes(i, 3)^a) * ((1/nodes(i,1))^b);
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
                 [nodes, nodevals] = generateNodes(next, levelId+1, nodes, nchildren, nodevals);
                 visited(next) = 1;
               end
               ants(1, ac) = next;
               nodes(curId, 3) = nodes(curId, 3) + 0.1;
    [nodes nodevals]
    nchildren
    visited
           end
           ants;
           %evaporate pheromones
           for i=1:size(nodes,1)
               nodes(i,3) = nodes(i,3) * evaporateFactor;
           end

           if(topscore > nodes(curId, 2))
               topscore = nodes(curId, 2);
               top = nodevals(curId, :);
           end
       end
       iterationcount = iterationcount + 1;
       %reset pheromones
       for i=1:size(nodes,1)
           nodes(i,3) = 1;
       end
    end
    
    topscore
    top
    
end

function [nodes, nodevals] = generateNodes(parentId, levelId, nodes, nchildren, nodevals)
    x = 1;
    s = size(nchildren(parentId, :), 2);
    maxopt = -1;
    for i = nchildren(parentId, :)
        nodevals(i,:) = nodevals(parentId, :);
        
        %set the quantized value based on the parent and the levelId
        if(levelId == 1)
            nodevals(i,1) = -3 + (6/s)*x;
        elseif(levelId == 2)
            nodevals(i,2) = -3 + (6/s)*x;
        end
        x = x + 1;
        
        opt = runSimpleBatch(nodevals(i));
        %cost = opt - nodes(parentId, 2);
        cost = opt;
        nodes(i, :) = [cost, opt, 1]; %normalize the cost to between 1 and 33
        
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
