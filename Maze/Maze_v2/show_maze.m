function show_maze(row, col, rRow, rCol, ~, ~, mRight, mDown,showMaze)
figure(showMaze)
line([.5,col+.5],[.5,.5]) % draw top border
line([.5,col+.5],[row+.5,row+.5]) % draw bottom border
line([.5,.5],[1.5,row+.5]) % draw left border
line([col+.5,col+.5],[.5,row-.5])  % draw right border
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
axis equal
axis([.5,col+.5,.5,row+.5])
axis off
set(gca,'YDir','reverse')
return