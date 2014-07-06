%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%
%   TODOS: Right now, this does stuff, but never seems to be able to
%   generate a child better than in the original random population.
%   
%   Some work needs to be done to find out why
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, solution]=geneticTweaking(wavfilename, tagfilename)
    iterationmax = 100;
    % generate initial population
    %TODO: learn how to init struct arrays in matlab
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %generate initial population, literature suggests an initial size of 50
    %because we have so many parameters, we may want a higher initial size,
    %but i'll try 50 for now
    for i=1:50
        population(i) = generateRandomIndividual(duration);
    end
    
    iteration = 0;
    pbestfitness = 0;
    convergecount = 4;
    while(iteration < iterationmax && convergecount > 0)
        [fitnesses] = runVadBatch(wavfilename,tagfilename, population);

        %transform fitnesses into maximization by taking inverse
        %may want to use the equation on lecture 11 slide 22 instead of this
        fitnesses = (1./(1+fitnesses)) * 1000;

        if(max(fitnesses) == pbestfitness)
            convergecount = convergecount - 1
        else
            convergecount = 4;
        end
        pbestfitness = max(fitnesses) %hopefully this number goes up
       
        
        %select mating pool by fitness proportional selection - stochastic
        %sampling
        % lets try to use GA (steady state works too, just replace 50 with
        % something < 50
        [selectedpop, rindex] = stochasticSamplingSelection(population, fitnesses, 50);

        %generate children
        [population] = generateChildren(selectedpop);

        %replace 50 random people who aren't parents with the new children
        % TODO: use another replacement algorithms
        % USED FOR Steady State
       % indices = linspace(1, size(population,2), size(population,2));
       % eligible = setdiff(indices, rindex);
       % for i=1:size(rindex, 2)
       %     ri = randi(size(eligible,2));
       %     eligible = setdiff(eligible, ri); 
       %     population(ri) = children(i);
       % end
        
        iteration = iteration + 1
    end
    
    [solutioncost, si] = max(fitnesses);
    solution = population(si);
    runvad(wavfilename, tagfilename, solution);
end

%stochastic sampling
function [selectedpop, rindex]=stochasticSamplingSelection(population, fitnesses, count)
    selectedpop = [];
    %generate probability of selection by total fitness
    totalfit = sum(fitnesses);
    
    pindex = linspace(1, size(population,2), size(population,2));
    scoredpop = [pindex; fitnesses];
    
    dselectors = totalfit / count;
    rv = rand * dselectors;
    rselectors = zeros(1, count);
    for i=1:count
        rselectors(i) = rv + (i-1) * dselectors;
    end
    
    %select population which gets to get laid
    x = 1;
    for i=1:size(scoredpop,2)
       fitnessum = sum(scoredpop(2,1:i));
       if(x < 16 && fitnessum > rselectors(x))
           selectedpop = [selectedpop population(scoredpop(1,i))];
           rindex(x) = scoredpop(1,i);
           x = x + 1;
       end
    end
end

function [pchildren] = generateChildren(population)
    % for each parent, select a random parent and remove both of them from
    % the list of eligible bachelors
    eligible = linspace(1, size(population,2), size(population,2));
    pchildren = [];
    for i=1:(size(population,2)/2 + 1)
        p1 = randi(size(eligible,2));
        eligible = setdiff(eligible, p1); 
        p2 = randi(size(population,2));
        eligible = setdiff(eligible, p2);
        
        % perform crossover and mutation to create two new children
        [child1, child2] = crossover(population(p1), population(p2));
        pchildren = [pchildren child1 child2];
    end
    
end

%TODO: I think there's a bug here which is creating children that all suck
%way worse than their parents.
%I need to look into this
function [child1, child2] = crossover(p1, p2)
    a = rand;
    child1.of= 1 + floor(a*p1.of + (1-a)*p2.of); %I think this needs to be a whole number
    child2.of= 1 + floor((1-a)*p1.of + (a)*p2.of); %I think this needs to be a whole number
   
    child1.pr=0.7; 
    child2.pr=0.7;
    
    a = rand;
    child1.ts= a*p1.ts + (1-a)*p2.ts; 
    child2.ts= (1-a)*p1.ts + (a)*p2.ts; 
    
    a = rand;
    child1.tn= a*p1.tn + (1-a)*p2.tn; 
    child2.tn= (1-a)*p1.tn + (a)*p2.tn;
    
    a = rand;
    child1.ti= a*p1.ti + (1-a)*p2.ti; 
    child2.ti= (1-a)*p1.ti + (a)*p2.ti;
    
    child1.ri=0;   
    child2.ri=0;
    
    child1.ta=0.396; 
    child2.ta=0.396; 
    
    a = rand;
    child1.gx= a*p1.gx + (1-a)*p2.gx; 
    child2.gx= (1-a)*p1.gx + (a)*p2.gx;
    
    a = rand;
    child1.xn= a*p1.xn + (1-a)*p2.xn; 
    child2.xn= (1-a)*p1.xn + (a)*p2.xn;
    

end