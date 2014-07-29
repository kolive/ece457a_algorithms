function [ resultsnorm, resultsadapt ] = averageTabuTweaking()
    for i=1:20
       resultsnorm(i) = tabuTweaking('audio2.wav', 'audio2.tag', 120, 200, -1, 1000)
       resultsadapt(i) = tabuTweaking('audio2.wav', 'audio2.tag', 120, 200, 2, 1000)
    end
    

end