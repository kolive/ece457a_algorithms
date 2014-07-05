%Function to optimize
function [res] = a3_funct(x)    
res = 0;
    for i = 1:size(x,1)
        res = res + abs(x(i))^(i+1);
    end
end