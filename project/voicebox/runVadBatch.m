%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [batchoptimality] = runVadBatch(wavfilename, tagfilename, population)
    %reads the wav file, stores the data in y
    %fs is the sampling frequency, you need to pass the correct frequency
    %to vahdson
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);
    
    %vadsohn with default parameters on y, fs
    %other parameters should be passed in a matrix called pp, i think
    %I haven't tried that yet.
    batchoptimality = zeros(1, size(population,2));
    parfor i=1:size(population,2)
        tags = vadsohn(y, fs, 'a', population(i));
        batchoptimality(i) = vadOptimality(tags, giventags, duration, 0);
    end
end