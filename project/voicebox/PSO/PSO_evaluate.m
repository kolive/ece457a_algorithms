function [fitness,min_fitness,min_individual, count]=PSO_evaluate(position,k,N,D,L,var,x_max,fitness,y, fs, duration, giventags,Num_func,min_fitness, min_individual, count, plotenable, figh, iteration)
count = count + 1;
iteration = N * iteration;
giventags = [giventags; 1.1];
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
    tags = [vadsohn(y, fs, 'a', individual); 1.1];
    if (mod(iteration, 50) == 0)

    end
    
    fitness(i,k) = vadOptimality(tags, giventags, duration, plotenable, figh, iteration);
    if fitness(i, k) < min_fitness
        min_fitness = fitness(i, k)
        min_individual = individual;
        count = 0;
        
                x1 = linspace(0, duration, size(tags,1));
        x1 = x1';


        x2 = linspace(0, duration, size(giventags,1));
        x2 = x2';

        %plot the two waveforms for comparison
        figure(figh(1));
        s(1) = subplot(3,1,3);
        plot(s(1), x1, tags);
        xlabel('Time (s)');
        ylabel('Tag Value');
        s(2) = subplot(3,1,2);
        plot(s(2), x2, giventags);
        title('Results of Vadsohn Analysis (bottom) vs. Given Tags (top)');
        xlabel('Time (s)');
        ylabel('Tag Value');
        s(3) = subplot(3,1,1);
        t=0:1/fs:(length(y)-1)/fs; %get the duration for plotting
        plot(s(3), t, y);
        title('Actual speech waveform');
        xlabel('Time (s)');

        saveas(figh(1), strcat('1Generation-', int2str(iteration), '.png'),'png');  
        
    end
    iteration = iteration + 1;
end
return