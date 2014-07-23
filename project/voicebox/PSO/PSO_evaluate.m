function [fitness,min_fitness,min_individual, count]=PSO_evaluate(position,k,N,D,L,var,x_max,fitness,y, fs, duration, giventags,Num_func,min_fitness, min_individual, count, plotenable, figh, iteration)
count = count + 1;

%tags = zeroes(N);
%individual = zeroes(N);
%X = zeroes(N,var);
for i=1:N
    for j=1:var
        temp=position(i,(j-1)*L+1:j*L);
        X(i,j)=PSO_decode(temp,L,x_max) + 0.5; 
    end
end
parfor i=1:N
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
    individual(i).of= floor(5 * X(i,1)) + 1; %I think this needs to be a whole number
    individual(i).pr=0.7;
    individual(i).ts= duration/2 * X(i,2); 
    individual(i).tn= duration/2 * X(i,3);
    individual(i).ti=10e-3 + ((10e-2 - 10e-3) * X(i,4));   
    individual(i).ri=0;       
    individual(i).ta=0.396;    
    individual(i).gx=10 + ((1000 - 10)*X(i,5));
    individual(i).xn=1.995262 * X(i,6);
    tags(i) = vadsohn(y, fs, 'a', individual(i));
    
    fitness(i,k) = vadOptimality2(tags(i), giventags);
end

for i=1:N
    if fitness(i, k) < min_fitness
        gt = [giventags; 1.1];
        ct = [tags(i); 1.1];
        min_fitness = fitness(i, k);
        min_individual = individual(i);
        count = 0;
        
        x1 = linspace(0, duration, size(ct,1));
        x1 = x1';


        x2 = linspace(0, duration, size(gt,1));
        x2 = x2';

        %plot the two waveforms for comparison
        figure(figh);
        s(1) = subplot(3,1,3);
        plot(s(1), x1, ct);
        xlabel('Time (s)');
        ylabel('Tag Value');
        s(2) = subplot(3,1,2);
        plot(s(2), x2, gt);
        title('Results of Vadsohn Analysis (bottom) vs. Given Tags (top)');
        xlabel('Time (s)');
        ylabel('Tag Value');
        s(3) = subplot(3,1,1);
        t=0:1/fs:(length(y)-1)/fs; %get the duration for plotting
        plot(s(3), t, y);
        title('Actual speech waveform');
        xlabel('Time (s)');

        %saveas(figh, strcat('1Generation-', int2str(iteration), '.png'),'png');  
        
    end
end
return