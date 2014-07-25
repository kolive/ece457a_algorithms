function [ results, average, bestsol ] = averageGeneticTweaking( wavfilename, tagfilename, params, count )
    [y, fs] = wavread(wavfilename);
        
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);    
    results = [];
    duration = size(y,1)/fs;
    
    for i=1:count
       [sc, sol] = geneticTweakingDirect(y, fs, giventags, params.iterationmax, params.popsize, params.a, params.mrate);
       results = [results runVadBatchDirect(y, fs, duration, giventags, sol)];
       if(results(i) == min(results)) bestsol = sol;
    end
    
    average = mean(results); 

end