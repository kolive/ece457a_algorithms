function [bestsolution, bestscore, adaptedimprovementfactor] = fullGeneticTweakingRun( wavfilename, tagfilename )
    %run adaptive algorithm to determine a good paramater set for GA
    [paramscore, adaptedparams]=adaptiveGeneticTweaking(wavfilename, tagfilename, 50, 20, 0.5, 1/8)
    
    %perform some average runs with default parameter set
    default.popsize = 50;
    default.a = 0.5;
    default.iterationmax = 200;
    default.mrate = 1/8; 
    [defaultresults, davg, dbestsol] = averageGeneticTweaking( wavfilename, tagfilename, default, 30 )
    
    %perform average runs with the adapted parameter set
    [adaptedresults, aavg, abestsol] = averageGeneticTweaking( wavfilename, tagfilename, adaptedparams, 30 )
    
    %return the best score found in both sets and the best solution
    bestscore = min([min(defaultresults), min(adaptedresults)]);
    if(min(defaultresults) < min(adaptedresults))
        bestsolution = dbestsol;
    else
        bestsolution = abestsol;
    end
    
    adaptedimprovementfactor = (davg - aavg)/davg;
end