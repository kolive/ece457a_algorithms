%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Owen Wang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [solutioncost, solution]=saTweaking(wavfilename, tagfilename)
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    % generate your initial solution
    solution = genInitialSolution();

    iteration = 0;
    iteration_max = 100;
    T_min = 1e-10;
    T_init = 1;
    T = T_init;
    alpha = 0.95;
    solutioncost = Inf;

    fig(1) = figure;
    fig(2) = figure;
    fig(3) = figure;

    while ((iteration < iteration_max) & (T > T_min))
        iteration = iteration + 1;

        % geometric cooling
        T = alpha * T;

        [optimalities] = runVadBatch(wavfilename,tagfilename, solution);
        %TODO: xn+1 = xn + randn
        %TODO: delta_f = fn+1(xn+1) - fn(xn)

        % accept new solution if it's better
        if (optimalities < solutioncost)
          solutioncost = optimalities;
        end

        %TODO: if not better
          %TODO: generate random r
          %TODO: accept if p=exp(-delta_f/T) > r

        %TODO: update best x and f

    end

    runvad(wavfilename, tagfilename, fig, solution);
end

