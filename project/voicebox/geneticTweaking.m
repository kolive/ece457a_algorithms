function [solutioncost, solution]= geneticTweaking(wavfilename, tagfilename, iterationmax, popsize, a, mrate)
    [y, fs] = wavread(wavfilename);
        
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);
    
    [solutioncost, solution] = geneticTweakingDirect(y, fs, giventags, iterationmax, popsize, a, mrate)
end