function [ results, average, bestsol ] = averageTabuTweaking(wavfilename, tagfilename, granularity, iterationmax, adaptivecount, stoppingcriteria, count)
   [y, fs] = wavread(wavfilename);
        
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);    
    results = [];
    duration = size(y,1)/fs;
    results = [];
  
    
    for i=1:count
       [sc, sol] = tabuTweaking(wavfilename, tagfilename, granularity, iterationmax, adaptivecount, stoppingcriteria);
       results = [results runVadBatchDirect(y, fs, duration, giventags, sol)];
       if(results(i) == min(results)) bestsol = sol;
    end
    
    average = mean(results); 

end