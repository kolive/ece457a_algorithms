%Function to optimize, should have minimum at (0,0)
function [res] = egg(x)    
	res = x(1)^2+x(2)^2+25*(sin(x(1)).^2+sin(x(2)).^2
end