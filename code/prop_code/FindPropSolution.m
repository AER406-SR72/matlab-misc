function [Power_in,prop_eff,motor_eff,esc_eff,i_m,v_m,i_b,v_b,k_e,n_s] = FindPropSolution(Thrust,V,K_v,K_t,i_0,r_m,r_esc,PropData_RPM,RPMtests,PropDia,rho,v_i_n)
%
% inputs:   Thrust - N
%           V - velocity m/s
%           K_v - motor constant rad/s/V
%           K_t - motor torque constant N-m/amp
%           i_0 - motor noload current amps
%           r_m - motor internal resistance
%           r_esc - ESC internal resistance
%           PropData_RPM -- UIUC propdata for all tested RPMS
%           RPMtests - prop test RPM values (rounded to closed 500rpm)
%           PropDia - prop diameter m
%           batt_data -- array of polynomial coefficients for battery
%           v_i_n = voltage*current^0.05 at specific discharge
%
% find prop rpm and J for this thrust (interpolate on RPM)
%
[CT,CP,prop_eff,n_s,J,RPMused] = findPropData(PropData_RPM,RPMtests,Thrust,V,rho,PropDia,1);

Thrust = CT*rho*n_s^2*PropDia^4;
Power_prop = CP*rho*n_s^3*PropDia^5;
omega = n_s*2*pi;
%
% find motor torque
Q = Power_prop/omega;
%
% find current into motor
%
i_m = Q/K_t + i_0;
%
% find voltage into motor
%
v_m = omega/K_v +i_m*r_m;
%
% determine motor efficiency
motor_eff = Q*omega/(i_m*v_m);
%
% determine voltage k_e*v_b
%
v_e_o = v_m + i_m*r_esc;
%
% determine ESC current
%
i_e_o = i_m;
%
% ESC efficiency
%
esc_eff = v_m/v_e_o;
%
% determine k_e for ESC
%
k_e = (v_e_o*i_e_o^0.05/v_i_n)^(1/0.95);
if k_e > 1.0
   fprint('Battery has insufficient power for this Thrust Velocity combination');
end
%
% determine battery voltage
% and current
%
v_b = v_e_o/k_e;
i_b = i_e_o*k_e;

%
% total power in incuding all losses
%
Power_in = v_b*i_b;

end

