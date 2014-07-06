function [solutioncost, solution]=geneticTweaking(wavfilename, tagfilename)
    
    % generate initial population
    %TODO: learn how to init struct arrays in matlab
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %generate initial population, literature suggests an initial size of 50
    %because we have so many parameters, we may want a higher initial size,
    %but i'll try 50 for now
    for i=1:50
        population(i) = generateRandomIndividual(duration);
    end
    [fitnesses] = runVadBatch(wavfilename,tagfilename, population);
    [solutioncost, si] = min(fitnesses);
    solution = population(si);
    runvad(wavfilename, tagfilename, solution);
end