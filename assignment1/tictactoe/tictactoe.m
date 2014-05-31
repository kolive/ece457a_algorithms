
function varargout = tictactoe(varargin)
% TICTACTOE M-file for tictactoe.fig
%      TICTACTOE, by itself, creates a new TICTACTOE or raises the existing
%      singleton*.
%
%      H = TICTACTOE returns the handle to a new TICTACTOE or the handle to
%      the existing singleton*.
%
%      TICTACTOE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TICTACTOE.M with the given input arguments.
%
%      TICTACTOE('Property','Value',...) creates a new TICTACTOE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before tictactoe_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to tictactoe_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help tictactoe

% Last Modified by GUIDE v2.5 09-May-2012 23:16:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tictactoe_OpeningFcn, ...
                   'gui_OutputFcn',  @tictactoe_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before tictactoe is made visible.
function tictactoe_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to tictactoe (see VARARGIN)

% Choose default command line output for tictactoe
handles.output = hObject;
set(hObject, 'Name', 'Tic Tac Toe');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes tictactoe wait for user response (see UIRESUME)
% uiwait(handles.MTTT);


% --- Outputs from this function are returned to the command line.
function varargout = tictactoe_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==1))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,1);
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==2))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,2);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==3))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,3);
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==4))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,4);
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==5))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,5);
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==6))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,6);
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==7))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,7);
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==8))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,8);
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
avsq=getappdata(gcbf,'avsq');
if isempty(avsq(avsq==9))
    set(handles.dispturn,'String','dont cheat');
else
    picksquare(handles,9);
end

function picksquare(handles,num)
turn=getappdata(gcbf,'turn');
avsq=getappdata(gcbf,'avsq');
avsq(avsq==num)=[];
setappdata(gcbf,'avsq',avsq);
board=getappdata(gcbf,'board');
board(num)=turn;
if turn==1
    set(eval(['handles.pushbutton' int2str(num)]),'String','X');
    turn=2;
    set(handles.dispturn,'String','O Turn');
elseif turn==2
    set(eval(['handles.pushbutton' int2str(num)]),'String','O');
    turn=1;
    set(handles.dispturn,'String','X Turn');
end
setappdata(gcbf,'turn',turn);
setappdata(gcbf,'board',board);
[win]=checkboard(board);

if win~=0
    for i=1:9
        set(eval(['handles.pushbutton' int2str(i)]),'Enable','off');
    end    
	if win==1
       set(handles.dispturn,'String','X WINS!');
    elseif win==2
       set(handles.dispturn,'String','O WINS!');
    end
end

if win==0
    if isempty(avsq)
       for i=1:9
           set(eval(['handles.pushbutton' int2str(i)]),'Enable','off');
       end
       set(handles.dispturn,'String','Tie Game');
       return
    end
    if turn==2
        decision(handles);
    end
end

function [win]=checkboard(b)    
win=0;
for i=1:2
    if b(1)==i && b(2)==i && b(3)==i
        win=i;
    elseif b(4)==i && b(5)==i && b(6)==i
        win=i;
    elseif b(7)==i && b(8)==i && b(9)==i
        win=i;
    elseif b(1)==i && b(4)==i && b(7)==i
        win=i;
    elseif b(2)==i && b(5)==i && b(8)==i
        win=i;
    elseif b(3)==i && b(6)==i && b(9)==i
        win=i;
    elseif b(1)==i && b(5)==i && b(9)==i
        win=i;
    elseif b(3)==i && b(5)==i && b(7)==i
        win=i;
    end
end

% --- Executes on button press in newgame.
function newgame_Callback(hObject, eventdata, handles)
% hObject    handle to newgame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
for i=1:9
    set(eval(['handles.pushbutton' int2str(i)]),'Enable','on');
    set(eval(['handles.pushbutton' int2str(i)]),'String','');
end
turn=ceil(rand*2);
if turn==1
    set(handles.dispturn,'String','X Turn');
elseif turn==2
    set(handles.dispturn,'String','O Turn');
end
setappdata(gcbf,'turn',turn);
board=zeros(1,9);
setappdata(gcbf,'board',board);
avsq=[1:9];
setappdata(gcbf,'avsq',avsq);
if turn==2
    decision(handles);
end

% Kyle's notes:
% This is the function that does the response move, it's rule based
% To convert to minimax, we need a function that can generate each valid
% next state and evaluate to determine min/max

