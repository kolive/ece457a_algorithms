
function eval = eval_board(board)
i = 1;
xscore = 0;
oscore = 0;
while i<=8
    if i==1     
    	s=[1 2 3];
    elseif i==2
    	s=[4 5 6];
    elseif i==3
    	s=[7 8 9];
    elseif i==4
    	s=[1 4 7];
    elseif i==5
    	s=[2 5 8];
    elseif i==6
    	s=[3 6 9];
    elseif i==7
    	s=[1 5 9];
    elseif i==8
    	s=[3 5 7];
    end
    
	%check row to see if X can win
    if(board(s(1)) ~= 2 && board(s(2)) ~= 2 && board(s(3)) ~= 2)
        xscore = xscore + 1;
    end
    %check row to see if O can win
    if(board(s(1)) ~= 1 && board(s(2)) ~= 1 && board(s(3)) ~= 1)
        oscore = oscore + 1;
    end
    
    i=i+1;
end
eval = xscore - oscore;

function [ blank_indices ] = get_zeros( board )
    zero_loc = 1;
    blank_indices = [];
    for b = board
        if(b == 0)
            blank_indices = [blank_indices, zero_loc];
        end
        zero_loc = zero_loc + 1;
    end
