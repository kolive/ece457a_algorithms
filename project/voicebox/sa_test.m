%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Owen Wang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [best_sol]=sa_test(granularity)
    sol = [0 0];
    best_sol = sol;

    iter= 0;
    total_iter = 0;
    accept = 0;
    rej = 0;
    sols = sol;

    % parameters to tweak
    max_iter = 1000;
    max_accept = 1000;
    max_rej = 1000;

    T = 1;
    T_min = 1e-10;

    alpha = 0.95;

    sol_cost = 1000000;
    cost_old = sol_cost;
    cost_new = sol_cost;

    while ((rej <= max_rej) & (T > T_min))
        iter = iter + 1;

        if (iter >= max_iter) | (accept >= max_accept)
          % geometric cooling
          T = alpha * T;
          total_iter = total_iter + iter;

          iter = 1;
          accept = 1;
        end

        % xn+1 = xn + randn
        sols = generateNeighbors(sol, granularity);

        %fn+1(xn+1)
        scores = runSimpleBatch(sols);
        [cost_new, si] = min(scores);
        sol = sols(si, :);

        % delta_f = fn+1(xn+1) - fn(xn)
        delta_cost = cost_new - cost_old;

        % accept new solution if it's better
        if (delta_cost < 0)
          % TODO: need the conditional?
          if (sol_cost > cost_new)
            best_sol = sol;
            sol_cost = cost_new;
          end

          cost_old = cost_new;
          accept = accept + 1;
          rej = 0;
        % accept if p=exp(-delta_f/T) > r
        elseif (exp(-delta_cost / T) > rand)
          cost_old = cost_new;
          accept = accept + 1;
        else
          rej = rej + 1;
        end
    end

    disp(strcat('Finished SA with iteration count of ', num2str(total_iter)));
    % runvad(wavfilename, tagfilename, fig, best_sol);
end

function [neighbors] = generateNeighbors(sol, granularity)
    %generate 10 neighbours.
    % +/- a quantization level to each parameter and make it a neighbour
    neighbors = [];
    sol
    n1 = [sol(1) + (1 / granularity), sol(2)];
    n2 = [sol(1), sol(2) + (1 / granularity)];
    n3 = [sol(1) + (1 / granularity), sol(2) + (1 / granularity)];
    n4 = [sol(1) - (1 / granularity), sol(2)];
    n5 = [sol(1), sol(2) - (1 / granularity)];
    n6 = [sol(1) - (1 / granularity), sol(2) - (1 / granularity)];
    n7 = [sol(1) + (1 / granularity), sol(2) - (1 / granularity)];
    n8 = [sol(1) - (1 / granularity), sol(2) + (1 / granularity)];
    neighbors = [neighbors; n1];
    neighbors = [neighbors; n2];
    neighbors = [neighbors; n3];
    neighbors = [neighbors; n4];
    neighbors = [neighbors; n5];
    neighbors = [neighbors; n6];
    neighbors = [neighbors; n7];
    neighbors = [neighbors; n8];
end
