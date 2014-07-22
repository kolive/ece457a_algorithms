%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Michael Thiessen
%  Date: Sometime after this joke stopped being funny
%  Comments: If you don't know what this does... look within yourself and
%  find the answers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function optimality=vadOptimality2(vtags, rtags)
    vsize = size(vtags,1);
    rsize = size(rtags,1);

    %resolution factor, e.g., how many vad tags per real tag?
    rfactor = vsize/rsize;
    errorcount = 0;
    for j=1:rsize,
       vindex = floor(j*rfactor);
       errorcount = errorcount + bitxor(rtags(j), vtags(vindex), 'int8');
    end
    
    optimality = (errorcount/rsize) * 100; % normalized optimality
end
