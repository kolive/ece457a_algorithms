function [individual]=generateRandomIndividual(duration)
    % currently, lets have this function generate a uniformly random value
    % within the range of each parameter
    % an individual is defined as (from SOW):
    % NOTE: we may want to make ti equal to what's used in the "good" file
    % NOTE: this may be a lot of stuff to search through. We may want to
    % focus on just a few of these parameters
    %   individual.of = overlap factor, between 0 and 5
    %   individual.ti = frame increment, between 0.001s and 0.01s
    %   individual.xn = a priori SNR, between 0 and 3db
    %   individual.gx = posterior SNR, between 10 and 1000
    %   individual.pr = voice threshold, 0.7
    %   individual.ts = talkspurt length, between 0 and duration/2 ms
    %   individual.tn = silence length, between 0 and duration/2 ms
    
    individual.of= floor(5 * rand) + 1; %I think this needs to be a whole number
    individual.pr=0.7;  
    individual.ts= duration/2 * rand; 
    individual.tn= duration/2 * rand;
    individual.ti=10e-3 + ((10e-2 - 10e-3) * rand);   
    individual.ri=0;       
    individual.ta=0.396;    
    individual.gx=10 + ((1000 - 10)*rand);     
    individual.xn=1.995262 * rand; 
    
end