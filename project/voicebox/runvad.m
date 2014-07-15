%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figh, duration, optimality, breakdown, nad]=runvad(wavfilename, tagfilename, figh, pp, iteration)
    if(nargin < 5)
        iteration = -1
    end

    if(nargin < 3)
        figh(1) = figure;
        figh(2) = figure;
        figh(3) = figure;
    end

    if(nargin < 4)
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
    %reads the wav file, stores the data in y
    %fs is the sampling frequency, you need to pass the correct frequency
    %to vahdson
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    [figh, duration, optimality, breakdown, nad] = runvadDirect(y, fs, duration, tagfilename, figh, pp, iteration);

end



