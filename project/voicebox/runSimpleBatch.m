%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [batchoptimality] = runSimpleBatch(population)
    batchoptimality = zeros(1, size(population,1), codistributor());
    parfor i=1:size(population,1)
        %batchoptimality(i) = a3_funct_test(population(i, :)); %vetoed for
        %a more predictable function
        batchoptimality(i) = banana(population(i, :));
    end
    batchoptimality = gather(batchoptimality);
end