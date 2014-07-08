%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [figh, duration, optimality, breakdown, nad]=runvad(wavfilename, tagfilename, figh, pp)
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

    %vadsohn with default parameters on y, fs
    %other parameters should be passed in a matrix called pp, i think
    %I haven't tried that yet.
    tags = vadsohn(y, fs, 'a', pp);
    tags = [tags; 1.1];
    x1 = linspace(0, duration, size(tags,1));
    x1 = x1';

    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);
    giventags = [giventags; 1.1];
    x2 = linspace(0, duration, size(giventags,1));
    x2 = x2';

    %plot the two waveforms for comparison
    figure(figh(1));
    s(1) = subplot(3,1,3);
    plot(s(1), x1, tags);
    xlabel('Time (s)');
    ylabel('Tag Value');
    s(2) = subplot(3,1,2);
    plot(s(2), x2, giventags);
    title('Results of Vadsohn Analysis (bottom) vs. Given Tags (top)');
    xlabel('Time (s)');
    ylabel('Tag Value');
    s(3) = subplot(3,1,1);
    t=0:1/fs:(length(y)-1)/fs; %get the duration for plotting
    plot(s(3), t, y);
    title('Actual speech waveform');
    xlabel('Time (s)');

    [optimality, breakdown, nad, figh(2:3)] = vadOptimality(tags, giventags, duration, 1, figh(2:3));


end
