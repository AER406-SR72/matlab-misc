% Load data from the text file
data = load('NACA0018.dat');
one_x = data(:,1);
one_y = data(:,2);

data = load('BOEING.dat');
two_x = data(:,1);
two_y = data(:,2);

data = load('NACAAMES.dat');
three_x = data(:,1);
three_y = data(:,2);

% determine max and min y points
max_y = max([one_y; two_y; three_y]);
min_y = min([one_y; two_y; three_y]);

%% Plots
figure()

spacing = 0.2;
plot(one_x, one_y, "LineWidth", 1)
text(0.2, 0, "Body: NACA 0018", "Interpreter", "latex", "color", [1 1 1])
hold on
plot(two_x, two_y - 1*spacing, "LineWidth", 1)
% this text block needed a little fudging
text(0.2, -1*spacing + 0.005, "Wing Root: Boeing NF14", "Interpreter", "latex", "color", [1 1 1])

plot(three_x, three_y - 2*spacing, "LineWidth", 1)
text(0.2, -2*spacing, "Wing Tip: NASA AMES", "Interpreter", "latex", "color", [1 1 1])

pbaspect([3 1 1])
axis equal
axis off

plot_darkmode
exportgraphics(gcf,"airfoils.png", 'Resolution', 500, ...
    'BackgroundColor','#191919')