function runvad(wavfilename, tagfilename)
    %reads the wav file, stores the data in y
    %fs is the sampling frequency, you need to pass the correct frequency
    %to vahdson
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;
    
    %vadsohn with default parameters on y, fs
    %other parameters should be passed in a matrix called pp, i think
    %I haven't tried that yet.
    tags = vadsohn(y, fs);
    tags = [tags; 1.1];
    x1 = linspace(0, duration, size(tags,1));
    x1 = x1';
    
    %read in the given tags to do a comparison
    giventags = dlmread(tagfilename);
    giventags = [giventags; 1.1];
    x2 = linspace(0, duration, size(giventags,1));
    x2 = x2';
    
    %plot the two waveforms for comparison
    figure;
    s(1) = subplot(3,1,1);
    plot(s(1), x1, tags);
    title('Results of Vadsohn Analysis (top) vs. Given Tags (middle)');
    xlabel('Time (s)');
    ylabel('Tag Value');
    s(2) = subplot(3,1,2);  
    plot(s(2), x2, giventags);
    xlabel('Time (s)');
    ylabel('Tag Value');
    s(3) = subplot(3,1,3);
    t=0:1/fs:(length(y)-1)/fs; %get the duration for plotting
    plot(s(3), t, y);
    title('Actual speech waveform');
    xlabel('Time (s)');
    
    
end