How to Run
==========

Extract all files into your active folder of Matlab and run the code `[lastsol, bestfun, count] = gasimple_modified(2,21);`. As opposed to the original function, which accepted the function to optomize as an argument, the function is hardcoded inside `gasimple_modified`. The function that is being optimized is `a3_funct.m`, while `a3_funct_test.m` and `a3_funct_test2.m` were used for testing purposes.

Arguments
=========
The arguments for the function are `nvariables` which is the number of x values desired to be plugged into the function to approximate and `resolution` which is the length of the binary string to use as the gene for running the genetic algorithm. For the function to run properly, `resolution` must be divisable by `nvariables + 1`.

Return Values
=============
The relevant return values are `lastsol` and `bestfun`. `bestfun` returns the fitness of the best solution as it evolved over time, while `lastsol` returns one of the values that were input in the last iteration to get the best result (since there can be multiple best values, but this isn't a concern for us). To see what value the best result returns, you can run `a3_funct(lastsol)`.

What was modified
=================
Although initially there was only one variable per binary gene string, the decoding process was modified so that instead of returning one variable, a `nvariables` were returned. This new function can be found in `bintox.m`.
