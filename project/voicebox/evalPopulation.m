%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [optimalities]=evalPopulation(I, y, fs, giventags, duration)
    optimalities = ones(1, size(I,1));
    pp = [];
    for i=1:size(I,1)
        pp = [pp decodeBinaryIndividual(I(i, :), duration)];
    end
    optimalities = runVadBatchDirect(y, fs, duration, giventags, pp);
end