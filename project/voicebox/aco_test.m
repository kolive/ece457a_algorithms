function [success] = aco_test()
    % generate children
    granularity = 3;
    nodecount = 1;
    nchildren = ones(1,granularity);
    visited(nodecount) = 1; %because it isn't changed in the test 
    acc_nchildren = [2 3 4];
    acc_visited = [1 -1 -1 -1];
    acc_nodecount = 4;
    
    [nchildren, visited, nodecount] = generateChildren_test(nchildren, visited, nodecount, 1, granularity);
    
    children_pass = isequal(acc_nchildren, nchildren)
    visited_pass = isequal(acc_visited, visited)
    nodecount_pass = isequal(acc_nodecount, nodecount)
    
    % generate nodes
    nodes = [0 0 1];
    nodevals = [0 0];
    acc_nodes = [0 0 1;
                banana([-1/3 0]) banana([-1/3 0]) 1;
                banana([1/3 0]) banana([1/3 0]) 1;
                banana([1 0]) banana([1 0]) 1
        ];
    acc_nodevals = [0, 0;
                    -1/3, 0;
                    1/3, 0;
                    1, 0
          ];
    
    [nodes, nodevals] = generateNodes_test(1, 1, nodes, nchildren, nodevals);
    
    nodes_pass = all(all((abs(acc_nodes - nodes) < 0.0001)))
    nodevals_pass = all(all(abs(acc_nodevals - nodevals) < 0.0001))
    
    % generate probabilities
    res_p = zeros(1,3);
    nchildren = [2 3 4];
    curId = 1;
    nodes = [0 0 1;
            3 3 0.9;
            6 6 1.17;
            9 9 0.9
        ];
    alpha = 1;
    beta = 1;
    acc_p = [0.5042, 0.3277, 0.1681];
    
    res_p = calculateProbability_test(res_p, nchildren, curId, nodes, alpha, beta);
    
    probability_pass = all(all(abs(acc_p - res_p) < 0.0001))
    
    % TODO: pheremone update test
    
    success = children_pass && visited_pass && nodecount_pass && nodes_pass && nodevals_pass && probability_pass
end