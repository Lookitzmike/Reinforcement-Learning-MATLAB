% Create Maze
n = 10;
maze = [1 1 1 1 -50 1 -50 1 1 1; -50 -50 -50 1 -50 1 1 1 -50 1; 1 1 1 1 -50 -50 1 -50 -50 -50; ...
    -50 1 -50 -50 -50 1 1 1 1 1; -50 1 1 -50 1 1 -50 1 -50 1; ...
    -50 -50 1 -50 -50 -50 -50 1 -50 1; 1 1 1 1 1 1 1 1 -50 1; ...
    1 -50 1 -50 1 1 -50 1 -50 1; 1 -50 -50 1 -50 1 -50 1 -50 -50; ...
    1 1 1 1 1 1 -50 1 1 10];
maze(1,1) = 1; % Start
maze(n,n) = 10; % Goal
disp(maze)


% Visualize Maze
n = length(maze);
figure
imagesc(maze)
colormap(summer)
text(1,1,'START','HorizontalAlignment','center', 'Color', 'blue')
text(n,n,'GOAL','HorizontalAlignment','center', 'Color', 'red')
axis off
