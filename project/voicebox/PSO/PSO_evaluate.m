function [fitness,min_fitness,min_individual, count]=PSO_evaluate(position,k,N,D,L,var,x_max,fitness,y, fs, duration, giventags,Num_func,min_fitness, min_individual, count)
count = count + 1;
for i=1:N
    for j=1:var
        temp=position(i,(j-1)*L+1:j*L);
        X(j)=PSO_decode(temp,L,x_max) + 0.5; %#ok<AGROW>
    end
%     switch Num_func
%         case 1
%             result = sum (X.^2);
%         case 2
%             result = sum(abs(X)) + prod(abs(X)) ;
%         case 3
%             result = 0 ;
%             for ii=1:var
%                 result = result + sum(X(1:ii)).^2;
%             end
%         case 4
%             result = max (abs(X));
%         case 5
%             result = 0;
%             for ii=1:var-1
%                 result = result + 100*((X(ii+1)-X(ii)^2)^2+(X(ii)-1)^2);
%             end
%     end
    individual.of= floor(5 * X(1)) + 1; %I think this needs to be a whole number
    individual.pr=0.7;  
    individual.ts= duration/2 * X(2); 
    individual.tn= duration/2 * X(3);
    individual.ti=10e-3 + ((10e-2 - 10e-3) * X(4));   
    individual.ri=0;       
    individual.ta=0.396;    
    individual.gx=10 + ((1000 - 10)*X(5));
    individual.xn=1.995262 * X(6);
    tags = vadsohn(y, fs, 'a', individual);
    fitness(i,k) = vadOptimality(tags, giventags, duration, 0);
    if fitness(i, k) < min_fitness
        min_fitness = fitness(i, k);
        min_individual = individual;
        count = 0;
    end
end
return