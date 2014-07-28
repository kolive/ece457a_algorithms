%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%
%   TODOS: Right now, this does stuff, but never seems to be able to
%   generate a child better than in the original random population.
%
%   Some work needs to be done to find out why
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncost, solution]=geneticTweakingDirect(y, fs, giventags, iterationmax, popsize, a, mrate, adaptiverate, stopcriteria)
    totalanalysedpoints = 0;

    duration = size(y,1)/fs;

    %generate initial population, literature suggests an initial size of 50
    %because we have so many parameters, we may want a higher initial size,
    %but i'll try 50 for now
    % generate initial population
    for i=1:popsize
        %population(i) = generateRandomIndividual(duration);
        population(i, :) = generateRandomBinaryIndividual(30);
    end
    
    iteration = 0;
    pbestfitness = 0;
    
    %set the base mrates
    basemrate = mrate;
    maxmrate = min(1,mrate+(7*adaptiverate));

    %we say we've converged if there's been no change in the optimal for
    %50% of the max iterations
    maxconvergecount = max(5, 0.5*iterationmax);
    convergecount = maxconvergecount;
    if(adaptiverate <= 0)
        adaptthreshold = -1;
    else
        adaptthreshold = 0.5 * popsize;
    end
    
    totalanalysedpoints = totalanalysedpoints + size(population, 1);
    [fitnesses] = evalPopulation(population, y, fs, giventags, duration);
    %we will have our stopping criteria be a parameter set that is 80%
    %better than the initial best
    %default population
    pp.of=2;   % overlap factor = (fft length)/(frame increment)
    pp.pr=0.7;    % Speech probability threshold
    pp.ts=0.1;  % mean talkspurt length (100 ms)
    pp.tn=0.05; % mean silence length (50 ms)
    pp.ti=10e-3;   % desired frame increment (10 ms)
    pp.ri=0;       % round ni to the nearest power of 2
    pp.ta=0.396;    % Time const for smoothing SNR estimate = -tinc/log(0.98) from [2]
    pp.gx=1000;     % maximum posterior SNR = 30dB
    pp.xn=0;        % minimum prior SNR = -Inf dB
    bestgoal = 0.01*runVadBatchDirect(y, fs, duration, giventags, pp); %base goal on 80% better than default
    bestgoal = (1/(1+bestgoal));
    fitnesses = 1./(1+fitnesses);
    
    
    %30% of population should mate
    csize = ceil(popsize/3);
    if(mod(csize, 2) ~= 0)
        csize = csize + 1;
    end
    
    mostfit = 0;
    while(iteration < iterationmax && max(fitnesses) < bestgoal && convergecount > 0 && totalanalysedpoints < stopcriteria) 
        if(mostfit == pbestfitness)
            convergecount = convergecount - 1;
        else
            convergecount = maxconvergecount;
        end
        
        uniquefitnesses = unique(fitnesses);
        if(size(uniquefitnesses, 2) < adaptthreshold)
            mrate = min(maxmrate, mrate + adaptiverate);
        else
            mrate = basemrate;
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
        totalanalysedpoints = totalanalysedpoints + size(children, 1);
        cfitnesses = evalPopulation(children, y, fs, giventags, duration);
        cfitnesses = 1./(1+cfitnesses);
       
       
        indices = linspace(1, size(population,1), size(population,1));
        eligible = setdiff(indices, rindex);
        for i=1:size(rindex, 2)
           %replace the 50% of population random elements that werent parents
            ri = eligible(randi(size(eligible,2)));
            eligible = setdiff(eligible, ri);
            
            %replace the parents
            %this is bad because we kill the strong genes
            %ri = rindex(i)
            population(ri, :) = children(i, :);
            fitnesses(ri) = cfitnesses(i);
        end
        
        %[sortedlist, sindex] = sort(fitnesses, 2);
        %for y=1:size(rindex, 2)
        %    sindex(y)
        %    population(sindex(y), :) = children(y, :);
        %end
        
        %randomly replace generations
        %ind = randperm(size(population, 1));
        %ind = ind(1:size(children,1))
        %for i = 1 : size(children,1)
        %    population(ind(i), :) = children(i, :);
        %    fitnesses(ind(i)) = cfitnesses(i);
        %end
        
        [pbestfitness, si] = max(fitnesses);
        solution = population(si, :);
        
        iteration = iteration + 1
        pbestfitness
     
    end
    totalanalysedpoints
    %change to run vad direct for graph
    [solutioncost] =  evalPopulation(solution, y, fs, giventags, duration);
    solution = decodeBinaryIndividual(solution, duration);
end

