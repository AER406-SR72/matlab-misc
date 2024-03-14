W = 1.627 .* 9.80665;
n = 4.91;

%% Colors
C1 = [0    0.4470    0.7410];
C2 = [0.8500    0.3250    0.0980];
C3 = [0.9290    0.6940    0.1250];

CASE = "Full_stall";

%% Read Lift Dist
dist_l = readmatrix(sprintf("%s_L.csv", CASE));
y = dist_l(2:end, 1);
l_y = dist_l(2:end, 2);
% fix bullshit
y = y(l_y > 0);
l_y = l_y(l_y > 0);
l_y = n * W ./ trapz(y, l_y) .* l_y;

b = max(y) - min(y);
y_smooth = linspace(-b/2, b/2, 400);

% interpolate
l_y_smooth = interp1(y, l_y, y_smooth, "spline");

[~, idx_y0] = min(abs(y_smooth));
l_elp = 4 * n * W / (b*pi) .*sqrt(1-(2.*y_smooth./b).^2);

% BC: zero at ends
shear_force = cumtrapz(y_smooth, -l_y_smooth .* sign(y_smooth));
shear_force = shear_force - shear_force(end);
bending_moment = cumtrapz(y_smooth, -shear_force .* sign(y_smooth));
bending_moment = bending_moment - bending_moment(end);

% stations
E = 2.55e9;
y_stns = mirror_vert(0.001 * [0; 92.5; 185; 318; 451; 584; 717; 850], true);
h_stn = mirror_vert(0.001 * [139; 103.5; 52.2; 45.1; 38.0; 30.8; 23.6; 16.4], false);
width = 3.175e-3;
I = width .* h_stn.^3 / 12;
EI = interp1(y_stns, E.*I, y_smooth);
h_smooth = interp1(y_stns, h_stn, y_smooth);
I_smooth = interp1(y_stns, I, y_smooth);

slope = cumtrapz(y_smooth, bending_moment ./ EI);
slope = slope - slope(idx_y0);

deflection = cumtrapz(y_smooth, slope);
deflection = deflection - deflection(idx_y0);

% bending stress
max_b_stress = bending_moment .* h_smooth./2 ./ I_smooth;

%% Plots
figure;

% CL
% Lift
subplot(311)
plot(y, l_y, "LineWidth", 2, "DisplayName", "Actual Lift Distr.")
hold on
area(y, l_y, "FaceAlpha", 0.5, "FaceColor", C1, "EdgeColor","none", "HandleVisibility", "off")
plot(y_smooth, l_elp, "LineWidth", 1, "Color", C3, "DisplayName", "Elliptical");
area(y_smooth, l_elp, "FaceAlpha", 0.1, "FaceColor", C3,"EdgeColor", "none", "HandleVisibility", "off")

xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$\ell(y)$$ (N/m)", "Interpreter", "latex")
grid
title(sprintf("Lift Distribution (scaled to n = %.2f)", n), "Interpreter", "latex")

% BMD
subplot(312)
yyaxis left
plot(y_smooth, bending_moment, "LineWidth", 2)
hold on
area(y_smooth, bending_moment, "FaceAlpha", 0.5, "FaceColor", C1)
% plot using flipped coordinates
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$M(y)$$ (Nm)", "Interpreter", "latex")
grid
title("Spar Loading", "Interpreter", "latex")

yyaxis right
plot(y_smooth, max_b_stress*1e-6, "LineWidth", 2)
sigma_max = max(max_b_stress*1e-6);
yline(sigma_max, "--", "color", C2);
ylabel("Bending Stress (MPa)")
yticks(sort([yticks, sigma_max]))

% Beam Deflection
subplot(313)
yyaxis left
plot(y_smooth, deflection*1e3, "LineWidth", 2)
ylabel("Deflection (mm)")
grid
lims = ylim;
xlabel("$$y$$ (m)", "Interpreter", "latex")

yyaxis right
ylabel("\% Span")
ylim(lims*1e-3 ./ b * 100)
t = yticks;
yticks(sort([yticks, max(lims*1e-3 ./ b * 100)]))

title("Spar Deformation", "Interpreter", "latex")

%% Export
% plot_darkmode
% exportgraphics(gcf,sprintf("BMD_%s.png", CASE), 'Resolution', 600, ...
%     'BackgroundColor','#191919')
set(gcf,'Position',[100 100 600 650])
exportgraphics(gcf,sprintf("BMD_%s.pdf", CASE))