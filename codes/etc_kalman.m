function [y_kf, r_kf]=etc_kalman(y,d,varargin)

% etc_kalman    Filtering auto-regressive signal with Kalman filter
%
% [y_kf, r_kf]=etc_kalman(y,d)
%
% y: n_y x n_t signals to be filtered
% d: n_x * n_t signals as the regressors
%
% y_kf: filtered signal
% r_kf: filtered residual
%
% option:
%   'Q': state covariance matrix 
%   'R': observation covariance matrix
%
% fhlin@Oct 28 2023
%

flag_dyn_H=1;

buffer_sample=1000; %default with a 1000-sample window

x_init=[];
P_init=[];

y_kf=[];
r_kf=[];

Q=[];
R=[];
F=[];
H=[];

for i=1:length(varargin)
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'buffer_sample'
            buffer_sample=option_value;
        case 'flag_dyn_h'
            flag_dyn_H=option_value;
        case 'x_init'
            x_init=option_value;
        case 'p_init'
            P_init=option_value;
        case 'q'
            Q=option_value;
        case 'r'
            R=option_value;
        case 'f'
            F=option_value;
        case 'h'
            H=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;



%Q: covariance matrix for the state vector
if(isempty(Q))
    x_mne=inv(d*d.')*d*y.';
    Q=diag(diag(cov(x_mne*x_mne')));
    Q(end+1,end+1)=1;
end;

%R: covariance matrix for the observation vector
if(isempty(R))
    R=diag(diag(cov(y.')));
end;

%F: state transition matrix
if(isempty(F))
    F=eye(size(d,1)+1); %no state transition.
end;
%F=eye(size(P_init,1)).*0.1; %state transition matrix

%H: gain matrix

%x: state vector
%y: obervation vector

if(isempty(x_init))
   x_init=zeros(size(d,1)+1,1);
end;

if(isempty(P_init))
    P_init=eye(size(d,1)+1);
end;


%predict (with inputs of x, F, P, Q)
x=x_init;
P=P_init;
for t_idx=buffer_sample:size(y,2)
    %fprintf('[%03d]...(%03d)\r',t_idx,size(y,2))
    x_apriori(:,t_idx)=F*x; %apriori state estimates
    P=F*P*F'+Q; %apriori state covariance matrix estimate

    %update (with inputs y, H, and R)
    if(flag_dyn_H)
        %H=d(:,t_idx-buffer_sample+1:t_idx).';
        H=d(:,t_idx).';
        H(end+1)=1;
    end;

    %r=y(:,t_idx-buffer_sample+1:t_idx).'-H*x; %innovation; pre-fit residual
    r=y(:,t_idx).'-H*x; %innovation; pre-fit residual
    
    S=H*P*H'+R; %innvoation covariance
    K=P*H'*inv(S); %Kalman gain

    %update
    x_aposteriori(:,t_idx)=x_apriori(:,t_idx)+K*r; %aposteriori state estaimtes
    P=(eye(size(K,1))-K*H)*P; %aposteriori state covariance matrix estimate
    tmp=H*x_aposteriori(:,t_idx);
    y_kf(:,t_idx)=tmp(end);
    r_kf(:,t_idx)=y(:,t_idx)-H*x_aposteriori(:,t_idx); %post-fit residual
end;




