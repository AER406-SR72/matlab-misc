function [rib_c, rib_A, rib_h, rib_xle] = interp_ribs(rib_y, control_points_y, ...
    control_points_c, control_points_tc, control_points_xle)
% Interpolation function to get rib chord at each point
rib_c = interp1(control_points_y, control_points_c, rib_y, "linear");
rib_tc = interp1(control_points_y, control_points_tc, rib_y, "linear");
rib_A = rib_tc .* rib_c.^2;
rib_h = rib_tc .* rib_c;
rib_xle = interp1(control_points_y, control_points_xle, rib_y, "linear");
end