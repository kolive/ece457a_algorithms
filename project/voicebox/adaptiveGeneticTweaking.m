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
function [solutioncosts, solutions]=adaptiveGeneticTweaking(wavfilename, tagfilename, iterationmax, popsize, a, mrate)
    
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);

    %generate initial population, literature suggests an initial size of 50
    %because we have so many parameters, we may want a higher initial size,
    %but i'll try 50 for now
    % generate initial population
    for i=1:popsize
        population(i) = generateRandomParameterSet();
    end
    
    iteration = 0;
    pbestfitness = 0;

    %we say we've converged if there's been no change in the optimal for
    %20% of the max iterations
    maxconvergecount = 0.2*iterationmax;
    convergecount = maxconvergecount;
    
    [fitnesses] = runGeneticTweakingBatch(y, fs, giventags, population);
    %we will have our stopping criteria be a parameter set that is 80%
    %better than the initial best
    stoppingGoal = 0.2*min(fitnesses); %output for user
    bestgoal = (1/(1+0.2*min(fitnesses))); 
    fitnesses = 1./(1+fitnesses);
    
    %30% of population should mate
    csize = ceil(popsize/3);
    if(mod(csize, 2) ~= 0)
        csize = csize + 1;
    end
    
    mostfit = 0;
    solutions = [];
    solutioncosts = [];
    while(iteration < iterationmax && convergecount > 0 && max(fitnesses) < bestgoal)
        if(mostfit == pbestfitness)
            convergecount = convergecount - 1;
        else
            convergecount = maxconvergecount;
        end
        
        %transform fitnesses into maximization by taking inverse
        %may want to use the equation on lecture 11 slide 22 instead of this
        fitsum = sum(fitnesses);
        mostfit = max(fitnesses);
             
        %select mating pool by fitness rank
        %select ~30% of the population to mate
        [selectedpop, rindex] = populationSelection(population, fitnesses, csize);

        %generate children
        [children] = generateChildren(selectedpop,a, mrate);
        cfitnesses = runGeneticTweakingBatch(y, fs, giventags, children);
        cfitnesses = 1./(1+cfitnesses);

        indices = linspace(1, size(population,2), size(population,2));
        eligible = setdiff(indices, rindex);
        for i=1:size(rindex, 2)
            %replace the 50% of population random elements that werent parents
            ri = eligible(randi(size(eligible,2)));
            eligible = setdiff(eligible, ri);
            
            %replace the parents
            %this is bad because we kill the strong genes
            %ri = rindex(i);
            population(ri) = children(i);
            fitnesses(ri) = cfitnesses(i);
        end
        
        
        iteration = iteration + 1
        [pbestfitness, si] = max(fitnesses)
        solution = population(si);
        
        solutions = [solutions solution];
        solutioncosts = [solutioncosts pbestfitness];
        
     
    end
    
    %change to run vad direct for graph
    solutions = [solutions solution];
    [solutioncost] =  runGeneticTweakingBatch(y, fs, giventags, solution);
    solutioncosts = [solutioncosts solutioncost];
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

function [pchildren] = generateChildren(population,a, mrate)
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
        [child1, child2] = crossover(population(p1), population(p2),a, mrate);
        pchildren = [pchildren child1 child2];
    end

end

%TODO:
function [child] = mutate(child, mrate)
    % generate rand number, if number < mrate, mutate the child
    if (rand < mrate)
       child.popsize = floor(child.popsize + ((rand - rand) * child.popsize));
       child.a = child.a + ((rand - rand) * child.a);
       child.iterationmax = ceil(child.iterationmax + ((rand - rand) * child.iterationmax));
       child.mrate = child.mrate + ((rand - rand) * child.mrate);
    end
end

function [child1, child2] = crossover(p1, p2, a, mrate)
    
    child1.popsize = floor((p1.popsize * a) + (p2.popsize * (1-a)));
    child2.popsize = ceil((p2.popsize * a) + (p1.popsize * (1-a)));
    
    child1.a = (p1.a * a) + (p2.a * (1-a));
    child2.a = (p2.a * a) + (p1.a * (1-a));
    
    child1.iterationmax = ceil((p1.iterationmax * a) + (p2.iterationmax * (1-a)));
    child2.iterationmax = floor((p2.iterationmax * a) + (p1.iterationmax * (1-a)));
    
    child1.mrate = (p1.mrate * a) + (p2.mrate * (1-a));
    child2.mrate = (p2.mrate * a) + (p1.mrate * (1-a));
    
    
    [child1]=mutate(child1, mrate);
    [child2]=mutate(child2, mrate);
end


function [individual] =  generateRandomParameterSet()
    individual.popsize = floor(10 + (150 * rand)); %population between 10 and 160
    individual.a = min(1, 0.01 + rand); %coefficient of crossover between 0.01 and 1
    individual.iterationmax = ceil(50 + (500 * rand)); %max iterations between 50 and 550
    
    individual.mrate = individual.popsize - ((individual.popsize-8)*rand); 
    individual.mrate = 1/individual.mrate; %mrate between 1/8 and 1/individual.popsize
    
end

function [batchoptimality] = runGeneticTweakingBatch(y, fs, giventags, population)
    batchoptimality = zeros(1, size(population,2));
    %genetictweaking is already running on multiple threads, so no point to
    %parfor it here.
    for i=1:size(population,2)
        iterationmax = population(i).iterationmax;
        popsize = population(i).popsize;
        a = population(i).a;
        mrate = population(i).mrate;
        [batchoptimality(i), f] = geneticTweakingDirect(y, fs, giventags, iterationmax, popsize, a, mrate);
    end
end
