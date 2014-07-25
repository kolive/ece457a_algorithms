% Temp file for lazy calculations
function [ res ] = toy_distance()

    x_l = 0;
    x_h = 4;
    y_l = 0;
    y_h = 2;
    gran = 3;
    
    % x, y, result
    res = zeros(gran^2,3);
    j = 0;
    for x =linspace(x_l,x_h,gran)
        for y=linspace(y_l,y_h,gran)
            j = j + 1;
            res(j,:) = [x, y, obj(x,y)]
        end
    end
end
       
function [ g ] = obj(x,y)
    g = 0;
    
    for i=1:3
        g = g + abs((x*i+y)-(3*i+1));
    end

end
           