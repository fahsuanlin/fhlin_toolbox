function [W, P, T, C, U, Y_pred, B,yy_est]=etc_plsr(x,y,varargin)
% etc_plsr    Partial least squares regression
%
% [W, P, T, C, U, Y_pred, B]=etc_plsr(X,Y,[option1, option_value1,...])
%
% X=T*P' Y=T*B*C'=X*Bpls  X and Y being Z-scores
%                          B=diag(b)
%    Y=X*Bpls_star with X being augmented with a col of ones
%                       and Y and X having their original units
%    Yjack is the jackknifed estimation of Y
% T'*T=I (NB normalization <> than SAS)
% W'*W=I
% C is unit normalized,           
% U, P are not normalized 
%  [Notations: see Abdi (2003) & Abdi (2007)
%               available from www.utd.edu/~herve]
%
% X: 2D neuroimaging data (txs)
% Y: behavioral/categorial data (txp)
%
% 'n_comp': number of components to be calculated
%
%
% fhlin@jun 23, 2020
%
W=[];
P=[];
T=[];
C=[];
U=[];

X_pred=[];
Y_pred=[];

yy_est=[];

flag_norm_x=1; %normalize x to be z-scores
flag_norm_y=1; %normalize y to be z-scores

flag_display=0;

n_comp=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'flag_norm_x'
            flag_norm_x=option_value;
        case 'flag_norm_y'
            flag_norm_y=option_value;
        case 'n_comp'
            n_comp=option_value;
        case 'x_pred'
            X_pred=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!error!\n',option);
            return;
    end;
end;


%the following are data in "Partial Least Squares (PLS) methods for
%neuroimaging: A tutorial and review", Krishnan et al, NeuroImage (2010).
%
% 
% x=[ 2 5 6 1 9 1 7 6 2 1 7 3
%     4 1 5 8 8 7 2 8 6 4 8 2
%     5 8 7 3 7 1 7 4 5 1 4 3
%     3 3 7 6 1 1 10 2 2 1 7 4
%     2 3 8 7 1 6 9 1 8 8 1 6
%     1 7 3 1 1 3 1 8 1 3 9 5
%     9 0 7 1 8 7 4 2 3 6 2 7
%     8 0 6 5 9 7 4 4 2 10 3 8
%     7 7 4 5 7 6 7 6 5 4 8 8];
% 
% y=[ 15 600
%     19 520
%     18 545
%     22 426
%     21 404
%     23 411
%     29 326
%     30 309
%     30 303];

%centralize data by getting z-scores
if(flag_norm_x)
    mean_x=mean(x,1);
    xx=x-repmat(mean(x,1),[size(x,1),1]);
    std_x=std(xx,0,1);
    std_x_nan=find(std_x<eps);
    std_x(std_x_nan)=1;
    xx=xx./repmat(std_x,[size(xx,1),1]);
    if(~isempty(X_pred))
        X_pred=X_pred-repmat(mean_x,[size(X_pred,1),1]);
        X_pred=X_pred./repmat(std_x,[size(X_pred,1),1]);
    end;
else
    xx=x;
end;

if(flag_norm_y)
    mean_y=mean(y,1);
    yy=y-repmat(mean(y,1),[size(y,1),1]);
    std_y=std(yy,0,1);
    yy=yy./repmat(std(yy,0,1),[size(yy,1),1]);
else
    yy=y;
    mean_y=[];
    std_y=[];
end;


rankx=rank(xx);
ranky=rank(yy);

rank_min=min([rankx ranky]);

if(isempty(n_comp))
    n_comp=rank_min;
    if(flag_display)
        fprintf('automatic [%d] components in PLSR\n ',n_comp);
    end;
end;
if(n_comp>rank_min)
    if(flag_display)
        fprintf('The specified number of component [%d] is more than the rank in the data ([%d] for x and [%d] for y).\n',n_comp,rankx,ranky);
    end;
    n_comp=rank_min;
    if(flag_display)
        fprintf('automatic [%d] components in PLSR\n ',n_comp);
    end;
end;

if(flag_display)
    fprintf('PLSR into [%d] components.\n',n_comp);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PLS regression
xx0=xx;
yy0=yy;

for idx=1:n_comp
    r=xx'*yy;
    [ww,ll,cc]=svd(r,'econ');
    t1=xx*ww(:,1);
    W(:,idx)=ww(:,1);
    t1=t1./sqrt(sum(t1.^2));
    T(:,idx)=t1(:);
    p1=xx'*t1;
    P(:,idx)=p1(:);
    xx_pred=t1*p1';
    xx=xx-xx_pred;
    
    u1=yy*cc(:,1);
    C(:,idx)=cc(:,1);
    U(:,idx)=u1(:);
    yy_pred=t1*(t1'*u1)*cc(:,1)';
    yy=yy-yy_pred;
    B(idx,idx)=t1'*u1;  
end;

Bpls=pinv(P')*B*C';
yy_est=xx0*Bpls;
if(flag_norm_y)
     tmp=yy_est.*repmat(std_y,[size(yy_est,1),1]);
     yy_est=tmp+repmat(mean_y,[size(yy_est,1),1]);
end;

%making prediction
if(~isempty(X_pred))
    for x_pred_idx=1:size(X_pred,1)
        Y_pred(x_pred_idx,:)=X_pred(x_pred_idx,:)*(P*inv(P'*P))*B*C';
    end;
    if(flag_norm_y)
        tmp=Y_pred.*repmat(std_y,[size(Y_pred,1),1]);
        Y_pred=tmp+repmat(mean_y,[size(Y_pred,1),1]);
    end;
end;
%PLS regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return;
