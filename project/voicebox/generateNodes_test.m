function [nodes, nodevals] = generateNodes_test(parentId, levelId, nodes, nchildren, nodevals)
    childs = nchildren(parentId, :);
    s = size(childs, 2);
    nodevals = [nodevals; zeros(s,2)]; % change 2 to 1 for real stuff
    %There's no way around this for loops, beause for the real application
    %we are using structs and there's no clever way to assign those
    %and there's no way to make it parallel either because of the way it's
    %iterating
    % would linspace make a difference here?
    x = 1;
    for i = childs
        nodevals(i,:) = nodevals(parentId, :);
        %should generate a value between -1 and +1
        nodevals(i,levelId) = -1 + (2/s)*x; %WTF, why not just use linspace?
        x = x + 1;
    end
    
    opt = runSimpleBatch(nodevals(childs, :));
    nodes(childs, :) = [opt', opt', ones(s,1)];
end