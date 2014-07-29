function [resultsnorm, resultsadapt, averagingnorm, averagingadaptive, itcostn, itcosta] = runGeneticBenchmark()
    
    maxiterationcount = [1]; 
    iterations = maxiterationcount
    x = 1;
    for ic=maxiterationcount
        ic
        for i=1:20
            [averagingnorm(i), itcostn(i)] = geneticTweaking('audio2.wav', 'audio2.tag', 250, 80, 0.5, 1/8, -1, 99999999)
            [averagingadaptive(i), itcosta(i)] = geneticTweaking('audio2.wav', 'audio2.tag', 250, 80, 0.5, 1/8, 0.1, 9999999)
        end
        resultsnorm(x) = mean(averagingnorm)
        resultsadapt(x) = mean(averagingadaptive)
        x = x + 1;
    end

end
