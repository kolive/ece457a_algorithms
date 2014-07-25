%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle. Maybe we should
%  make per-parameter granularity?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, solution]=acoSimple_sean(numberOfAnts, iterationmax, qgranularity)
 
    % because of the pheremone update, this algorithm won't work with
    % anything less than 2 ants
    numberOfLevels = 2;
    explorationIterations = 1; % the amount of time to not use beta for
    
    %we want to generate a graph where each level represents a design
    %variable
    
    %quantize the possible values of each variable
    
    %make the edge cost the difference in optimality between the previous
    %node and this one
    
    %what should the matrix look like?
    % initially all -1
    % when a node is visited, generate the children of that node and update
    % the indexes in graph
    % nodes(i,:) = [edgecost, solutioncost, pheremoneLevel] %edgecost and
    % solutioncost are the same thing now
    % nodevals(i,:) = parameters_to_plug_in
    % nchildren(i, :) = [quantization level cols with indexes to children]
    % visited(i, :) = [-1 if child nodes have been generated, 0 otherwise]
    % p = probability array for children
    
    %the first level is populated manually, contains of values
    % children for each of those nodes are initialized to -1
    %at each node, select one of the non-negative indexes to visit next
    %if that node has not been visited before, generate it's children
    %(check if a node has been visited by seeing if children(i,:) is not
    %-1's)
    
    %initialize root
    nodeCount = 1;
    levelId = 1;
    nest = runSimpleBatch([0 0]);
    nodes(nodeCount, :) = [0, nest, 1]; % note the pheremone level of the nest doesn't matter
    visited(nodeCount) = -1;
    nodevals(nodeCount, :) = [0 0];
    nchildren = ones(1,qgranularity);
    %generates the children identifiers, 5 for the first level since of is
    %whole numbers from 1 to 5
    [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, 1, qgranularity); 
    
    %we need to generate all the first layer of nodes
    [nodes, nodevals] = generateNodes(1, levelId, nodes, nchildren, nodevals);
    visited(1) = 1; %mark the root node's children as generated
    
    
    iterationcount = 1;
    a = 1.0; % How much you look at the pheremones
    b = 1.0; % How much you look at the score
    evaporateFactor = 0.9; % How much the pheremones evaporate per ant
    topscore = -1;
    worstscore = -1;
    top = ones(1,numberOfLevels) * 100;
    %for the pheremone update, we have to keep track of the best and
    %worst function. Only the best ant gets it's function updated
    scalingParameter = 0.5; % because that's what it was in the notes
    paths = ones(numberOfAnts, numberOfLevels) * -1; % each row is an ant, each column is a level
    bestAntsIndex = ones(1, numberOfAnts) * -1;
    % p is the probability array
    p = zeros(1,qgranularity);
    
    while(iterationcount < iterationmax)
       iteration = iterationcount %printing out and giving a different name
       
       if(iterationcount > explorationIterations)
           specialB = b;
       else
           specialB = 0;
       end
    
       %an ant starts looking for food starting from home
       %this array will hold where the ant currently is
       ants(1, :) = ones(1, numberOfAnts);
       
       %traverse the graph, one level per parameter
       for levelId=1:numberOfLevels
           aid = 0;
           for curId=ants
               aid = aid + 1;
               %select the next step based on ACO calculations
           
               %calculate the transition probability of each child
               p = calculateProbability_test(p, nchildren, curId, nodes, a, specialB);

               % Roulette wheel selection of next node to visit % replace with MATLAB
               % built-in function?
               for i=2:size(p,2)
                   p(1,i) = (p(1,i-1) + p(1,i));
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
                 [nchildren, visited, nodeCount] = generateChildren_test(nchildren, visited, nodeCount, next, qgranularity); 
                 %generates child nodes
                 [nodes, nodevals] = generateNodes_test(next, levelId, nodes, nchildren, nodevals);
                 visited(next) = 1;
               end
               ants(1, aid) = next;
               %levelId
               paths(aid,levelId) = next; % save the path
               ants
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
       
       iterationcount = iterationcount + 1;
    end
    
    top = nodevals(paths(bestAntsIndex(1),end),:)
    topscore = runSimpleBatch(top)
    topscore
    
end

function [nodes, nodevals] = generateNodes(parentId, levelId, nodes, nchildren, nodevals)
    x = 1;
    s = size(nchildren(parentId, :), 2);
    % This could probably be vectorized
    % For every child in this parent
    for i = nchildren(parentId, :)
        nodevals(i,:) = nodevals(parentId, :);
        
        %set the quantized value based on the parent and the levelId
        %should generate a value between -2 and +2
        nodevals(i,levelId) = -2 + (4/s)*x; %WTF, why not just use linspace?
        x = x + 1;
        
        opt = runSimpleBatch(nodevals(i, :));
        %cost = opt - nodes(parentId, 2); % This is the old way we used to
        %cost the edges
        cost = opt;
        %opt
        nodes(i, :) = [cost, opt, 1];
        
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
