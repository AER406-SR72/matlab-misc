%
% Main script used to find propulsion system parameters for known speed,
% required thrust
%
% PathName for UIUC data *** EDIT THIS ****
PathName = 'lib/UIUC-propDB/volume-1/data/';

%
%
% Thrust and velocity you'd like to generate
%
V = 10;
T = 1.7;

%
%
in2m = 0.0254;
rho = 1.225;

DC = 100; % 100mAhr discharge
%
% motor data
%
% Now read in motor data
%

% sunnysky XV3 2216 950Kv
motorname = 'SSXV3_2216_950';
K_v = 950*2*pi/60*1.0;
K_t = 1/K_v;
i_0 = 0.7;
r_m = 0.0736;
imax = 32;
    
%
r_esc =0.02;
%
% propdata
%
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



[PropData_RPM,RPMtests,PropDia] = readPropDataAllRPM(propname,PathName);

%
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
v_i_DC = @(x) (bat_a + bat_c*x + bat_e*x^2)/(1 + bat_b*x + bat_d*x^2 + bat_f*x^3);% this is the Vi^n curve (n=0.05)
v_i_n = v_i_DC(DC);

[Power_in,prop_eff,motor_eff,esc_eff,i_m,v_m,i_b,v_b,k_e,n_s] = FindPropSolution(T,V,K_v,K_t,i_0,r_m,r_esc,PropData_RPM,RPMtests,PropDia,rho,v_i_n);

fprintf('\n\n');
fprintf('RPM = %5.1f Prop eff = %3.1f %%, Motor eff = %3.1f %%, Esc eff =  %3.1f %%, Total eff = %3.1f %%, Input Power = %4.1f W\n',n_s*60,prop_eff*100,motor_eff*100,esc_eff*100, (T*V)/Power_in*100,Power_in );