% this works by looking at each possible winning row and checking to see if
% you can win by putting a square there

%http://www.neverstopbuilding.com/minimax
%def score(game, depth)
%    if game.win?(@player)
%        return 10 - depth
%    elsif game.win?(@opponent)
%        return depth - 10
%    else
%        return 0
%    end
%end

%def minimax(game)
%    return score(game) if game.over?
%    scores = [] # an array of scores
%    moves = []  # an array of moves
%
%    # Populate the scores array, recursing as needed
%    game.get_available_moves.each do |move|
%        possible_game = game.get_new_state(move)
%        scores.push minimax(possible_game)
%        moves.push move
%    end
%
%    # Do the min or the max calculation
%    if game.active_turn == @player
%        # This is the max calculation
%        max_score_index = scores.each_with_index.max[1]
%        @choice = moves[max_score_index]
%        return scores[max_score_index]
%    else
%        # This is the min calculation
%        min_score_index = scores.each_with_index.min[1]
%        @choice = moves[min_score_index]
%        return scores[min_score_index]
%    end
%end

function game_tree = create_game_tree(board)
  % 3 matrixes, one for each node and it's score, one for each node and
  % it's parent, one for each node and it's level
  nodes = []
  node_scores = [];
  node_parents = [];
  node_levels = [];
  node_id = 0;
 
  node_parents = [node_parents, -1];
  node_scores = [node_scores, eval(board)];
  node_levels = [node_levels, 0];
  node_parents = [node_parents, -1];
  
  %init generation
  nodes = [ nodes , board ];
  %for each node in nodes
  while( node_id < size(nodes,2) )        
      %score the node
      node_scores = [node_scores, eval(nodes(node_id))]; 
      
      %for each child of the current node
      % set the node = [node, new node]
      % set the node_parents = [node_parents, node_id]; 
      % set the node_levels = [node_levels, node_levels(node_id)+1]; 
      
      node_id = node_id + 1;
  end
  %set the level of the node
  %increment node counter
  %calculate children, push into nodes - How to keep track of node level? Use parent's
  %level + 1? 
  %check if there are more nodes to investigate (i.e., if current node
  %index < max node index
  
  %todo: check syntax
  game_tree = [ nodes ; node_scores ; node_parents ; node_levels ];
  

%(* Initial call for maximizing player *)
%minimax(origin, depth, TRUE)
function optimal_score = minimax(board)
  create_game_tree();
  optimal_score = 1;

function child = get_child_with_score(optimal_score)
  child = 1;

% if there's no winning spot, switch to the view of the opponent and try to
% block (j = turn identifier), num=square to put piece in
function decision(handles)
  avsq=getappdata(gcbf,'avsq');
  board=getappdata(gcbf,'board');
  num=0;
  %i=1;
  j=2;
  pause(0.5);

  %try to win, if u can't try to block
  %while num==0
  %    if i==1     
  %    	s=[1 2 3];
  %    elseif i==2
  %    	s=[4 5 6];
  %    elseif i==3
  %    	s=[7 8 9];
  %    elseif i==4
  %    	s=[1 4 7];
  %    elseif i==5
  %    	s=[2 5 8];
  %    elseif i==6
  %    	s=[3 6 9];
  %    elseif i==7
  %    	s=[1 5 9];
  %    elseif i==8
  %    	s=[3 5 7];
  %    elseif i==9 && j==2
  %        j=1;
  %        i=1;
  %    elseif i==9 && j==1
  %        num=avsq(ceil(rand*(length(avsq)))); %pick any sq if everything fails
  %    end
  %	
  %	if board(s(1))==j && board(s(2))==j && board(s(3))==0
  %        num=s(3);
  %	elseif board(s(1))==j && board(s(2))==0 && board(s(3))==j
  %        num=s(2);
  %	elseif board(s(1))==0 && board(s(2))==j && board(s(3))==j
  %        num=s(1);
  %	end
  %    i=i+1;
  %end

  optimal_score = minimax(board);
  num = get_child_with_score(optimal_score);

  picksquare(handles,num);

function eval = eval_board(board)
%try to win, if u can't try to block
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

  % --- Executes during object creation, after setting all properties.
  function MTTT_CreateFcn(hObject, eventdata, handles)
  % hObject    handle to MTTT (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    empty - handles not created until after all CreateFcns called
