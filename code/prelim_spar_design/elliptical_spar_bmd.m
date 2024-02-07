%% Givens
m = 1.627;
W = m * 9.80665;
n = 1;
b = (0.665 + 0.185) * 2;

C = 4/pi * n * W / b;

y = linspace(0, b/2, 500)';
y_full = [-flipud(y); y];

%% Define lift dist and shear as functions so integration is more precise
l_y = @(y) C*sqrt(1-(2.*y./b).^2);

% shear BC: no shear at end of cantilever
V_y = @(y) integral(@(x) -l_y(x), 0, y) + integral(@(x) l_y(x), 0, b/2);

% analytical bending moment (from -b/2 to 0)
BM_predicted = @(y) n*W / (6 * b.^2 * pi) .* (...
    3.*b.^2 .* sqrt(b.^2 - 4.*y.^2)...
    -(b.^2-4.*y.^2).^(3/2)...
    +6.*b.^2.*y.*asin(2.*y./b)...
    +3.*pi.*b.^2.*y);

%% Plot Dist. Load
figure
subplot(311)
plot(y_full, [flipud(l_y(y)); l_y(y)], "DisplayName", "Lift Distribution", "LineWidth", 2)
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$\ell(y)$$ (N/m)", "Interpreter", "latex")
grid
title("Elliptical Wing Loading", "Interpreter", "latex")

%% Integration
shear_force = arrayfun(V_y, y);
bending_moment = arrayfun(V_y, y);

for i = 1:length(y)
    bending_moment(i) = -trapz(y(1:i), shear_force(1:i), 1);
end
bending_moment = bending_moment - bending_moment(end);

%% Compare with exact formulae on slides
expected_M_0 = n*W*b/(3*pi);
calculated_M_0 = bending_moment(1);

%% Plot BMD etc
subplot(312)
plot(y_full, [flipud(shear_force); shear_force], "LineWidth", 2)
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$V(y)$$ (N/m)", "Interpreter", "latex")
grid
title("Zero shear at tip assumed", "Interpreter", "latex")


subplot(313)
plot(y_full, [flipud(bending_moment); bending_moment], "LineWidth", 2)
hold on
% plot using flipped coordinates
plot(y_full, [BM_predicted(-flipud(y)); flipud(BM_predicted(-flipud(y)))], "--", "LineWidth", 2)
xlabel("$$y$$ (m)", "Interpreter", "latex")
ylabel("$$M(y)$$ (N/m)", "Interpreter", "latex")
grid
title(sprintf("Exact $$M_0$$ from slides is %.4f Nm while numerical EBT gives %.4f Nm\n", ...
    expected_M_0, calculated_M_0), "Interpreter", "latex")


%% Section Sizing
w = 0.011;
h = 0.011;
c_max = h/2;
I = w*h^3/12;

sigma_max_spar = bending_moment .* c_max ./ I;

fprintf("Maximum axial stress is %.2f MPa\n", max(sigma_max_spar)/1e6);