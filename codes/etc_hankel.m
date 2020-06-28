function [Lambda_h,V_h,E,L_m_neg,a,opt_order]=etc_hankel(data,lag,varargin)
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
H=[];
H_n=[];
E=[];
Lamda_h=[];
V_h=[];
a=[];
opt_order=[];

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
    fprintf('calculating Hankel matrix of lag [%d]...\n',lag);
end;

Y_neg=[];
Y_pos=[];

data=data-repmat(mean(data,1),[size(data,1),1]);

for i=1:lag
    Y_neg=cat(1,data(i:end-2*lag+i-1,:)',Y_neg);
    Y_pos=cat(1,Y_pos,data(lag+i:end-lag+i-1,:)');
end;

H=Y_neg*Y_pos'./size(Y_pos,2);

[Q_pos, R_pos]=qr(Y_pos');
[Q_neg, R_neg]=qr(Y_neg');


%normalization
H_n=Q_neg(:,1:size(Y_neg,1))'*Q_pos(:,1:size(Y_pos,1));

%SVD
[U_h,Lambda_h,V_h]=svd(H_n);

%dimension estimation by AIC
T=size(data,1);
p=size(data,2);
m=lag;
for k=1:m
    ss=0;
    for j=k+1:m
        ss=ss+log(1-Lambda_h(j,j).^2);
    end;
    a(k)=ss*(-(T-2*m))-2*(p*m-k).^2.*log(T-2*m); %BIC
end;
[mmx,opt_order]=min(a);
if(flag_display)
    plot(a); xlabel('order'); ylabel('BIC'); hold on;
    plot(opt_order,mmx,'r.');
    title(sprintf('[%d] order is optimal from BIC',opt_order));
end;
fprintf('[%d] order is optimal from BIC\n',opt_order)

%auxillary matrix E
S_m_1_neg=Y_neg(size(data,2)+1:end,:)*(Y_neg(size(data,2)+1:end,:))'./size(Y_neg,2);

E1=[];
for i=1:lag-1
    E1=cat(2,E1,etc_delay_cov(data,i,'flag_display',0)');
end;
E2=etc_delay_cov(data,lag,'flag_display',0)';
E3=[];
for i=lag-1:-1:1
    E3=cat(1,E3,etc_delay_cov(data,i,'flag_display',0)');
end;
E=[E1,E2;S_m_1_neg,E3];

%get L_m_neg
[S_m_pos,S_m_neg, L_m_pos, L_m_neg]=etc_delay_toeplitz(data,lag,'flag_display',0);

return;