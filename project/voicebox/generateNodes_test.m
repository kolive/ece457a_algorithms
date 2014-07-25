function [nodes, nodevals] = generateNodes_test(parentId, levelId, nodes, nchildren, nodevals)
    x = 1;
    s = size(nchildren(parentId, :), 2);
    % This could probably be vectorized
    for i = nchildren(parentId, :)
        nodevals(i,:) = nodevals(parentId, :);
        
        %set the quantized value based on the parent and the levelId
        %should generate a value between -1 and +1
        nodevals(i,levelId) = -1 + (2/s)*x; %WTF, why not just use linspace?
        x = x + 1;
        
        opt = runSimpleBatch(nodevals(i, :));
        %cost = opt - nodes(parentId, 2); % This is the old way we used to
        %cost the edges
        cost = opt;
        %opt
        nodes(i, :) = [cost, opt, 1];
        
    end
end