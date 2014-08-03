ECE457a - Co-operative and Adaptive Algorithms
==============================================

This repository is a collection of some of the algorithms learned about in ece457a. Note that these algorithms are not all commented, and may not all even work properly. 

I would ask that if you're taking the course or a similar course on the subject matter to only use my implementations as a reference, for two reasons. 

1. I can't speak for the integrity of all the implementations, as these are mostly off-the-cuff implementations to test my understanding 
2. Academic Integrity and stuff.

Otherwise, go crazy.

Metaheuristic Search Algorithms for Voice Activity Detection (specifically VADSohn) parameter tuning
----------------------------------------------------------------------------------------------------

As part of this course project, several metaheuristic search algorithms were implemented for the purpose of tuning the output of VADSohn to match some given state of voice detection for the purpose of paramater tuning and calibration.

Note that the error rate is only as accurate as the number of samples in the given tags, and any output from VADSohn should be sampled at the same frequency to maintain the error rate discovered by the search functions. 

These algorithms can be found as modifications to the voicebox library (http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html), under project/voicebox.

Also note that Tabu and ACO would probably work better with random neighbor generation using Gaussian White noise as the neighborhood operator.

Contributors 
------------

kolive - Kyle Olive (kolive@uwaterloo.ca)

rawkcy - Roxanne Guo

wangfowen - Owen Wang

Seanny123 - Sean Aubin

joebobfrank - Michael Thiessen 
