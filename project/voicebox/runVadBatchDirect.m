%%%%%%%
%  Author: Kyle
%
%	runVadBatchDirect takes the following parameters:
%
%		y - the WAV audio file data
%		fs - the sampling frequency of the WAV file
%		duration - the length of the audio clip
%		giventags - the ground truth
%		population - the set of solutions to evaluate, can be of size 1..N
%
%		RunVadBatchDirect then runs the evaluation and optimality calculations
%		in parallel. The user is responsible for settingup the matlabpool. 
%
%		Returns the optimalities of the clients. 
%
%%%%%%%
function [batchoptimality] = runVadBatchDirect(y, fs, duration, giventags, population)
    
    %vadsohn with default parameters on y, fs
    %other parameters should be passed in a matrix called pp, i think
    %I haven't tried that yet.
    batchoptimality = zeros(1, size(population,2), codistributor());
    parfor i=1:size(population,2)
        tags = vadsohn(y, fs, 'a', population(i));
        batchoptimality(i) = vadOptimality2(tags, giventags);
    end
    batchoptimality = gather(batchoptimality);
end