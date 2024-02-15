W = 1.627 .* 9.80665;

%% Colors
C1 = [0    0.4470    0.7410];
C2 = [0.8500    0.3250    0.0980];
C3 = [0.9290    0.6940    0.1250];

CASE = "tkf";

%% Read Lift Dist
dist_l = readmatrix(sprintf("NF844_D_ldist_%s.txt", CASE));
dist_cl = readmatrix(sprintf("NF844_D_CLdist_%s.txt", CASE));
y = dist_l(:, 1);
l_y = dist_l(:, 2);
cl_y = dist_cl(:, 2);
l_y = W ./ trapz(y, l_y) .* l_y;

b = max(y) - min(y);
y_smooth = linspace(-b/2, b/2, 200);
l_elp = max(l_y).*sqrt(1-(2.*y_smooth./b).^2);

% BC: zero at ends
shear_force = cumtrapz(y, -l_y .* sign(y));
shear_force = shear_force - shear_force(end);
bending_moment = cumtrapz(y, -shear_force .* sign(y));
bending_moment = bending_moment - bending_moment(end);

%% Plots
figure;

% CL
subplot(311)
plot(y, cl_y, "LineWidth", 2)
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$C_L(y)$$", "Interpreter", "latex")
grid
title("$$C_L$$ Distribution", "Interpreter", "latex")
ylim([0, 0.9])
yticks([0, 0.3, 0.6, 0.9])

% Lift
subplot(312)
plot(y, l_y, "LineWidth", 2)
hold on
area(y, l_y, "FaceAlpha", 0.5, "FaceColor", C1, "EdgeColor","none")
plot(y_smooth, l_elp, "LineWidth", 1, "Color", C3);
area(y_smooth, l_elp, "FaceAlpha", 0.1, "FaceColor", C3,"EdgeColor", "none")
ylim([0, 15])
yticks([0, 3, 6, 9, 12, 15])

xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$\ell(y)$$ (N/m)", "Interpreter", "latex")
grid
title("Lift Distribution", "Interpreter", "latex")

% BMD
subplot(313)
plot(y, bending_moment, "LineWidth", 2)
hold on
area(y, bending_moment, "FaceAlpha", 0.5, "FaceColor", C1)
% plot using flipped coordinates
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$M(y)$$ (Nm)", "Interpreter", "latex")
grid
yticks([0, 0.5, 1, 1.5, 2, 2.5, 3])
title("Structural Bending Moment", "Interpreter", "latex")
ylim([0, 3])

%% Export
% plot_darkmode
% exportgraphics(gcf,sprintf("BMD_%s.png", CASE), 'Resolution', 600, ...
%     'BackgroundColor','#191919')

exportgraphics(gcf,sprintf("BMD_%s.pdf", CASE))


%% Section Sizing
fprintf("Maximum BM is %.3f Nm\n", max(bending_moment));