%stochastic sampling
function [selectedpop, rindex]=populationSelection(population, fitnesses, count)
    selectedpop = [];
    %generate probability of selection by total fitness
    totalfit = sum(fitnesses);

    pindex = linspace(1, size(population,1), size(population,1));
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
    %            selectedpop = [selectedpop; population(i, :)];
    %            rindex(y) = i;
    %        end
    %        if(i > 1 && pr > scoredpop(3,i - 1) && pr < scoredpop(3,i))
    %            selectedpop = [selectedpop; population(i, :)];
    %            rindex(y) = i;
    %        end
    %    end
    %end
    
    
    %fitness ranking
    % this might limit the gene pool, but we have a fairly high mutation
    % rate
    
    [sortedlist, sindex] = sort(fitnesses, 2);
    %sortedlist
    for y=1:count
        i = sindex(size(fitnesses, 2) - y + 1);
        selectedpop = [selectedpop; population(i, :)];
        rindex(y) = i;
    end
end

function [pchildren] = generateChildren(population,a, mrate)
    
    % for each parent, select a random parent and remove both of them from
    % the list of eligible bachelors
    eligible = linspace(1, size(population,1), size(population,1));
    pchildren = [];
    for i=1:(size(population,1)/2)
        p1 = randi(size(eligible,2));
        eligible = setdiff(eligible, p1);
        p2 = randi(size(eligible,1));
        eligible = setdiff(eligible, p2);

        % perform crossover and mutation to create two new children
        [child1, child2] = bincrossover(population(p1, :), population(p2, :),a, mrate);
        pchildren = [pchildren; child1; child2];
    end
    

end

%TODO:
function [child] = mutate(child, mrate)
    % generate rand number, if number < mrate, mutate the child
    if (rand < mrate)
       child.ts = child.ts + ((rand - rand) * child.ts);
       child.tn = child.tn + ((rand - rand) * child.tn);
       child.ti = child.ti + ((rand - rand) * child.ti);
       child.gx = child.gx + ((rand - rand) * child.gx);
       child.xn = child.xn + ((rand - rand) * child.xn);
    end
end

function [child] = binmutate(child, mrate)
    if(mrate > rand)
        for i = 1:180
            x = rand;
            if(rand < 0.3)
                if(child(i) == 1)
                    child(i) = 0;
                else
                    child(i) = 1;
                end
            end
        end
    end
    
end

function [child1, child2] = crossover(p1, p2, a, mrate)
    
    %50% crossover on overlap factor
    child1.of = floor((p1.of + p2.of)/2);
    child2.of = ceil((p1.of + p2.of)/2);
    
    child1.pr=0.7;
    child2.pr=0.7;

    child1.ts= a*p1.ts + (1-a)*p2.ts;
    child2.ts= (1-a)*p1.ts + (a)*p2.ts;

    child1.tn= a*p1.tn + (1-a)*p2.tn;
    child2.tn= (1-a)*p1.tn + (a)*p2.tn;

    child1.ti= a*p1.ti + (1-a)*p2.ti;
    child2.ti= (1-a)*p1.ti + (a)*p2.ti;

    child1.ri=0;
    child2.ri=0;

    child1.ta=0.396;
    child2.ta=0.396;

    child1.gx= a*p1.gx + (1-a)*p2.gx;
    child2.gx= (1-a)*p1.gx + (a)*p2.gx;

    child1.xn= a*p1.xn + (1-a)*p2.xn;
    child2.xn= (1-a)*p1.xn + (a)*p2.xn;

    [child1]=mutate(child1, mrate);
    [child2]=mutate(child2, mrate);
end

function [child1, child2] = bincrossover(p1, p2, a, mrate)
    
    %a% crossover on overlap factor
    %crossover at midpoint of floor(30*a)
    child1 = zeros(1,30*6);
    child2 = zeros(1,30*6);
    %a = floor(a * 30);
    
    %for i=1:6
    %    lowi = max(1,((i-1)*30 + 1));
    %    highi = lowi + 29;  
    %    crossoverlowa = max(1, 30*(i-1) + 1);
    %    crossoverhigha = crossoverlowa + a;
    %    crossoverlowb = 1 + crossoverhigha;
    %    crossoverhighb = (30*i);
    %    child1(lowi:highi) = [p1(crossoverlowa:crossoverhigha) p2(crossoverlowb:crossoverhighb)];
    %    child2(lowi:highi) = [p2(crossoverlowa:crossoverhigha) p1(crossoverlowb:crossoverhighb)];
    %end
    
    %uniform crossover
    for i=1:180
        if(rand > a)
            child1(i) = p2(i);
            child2(i) = p1(i);
        else
            child1(i) = p1(i);
            child2(i) = p2(i);
        end
    end
    
    child1 = binmutate(child1, mrate);
    child2 = binmutate(child2, mrate);
    
end

