function [yout, tout]=etc_bloch_ode(varargin)

%simulating the simple Bloch equation by solving coupled differential
%equations
%
%
% fhlin@dec 25 2009
%

T1=1000./1e3; %s; T1 relaxation constant
T2=100./1e3; %s; T2 relaxation constant

gamma=42.58e6; %Hz/T
B0=3e-6;    %Tesla

%initial values;
Mx0=1;
My0=0;
Mz0=0;
M0=[Mx0 My0 Mz0]';

%terminal values;
Mx_inf=0;
My_inf=0;
Mz_inf=1;
Minf=[Mx_inf My_inf Mz_inf]';

%time stamps
timeVec=[0:0.001:10];

flag_display=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(varargin)/2
    option=varargin{i*2-1}
    option_value=varargin{i*2};
    
    switch lower(option)
        case t1
            T1=option_value;
        case t2
            T2=option_value;
        case m0
            M0=option_value;
        case minf
            Minf=option_value;
        case timevec
            timeVec=option_value;
        case gamma
            gamma=option_value;
        case b0
            B0=option_value;
        case flag_display
            flag_display=option_value;
    end;
end;

%Bloch equation parameters
ode_obj.T1=T1;
ode_obj.T2=T2;
ode_obj.gamma=gamma; 
ode_obj.B0=B0;
ode_obj.M0=[Mx0 My0 Mz0]';
ode_obj.M_inf=[Mx_inf My_inf Mz_inf]';

%solver
[tout,yout]=ode45(@etc_bloch_ode_core, timeVec, M0, [], ode_obj);

if(flag_display)
    plot(tout,yout);
    xlabel('time (s)');
    ylabel('magnetization');
    legend({'M_x','M_y','M_z'});
end;



