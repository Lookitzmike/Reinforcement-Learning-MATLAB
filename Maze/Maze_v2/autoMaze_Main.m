row = 10;
col = 10;
pattern = 's'; % Random(r), vertical(v), horizontal(h), checkerboard(c), spiral(s), burst(b)

rand('state', sum(100*clock))
[rCol, rRow] = meshgrid(1:col, 1:row);
state = reshape (1:row*col, row, col); % State checks for connected regions
id_Intersection = reshape(1:row*col, row, col); % Identify intersection of maze

% Create pointers to adjacent intersections
mLeft = (zeros(size(id_Intersection)));
mRight = (zeros(size(id_Intersection)));
mUp = (zeros(size(id_Intersection)));
mDown = (zeros(size(id_Intersection)));

mLeft(:,2:size(id_Intersection, 2)) = id_Intersection(:,1:size(id_Intersection, 2)-1);
mRight(:,1:size(id_Intersection, 2)-1) = id_Intersection(:,2:size(id_Intersection, 2));
mUp(2:size(id_Intersection,1),:) = id_Intersection(1:size(id_Intersection, 1)-1, :);
mDown(1:size(id_Intersection,1)-1,:) = id_Intersection(2:size(id_Intersection, 1), :);

% Sort graph entities 
maze = cat(2,reshape(id_Intersection,row*col,1),reshape(rRow,row*col,1),reshape(rCol,row*col,1),reshape(state,row*col,1),...
    reshape(mLeft,row*col,1),reshape(mUp,row*col,1),reshape(mRight,row*col,1),reshape(mDown,row*col,1));
id_Interseciton = maze(:,1);
rRow=maze(:,2);
rCol=maze(:,3);
state=maze(:,4);
mLeft=maze(:,5);
mUp=maze(:,6);
mRight=maze(:,7);
mDown=maze(:,8);
clear maze;

% Create random maze
[state, mLeft, mUp, mRight, mDown] = makePattern(row, col, pattern, id_Intersection, ...
    rRow, rCol, state, mLeft, mUp, mRight, mDown);

% Show maze
showMaze=figure('KeyPressFcn', @keyPress, 'color', 'white');
show_maze(row, col, rRow, rCol, mLeft, mUp, mRight, mDown, showMaze); % Call show_maze Function

% Start 
cursor_pos=[1,1];
current_id=1;
figure(showMaze)
text(cursor_pos(1), cursor_pos(2), '\diamondsuit', 'HorizontalAlignment', 'Center',...
   'color', 'b')
set(gcf, 'Units', 'normalized');
set(gcf, 'position', [0 0 1 .91]);
tic

% Keep processing keystrokes till maze solved
while ~all(cursor_pos == [col, row])
    waitfor(gcf, 'CurrentCharacter')
    set(gcf, 'CurrentCharacter', '~') % Update to another character so repeats are reconized
    
    % Key updated by move_spot function
    switch double(key(1))
        case 108 % left
            if mLeft(current_id) < 0 % check for legal move
                current_id = -mLeft(current_id);
                cursor_pos(1)=cursor_pos(1)-1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit',...
                    'HorizontalAlignment','Center','color','black');
            end
        case 114 % right
            if mRight(current_id)<0 % check for legal move
                current_id=-mRight(current_id);
                cursor_pos(1)=cursor_pos(1)+1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit',...
                    'HorizontalAlignment','Center','color','black');
            end
        case 117 % up
            if mUp(current_id)<0 % check for legal move
                current_id=-mUp(current_id);
                cursor_pos(2)=cursor_pos(2)-1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit',...
                    'HorizontalAlignment','Center','color','black');
            end
        case 100 % down
            if mDown(current_id)<0 % check for legal move
                current_id=-mDown(current_id);
                cursor_pos(2)=cursor_pos(2)+1;
                text(cursor_pos(1),cursor_pos(2),'\diamondsuit',...
                    'HorizontalAlignment','Center','color','black');
            end
        otherwise
    end
end
title(cat(2,' You Win ',20))
return




                
