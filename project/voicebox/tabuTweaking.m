%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [solutioncost, solution]=tabuTweaking(wavfilename, tagfilename, granularity, iterationmax)
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    quant.of = 1;
    quant.ts = (duration/2)/granularity;
    quant.tn = (duration/2)/granularity;
    quant.ti = (10e-2 - 10e-3)/granularity;
    quant.gx = (1000 - 10)/granularity;
    quant.xn = 1.995262/granularity;
    
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);

    % generate your initial solution (default sol'n)
    solution = genInitialSolution();

    %TODO: add in end case scenario (for example, get lowest possible optimality). otherwise end when reach iterationmax
    % want lowest optimality value for Tabu Search
    iteration = 1;
    tabulength = granularity;
    [optimality] = runVadBatchDirect(y, fs, duration, giventags, solution);
    tabulist = [solution];
    tabuscores = [optimality];
    tabuage = [tabulength];
    globalbest = optimality;
    globalbestsol = solution;
    neighbors = solution;
    
    backupneighbors = []; %building a list of backup neighbors to search so we never run out of space
    
    while(iteration < iterationmax && globalbest > 5)
        tabuage = tabuage - 1;
        %get indices of valid tabus
        tabuindex = find(tabuage);
        
        %update tabu list
        tabuage = tabuage(tabuindex);
        tabulist = tabulist(tabuindex);
        tabuscores = tabuscores(tabuindex);
        
        neighbors = generateNeighbors(solution, quant, duration);
        if(size(neighbors, 2) == 0)
            %start searching the backup neighborhood if we've run into a
            %dead end
            neighbors = backupneighbors;
            backupneighbors = [];
        end
        scores = runVadBatchDirect(y, fs, duration, giventags, neighbors);
        
        
        %regular tabu-minded selection
        [nontabuscores, nontabuscoresi] = setdiff(scores, tabuscores);
        neighbors = neighbors(nontabuscoresi);
        scores = nontabuscores;

        %if everything is tabu, pick a random tabu item
        %aspiration!!!
        if(size(scores,2) == 0)
            in = randi(size(tabuscores, 2));
            nin = linspace(1,size(tabuscores, 2), size(tabuscores, 2));
            nin = setdiff(nin, in);
            neighbors = tabulist(in);
            
            tabulist = tabulist(nin);
            tabuscores = tabuscores(nin);
            tabuage = tabuage(nin);
            
            scores = runVadBatchDirect(y, fs, duration, giventags, neighbors);

        end

        [sval, si] = min(scores);
        if(sval < globalbest)
            globalbest = sval; 
            globalbestsol = neighbors(si);
        end
        
        
        %add the solution to the tabu list
        tabulist = [tabulist neighbors(si)];
        tabuscores = [tabuscores sval];
        tabuage = [tabuage tabulength];

        
        solution = neighbors(si);
        
        %save some solutions to look at if we run into a dead end
        if(size(backupneighbors, 2) < 8)
            [scores, scoresi] = setdiff(scores, scores(si));
            neighbors = neighbors(scoresi);
            [sval2, si2] = min(scores);
            %take the second best option and save it in the backup
            %neighbors
            backupneighbors = [backupneighbors neighbors];
        end
        
        iteration = iteration + 1
        globalbest
        sval
    end
    globalbest
    globalbestsol
    [solutioncost] = runVadBatchDirect(y, fs, duration, giventags, globalbestsol)
end

function [neighbors] = generateNeighbors(node, quant, duration)
    %generate 10 neighbours.
    % +/- a quantization level to each parameter and make it a neighbour
    neighbors = [];
    if(node.of < 5)
        nn = node;
        nn.of = nn.of + quant.of;
        neighbors = [neighbors nn];
    end
    
    if(node.of >= 2)
        nn = node;
        nn.of = nn.of - quant.of;
        neighbors = [neighbors nn];
    end
    
    if(node.ts < duration/2)
        nn = node;
        nn.ts = nn.ts + quant.ts;
        neighbors = [neighbors nn];
    end
    
    if(node.ts > quant.ts)
        nn = node;
        nn.ts = nn.ts - quant.ts;
        neighbors = [neighbors nn];
    end
    
    if(node.tn < duration/2)
        nn = node;
        nn.tn = nn.tn + quant.tn;
        neighbors = [neighbors nn];
    end
    
    if(node.tn > quant.tn)
        nn = node;
        nn.tn = nn.tn - quant.tn;
        neighbors = [neighbors nn];
    end
    
    if(node.ti < 10e-2)
        nn = node;
        nn.ti = nn.ti + quant.ti;
        neighbors = [neighbors nn];
    end
    
    if(node.ti > 10e-3)
        nn = node;
        nn.ti = nn.ti - quant.ti;
        neighbors = [neighbors nn];
    end
    
    if(node.gx < 1000)
        nn = node;
        nn.gx = nn.gx + quant.gx;
        neighbors = [neighbors nn];
    end
    
    if(node.gx > 10)
        nn = node;
        nn.gx = nn.gx - quant.gx;
        neighbors = [neighbors nn];
    end
    
    if(node.xn < 1.995262)
        nn = node;
        nn.xn = nn.xn + quant.xn;
        neighbors = [neighbors nn];
    end
    
    if(node.xn > quant.xn)
        nn = node;
        nn.xn = nn.xn - quant.xn;
        neighbors = [neighbors nn];
    end
    
    
end

