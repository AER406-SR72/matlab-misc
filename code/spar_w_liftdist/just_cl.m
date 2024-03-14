W = 1.627 .* 9.80665;

%% Colors
C1 = [0    0.4470    0.7410];
C2 = [0.8500    0.3250    0.0980];
C3 = [0.9290    0.6940    0.1250];

CASE = "Full_stall";

%% Read Lift Dist
dist_cl = readmatrix(sprintf("%s_CL.csv", CASE));
y_cl = dist_cl(2:end, 1);
cl_y = dist_cl(2:end, 2);

dist_l = readmatrix(sprintf("%s_L.csv", CASE));
y = dist_l(2:end, 1);
l_y = dist_l(2:end, 2);
% fix bullshit
y = y(l_y > 0);
l_y = l_y(l_y > 0);
l_y = W ./ trapz(y, l_y) .* l_y;

b = max(y) - min(y);
y_smooth = linspace(-b/2, b/2, 400);

% interpolate
l_y_smooth = interp1(y, l_y, y_smooth, "spline");

[~, idx_y0] = min(abs(y_smooth));
l_elp = 4 * W / (b*pi) .*sqrt(1-(2.*y_smooth./b).^2);


%% Plots
figure;

% CL
subplot(211)
plot(y_cl, cl_y, "LineWidth", 2)
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$C_L(y)$$", "Interpreter", "latex")
grid
title("$$C_L$$ Distribution", "Interpreter", "latex")
ylim([0, 1.2])
yticks([0, 0.3, 0.6, 0.9, 1.2])

% Lift Distr
subplot(212)
plot(y, l_y, "LineWidth", 2, "DisplayName", "Actual Lift Distr.")
hold on
area(y, l_y, "FaceAlpha", 0.5, "FaceColor", C1, "EdgeColor","none", "HandleVisibility", "off")
plot(y_smooth, l_elp, "LineWidth", 1, "Color", C3, "DisplayName", "Elliptical");
area(y_smooth, l_elp, "FaceAlpha", 0.1, "FaceColor", C3,"EdgeColor", "none", "HandleVisibility", "off")

xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$\ell(y)$$ (N/m)", "Interpreter", "latex")
grid
title(sprintf("Lift Distribution (n = 1)"), "Interpreter", "latex")
