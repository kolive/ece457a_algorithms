%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Owen Wang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sol_cost, best_sol, all_sol_costs, all_sols]=saTweaking(wavfilename, tagfilename, granularity)
    [y, fs] = wavread(wavfilename);
    duration = size(y,1)/fs;

    % generate your initial solution
    sol = genInitialSolution();
    best_sol = sol;

    [y, fs] = wavread(wavfilename);
    duration = size(y,1) / fs;
    giventags = dlmread(tagfilename);

    quant.of = 1;
    quant.ts = (duration / 2) / granularity;
    quant.tn = (duration / 2) / granularity;
    quant.ti = (10e-2 - 10e-3) / granularity;
    quant.gx = (1000 - 10) / granularity;
    quant.xn = 1.995262 / granularity;

    recent = 0;
    iter= 0;
    total_iter = 0;
    accept = 0;
    rej = 0;
    recent = 0;
    sols = sol;
    all_sols = [];
    all_sol_costs = [];

    % iteration parameters to tweak
    max_iter = 50;
    max_accept = 30;
    max_rej = 30;
    cost_diff = 1.5;
    max_recent = 15;

    % temperature parameters to tweak
    T = 1;
    T_min = 0.25;
    alpha = 0.95;
    k = 1;

    % worst case is 100% error
    sol_cost = 100;
    cost_old = sol_cost;
    cost_new = sol_cost;

    % fig(1) = figure;
    % fig(2) = figure;
    % fig(3) = figure;

    while ((rej <= max_rej) & (T > T_min))
        % xn+1 = xn + randn
        sols = generateNeighbors(sol, quant, duration);

        %fn+1(xn+1)
        for i=1:size(sols,2)
          if (any(contains(all_sols, sol)))
             recent = recent + 1;

             if (recent > max_recent)
               recent = 0;
               % adaptivity: if stuck in a cycle, increase temperature
               T = T / alpha;
               %generate new neighbors from one of the current neighbors
               sols = generateNeighbors(sols(floor(size(sols,2) / 2)), quant, duration);
             end
          end

          iter = iter + 1;

          if (iter >= max_iter) | (accept >= max_accept)
            % geometric cooling
            T = alpha * T;
            total_iter = total_iter + iter;

            if (total_iter > 750)
              disp(strcat('Iteration count: ', num2str(total_iter)));
              disp(strcat('Best solution: ', num2str(sol_cost)));
              return;
            end

            iter = 1;
            accept = 1;
          end

          sol = sols(i);
          cost_new = runVadBatchDirect(y, fs, duration, giventags, sol);

          % gathering stats
          all_sols = [all_sols sol];
          all_sol_costs = [all_sol_costs cost_new];

          % delta_f = fn+1(xn+1) - fn(xn)
          delta_cost = cost_new - cost_old;

          % accept new solution if it's better
          if (delta_cost < 0)
            if (sol_cost > cost_new)
              best_sol = sol;
              sol_cost = cost_new;
            end

            cost_old = cost_new;
            accept = accept + 1;
            rej = 0;
            recent = 0;
          % accept if p=exp(-delta_f/T) > r
          elseif (delta_cost < cost_diff & exp(-delta_cost / (k * T)) > rand)
            cost_old = cost_new;
            accept = accept + 1;
            break;
          else
            rej = rej + 1;
          end
        end
    end

    disp(strcat('Iteration count: ', num2str(total_iter)));
    disp(strcat('Best solution: ', num2str(sol_cost)));
    % runvad(wavfilename, tagfilename, fig, best_sol);
end

function [bin_arr] = contains(struct_arr, struct)
  bin_arr = [];

  for i = 1:size(struct_arr, 2)
    if (isequal(struct_arr(i), struct))
      bin_arr = [bin_arr 1];
    else
      bin_arr = [bin_arr 0];
    end
  end
end

function [neighbors] = generateNeighbors(node, quant, duration)
    %generate 10 neighbours.
    % +/- a quantization level to each parameter and make it a neighbour
    neighbors = [];
    if(node.of < 5)
        nn = node;
        nn.of = nn.of + quant.of;
        neighbors = [neighbors nn];
    end

    if(node.of >= 2)
        nn = node;
        nn.of = nn.of - quant.of;
        neighbors = [neighbors nn];
    end

    if(node.ts < duration/2)
        nn = node;
        nn.ts = nn.ts + quant.ts;
        neighbors = [neighbors nn];
    end

    if(node.ts > quant.ts)
        nn = node;
        nn.ts = nn.ts - quant.ts;
        neighbors = [neighbors nn];
    end

    if(node.tn < duration/2)
        nn = node;
        nn.tn = nn.tn + quant.tn;
        neighbors = [neighbors nn];
    end

    if(node.tn > quant.tn)
        nn = node;
        nn.tn = nn.tn - quant.tn;
        neighbors = [neighbors nn];
    end

    if(node.ti < 10e-2)
        nn = node;
        nn.ti = nn.ti + quant.ti;
        neighbors = [neighbors nn];
    end

    if(node.ti > 10e-3)
        nn = node;
        nn.ti = nn.ti - quant.ti;
        neighbors = [neighbors nn];
    end

    if(node.gx < 1000)
        nn = node;
        nn.gx = nn.gx + quant.gx;
        neighbors = [neighbors nn];
    end

    if(node.gx > 10)
        nn = node;
        nn.gx = nn.gx - quant.gx;
        neighbors = [neighbors nn];
    end

    if(node.xn < 1.995262)
        nn = node;
        nn.xn = nn.xn + quant.xn;
        neighbors = [neighbors nn];
    end

    if(node.xn > quant.xn)
        nn = node;
        nn.xn = nn.xn - quant.xn;
        neighbors = [neighbors nn];
    end
end
