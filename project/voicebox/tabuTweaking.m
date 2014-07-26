%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [solutioncost, solution]=tabuTweaking(wavfilename, tagfilename, granularity)
    iterationmax = 100;
    
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
    tabulength = 8;
    [optimality] = runVadBatchDirect(y, fs, duration, giventags, solution);
    tabulist = [solution];
    tabuscores = [optimality];
    tabuage = [tabulength];
    globalbest = optimality;
    globalbestsol = solution;
    neighbors = solution;
    
    %todo: should probably search old neighbors rather than terminate
    while(iteration < iterationmax && globalbest > 5 && size(neighbors, 2) ~= 0)
        tabuage = tabuage - 1;
        %get indices of valid tabus
        tabuindex = find(tabuage);
        
        %update tabu list
        tabuage = tabuage(tabuindex);
        tabulist = tabulist(tabuindex);
        tabuscores = tabuscores(tabuindex);
        
        neighbors = generateNeighbors(solution, quant, duration);
        scores = runVadBatchDirect(y, fs, duration, giventags, neighbors)
        
        %aspiration
        %with current implementation, this aspiration criteria does
        %nothing. need to come up with a better one
        [sval, si] = min(scores);
        if(ismember(sval,tabuscores) && sval < globalbest)
            globalbest = sval;
            globalbestsol = neighbors(si);
        else
            %regular tabu-minded selection
            [nontabuscores, nontabuscoresi] = setdiff(scores, tabuscores);
            neighbors = neighbors(nontabuscoresi);
            scores = nontabuscores;

            [sval, si] = min(scores);
            if(sval < globalbest)
                globalbest = sval; 
                globalbestsol = neighbors(si);
            end
        end
        
        
        %add the solution to the tabu list
        neighbors(si);
        tabulist = [tabulist neighbors(si)];
        size(tabulist, 2);
        tabuscores = [tabuscores sval];
        tabuage = [tabuage tabulength];
        solution = neighbors(si);
        
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

