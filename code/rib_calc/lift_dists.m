%% Params
n = 3;
m0 = 1.63;
W = m0 * 9.08665;
b = 1.7;
spar_d = 0.465 * 25.4/1000;
s_crush = 1;
s_pullout = 1.1;

%% Planform
control_points_y = mirror_vert(0.001 * [0; 92.5; 185; 850], true);
control_points_c = mirror_vert(0.001 * [780; 600; 400; 120]);
control_points_tc = mirror_vert([0.18; 0.18; 0.14; 0.0756]);
control_points_xle = mirror_vert([0; 0.120; 0.215; 0.598]);

% assume rectangles for now


%% Rib Points (postiive only)
rib_y = mirror_vert(0.001 * [0; 92.5; 185; 319.588; 452.588; 585.588; 718.588; 850], true);
rib_t = mirror_vert(25.4/1000 * [1/16; 1/16; 1/16; 1/16; 1/16; 1/16; 1/16; 1/16]);

% interp intermediate ribs
[rib_c, rib_A, rib_h, rib_xle] = interp_ribs(...
    rib_y, control_points_y,...
    control_points_c, control_points_tc, control_points_xle);

num_ribs = length(rib_y);


%% Lift Loads
ell = @(y) 4.*n.*W/(b.*pi) .* sqrt(1-(2.*y./b).^2);

F = zeros(num_ribs, 1);
for i = 1:num_ribs
    
    if i == 1
        bound_l = rib_y(i);
    else
        bound_l = (rib_y(i-1) + rib_y(i)) / 2;
    end

    if i == num_ribs
        bound_r = rib_y(i);
    else
        bound_r = (rib_y(i+1) + rib_y(i)) / 2;
    end

    F(i) = integral(ell, bound_l, bound_r);
end

crush_stress = F ./ (rib_t .* spar_d);
pullout_stress = F ./ ((rib_h - spar_d).*rib_t);

%% Printout
for i = 1:num_ribs
    if rib_y(i) >= 0
        fprintf("y = %.4f m: F = %.4f N\n", rib_y(i), F(i));
    end
end

fprintf("[")
for i = 1:num_ribs
    if rib_y(i) >= 0
        fprintf("%.4f", rib_y(i));
        if i ~= num_ribs
            fprintf(", ");
        end
    end
    
end
fprintf("]\n")

fprintf("[")
for i = 1:num_ribs
    if rib_y(i) >= 0
        fprintf("%.4f", F(i));
        if i ~= num_ribs
            fprintf(", ");
        end
    end
   
end
fprintf("]\n")


%% Plot
figure
subplot(211)
hold on
for i = 1:num_ribs
    plot([rib_y(i); rib_y(i)], [rib_xle(i); rib_xle(i) + rib_c(i)]* ell(0),...
        "Color", "#5ED822", "LineWidth", 2);
end
title("Rib Locations wrt Planform")
xlabel("x position (m)")
ylabel("Lift Per Span (N/m)")
grid

subplot(212)
yyaxis left
fplot(ell, [-b/2 b/2])
ylabel("Lift Per Span (N/m)");
yyaxis right
bar(rib_y, F, "FaceAlpha", 0.2);
title("Rib Loading")
ylabel("Rib Load (N)")
xlabel("x position (m)")
grid

figure
subplot(211)
bar(rib_y, crush_stress / 1e6, "FaceAlpha", 0.2);
ylabel("Rib Crush Stress (MPa)")
xlabel("x position (m)")
title(sprintf("Rib Crushing (Limit: %.2f MPa)", s_crush))
grid

subplot(212)
bar(rib_y, pullout_stress/ 1e6, "FaceAlpha", 0.2);
ylabel("Rib Pullout Stress (MPa)")
xlabel("x position (m)")
title(sprintf("Rib Pullout (Limit: %.2f MPa)", s_pullout))
grid





