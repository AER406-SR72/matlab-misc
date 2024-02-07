function [CT,CP,eff,n_s,J,RPMused] = findPropData(PropData_RPM,RPMaa,Drag,V,rho,PropDia,InterpRPM)
%
% find the best propdata to generate T=Drag at given speed
% inputs: PropData_RPM -- propeller data at various measured RPMs
%         RPMaa -- actual RPM for the different sets
%         Drag -- Drag to balance with thrust (N)
%         V -- flight speed for Drag (m/s)
%         rho -- density (in kg/m^3)
%         PropDia -- diameter of prop (in m)
%         InterpRPM -- 0 -> don't interpolate, just find closest RPM
%         dataset and interpolate on J
%                   -- 1 -> interpolate on RPM datasets and then on J
%
D = PropDia; % diameter in meters

for j=1:length(RPMaa)
    PropData = PropData_RPM{j};
    CToverJsq = PropData(:,2)./(PropData(:,1).^2);
    CToverJsq(1) = 1e9; % first value will be infinite
    %
    % interpolate to find J for each RPM dataset
    %
    Ja(j) = interp1(CToverJsq,PropData(:,1),Drag/(rho*D^2*V^2));
    %
    % Now find CT, CP, eff and rotational speed for each RPM dataset
    %
    CTa(j) = interp1(PropData(:,1),PropData(:,2),Ja(j));
    CPa(j) = interp1(PropData(:,1),PropData(:,3),Ja(j));
    effa(j) = interp1(PropData(:,1),PropData(:,4),Ja(j));
    n_s_a(j) = V/(Ja(j)*D);
    RPM(j) = n_s_a(j)*60;
    dRPM(j) = RPMaa(j)-RPM(j);
end
if InterpRPM == 0
    %
    % if not interpolating just use closest RPM datafile to interpolate
    %
    [rpmb,index] = min(abs(dRPM));
    CT = CTa(index);
    CP = CPa(index);
    eff = effa(index);
    n_s= n_s_a(index);
    J = Ja(index);
    RPMused = RPMaa(index);
else
    % now interpolate to find best RPM case
    if min(RPM) > RPMaa(end)
        CT = CTa(end);
        CP = CPa(end);
        eff = effa(end);
        n_s = n_s_a(end);
        J = Ja(end);
        RPMused = RPMaa(end);
    else
        J = interp1(dRPM,Ja,0);
        CT = interp1(dRPM,CTa,0);
        CP = interp1(dRPM,CPa,0);
        eff = interp1(dRPM,effa,0);
        n_s = V/(J*D);
        RPMused = n_s*60;
    end
end
        
end

