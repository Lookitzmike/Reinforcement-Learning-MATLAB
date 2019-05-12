row = 10;
col = 10;

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

while max(state)>1 % remove walls until there is one simply connected region
    tid=ceil(col*row*rand(15,1)); % get a set of temporary ID's
    cityblock=rCol(tid)+rRow(tid); % get distance from the start
    is_linked=(state(tid)==1); % The start state is in region 1 - see if they are linked to the start
    temp = sortrows(cat(2,tid,cityblock,is_linked),[3,2]); % sort id's by start-link and distance
    tid = temp(1,1); % get the id of the closest unlinked intersection
    
    dir = ceil(8*rand);
        if abs((rRow(tid)-row/2))<abs((rCol(tid)-col/2))
            if dir>6
                dir=4;
            end
            if dir>4
                dir=3;
            end
        else
            if dir>6
                dir=2;
            end
            if dir>4
                dir=1;
            end
        end
        
    switch dir
    case -1
        
    case 1
        if mLeft(tid)>0 && state(tid)~=state(mLeft(tid))
            state( state==state(tid) | state==state(mLeft(tid)) )=min([state(tid),state(mLeft(tid))]);
            mRight(mLeft(tid))=-mRight(mLeft(tid));
            mLeft(tid)=-mLeft(tid);
        end
    case 2
        if mRight(tid)>0 && state(tid)~=state(mRight(tid))
            state( state==state(tid) | state==state(mRight(tid)) )=min([state(tid),state(mRight(tid))]);
            mLeft(mRight(tid))=-mLeft(mRight(tid));
            mRight(tid)=-mRight(tid);
        end
    case 3
        if mUp(tid)>0 && state(tid)~=state(mUp(tid))
            state( state==state(tid) | state==state(mUp(tid)) )=min([state(tid),state(mUp(tid))]);
            mDown(mUp(tid))=-mDown(mUp(tid));
            mUp(tid)=-mUp(tid);
        end
    case 4
        if mDown(tid)>0 && state(tid)~=state(mDown(tid))
            state( state==state(tid) | state==state(mDown(tid)) )=min([state(tid),state(mDown(tid))]);
            mUp(mDown(tid))=-mUp(mDown(tid));
            mDown(tid)=-mDown(tid);
        end
    otherwise
        dir
        error('quit')
    end
    
end

line([.5,col+.5],[.5,.5]) % draw top border
line([.5,col+.5],[row+.5,row+.5]) % draw bottom border
line([.5,.5],[1.5,row+.5]) % draw left border
line([col+.5,col+.5],[.5,row-.5])  % draw right border

axis equal
axis([.5,col+.5,.5,row+.5])
axis off
set(gca,'YDir','reverse')

for ii=1:length(mRight)
    if mRight(ii)>0 % right passage blocked
        line([rCol(ii)+.5,rCol(ii)+.5],[rRow(ii)-.5,rRow(ii)+.5]);
        hold on
    end
    if mDown(ii)>0 % down passage blocked
        line([rCol(ii)-.5,rCol(ii)+.5],[rRow(ii)+.5,rRow(ii)+.5]);
        hold on
    end
    
end

n = 10;
maze(1,1) = 1; % Start
maze(n,n) = 10; % Goal
text(1,1,'START','HorizontalAlignment','center', 'Color', 'blue')
text(n,n,'GOAL','HorizontalAlignment','center', 'Color', 'red')
axis off




