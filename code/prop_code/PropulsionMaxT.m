%
% find maximum thrust for a given propeller from UIUC database
% and one of 3 motors as function of forward speed with a Electrifly 
% 1300mAhr, 3 cells, 30C battery.
%
% PathName for UIUC data *** EDIT THIS ****
PathName = 'lib/UIUC-propDB/volume-1/data/';

in2m = 0.0254;
rho = 1.225;
%
% Data for ESC (value is a complete guess)
%
r_esc = 0.02;
%
% Battery data
%
% This model uses a battery discharge model from 
% Lance W. Traub Calculation of Constant Power
% Discharge Curves that specificly fits the
% Great Planes Electrifly 1300mAH 30 C battery
% discharge coefficients from paper
%
bat_a = 12.3063;
bat_b = -0.000328;
bat_c = -0.008112;
bat_d = -4.7809e-7;
bat_e = -7.7835e-7;
bat_f = 1.4086e-10;
%
% anonymous function for vi^n
%
vi_n = @(x) (bat_a + bat_c*x + bat_e*x^2)/(1 + bat_b*x + bat_d*x^2 + bat_f*x^3);% this is the Vi^n curve (n=0.05)
%
% Now read in motor data
%

motorname = 'SSXV3_2216_950';
K_v = 950*2*pi/60*1.0;
K_t = 1/K_v;
i_0 = 0.7;
r_m = 0.0736;
imax = 32;


%
% Now read in propeller data
%
propopts={'APC 8x8E','APC 9x6E','APC 9x6SF','APC 10x5E','APC 10x4.7SF','APC 11x3.8SF','APC 10x7E'};
promptstring={'Select Prop for Analysis'};
[indx,tf] =listdlg('PromptString',promptstring,'SelectionMode','single',...
    'ListString',propopts);
switch indx
    case 1
        propname = 'apce_8x8';
        PropDia = 8*in2m;
    case 2
        propname = 'apce_9x6';
        PropDia = 9*in2m;
    case 3
        propname = 'apcsf_9x6';
        PropDia = 9*in2m;
    case 4
        propname = 'apce_10x5';
        PropDia = 10*in2m;
    case 5
        propname = 'apcsf_10x4.7';
        PropDia = 10*in2m;
    case 6
        propname = 'apcsf_11x3.8';
        PropDia = 11*in2m;
    case 7
        propname = 'apce_10x7';
        PropDia = 10*in2m;
end

RPMD = 7500; % RPM will be close to 8000
%
% read_prop_data finds all the files for the given prop at an RPM that is
% close the one specified in RPMD
%
PropData = read_prop_data(propname,RPMD,PathName,1);
%
% enter maximum velocity and battery discharge value
%
prompt = {'Enter Max Velocity m/s'; 'Enter Battery Discharge (mAhr)0-1300'};
dlgtitle = 'Velocity';
dims = 2;
definput = {'20','20'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
Vmax = str2num(answer{1});
DC = str2num(answer{2});

%
% options to reduce output from fsolve
%
options = optimoptions('fsolve','Display','off');
%
% find v*i^0.05 for given discharge
%
vi = vi_n(DC); 
%
% range of velocities to solve for
%
V = 0:0.1:Vmax;
%
%
for j=1:length(V)
    %
    % make anonymous function for motor_bat_prop() so we can pass in
    % required information other than voltage
    % NOTE: motor_bat_prop calls motor_prop()
    %
    fun1 = @(y) motor_bat_prop(y,vi,rho,K_v,K_t,PropDia,i_0,imax,r_m,r_esc,PropData,V(j),options);
    %
    % fsolve is used to find battery voltage such that v_bat*current^0.05 =
    % vi
    %
    y = fsolve(fun1,[11.5],options);
    %
    % unfortunately because we can't pass anything out of functions
    % we need to call motor_prop outside of motor_bat_prop to get solution
    %
    v_bat(j) = y(1);
    %
    % anonymous function to call motor_prop with only omega as argument for
    % fsolve
    %
    fun2 = @(x) motor_prop(x,rho,K_v,K_t,PropDia,i_0,imax,v_bat(j),r_m,r_esc,PropData,V(j));
    x = fsolve(fun2,[7000*2*pi/60],options);
    omega(j) = x(1);
    %
    % now find remaining information
    %
    current(j) = (v_bat(j)-omega(j)/K_v)/(r_m+r_esc);
    %
    n = omega(j)/2/pi;
    J(j) = V(j)/(n*PropDia);
    %
    % find thrust and power by interpolating using J
    %
    T(j) = interp1(PropData(:,1),PropData(:,2),J(j),'pchip','extrap')*rho*n^2*PropDia^4; % available thrust
    P_prop(j) = interp1(PropData(:,1),PropData(:,3),J(j),'pchip','extrap')*rho*n^3*PropDia^5; % Power required to turn prop=motor output power
    v_motor(j) = v_bat(j)-current(j)*r_esc;
    P_motor(j) = v_motor(j)*current(j); % power into motor
    P_useful(j) = T(j)*V(j); % useful (i.e. available) power
    RPM(j) =n*60;
    eff_p(j) = interp1(PropData(:,1),PropData(:,4),J(j),'pchip','extrap');
    eff_m(j) = P_prop(j)/P_motor(j);
    eff_esc(j) = v_motor(j)*current(j)/(v_bat(j)*current(j));
    eff_tot(j) = P_useful(j)/(v_bat(j)*current(j));
end

%
% now store data in structure with propname combined so can run multiple times and
% plot results against each other
%
% first remove any decimals from string and replace with _

propname = strrep(propname,'.','_');
motor_prop_DC = sprintf('%s_%s_%d',motorname,propname,DC);

PropulsionData.(motor_prop_DC).DC = DC;
PropulsionData.(motor_prop_DC).V = V;
PropulsionData.(motor_prop_DC).T = T;
PropulsionData.(motor_prop_DC).P_prop = P_prop;
PropulsionData.(motor_prop_DC).v_motor = v_motor;
PropulsionData.(motor_prop_DC).P_motor = P_motor;
PropulsionData.(motor_prop_DC).P_useful = P_useful;
PropulsionData.(motor_prop_DC).RPM = RPM;
PropulsionData.(motor_prop_DC).v_bat = v_bat;
PropulsionData.(motor_prop_DC).current = current;
PropulsionData.(motor_prop_DC).eff_p = eff_p;
PropulsionData.(motor_prop_DC).eff_m = eff_m;
PropulsionData.(motor_prop_DC).eff_esc = eff_esc;
PropulsionData.(motor_prop_DC).eff_tot = eff_tot;



V_maxT = PropulsionData.(motor_prop_DC).V;
T_maxT = PropulsionData.(motor_prop_DC).T;

filename_max = sprintf('%s_MAXT.mat',motor_prop_DC);

save(filename_max,'V_maxT','T_maxT');

