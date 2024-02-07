function [ F ] = motor_prop(x,rho,Kv,Kt,D,i0,imax,vbat,r_m,r_esc,PropData,V )
%
% x- omega returned from optimization
% rho - density
% Kv - rad/s/V for motor
% Kt - N-m/A for motor
% D - diameter of prop, m
% i0 - zero load current, amps
% vmax - voltage
% r_m - motor internal resistance, ohms
% r_esc - ESC resistance, ohms
% PropData [J,CT,CP,eff]
% V - forward speed m/s

% for given omega and forward velocity V
% determine torque required to turn prop (Qp) and
% motor torque (Qm)
% motor data: i0-no load current, r-resistance, vmax-battery voltage,
%               Kv, Kt motor constants
% prop data: D-diameter (m), PropData
% rho - density
% returns difference in motor and prop torque *100 which when the solution
% is correct should be zero!
%
%

    omega = x(1);
    n = omega/2/pi;
    %
    % calculate motor current given input omega and voltage
    %
    i = (vbat - omega/Kv)/(r_m+r_esc);
    %
    % calculate motor torque
    %
    Qm = (i-i0)*Kt;
    %
    % calculate J given input omega and forward speed (convert to rps first)
    %
    J = V/(n*D);
    %
    % find power required to turn prop at given rpm forward speed (J)
    % by interpolation prop data
    %
    CP = interp1(PropData(:,1),PropData(:,3),J,'pchip','extrap');
    %
    % find torque required to turn prop (Power_to_prop = Q*omega)
    %
    Qp = CP*rho*n^3*D^5/omega;
    %
    % cost is 100 times the difference in motor torque and prop torque
    F(1) = 100*(Qm-Qp);
end

