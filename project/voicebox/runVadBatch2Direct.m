function [batchoptimality] = runVadBatchDirect(y, fs, duration, giventags, population)
    
    %vadsohn with default parameters on y, fs
    %other parameters should be passed in a matrix called pp, i think
    %I haven't tried that yet.
    batchoptimality = zeros(1, size(population,2), codistributor());
    parfor i=1:size(population,2)
        tags = vadsohn(y, fs, 'a', population(i));
        batchoptimality(i) = vadOptimality(tags, giventags, duration, 0);
    end
    batchoptimality = gather(batchoptimality);
end