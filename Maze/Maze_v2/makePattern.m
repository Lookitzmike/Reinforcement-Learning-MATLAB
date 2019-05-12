function [state, mLeft, mUp, mRight, mDown]=makePattern(row,col,pattern,~, rRow, rCol, state, mLeft, mUp, mRight, mDown)
while max(state)>1 % remove walls until there is one simply connected region
    tid=ceil(col*row*rand(15,1)); % get a set of temporary ID's
    cityblock=rCol(tid)+rRow(tid); % get distance from the start
    is_linked=(state(tid)==1); % The start state is in region 1 - see if they are linked to the start
    temp = sortrows(cat(2,tid,cityblock,is_linked),[3,2]); % sort id's by start-link and distance
    tid = temp(1,1); % get the id of the closest unlinked intersection
    
    % The pattern is created by selective random removal of vertical or 
    % horizontal walls as a function of position in the maze. I find the
    % checkerboard option the most challenging. Other patterns can be added
    
    switch upper(pattern) 
    case 'C' % checkerboard
        dir = ceil(8*rand);
        nb=3;
        block_size =  min([row,col])/nb;
        while block_size>12
            nb=nb+2;
            block_size =  min([row,col])/nb;
        end
        odd_even = (ceil(rRow(tid)/block_size)*ceil(col/block_size) + ceil(rCol(tid)/block_size));
        if odd_even/2 == floor(odd_even/2)
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
    case 'B' % burst
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
    case 'S' %spiral
        dir = ceil(8*rand);
        if abs((rRow(tid)-row/2))>abs((rCol(tid)-col/2))
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
    case 'V'
        dir = ceil(8*rand);
        if dir>6
            dir=4;
        end
        if dir>4
            dir=3;
        end
    case 'H'
        dir = ceil(8*rand);
        if dir>6
            dir=2;
        end
        if dir>4
            dir=1;
        end
        otherwise % random
        dir = ceil(4*rand);
    end

    % after a candidate for wall removal is found, the candidate must pass
    % two conditions. 1) it is not an external wall  2) the regions on
    % each side of the wall were previously unconnected. If successful the
    % wall is removed, the connected states are updated to the lowest of
    % the two states, the pointers between the connected intersections are
    % now negative.
    
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
return