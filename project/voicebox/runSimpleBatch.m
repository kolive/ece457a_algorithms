%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [batchoptimality] = runSimpleBatch(population)
    batchoptimality = zeros(1, size(population,2));
    for i=1:size(population,2)
        batchoptimality(i) = a3_funct_test(population(i));
    end
end