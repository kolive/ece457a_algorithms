%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Her Mama
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: create a new file for your own algorithm and rename it to be what your algorithm is
function [solutioncost, solution]=generalTweaking(wavfilename, tagfilename)
    iterationmax = 100;

    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    % generate your initial solution (default sol'n)
    solution = genInitialSolution();

    %TODO: add in end case scenario (for example, get lowest possible optimality). otherwise end when reach iterationmax
    % want lowest optimality value for Tabu Search
    iteration = 0;
    while(iteration < iterationmax)
        [optimality] = runVadBatch(wavfilename, tagfilename, solution);

        %TODO: generate next solution through your algorithm

        iteration = iteration + 1;
    end

    [solutioncost] = max(optimality);
    runvad(wavfilename, tagfilename, solution);
end

