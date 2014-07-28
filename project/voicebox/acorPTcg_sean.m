function  result = acorPTcg_sean()
%Archive table is initialized by uniform random
%
clear all
nVar = 10;
nSize = 50; %size
nAnts = 2;
fopt = 0; %Apriori optimal
q=0.1;
qk=q*nSize;
xi = 0.85;
maxiter = 25000;
errormin = 1e-04; %Stopping criteria
%Paramaeter range
Up = 0.5*ones(1,nVar); %range for dp function
Lo = 1.5*ones(1,nVar);
%Initialize archive table with uniform random and sort the result from
%the lowest objective function to largest one.
S = zeros(nSize,nVar+1,1);
Solution = zeros(nSize,nVar+2,1);
for k=1:nSize
    Srand = zeros(nVar);
    for j = 1:nAnts
        for i=1:nVar
            Srand(j,i) = (Up(i) - Lo(i))* rand(1) + Lo(i); %uniform distribution
        end
        ffbest(j)=dp(Srand(j,:));  %dp test function
    end
    [fbest kbest] = min(ffbest);
    S(k,:)=[Srand(kbest,:) fbest];
end
%Rank the archive table from the best (the lowest)
S = sortrows(S,nVar+1);
%Select the best one as the best
%Calculate the weight,w
%the parameter q determine which solution will be chosen as a guide to
%the next solution, if q is small, we prefer the higher rank
%qk is the standard deviation
% mean = 1, the best on
w = zeros(1,nSize);
for i=1:nSize
    w(i) = pdf('Normal',i,1.0,qk);
end
Solution=S;
%end of archive table initialization
stag = 0;
% Iterative process
for iteration = 1: maxiter
    %phase one is to choose the candidate base one probability
    %the higher the weight the larger probable to be chosen
    %value of function of each pheromone
    p=w/sum(w);
    ref_point = mean(Solution(:,nVar+1));
    for i=1:nSize
        pw(i) = weight_prob(p(i),0.6);
        objv(i)= valuefunction(0.8,0.8, 2.25, ref_point-Solution(i, nVar+1));
        prospect(i) = pw(i)*objv(i);
    end
    [max_prospect ix_prospect]=max(prospect);
    selection = ix_prospect;
    %phase two, calculate Gi
    %first calculate standard deviation
    delta_sum =zeros(1,nVar);
    for i=1:nVar
        for j=1:nSize
            delta_sum(i) = delta_sum(i) + abs(Solution(j,i)- ...
                Solution(selection,i)); %selection
        end
        delta(i)=xi /(nSize - 1) * delta_sum(i);
    end
    % xi has the same as pheromone evaporation rate. Higher xi, the lower
    % convergence speed of algorithm
    % do sampling from PDF continuous with mean chosen from phase one and
    % standard deviation calculated above
    % standard devation * randn(1,) + mean , randn = random normal
    generator
    Stemp = zeros(nAnts,nVar);
    for k=1:nAnts
        for i=1:nVar
            Stemp(k,i) = delta(i) * randn(1) + Solution(selection,i);
            %selection
            if Stemp(k,i)> Up(i)
                Stemp(k,i) = Up(i);
            elseif Stemp(k,i) < Lo(i);
                Stemp(k,i) = Lo(i);
            end
        end
        ffeval(k) =dp(Stemp(k,:));  %dp test function
    end
    Ssample = [Stemp ffeval']; %put weight zero
    %insert this solution to archive, all solution from ants
    Solution_temp = [Solution; Ssample];
    %sort the solution
    Solution_temp = sortrows(Solution_temp,nVar+1);
    %remove the worst
    Solution_temp(nSize+1:nSize+nAnts,:)=[];
    Solution = Solution_temp;
    best_par(iteration,:) = Solution(1,1:nVar);
    best_obj(iteration) = Solution(1,nVar+1);
    %check stopping criteria
    if iteration > 1
        dis = best_obj(iteration-1) - best_obj(iteration);
        if dis <=1e-04
            stag = stag + 1;
        else
            stag = 0;
        end
    end
    ftest = Solution(1,nVar+1);
    if abs(ftest - fopt) < errormin || stag >=5000
        break
    end
end
plot(1:iteration,best_obj);
clc
title (['ACOR6 ','best obj = ', num2str(best_obj(iteration))]);
disp('number of function eveluation')
result = nAnts*iteration;

%%-------------------------------------------------------------

function value = valuefunction(alpha, beta, lambda, xinput)
value =[];
n = length(xinput);
for i=1:n
    if xinput(1,i) >= 0
        value(1,i) = xinput(1,i) ^ alpha;
    else
        value(1,i) = -lambda * (-xinput(1,i))^ beta;
    end
end

function prob = weight_prob(x, gamma)
% weighted the probability
% gamma is weighted parameter
prob=[];
for i=1:length(x)
    if x(i) < 1
        prob(i) = (x(i)^(gamma))/((x(i)^(gamma) + (1-x(i))^(gamma))^(1/gamma));
        %prob(i) = (x(i)^(1/gamma))/((x(i)^(1/gamma) + (1-x(i))^(1/gamma))^(1/gamma));
    else
        prob(i) = 1.0;
    end
end

function y = dp(x)
% Diagonal plane
% n is the number of parameter
n = length(x);
s = 0;
for j = 1: n
    s = s + x(j);
end
y = 1/n * s;