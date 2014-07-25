%Function to optimize, should have minimum at (1,1)
function [res] = banana(x)    
	res = (1-x(1))^2+100*(x(2)-x(1)^2)^2
end