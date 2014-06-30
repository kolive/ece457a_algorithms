% Genetic Algorithm (Simple Demo) Matlab/Octave Program
% Written by X S Yang (Cambridge University) modified by Sean Aubin
% Usage: gasimple_modified(2, 15);
function [lastsol, bestfun, count]=gasimple_modified(ndimensions, resolution)
% Evil global variable declaration
global solnew sol pop popnew fitness fitold f range;

% Add as arguments later?
f = @(x)(1/(1+a3_funct(x)));
range=[-1 1];
% throw error on invalid arguments?

% Initializing the parameters
rand('state' ,0'); % Reset the random generator
popsize=20; % Population size
MaxGen=200; % Max number of generations
count=0;    % counter
nsite=2;    % number of mutation sites
pc=0.95;    % Crossover probability
pm=0.1;    % Mutation probability
%nsbit=16;   % String length (bits)
nsbit=resolution;
% Generating the initial population
% Where every row is a member with it's genes
popnew=init_gen(popsize,nsbit);
fitness=zeros(1,popsize); % fitness array
% Initialize solution <- initial population
% every column is a trial solution with it's input value
solnew = zeros(ndimensions, popsize);
bestsol = zeros(ndimensions, popsize*MaxGen);
bestfun = zeros(1,MaxGen);

% This could probably be vectorized
for i=1:popsize,
    solnew(:,i)=bintox(popnew(i,:));
end
% Start the evolution loop
for i=1:MaxGen,
    % Record as the history
   fitold=fitness; pop=popnew; sol=solnew;
   for j=1:popsize,
   % Crossover pair
   ii=floor(popsize*rand)+1; jj=floor(popsize*rand)+1;
   % Cross over
   if pc>rand,
      [popnew(ii,:),popnew(jj,:)]=crossover(pop(ii,:),pop(jj,:));
   % Evaluate the new pairs
    count=count+2; % What is this counting?
    evolve(ii); evolve(jj);
end

% Mutation at n sites
 if pm>rand,
  kk=floor(popsize*rand)+1; count=count+1;
  popnew(kk,:)=mutate(pop(kk,:),nsite);
  evolve(kk);
 end
end % end for j
% Record the current best fitness
bestfun(i)=max(fitness);
end
% Display results
[~, lastsol_index] = max(fitness);
lastsol = sol(:, lastsol_index);
set(gcf,'color','w');
plot(bestfun); title('Fitness');

% All the sub functions
% generation of the initial population
function pop=init_gen(np,nsbit)
% String length=nsbit+l with pop(:,l) for the Sign
pop=rand(np,nsbit+1)>0.5;

% Evolving the new generation
function evolve(j)
global solnew popnew fitness fitold pop sol f;
solnew(:,j)=bintox(popnew(j,:));
fitness(j)=f(solnew(:,j)); % THIS IS WHERE THE EVAL HAPPENS
if fitness(j)>fitold(j),
pop(j,:)=popnew(j,:);
sol(:,j)=solnew(:,j);
end

% Crossover operator
function [c,d]=crossover(a,b)
nn=length(a)-1;
% generating a random crossover point
cpoint=floor(nn*rand)+1;
c=[a(1:cpoint) b(cpoint+1:end)];
d=[b(1:cpoint) a(cpoint+1:end)];

% Mutatation operator
function anew=mutate(a,nsite)
nn=length(a); anew=a;
for i=1:nsite,
j=floor(rand*nn)+1;
anew(j)=mod(a(j)+1,2);
end