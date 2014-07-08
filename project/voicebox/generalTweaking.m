%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Yo Mama
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: create a new file for your own algorithm and rename it to be what your algorithm is
function [solutioncost, solution]=generalTweaking(wavfilename, tagfilename)
    fig(1) = figure;
    fig(2) = figure;
    fig(3) = figure;

    iterationmax = 100;

    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    % generate your initial solution
    solution = genInitialSolution();

    %TODO: add in end case scenario (for example, get lowest possible optimality). otherwise end when reach iterationmax
    iteration = 0;
    while(iteration < iterationmax)
        [optimalities] = runVadBatch(wavfilename,tagfilename, solution);

        %TODO: generate next solution through your algorithm

        iteration = iteration + 1;
        [solutioncost] = min(optimalities);
    end

    runvad(wavfilename, tagfilename, fig, solution);
end

