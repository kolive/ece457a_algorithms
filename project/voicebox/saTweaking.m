%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Author: Owen Wang

% example running: [sol_cost, best_sol, all_sol_costs, total_iter] = saTweaking('audio2.wav', 'audio2.tag', 50);

% Inputs:
% wavfilename is the name of the wav file used in voice detection
% tagfilename is the name of the accompanying tag file
% granularity is the granularity of solutions explored. Larger means more granularity

% Outputs:
% sol_cost is the VAD error % of the best solution found
% best_sol is the VAD parameters of the best solution
% all_sol_costs is a matrix of the best solution found per iteration
% total_iter is the count of how many iterations were performed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sol_cost, best_sol, all_sol_costs, total_iter]=saTweaking(wavfilename, tagfilename, granularity)
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

    % iteration parameters to tweak
    max_iter = 60;
    max_accept = 20;
    max_rej = 300;
    init_cost_diff = 1.5;
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

    recent = 0;
    iter= 0;
    total_iter = 0;
    accept = 0;
    rej = 0;
    recent = 0;
    sols = sol;
    all_sols = [];
    all_sol_costs = [];
    cost_diff = init_cost_diff;

    % fig(1) = figure;
    % fig(2) = figure;
    % fig(3) = figure;

    while ((rej <= max_rej) & (T > T_min))
        % xn+1 = xn + randn
        sols = generateNeighbors(sol, quant, duration, T);

        %fn+1(xn+1)
        for i=1:size(sols,2)
          if (any(contains(all_sols, sol)))
             recent = recent + 1;

             if (recent > max_recent & T < 1)
               recent = 0;
               % adaptivity: if stuck in a cycle, increase temperature
               T = T / alpha;
               cost_diff = init_cost_diff * T;
               %generate new neighbors from one of the current neighbors
               sols = generateNeighbors(sols(floor(size(sols,2) / 2)), quant, duration, T);
             end
          end

          if (i > size(sols, 2))
            continue;
          end

          iter = iter + 1;
          total_iter = total_iter + 1;

          % display at 1000 iterations
          if (total_iter == 1000)
            disp(strcat('Best solution at 1000: ', num2str(sol_cost)));
          end

          if (iter >= max_iter) | (accept >= max_accept)
            % geometric cooling
            T = alpha * T;
            cost_diff = init_cost_diff * T;

            iter = 1;
            accept = 1;
          end

          sol = sols(i);
          cost_new = runVadBatchDirect(y, fs, duration, giventags, sol);

          % gathering stats
          all_sols = [all_sols sol];
          all_sol_costs = [all_sol_costs cost_old];

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
          % accept if p = exp(-delta_f/(boltzmann's constant * T)) > r
          elseif (delta_cost < cost_diff & exp(-delta_cost / (k * T)) > rand)
            cost_old = cost_new;
            accept = accept + 1;
            break;
          else
            rej = rej + 1;
          end
        end
    end

    total_iter = total_iter + iter;
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

function [neighbors] = generateNeighbors(node, quant, duration, T)
    %generate 10 neighbours.
    % +/- a quantization level to each parameter and make it a neighbour
    neighbors = [];
    if(node.of + (quant.of * T) < 5)
        nn = node;
        nn.of = nn.of + (quant.of * T) - rand;
        neighbors = [neighbors nn];
    end

    if(node.of - (quant.of * T) >= 2)
        nn = node;
        nn.of = nn.of - (quant.of * T) - rand;
        neighbors = [neighbors nn];
    end

    if(node.ts + (quant.ts * T) < duration/2)
        nn = node;
        nn.ts = nn.ts + (quant.ts * T) + rand;
        neighbors = [neighbors nn];
    end

    if(node.ts - (quant.ts * T) > quant.ts)
        nn = node;
        nn.ts = nn.ts - (quant.ts * T) - rand;
        neighbors = [neighbors nn];
    end

    if(node.tn + (quant.tn * T) < duration/2)
        nn = node;
        nn.tn = nn.tn + (quant.tn * T) + rand;
        neighbors = [neighbors nn];
    end

    if(node.tn - (quant.tn * T) > quant.tn)
        nn = node;
        nn.tn = nn.tn - (quant.tn * T) - rand;
        neighbors = [neighbors nn];
    end

    if(node.ti + (quant.ti * T) < 10e-2)
        nn = node;
        nn.ti = nn.ti + (quant.ti * T);
        neighbors = [neighbors nn];
    end

    if(node.ti - (quant.ti * T) > 10e-3)
        nn = node;
        nn.ti = nn.ti - (quant.ti * T);
        neighbors = [neighbors nn];
    end

    if(node.gx + (quant.gx * T) < 1000)
        nn = node;
        nn.gx = nn.gx + (quant.gx * T) + rand;
        neighbors = [neighbors nn];
    end

    if(node.gx - (quant.gx * T) > 10)
        nn = node;
        nn.gx = nn.gx - (quant.gx * T) - rand;
        neighbors = [neighbors nn];
    end

    if(node.xn + (quant.xn * T) < 1.995262)
        nn = node;
        nn.xn = nn.xn + (quant.xn * T) + rand;
        neighbors = [neighbors nn];
    end

    if(node.xn - (quant.xn * T) > quant.xn)
        nn = node;
        nn.xn = nn.xn - (quant.xn * T) - rand;
        neighbors = [neighbors nn];
    end
end
