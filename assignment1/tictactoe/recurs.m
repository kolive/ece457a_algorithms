function [a, b] = recurs(num)
    if (num == 1)
        a = 1;
        b = 1;
    else
        a = num + recurs(num - 1);
        b = num + recurs(num - 1);
    end
end