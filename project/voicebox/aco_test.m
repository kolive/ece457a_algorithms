function [success] = aco_test()
    % generate children
    acc_nchildren = [];
    nchildren = generateChildren_test()
    
    children_pass = isequal(acc_nchildren, n
    
    % generate nodes
    generateNodes_test()
    
    % generate probabilities
    res_p = zeros(1,3);
    nchildren = [2 3 4];
    curId = 1;
    nodes = [3 3 0.9;
            6 6 1.17;
            9 9 0.9
        ];
    beta = 1;
    
    res_p = calculateProbability_test(res_p, nchildren, curId, nodes, beta);
    
    propability_pass = isequal(accepted_p, res_p)
end