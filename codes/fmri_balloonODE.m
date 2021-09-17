function dy = fmri_balloonODE(t,y,varargin)
%dy(1) = y(2);
%dy(2) = y(1)*y(2)-2;

u=0;
for i=1:length(varargin)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'u'
            u=option_value;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% definition of constants and variables
t_MTT =1; %[1 4];
t_v=0; %[0 30];

%hemodynamic fixed parameters
E0=0.4;
alpha=0.4;

% coupling constants
epison =0.5;
t_s=0.8;
t_f=0.4;

%variables
E=1-(1-E0)^(1/y(3));                        %E: oxygen extraction fraction
r=y(3)*E/E0;                                %r: CMRO2
f_out=1/(t_v+t_MTT)*(t_MTT*(y(2)^(1/alpha))+t_v*y(3));  %f_out: outflow

% end of definition of constants and variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ODE begin

dy(1)=1/t_MTT*(r-f_out*y(1)/y(2));          %q: deoxyhemoglobin concentration
dy(2)=1/t_MTT*(y(3)-f_out);                 %v: blood volume
dy(3)= y(4);                                %f_in: inflow
dy(4)= epison*u-y(4)*t_s-(y(3)-1)/t_f;      %s: inducing signal for flow

dy=dy(:);
% ODE end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
