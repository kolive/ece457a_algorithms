%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Owen Wang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [solutioncost, solution]=saTweaking(wavfilename, tagfilename)
    iterationmax = 100;

    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    % generate your initial solution
    solution = genInitialSolution();

    iteration = 0;
    % TODO: set T
    T = 100;

    while(iteration < iterationmax && T > 0)
        [optimalities] = runVadBatch(wavfilename,tagfilename, solution);
        %TODO: xn+1 = xn + randn
        %TODO: delta_f = fn+1(xn+1) - fn(xn)
        %TODO: accept new solution if it's better
        %TODO: if not better
          %TODO: generate random r
          %TODO: accept if p=exp(-delta_f/T) > r

        %TODO: update best x and f

        iteration = iteration + 1;
    end

    [solutioncost] = max(fitnesses);
    runvad(wavfilename, tagfilename, solution);
end

