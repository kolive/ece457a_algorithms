%Function to optimize
function [res] = a3_funct_test(x)    
res = 0;
x
    for i = 1:size(x)
        res = res + (x(i)+i)^2;
    end
end