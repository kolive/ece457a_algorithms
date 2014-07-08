%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Yo Mama
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [solutioncost, solution]=saTweaking(wavfilename, tagfilename)
    iterationmax = 100;

    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    %TODO: generate your initial solution
    %solution = ??? (see generateRandomIndividual.m for example)

    %TODO: add in converging end case. otherwise end when reach iterationmax
    iteration = 0;
    while(iteration < iterationmax)
        [fitnesses] = runVadBatch(wavfilename,tagfilename, solution);

        %TODO: generate next solution

        iteration = iteration + 1
    end

    [solutioncost] = max(fitnesses);
    runvad(wavfilename, tagfilename, solution);
end

