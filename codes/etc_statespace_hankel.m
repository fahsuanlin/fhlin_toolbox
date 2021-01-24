function [A,B,C,Gm,E,opt_order]=etc_statespace_hankel(data,lag,varargin)
%
% calculate the state space matrices from a hankel matrix of the data given a delay
%
% [A,B,C,Gm,E,opt_order]=etc_statespace_hankel(data,lag);
%
% data: [n_time, n_var] matrix of n_time time points and n_var variables
% lag: the lag for the Hankel matrix; lag must be equal or larger than 1
%
% A, B, C, Gm, E are output matrics of state space model
% opt_order: the optimal order of the state space from BIC
%
% fhlin@aug. 9 2007
%
flag_display=1;
A=[];
B=[];
C=[];
Gm=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]...!\nerror!\n',option);
            return;
    end;
end;

if(lag<0) 
    fprintf('error! the lag must be >=0!\n');
    return;
end;

if(flag_display)
    fprintf('calculating state space matrices of lag [%d]...\n',lag);
end;

[Lambda_h,V_h,E,L_m_neg,a,opt_order]=etc_hankel(data,lag,'flag_display',0);

Lambda_h=Lambda_h(1:opt_order,1:opt_order);
V_h=V_h(:,1:opt_order);
%L_m_neg=L_m_neg(:,1:opt_order);
%E=E(1:opt_order,1:opt_order);

A=sqrt(Lambda_h)*V_h'*L_m_neg*E*L_m_neg'*V_h*sqrt(Lambda_h);

B_etc=eye(size(data,2));
for i=1:lag-1
    B_etc=cat(1,B_etc,zeros(size(data,2),size(data,2)));
end;
B=sqrt(Lambda_h)*V_h'*L_m_neg*E*L_m_neg'*B_etc;

Gm=[];
for i=1:lag
    Gm=cat(2,Gm,etc_delay_cov(data,i,'flag_display',0));
end;
C=Gm*L_m_neg'*V_h*sqrt(inv(Lambda_h));

C0=etc_delay_cov(data,0,'flag_display',0);
E=C0-C*Lambda_h*C';

return;