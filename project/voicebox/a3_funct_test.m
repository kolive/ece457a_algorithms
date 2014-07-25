%Function to optimize: (x+1)^2+(y+2)^2, should have minimum at -1 and -2, as
%well at other places
function [res] = a3_funct_test(x)    
res = 0;
%x
    for i = 1:size(x)
        res = res + (x(i)+i)^2;
    end
end