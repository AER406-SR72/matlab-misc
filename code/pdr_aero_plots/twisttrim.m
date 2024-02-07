%% Data
twist = [-4, -3, -2, -1, 0, 1, 2, 3, 4];
trim = [9.5, 8, 6, 4, 2, 0, -2, -4, -6];

%% Colors
C1 = [0    0.4470    0.7410];
C2 = [0.8500    0.3250    0.0980];
C3 = [0.9290    0.6940    0.1250];

%% Plot
plot(twist, trim, "LineWidth", 2)
hold on
fill([min(twist), min(twist), max(twist), max(twist)],...
    [5, 7, 7, 5], "g",...
    "FaceAlpha", 0.5, "EdgeColor","none")
xlabel("Wing Twist (deg)", "Interpreter", "latex")
ylabel("Trimmed $$\alpha$$ (deg)", "Interpreter", "latex")
grid
title("Effect of Wing Twist on Trimmed AoA", "Interpreter", "latex")

%% Export
plot_darkmode
exportgraphics(gcf,"twistsweep.png", 'Resolution', 600, ...
    'BackgroundColor','#191919')