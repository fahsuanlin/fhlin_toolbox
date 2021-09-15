function dmdt=bloch(t,m,b1_t,b1,g_t,g,r,varargin)
% t: time (n_t x 1) [s]
% m: magnetization vector (n_t x 3) [a.u.]
% b1_t: the time vector for b1 field (n_b1_t x 1) [s]
% b1: b1 field (n_b1_t x 3) [T]
% g_t: the time vector for gradient (n_g_t x 1) [s]
% g: gradient field (n_g_t x 3) [T]
% r: position vector (3x1) [m]

gamma=267.522e6; %proton [rad/s/T] %42.58*1e6; %proton; MHz/T
%M0=[0 0 1]'; %initial condition; mx=0, my=0, mz=1
%B=[0 0 0]; %rotatory frame; on-resonance bx=0; by=0; bz=0;

T1=inf; %T1 relaxation constant; s
T2=inf; %T2 relaxation constant; s

% b1=[]; b1_t=[];
% gx=[]; gx_t=[];
% gy=[]; gy_t=[];
% gz=[]; gz_t=[];
m0=[0 0 1];

B_add=[];
B_add_t=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'gamma'
            gamma=option_value;
        case 't1' % second
            T1=option_value;
        case 't2' % second
            T2=option_value;
        case 'b_add_t'
            B_add_t=option_value;
        case 'b_add'
            B_add=option_value;
        case 'm0'
            m0=option_value;
%        case 'fov'
%            FOV=option_value;
%         case 'gx'
%             gx=option_value; %read-out gradient
%         case 'gx_t'
%             gx_t=option_value; %time stamps for read-out gradient
%         case 'gy'
%             gy=option_vaule; %phase encoding gradient
%         case 'gy_t'
%             gy_t=option_vaule; %time stamps for phase encoding gradient
%         case 'gz'
%             gz=option_value; %slice selection gradient
%         case 'gz_t'
%             gz_t=option_value; %time stamps for slice selection gradient
%         case 'b1'
%             b1=option_value; %RF excitation
%         case 'b1_t'
%             b1_t=option_value;% time stamps for RF excitation
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

%B1 waveform interpolation
B1=zeros(length(t),3);
if(~isempty(b1))
    B1(:,1)=interp1(b1_t,b1(:,1),t);
    B1(:,2)=interp1(b1_t,b1(:,2),t);
    B1(:,3)=interp1(b1_t,b1(:,3),t);
else
    B1=0;
end;

%Gradient waveform interpolation
Gx=zeros(length(t),1);
if(~isempty(g_t))
    Gx=interp1(g_t,g(:,1),t);
end;

Gy=zeros(length(t),1);
if(~isempty(g_t))
    Gy=interp1(g_t,g(:,2),t);
end;

Gz=zeros(length(t),1);
if(~isempty(g_t))
    Gz=interp1(g_t,g(:,3),t);
end;


%additional magnetic field waveform interpolation
B_add_interp=zeros(length(t),3);
if(isempty(B_add))
    B_add=zeros(length(t),3);
else
    for idx=1:3
        B_add_interp(:,idx)=interp1(B_add_t,B_add(:,idx),t);
    end
end;
%%%%%%%%%%%%%%%%%%%%%%%

B=[Gx(:).*r(1)+B1(:,1)+B_add_interp(:,1), Gy(:).*r(2)+B1(:,2)+B_add_interp(:,2), Gz(:).*r(3)+B1(:,3)+B_add_interp(:,3)]; %the total effective magnetic field in the rotating frame

%dmdt=gamma.*cross(m,B).'-[m(1)/T2, m(2)/T2, (m(3)-m0(3))/T1].';
dmdt=(gamma.*cross(m,B)).';

%if((dmdt(1))>eps) keyboard; end;

if(find(isnan(dmdt))) keyboard; end;

return;
