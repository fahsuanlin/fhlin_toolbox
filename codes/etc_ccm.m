function [y_est, rho, W, U, D, y_trim]=etc_ccm(x,y,varargin)
% etc_ccm convergent cross mapping
%
%
% [y_est, rho, W, U, D, y_trim]=etc_ccm(x,y,[option, option_value,...]);
%
% estimate  y (source) by cross mapping from x (target) (M_x)
% y --> x gives high correlation coefficient (rho) between cross mapped y and y.
%
% y_est: the estimated time series y (the lenth of y_est is shorther than
% the length of y because of data trimmed at shadowing manifold
% construction).
% rho: correlation coefficient between y and cross mapped y; high
% correlation suggests y --> x
% W: normalized cross mapping weights
% U: cross mapping weights
% D: cross mapping distances
% y_trim: the trimmed original time series y (the lenth of y_trim is shorter
% than the length of y because of data trimmed at shadowing manifold
% construction).
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
nn=[];
delay=0;

flag_normalize=1;
flag_display=0;
flag_graphics=1;
flag_same=1;

tau=1; %interval between time series; in sample
E=1; %dimension of the shadowing manifold

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option_name)
        case 'e'
            E=option_value;
        case 'tau'
            tau=option_value;
        case 'nn'
            nn=option_value;
        case 'delay'
            delay=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_normalize'
            flag_normalize=option_value;
        case 'flag_graphics'
            flag_graphics=option_value;
        case 'flag_same'
            flag_same=option_value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option_name);
            return;
    end;
end;

if(isempty(nn))
    nn=E+2;
end;

if(flag_normalize)
    x=x-mean(x);
    x=x./std(x);
    y=y-mean(y);
    y=y./std(y);
end;

orig_length=length(y);

for time_idx=1:length(x)
    t(:,time_idx)=[time_idx:tau:time_idx+(E-1)*tau]'+delay;
end;
mask=zeros(size(t));
mask(find(t>length(x)))=1;
mask(find(t<1))=1;
idx_trim=find(sum(mask,1)>eps);
t(:,idx_trim)=[];
y_trim=y;
y_trim(idx_trim)=[];
X=x(t)'; %shadowed manifold for X
Y_m=y(t)'; %shadowed manifold for Y 

[IDX,D] = knnsearch(X,X,'K',nn); %find the nn (default: E+2) nearest neighbors, including itself.
IDX0=IDX;
D0=D;

%find E+1 nearest neighbors other than itself 
IDX(:,1)=[];
D(:,1)=[];

done=0;
y_est=zeros(size(y_trim)).*nan;

% %find cases where the nearest neighbors in the manifolds are the same as
% %the self;
% d=sum(D,2);
% idx=find(d<eps);
% y_est(idx)=y(idx);

%typically, this should be done only once. But there are cares where
%instants in the dynamics have replica. So we tried to remove those
%replica, where the distance measure D is zero (and thus nan in U).
while(~done)
    nan_idx=find(isnan(y_est));
    
    %weightings
    idx=find(D(:,1)>eps);
    idxz=find(D(:,1)<=eps);
    U=D;
    U(idx,:)=exp(-D(idx,:)./repmat(D(idx,1),[1,size(D,2)])); %<----need to be normalized to the first one?
    U(idxz,:)=exp(-D(idxz,:));
    W=U./repmat(sum(U,2),[1,size(U,2)]);
    
    %Y=y(IDX); %<---locating the nearest points in Y manifold
    Y=reshape(y(IDX),size(IDX));%<---locating the nearest points in Y manifold
    tmp=reshape(sum(Y.*W,2),size(y_trim));
    
    y_est(nan_idx)=tmp(nan_idx);
    
    if(length(find(isnan(y_est)))<eps)
        done=1;
    else
        if(size(D,2)>1)
            D(:,1)=[];
            IDX(:,1)=[]; 
        else
            done=1;
            fprintf('CCM diverge!\n');
        end;
    end;
end;

y_est_append=y;
y_est_append(1:length(y_est))=y_est;
Y_e=y_est_append(t(:,IDX))'; %<---create a shadow Y manifold from estimates

%Y_e=y_est(IDX); %<---create a shadow Y manifold from estimates

%if((flag_display)&&(E==2))
if(flag_display)
     figure;
    subplot(221); hold on;
    plot(X(:,1),'.')
    
    subplot(222); hold on;
    plot(Y_m(:,1),'.')

    if(E==2)
        subplot(223); hold on;
        plot(X(:,1),X(:,2),'.')
    
        subplot(224); hold on;
        plot(Y_m(:,1),Y_m(:,2),'.')
    end;
    
    h1=[];
    ha=[];
    h2=[];
    hb=[];
    he=[];
    hh1=[];
    hha=[];
    hh2=[];
    hhb=[];
    hhe=[];
    for ii=1:size(X,1)
        if(~isempty(hh1)) delete(hh1); end;
        if(~isempty(hha)) delete(hha); end;
        subplot(221);
        hh1=plot(IDX(ii,:),X(IDX(ii,:),1),'ro');
        hha=plot(ii,X(ii,1),'go');
        
        fprintf('[%d] x: %s\n',ii,mat2str(X(IDX0(ii,:),1)));
        
        if(E==2)
            if(~isempty(h1)) delete(h1); end;
            if(~isempty(ha)) delete(ha); end;
            subplot(223);
            h1=plot(X(IDX(ii,:),1),X(IDX(ii,:),2),'ro');
            ha=plot(X(ii,1),X(ii,2),'go');
        end;
        
        if(~isempty(hh2)) delete(hh2); end;
        if(~isempty(hhb)) delete(hhb); end;
        if(~isempty(hhe)) delete(hhe); end;
        subplot(222);
        hh2=plot(IDX(ii,:),Y_m(IDX(ii,:),1),'ro');
        hhb=plot(ii,Y_m(ii,1),'go');

        fprintf('x: %s\t',mat2str(X(IDX0(ii,:),1)));

        if(E==2)
            if(~isempty(h2)) delete(h2); end;
            if(~isempty(hb)) delete(hb); end;
            if(~isempty(he)) delete(he); end;
            subplot(224);
            h2=plot(Y_m(IDX(ii,:),1),Y_m(IDX(ii,:),2),'ro');
            hb=plot(Y_m(ii,1),Y_m(ii,2),'go');
            he=plot(Y_e(ii,1),Y_e(ii,2),'c+');
        end;
        
        pause(0.1);
    end;
end;


rho=corrcoef(y_trim(:),y_est(:));
rho=rho(2,1);

if(flag_same)
    y_est(end+1:orig_length)=0;
end;

return;
