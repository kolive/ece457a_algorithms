% group and average
function [res]=gaav(m, nAvg)
    res=reshape(mean(reshape(m,nAvg,[])),nAvg,[]);
end