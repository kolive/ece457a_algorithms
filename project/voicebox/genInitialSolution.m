function [pp]=genInitialSolution()
    pp.of=2;   % overlap factor = (fft length)/(frame increment)
    pp.pr=0.7;    % Speech probability threshold
    pp.ts=0.1;  % mean talkspurt length (100 ms)
    pp.tn=0.05; % mean silence length (50 ms)
    pp.ti=10e-3;   % desired frame increment (10 ms)
    pp.ri=0;       % round ni to the nearest power of 2
    pp.ta=0.396;    % Time const for smoothing SNR estimate = -tinc/log(0.98) from [2]
    pp.gx=1000;     % maximum posterior SNR = 30dB
    pp.xn=0;        % minimum prior SNR = -Inf dB
end
