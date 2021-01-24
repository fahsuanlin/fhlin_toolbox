function [A,B,C,E,opt_order]=etc_hankel_2(data,lag,varargin)
%
% calculate the hankel matrix of the data given a delay
%
% [Lambda_h,V_h,L_m_neg,a,opt_order]=etc_hankel(data,lag);
%
% data: [n_time, n_var] matrix of n_time time points and n_var variables
% lag: the lag for the Hankel matrix; lag must be equal or larger than 1
%
% Lambda_h: singular value matrix of normalized Hankel matrix of lag 0 to lag "lag-1"
% V_h: right singular vector matrix of normalized Hankel matrix of lag 0 to lag "lag-1"
% E: auxiliary marix for state space identification
% L_m_neg: Cholesky decomposition matrix for toeplitz delay covariance matrix
% a: spectrum for BIC
% opt_order: the optimal order from BIC
%
% fhlin@aug. 9 2007
%
flag_display=1;
E=[];
C=[];
B=[];
A=[];
opt_order=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'opt_order'
            opt_order=option_value;
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
    fprintf('calculating Hankel matrix of lag [%d]...\n',lag);
end;

Y_neg=[];
Y_pos=[];

data=data-repmat(mean(data,1),[size(data,1),1]);

for i=1:lag
    %Y_neg=cat(1,data(i:end-2*lag+i-1,:)',Y_neg);
    Y_neg=cat(1,data(i:end-2*lag+i,:)',Y_neg);
    %Y_pos=cat(1,Y_pos,data(lag+i:end-lag+i-1,:)');
    Y_pos=cat(1,Y_pos,data(lag+i:end-lag+i,:)');
end;

%keyboard;
[Q_pos, R_pos]=qr(Y_pos',0);
Q_pos=Q_pos(:,1:size(Y_pos,1));
R_pos=R_pos(1:size(Y_pos,1),1:size(Y_pos,1));


[Q_neg, R_neg]=qr(Y_neg',0);
Q_neg=Q_neg(:,1:size(Y_neg,1));
R_neg=R_neg(1:size(Y_neg,1),1:size(Y_neg,1));

%keyboard;

%SVD
H_n=Q_pos'*Q_neg;
[U_h,Lambda_h,V_h]=svd(H_n);

%dimension estimation by AIC
T=size(data,1);
p=size(data,2);
m=lag;
if(isempty(opt_order))
    for k=1:m
        ss=0;
        for j=k+1:m
            ss=ss+log(1-Lambda_h(j,j).^2);
        end;
        %a(k)=ss*(-(T-2*m))-2*(p*m-k).^2.*log(T-2*m); %BIC
        a(k)=2*ss*(-(T-2*m))-2*(p*m-k).^2.*log(T-2*m); %BIC
    end;

    [mmx,opt_order]=min(real(a));
    if(flag_display)
        plot(a); xlabel('order'); ylabel('BIC'); hold on;
        plot(opt_order,mmx,'r.');
        title(sprintf('[%d] order is optimal from BIC',opt_order));
    end;
    if(flag_display)
        fprintf('[%d] order is optimal from BIC\n',opt_order)
    end;
else
    if(flag_display)
        fprintf('opt. order is specified as [%d].\n',opt_order);
    end;
end;

U_opt=U_h(:,1:opt_order);
Lambda_opt=Lambda_h(1:opt_order,1:opt_order);
V_opt=V_h(:,1:opt_order);

tmp=R_pos';
R_11_t=tmp(1:p,1:p);
U1=U_opt(1:p,:);
P=R_11_t*U1;

C=P*sqrt(Lambda_opt)./sqrt(T-2*m+1);

E=1/(T-2*m+1).*(R_11_t*R_11_t'-P*(Lambda_opt.^2)*P');

W=inv(R_neg)*V_opt;
W1=W(1:p,:);
W2=W(p+1:end,:);
B=sqrt(T-2*m+1).*sqrt(Lambda_opt)*W1';

tmp=R_neg'*V_opt;
Phi=tmp(1:end-p,:);
Gamma=tmp(end-p+1:end,:);
buffer=cat(1,P*Lambda_opt, Phi);
A=sqrt(Lambda_opt)*W'*buffer*(diag(1./sqrt(diag(Lambda_opt))));

%keyboard;

return;
