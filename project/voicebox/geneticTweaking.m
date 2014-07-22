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
function [solutioncost, solution]=geneticTweaking(wavfilename, tagfilename, figh, animate)
    
    if(nargin < 3)
        figh(1) = figure;
        figh(2) = figure;
        figh(3) = figure;
    end

    iterationmax = 100;
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);

    %generate initial population, literature suggests an initial size of 50
    %because we have so many parameters, we may want a higher initial size,
    %but i'll try 50 for now
    % generate initial population
    %TODO: learn how to init struct arrays in matlab
    for i=1:200
        population(i) = generateRandomIndividual(duration);
    end

    iteration = 0;
    pbestfitness = 0;
    convergecount = 200;
    while(iteration < iterationmax && convergecount > 0)
        [fitnesses] = runVadBatchDirect(y, fs, duration,giventags, population);
        %transform fitnesses into maximization by taking inverse
        %may want to use the equation on lecture 11 slide 22 instead of this
        %fitnesses = (1./(1+fitnesses)) * 1000;
        fitnesses = 1./(1+fitnesses);
        fitsum = sum(fitnesses);
        %fitnesses = 2 - ((fitnesses*size(fitnesses,2))/fitsum);
        mostfit = max(fitnesses)
        
        
        
        if(max(fitnesses) == pbestfitness)
            convergecount = convergecount - 1
        else
            convergecount = 200;
        end
        
        %select mating pool by fitness proportional selection - stochastic
        %sampling
        [selectedpop, rindex] = populationSelection(population, fitnesses, 100);

        %generate children
        [children] = generateChildren(selectedpop);

        indices = linspace(1, size(population,2), size(population,2));
        eligible = setdiff(indices, rindex);
        for i=1:size(rindex, 2)
            %replace the 26 random elements that werent parents
            ri = eligible(randi(size(eligible,2)));
            eligible = setdiff(eligible, ri);
            
            %replace the parents
            %this is bad because we kill the strong genes
            %ri = rindex(i);
            population(ri) = children(i);
        end
        
        [pbestfitness, si] = max(fitnesses)
        solution = population(si);
        
        iteration = iteration + 1
        
        if(animate == 1)
            runvadDirect(y, fs, duration, giventags, figh, solution,iteration);
        end
    end
    
    [figh, duration, solutioncost, breakdown, nad] =  runvadDirect(y, fs, duration, giventags, figh, solution, iteration);
end

%stochastic sampling
function [selectedpop, rindex]=populationSelection(population, fitnesses, count)
    selectedpop = [];
    %generate probability of selection by total fitness
    totalfit = sum(fitnesses);

    pindex = linspace(1, size(population,2), size(population,2));
    scoredpop = [pindex; fitnesses; fitnesses/totalfit];
    
    for i=2:size(scoredpop,2)
        scoredpop(3,i) = scoredpop(3,i-1) + scoredpop(3,i);
    end

    %select population which gets to get laid
    
    %roulette wheel selection
    %Expected cons: because the differences in optimality aren't super
    %huge, bad solutions get a higher chance of being selected.
    %for y=1:count
    %    pr = rand;
    %    for i=1:size(scoredpop,2)
    %        if(i == 1 && (pr < scoredpop(3,1)))
    %            selectedpop = [selectedpop population(i)];
    %            rindex(y) = i;
    %        end
    %        if(i > 1 && pr > scoredpop(3,i - 1) && pr < scoredpop(3,i))
    %            selectedpop = [selectedpop population(i)];
    %            rindex(y) = i;
    %        end
    %    end
    %end
    
    
    %fitness ranking
    % this might limit the gene pool, but we have a fairly high mutation
    % rate
    
    [sortedlist, sindex] = sort(fitnesses, 2);
    for y=1:count
        i = sindex(size(fitnesses, 2) - y + 1);
        selectedpop = [selectedpop population(i)];
        rindex(y) = i;
    end
end

function [pchildren] = generateChildren(population)
    % for each parent, select a random parent and remove both of them from
    % the list of eligible bachelors
    eligible = linspace(1, size(population,2), size(population,2));
    pchildren = [];
    for i=1:(size(population,2)/2)
        p1 = randi(size(eligible,2));
        eligible = setdiff(eligible, p1);
        p2 = randi(size(population,2));
        eligible = setdiff(eligible, p2);

        % perform crossover and mutation to create two new children
        [child1, child2] = crossover(population(p1), population(p2));
        pchildren = [pchildren child1 child2];
    end
end

%TODO:
function [child] = mutate(child, mrate)
    % generate rand number, if number < mrate, mutate the child
    if (rand < mrate)
       % child.of = max(floor(child.of + (randi(-1,1)*rand*(5-child.of))), 1);
       child.ts = child.ts + ((rand - rand) * child.ts);
       child.tn = child.tn + ((rand - rand) * child.tn);
       child.ti = child.ti + ((rand - rand) * child.ti);
       child.gx = child.gx + ((rand - rand) * child.gx);
       child.xn = child.xn + ((rand - rand) * child.xn);
    end
end

%TODO: Need to figure out how to do crossovers well
function [child1, child2] = crossover(p1, p2)
    a = 0.5;
    %child1.of= 1 + floor(a*p1.of + (1-a)*p2.of); %I think this needs to be a whole number
    %child2.of= 1 + floor((1-a)*p1.of + (a)*p2.of); %I think this needs to be a whole number
    child1.of = floor((p1.of + p2.of)/2);
    child2.of = ceil((p1.of + p2.of)/2);
    
    child1.pr=0.7;
    child2.pr=0.7;

    a = 0.8;
    child1.ts= a*p1.ts + (1-a)*p2.ts;
    child2.ts= (1-a)*p1.ts + (a)*p2.ts;

    a = 0.8;
    child1.tn= a*p1.tn + (1-a)*p2.tn;
    child2.tn= (1-a)*p1.tn + (a)*p2.tn;

    a = 0.8;
    child1.ti= a*p1.ti + (1-a)*p2.ti;
    child2.ti= (1-a)*p1.ti + (a)*p2.ti;

    child1.ri=0;
    child2.ri=0;

    child1.ta=0.396;
    child2.ta=0.396;

    a = 0.8;
    child1.gx= a*p1.gx + (1-a)*p2.gx;
    child2.gx= (1-a)*p1.gx + (a)*p2.gx;

    a = 0.8;
    child1.xn= a*p1.xn + (1-a)*p2.xn;
    child2.xn= (1-a)*p1.xn + (a)*p2.xn;

    [child1]=mutate(child1, 1/8);
    [child2]=mutate(child2, 1/8);
end
