%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  
%	The genetic tweaking algorithm for VADSohn takes the following parameters:
%	wavfilename - The WAV file name used for tuning
%	tagfilename - The tag file name used for tuning as the ground truth
%	iterationmax - the maximum number of iterations to run the genetic 
%		algorithm
%	popsize - the size of the population in the genetic algorithm
%	a - alpha, the crossover factor, value between 0 and 1, dictates the 
%		probability of uniform crossover
%	mrate - value between 0 and 1, dictates the probability of child mutation 
%		after crossover
%	adaptiverate - either -1 or between 0 and 1, if -1 algorithm runs in normal 
%		mode, if between 0 and 1, the adaptive rate is as the linear mrate 
%		modifier
%	stopcriteria - a value that can be passed to limit the number of fitness 
%		evaluations. Pass popsize*iterationmax to prevent early termination due
%		to this criteria.
%
%	It then runs a genetic or adaptive genetic algorithm, and returns the optimality
%	of the best solution found and the solutionitself, as discussed in the 
%	report submitted with this code. it also returns the iterations before returning:
%	[solutioncost, iterationcount, solution]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, iterationcount, solution ]= geneticTweaking(wavfilename, tagfilename, iterationmax, popsize, a, mrate, adaptiverate, stopcriteria)
    [y, fs] = wavread(wavfilename);
        
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);
    
    [solutioncost, iterationcount, solution] = geneticTweakingDirect(y, fs, giventags, iterationmax, popsize, a, mrate,adaptiverate, stopcriteria) 
end