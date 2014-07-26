function [p] = calculateProbability_test(p, nchildren, curId, nodes, alpha, beta)
    x = 1;
   % iterating through the children of the node that the ant is
   % at, create the probability array
   for i=nchildren(curId, :)
       % equation taken from slides % could be vectorized... somehow..
       p(1,x) = (nodes(i, 3)^alpha) ... \\ % Pheremone component
           * ((1/nodes(i,1))^beta); % Inverse of length component (because of minimization)
       x = x + 1;
   end
   p = p ./ sum(p);
end