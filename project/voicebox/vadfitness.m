%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Kyle Olive
%  Date: Sometime after the fall of Rome
%  Comments: If you don't know what this does... ask Kyle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fitness, breakdown, uad, figh]=vadfitness(vtags, rtags, duration, plotenable, figh)

    if(nargin < 4)
        plotenable = 0;
    end

    if(nargin < 5 && plotenable == 1)
        %make new figure
        figh(1) = figure;
        figh(2) = figure;
    end

    %create time chunk size for vtags
    vchunksize = duration/size(vtags,1);

    %offset amount, e.g., how many vad tags per real tag?
    ocount = floor(size(vtags,1)/size(rtags,1));

    %some of the vtags won't be analyzed because #vtags not divisible by #rtags
    %this will introduce some analysis error.. may want to select which vtags
    %to skip in order to minimize this
    %right now, just the  vtags at the end chunks will be thrown out
    analysisrange = ocount * size(rtags,1);

    %amount of thrown out vtags, may introduce error because the ones we keep
    %dont line up perfectly with the rtags, though this is a small chunk of
    %time so error should be neglible
    uad = duration - analysisrange * vchunksize;
    
    %initialize error types
    fec = 0;
    msc = 0;
    over = 0;
    nds = 0;

    %for plotting
    vtimeplot = linspace(0, duration, size(vtags,1));
    rtimeplot = linspace(0, duration, size(rtags,1));
    fecplot = zeros(1, size(vtags,1));
    mscplot = zeros(1, size(vtags,1));
    overplot = zeros(1, size(vtags,1));
    ndsplot = zeros(1, size(vtags,1));

    %calculate the VAD Error Rate
    %detect FEC and MSC
    i = 1;
    fecmode = 1;
    mscmode = 0;
    for j=1:analysisrange,
       %to calculate FEC, determine if we've recently transitioned from a
       %no-speech to a speech zone and add up the duration of time that we're
       %mis-detecting speech
       if(i > 1 && rtags(i-1) == 0 && rtags(i) == 1 && fecmode == 0)
          %set FEC detection mode on
          fecmode = 1;
       end
       if((fecmode == 1 || mscmode == 1) && (rtags(i) == vtags(j) || rtags(i) == 0))
          %we've either left the speech zone or detection started so no longer
          %FEC and now into MSC mode
          if(rtags(i) == 0)
              fecmode = 0;
              mscmode = 0;
          elseif(fecmode == 1)
              fecmode = 0;
              mscmode = 1;
          end
          
       end

       %if fecmode or mscmode is on and there is an error,
       %classify it as the correct error
       if((mscmode == 1 || fecmode == 1) && vtags(j) ~= rtags(i))
           if(mscmode == 1)
               msc = msc + vchunksize;
               mscplot(j) = 1;
           elseif(fecmode == 1)
               fec = fec + vchunksize;
               fecplot(j) = 1;
           end
       end

       if(mod(j,ocount) == 0)
           %time to increment the real chunk counter
           i = i + 1;
       end
    end
    %calculate the FTR Error Rate
    %detect OVER and NDS
    i = 1;
    overmode = 0;
    ndsmode = 0;
    for j=1:analysisrange,
       %to calculate OVER, determine if we've recently transitioned from a
       %speech to a no-speech zone and add up the duration of time that we're
       %mis-detecting speech

       if(i > 1 && rtags(i-1) == 1 && rtags(i) == 0 && overmode == 0)
          %set FEC detection mode on
          overmode = 1;
       end
       if((overmode == 1 || ndsmode == 1) && (rtags(i) == vtags(j) || rtags(i) == 1)) 
          %we've either entered a speech zone or detection stopped so no longer
          %OVER and now into NDS region
          if(rtags(i) == 1)
            overmode = 0;
            ndsmode = 0;
          elseif(overmode == 1)
              ndsmode = 1;
              overmode = 0;
          end
        
       end

       %if overmode or ndsmode is on and there's an error, classify it as the 
       %correct error
       if((overmode == 1 || ndsmode == 1) && rtags(i) ~= vtags(j))
           if(ndsmode == 1)
               nds = nds + vchunksize;           
               ndsplot(j) = 1;
           elseif(overmode == 1)
               over = over + vchunksize;
               overplot(j) = 1;
           end
       end     

       if(mod(j,ocount) == 0)
           %time to increment the real chunk counter
           i = i + 1;
       end
    end

    fitness = msc + fec + nds + over;
    fitness = (fitness/duration) * 100; % normalized fitness
    breakdown = [msc, fec, nds, over];

    %IDEA: We should generate plots for the best solution on every iteration of
    %our search algorithms
    %we can use the plots to generate a video and show how our solution reaches
    %optimality
    if(plotenable == 1)    
        rtimeplot = rtimeplot';
        vtimeplot = vtimeplot';
        %plot the two basband waveforms and full error waveform
        figure(figh(1));
        s(1) = subplot(3,1,1);
        plot(s(1), rtimeplot, rtags);
        title('"Good" Tags');
        xlabel('Time (s)');
        ylabel('Tag Value');
        s(2) = subplot(3,1,2);  
        plot(s(2), vtimeplot, vtags');
        title('Vadsohn Tags');
        xlabel('Time (s)');
        ylabel('Tag Value');
        s(3) = subplot(3,1,3);
        %hack to make plot look better
        vtimeplot = [vtimeplot; (vtimeplot(size(vtimeplot,1)) + vchunksize)];
        errorplot = fecplot + mscplot + ndsplot + overplot;
        errorplot = [errorplot 1.1];
        plot(s(3), vtimeplot, errorplot);
        title('VER + FTR');
        xlabel('Time (s)');
        ylabel('Erroneous Tag');

        %plot the four seperate errors
        figure(figh(2));
        %Hacks to make the graph look nice 
        %because I don't know how to plot in matlab
        fecplot = [fecplot 1.1];
        mscplot = [mscplot 1.1];
        ndsplot = [ndsplot 1.1];
        overplot = [overplot 1.1];

        s(1) = subplot(4,1,1);
        plot(s(1), vtimeplot, fecplot);
        title('FEC Error');
        xlabel('Time (s)');
        ylabel('Erroneous Tag');
        s(2) = subplot(4,1,2);  
        plot(s(2), vtimeplot, mscplot');
        title('MSC Error');
        xlabel('Time (s)');
        ylabel('Erroneous Tag');
        s(3) = subplot(4,1,3);
        plot(s(3), vtimeplot, ndsplot);
        title('NDS Error');
        xlabel('Time (s)');
        ylabel('Erroneous Tag');
        s(4) = subplot(4,1,4);
        plot(s(4), vtimeplot, overplot);
        title('OVER Error');
        xlabel('Time (s)');
        ylabel('Erroneous Tag');
    end

end