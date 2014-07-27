%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%
%   TODOS: Right now, this does stuff, but never seems to be able to
%   generate a child better than in the original random population.
%
%   Some work needs to be done to find out why
%   HOW TO SAVE GRAPH?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [solutioncosts, solutions]=adaptiveAcoTweaking(wavfilename, tagfilename, iterationmax, popsize, a, mrate, gran)
    
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
    
    % check if the graph file exists
    
    if(exist(['nodes_' num2str(gran) '.bin'],'file') == 2)
        %read in graph file
        fileID = fopen(['nodes_' num2str(gran) '.bin']);
        nodes = fread(fileID);
        fclose(fileID);
        fileID = fopen(['nchildren_' num2str(gran) '.bin']);
        nchildren = fread(fileID,[3 3],'double');
        fclose(fileID);
        fileID = fopen(['nodevals_' num2str(gran) '.bin']);
        nodevals = fread(fileID,[3 3],'double');
        fclose(fileID);
        fileID = fopen(['nodeCount_' num2str(gran) '.bin']);
        nodeCount = fread(fileID,[3 3],'double');
        fclose(fileID);
        
        [fitnesses, nodes, nchildren, nodevals, nodeCount, visited] = runAcoTweakingBatch(y, fs, giventags, population, gran, nodes, nchildren, nodevals, nodeCount, visited);
    else
        [fitnesses, nodes, nchildren, nodevals, nodeCount, visited] = runAcoTweakingBatch(y, fs, giventags, population, gran, [0,0], 0, 0, 0, 0);
    end
    
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
            convergecount = convergecount - 1
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
        [cfitnesses, nodes, nchildren, nodevals, nodeCount, visited] = runAcoTweakingBatch(y, fs, giventags, children, gran, nodes, nchildren, nodevals, nodeCount, visited);
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
    
    solutions = [solutions solution];
    [solutioncost, nodes, nchildren, nodevals, nodeCount, visited] =  runAcoTweakingBatch(y, fs, giventags, solution, gran, nodes, nchildren, nodevals, nodeCount, visited);
    solutioncosts = [solutioncosts solutioncost];
    
    %serialize the graph
    fileID = fopen(['nodes_' num2str(gran) '.bin']);
    fwrite(fileID,nodes);
    fclose(fileID);
    fileID = fopen(['nchildren_' num2str(gran) '.bin']);
    fwrite(fileID,nchildren);
    fclose(fileID);
    fileID = fopen(['nodevals_' num2str(gran) '.bin']);
    fwrite(fileID,nodevals);
    fclose(fileID);
    fileID = fopen(['nodeCount_' num2str(gran) '.bin']);
    fwrite(fileID,nodeCount);
    fclose(fileID);
    fileID = fopen(['visited_' num2str(gran) '.bin']);
    fwrite(fileID,visited);
    fclose(fileID);
    
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
    
    [~, sindex] = sort(fitnesses, 2);
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

function [child] = mutate(child, mrate)
    % generate rand number, if number < mrate, mutate the child
    if (rand < mrate)
       child.alpha = child.alpha + ((rand - rand) * child.alpha);
       child.beta = child.beta + ((rand - rand) * child.beta);
       child.eva = child.eva + ((rand - rand) * child.eva);
       child.scal = child.scal + ((rand - rand) * child.scal);
       child.ants = ceil(child.ants + ((rand - rand) * child.ants));
    end
end

function [child1, child2] = crossover(p1, p2, a, mrate)
    
    child1.alpha = (p1.alpha * a) + (p2.alpha * (1-a));
    child2.alpha = (p2.alpha * a) + (p1.alpha * (1-a));
    
    child1.beta = (p1.beta * a) + (p2.beta * (1-a));
    child2.beta = (p2.beta * a) + (p1.beta * (1-a));
    
    child1.eva = (p1.eva * a) + (p2.eva * (1-a));
    child2.eva = (p2.eva * a) + (p1.eva * (1-a));
    
    child1.scal = (p1.scal * a) + (p2.scal * (1-a));
    child2.scal = (p2.scal * a) + (p1.scal * (1-a));
    
    child1.ants = ceil((p1.ants * a) + (p2.ants * (1-a)));
    child2.ants = floor((p2.ants * a) + (p1.ants * (1-a)));
    
    [child1]=mutate(child1, mrate);
    [child2]=mutate(child2, mrate);
end

function [individual] =  generateRandomParameterSet()
    individual.alpha = min(2, (0.5*rand)); %between 2 and 0.5
    individual.beta = min(1, 0.01 + rand); %between 0.1 and 1
    individual.eva = min(0.99, 0.1 + rand); %between 0.1 and 0.99
    individual.scal = (0.5 + (1.5 * rand)); %between 0.5 and 1.5
    individual.ants = ceil(2 + (18 * rand)); %between 2 and 20
end

function [batchoptimality, nodes, nchildren, nodevals, nodeCount, visited] = runAcoTweakingBatch(y, fs, giventags, population, gran, nodes, nchildren, nodevals, nodeCount, visited)
    batchoptimality = zeros(1, size(population,2));
    %genetictweaking is already running on multiple threads, so no point to
    %parfor it here.
    for i=1:size(population,2)
        alpha = population(i).alpha;
        beta = population(i).beta;
        evaporationConstant = population(i).eva;
        scalingParameter = population(i).scal;
        numberOfAnts = population(i).ants;
        [batchoptimality(i), nodes, nchildren, nodevals, nodeCount, visited] = acoTweakingDirect(y, fs, giventags, alpha, beta, evaporationConstant, scalingParameter, numberOfAnts, 40, gran, nodes, nchildren, nodevals, nodeCount, visited);
    end
end
