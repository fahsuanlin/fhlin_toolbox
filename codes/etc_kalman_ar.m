%close all; clear all;

function [y_kf]=etc_kalman_ar(y,p)

% etc_kalman_ar    Filtering auto-regressive signal with Kalman filter
%
% [y_kf]=etc_kalman_ar(y,p)
%
% y: one-dimensional signal to be filtered
% p: auto-regressive model order
%
% y_kf: filtered signal
%
% option:
%   'a0': the diagnal value for the state vector transition matrix (a pxp
%   diagonal matrix). default: a0=0.8;
%   'q0': the noise level for the state vector (a pxp diagonal
%   matrix). default: q0=0.9;
%   'r0': the noise level parameter for the observation (a scalar). The noise level for the ovservation variable 'y' is assumed to be r0*std(y). default: r0=1.5;
%
% fhlin@May 19 2022
%

y_kf=[];

a0=0.8;
q0=0.9;
r0=1.5;

for i=1:length(varargin)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'a0'
            a0=option_value;
        case 'q0'
            q0=option_value;
        case 'r0'
            r0=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;



%load temp.mat; %'ecg' and 'fs'
%y=ecg(:);
%p=20% AR order







Y=toeplitz(y(1:p+1),y');

%state transition matrix
A=eye(p).*a0;

%noise covariance
Q=eye(p).*q0; %for state vector
R=std(y).*r0; %for measurement

%inital state
P_apriori=zeros(p,p); %covariance for the state vector
s_apriori=zeros(p,1); %state vector


for t_idx=1:length(y)
    y(t_idx)=Y(1,t_idx);
    %if(t_idx>p)
    %    C=y_kf(t_idx-p:t_idx-1)';
    %else
        C=Y(2:end,t_idx)';
    %end;
    
    %predict (extrapolation)
    P_posteriori=A*squeeze(P_apriori)*A'+Q;
    s_posteriori=A*s_apriori; %+input
    y_kf(t_idx,:)=C*s_posteriori;
    
    %update
    K=squeeze(P_apriori)*C'*inv(R+C*P_apriori*C');
    P_apriori=(eye(size(K,1))-K*C)*P_posteriori*((eye(size(K,1))-K*C))'+K*R*K';
    %P_apriori=(eye(size(K,1))-K*C)*P_posteriori;
    s_apriori=s_posteriori+K*(y(t_idx)-C*s_posteriori);    
    
end;

plot(y)
hold on
plot(y_kf)
