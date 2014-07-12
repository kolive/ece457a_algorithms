%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, solution]=acoTweaking(wavfilename, tagfilename, qgranularity, figh, animate)
    
    if(nargin < 3)
        qgranularity = 5;
    end

    if(nargin < 4)
        figh(1) = figure;
        figh(2) = figure;
        figh(3) = figure;
    end

    iterationmax = 100;
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

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
    nodes(nodeCount, :) = [0, runVadBatch(wavfilename,tagfilename, nest), 1];
    visited(nodeCount) = -1;
    nodevals(nodeCount) = nest;
    nchildren(nodeCount, :) = [-1 -1 -1 -1 -1];

    
    %generates the children identifiers
    [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, 1, qgranularity); 
    
    %we need to generate all the first layer nodes (of)
    [nodes] = generateNodes(1, levelId, nodes, nchildren, nodevals, wavfilename, tagfilename, duration);
    visited(1) = 1; %mark the root node's children as generated
    
    iterationcount = 1;
    while(iterationcount < 2)
       %an ant starts looking for foooooooooood 
       curId = 1;
       
       %traverse the graph
       for levelId=1:1
           %select the next step based on ACO calculations
           next = 2;
           
           %if the next step hasn't yet been visited, generate it's children
           if(visited(next) == -1)
             %generates child nodes
             [nodes] = generateNodes(curId, levelId, nodes, nchildren, nodevals, wavfilename, tagfilename, duration);
             %generates the children identifiers
             [nchildren, visited, nodeCount] = generateChildren(nchildren, visited, nodeCount, next, qgranularity); 
           end
           
       end
       iterationcount = iterationcount + 1;
    end
    
    nodes
    nchildren
    visited
    nodeCount
    
end

function [nodes, nodevals] = generateNodes(parentId, levelId, nodes, nchildren, nodevals, wavfile, tagfile, duration)

    x = 1;
    s = size(nchildren(parentId, :), 2);
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
            nodevals(i).gx = 10 + ((1000 - 10)/s)*x
        elseif(levelId == 6)
            nodevals(i).xn = (1.995262/s)*x;
        end
            
        x = x + 1;
        
        opt = runVadBatch(wavfile,tagfile, nodevals(i));
        nodes(i, :) = [opt - nodes(parentId, 2), opt, 1];
        
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
