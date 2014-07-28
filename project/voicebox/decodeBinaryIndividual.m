%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [individual]=decodeBinaryIndividual(I, duration)
    vals = zeros(1, 6);
    
    %for every param
    for i=1:6
        %evaluate binary
        for n=1:30
            vals(i)=vals(i)+I(i*n)*2^(n-1);
        end
    end
    
    vals=vals/(2^30-1);
    
    individual.of= floor(5 * vals(1,1)) + 1; %I think this needs to be a whole number
    individual.pr=0.7;
    individual.ts= duration/2 * vals(1,2); 
    individual.tn= duration/2 * vals(1,3);
    individual.ti=10e-3 + ((10e-2 - 10e-3) * vals(1,4));   
    individual.ri=0;       
    individual.ta=0.396;    
    individual.gx=10 + ((1000 - 10)*vals(1,5));
    individual.xn=1.995262 * vals(1,6);
end