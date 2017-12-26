function [y_est, rho, W, U, D]=etc_ccm(x,y,varargin)
% etc_ccm convergent cross mapping
%
% [y_est, rho, W, U, D]=etc_ccm(x,y,[option, option_value,...]);
%
% estimate  y (source) by cross mapping from x (target) (M_x)
% y --> x gives high correlation coefficient (rho) between cross mapped y and y.
%
% rho: correlation coefficient between y and cross mapped y; high
% correlation suggests y --> x
% W: normalized cross mapping weights
% U: cross mapping weights
% D: cross mapping distances
%
% fhlin@dec. 20 2017
%
%
% ----------------------------------------------------------------------
% close all; clear all;
% examples in Detecting Causality in Complex Ecosystems Sugihara et al.
% Science (2012): DOI: 10.1126/science.1227079
%
% 
% ll=[100:10:4000];
% 
% for l_idx=1:length(ll)
%     d=zeros(ll(l_idx),2);
%     d(1,:)=[0.2 0.4];
%     for L=2:ll(l_idx)
%         %figures 3c and 3d
%         %d(L,1)=d(L-1, 1)*(3.7-3.7*d(L-1, 1)-0.0*d(L-1, 2));
%         %d(L,2)=d(L-1,2)*(3.7-3.7*d(L-1, 2)-0.32*d(L-1, 1)); % x --> y
%         
%         %figures 1 and figure 3a
%         d(L,1)=d(L-1, 1)*(3.8-3.8*d(L-1, 1)-0.02*d(L-1, 2));
%         d(L,2)=d(L-1, 2)*(3.5-3.5*d(L-1, 2)-0.1*d(L-1, 1));
%     end;
%     
%     
%     [y_est, y_rho(l_idx)]=etc_ccm(d(:,1),d(:,2),'E',2);
%     [x_est, x_rho(l_idx)]=etc_ccm(d(:,2),d(:,1),'E',2);
%     
% end;
% 
% 
% plot(ll,x_rho,'b'); hold on;
% plot(ll,y_rho,'r'); hold on;
% 
% return;
% ----------------------------------------------------------------------


y_est=[];
rho=[];
W=[];
U=[];
D=[];

flag_normalize=1;
flag_display=1;
flag_graphics=1;

tau=1; %interval between time series; sample
E=1; %dimension of manifold

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option_name)
        case 'e'
            E=option_value;
        case 'tau'
            tau=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_normalize'
            flag_normalize=option_value;
        case 'flag_graphics'
            flag_graphics=option_value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option_name);
            return;
    end;
end;

if(flag_normalize)
    x=x-mean(x);
    x=x./std(x);
    y=y-mean(y);
    y=y./std(y);
end;

for time_idx=1:length(x)
    t(:,time_idx)=[time_idx:tau:time_idx+(E-1)*tau]';
end;
mask=zeros(size(t));
mask(find(t>length(x)))=1;
idx_trim=find(sum(mask,1)>eps);
t(:,idx_trim)=[];
y_trim=y;
y_trim(idx_trim)=[];
X=x(t)';

[IDX,D] = knnsearch(X,X,'K',E+2); %find the E+2 nearest neighbors, including itself.

%find E+1 nearest neighbors by removing each point from itself 
IDX(:,1)=[];
D(:,1)=[];

%weightings
U=exp(-D./repmat(D(:,1),[1,size(D,2)]));
W=U./repmat(sum(U,2),[1,size(U,2)]);

Y=y(IDX); %<---locating the nearest points in Y manifold
y_est=reshape(sum(Y.*W,2),size(y_trim));

rho=corrcoef(y_trim(:),y_est(:));
rho=rho(2,1);

return;
