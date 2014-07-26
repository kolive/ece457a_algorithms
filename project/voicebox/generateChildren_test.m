function [nchildren, visited, nodeCount] = generateChildren_test(nchildren, visited, startId, nodeId, qgranularity)
    x = 1;
    for i=(startId+1):(startId+qgranularity)
        nchildren(nodeId, x) = i;
        visited(i) = -1;
        x = x + 1;
        nodeCount = i;
    end
end

% Trying to be clever
%function [nchildren, visited, nodeCount] = generateChildren_test(nchildren, visited, startId, nodeId, qgranularity)
%    x = 1;
%    s = (startId+1):(startId+qgranularity);
%    nchildren(nodeId,
%    for i=s
%        nchildren(nodeId, x) = i;
%        x = x + 1;      
%    end
%    visited(s) = ones(size(s),2) * -1;
%    nodeCount = startId+qgranularity;
%end