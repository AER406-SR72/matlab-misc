%
% Main script used to find propulsion system parameters for known speed,
% required thrust
%
% PathName for UIUC data *** EDIT THIS ****
PathName = '/Users/prgrant/Documents/Courses/AER1216/UIUC-propDB/volume-1/data/';

%
%
% Thrust and velocity you'd like to generate
%
prompt = {'Enter Velocity m/s'; 'Enter Required Thrust';'Enter Battery Discharge (mAhr)0-1300'};
dlgtitle = 'Velocity';
dims = 3;
definput = {'10','1.5','100'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
V = str2num(answer{1});
T = str2num(answer{2});
DC = str2num(answer{3});

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
motoropts = {'AXI 2216/16','D2830-11','SK3 2830-1020','SSX 2212-980','SSXV3 2216-950','SSXV3 2216-880','SSXV3 2212-980'};
promptstring = {'Select Motor for Analysis'};
[indx,tf] = listdlg('PromptString',promptstring,'SelectionMode','single',...
    'ListString',motoropts);

switch indx
    case 1
        % AXI 2216/17
        % Data for motor
        %AXI 2017/16
        motorname = 'AXI_2216_17';
        K_v = 1050*2*pi/60*1.0; %RPM/V->rad/s/V
        K_t = 1/K_v;
        i_0 = 0.4; % A at 10V
        r_m = 0.120; %Ohm
        imax = 22;
    case 2
        % D2830-11 (1000 2019 motor)
        motorname = 'D_2830_11';
        K_v = 1000*2*pi/60*1.0;
        K_t = 1/K_v;
        i_0 = 0.4;
        r_m = 0.11;
        imax = 21;
    case 3
        % SK302830-1020
        motorname = 'SK3_2830_1020';
        K_v = 1020*2*pi/60*1.0;
        %K_v = 843*2*pi/60*1.0;
        K_t = 1/K_v;
        i_0 = 0.95;
        r_m = 0.112;
        imax = 18;
    case 4
        % sunnysky X2212 980Kv
        motorname = 'SSX_2212_980';
        K_v = 980*2*pi/60*1.0;
        K_t = 1/K_v;
        i_0 = 0.3;
        r_m = 0.133;
        imax = 15;
    case 5
        % sunnysky XV3 2216 950Kv
        motorname = 'SSXV3_2216_950';
        K_v = 950*2*pi/60*1.0;
        K_t = 1/K_v;
        i_0 = 0.7;
        r_m = 0.0736;
        imax = 32;
    case 6
        % sunnysky XV3 2216 880Kv
        motorname = 'SSXV3_2216_880';
        K_v = 880*2*pi/60*1.0;
        K_t = 1/K_v;
        i_0 = 0.5;
        r_m = 0.089;
        imax = 32;
    case 7
        % sunnysky XV3 2212 980Kv
        motorname = 'SSXV3_2212_980';
        K_v = 980*2*pi/60*1.0;
        K_t = 1/K_v;
        i_0 = 0.6;
        r_m = 0.092;
        imax = 26;

end
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