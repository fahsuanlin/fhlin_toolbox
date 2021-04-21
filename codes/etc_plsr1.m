function [W, P, T, C, U, Y_pred, B, Bpls]=etc_plsr1(x,y,varargin)
% etc_plsr1    Partial least squares regression
%
% [W, P, T, C, U, Y_pred, B, Bpls]=etc_plsr1(X,Y,[option1, option_value1,...])
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
B=[];
Bpls=[];

X_pred=[];
Y_pred=[];

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
    xx=x-repmat(mean(x,1),[size(x,1),1]);
    xx=xx./repmat(std(xx,0,1),[size(xx,1),1]);
else
    xx=x;
end;

if(flag_norm_y)
    yy=y-repmat(mean(y,1),[size(y,1),1]);
    yy=yy./repmat(std(yy,0,1),[size(yy,1),1]);
else
    yy=y;
end;

meanX = mean(xx,1);
meanY = mean(yy,1);
xx = bsxfun(@minus, x, meanX);
yy = bsxfun(@minus, y, meanY);


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

Cov=xx'*yy;
V = zeros(size(xx,2),n_comp);

for idx=1:n_comp
    
    
    [ri,si,ci] = svd(Cov,'econ'); ri = ri(:,1); ci = ci(:,1); si = si(1);
    ti = xx*ri;
    normti = norm(ti); ti = ti ./ normti; % ti'*ti == 1
    Xloadings(:,idx) = xx'*ti;
    
    qi = si*ci/normti; % = Y0'*ti
    Yloadings(:,idx) = qi;
    
    %if nargout > 2
        T(:,idx) = ti;
        U(:,idx) = yy*qi; % = Y0*(Y0'*ti), and proportional to Y0*ci
    %    if nargout > 4
            Weights(:,idx) = ri ./ normti; % rescaled to make ri'*X0'*X0*ri == ti'*ti == 1
    %    end
    %end
    
    
    % Update the orthonormal basis with modified Gram Schmidt (more stable),
    % repeated twice (ditto).
    vi = Xloadings(:,idx);
    for repeat = 1:2
        for j = 1:idx-1
            vj = V(:,j);
            vi = vi - (vj'*vi)*vj;
        end
    end
    vi = vi ./ norm(vi);
    V(:,idx) = vi;

    % Deflate Cov, i.e. project onto the ortho-complement of the X loadings.
    % First remove projections along the current basis vector, then remove any
    % component along previous basis vectors that's crept in as noise from
    % previous deflations.
    Cov = Cov - vi*(vi'*Cov);
    Vi = V(:,1:idx);
    Cov = Cov - Vi*(Vi'*Cov);
   
%     r=xx'*yy;
%     [ww,ll,cc]=svd(r,'econ');
%     t1=xx*ww(:,1);
%     W(:,idx)=ww(:,1);
%     t1=t1./sqrt(sum(t1.^2));
%     T(:,idx)=t1(:);
%     p1=xx'*t1;
%     P(:,idx)=p1(:);
%     xx_pred=t1*p1';
%     xx=xx-xx_pred;
%     
%     u1=yy*cc(:,1);
%     C(:,idx)=cc(:,1);
%     U(:,idx)=u1(:);
%     yy_pred=t1*(t1'*u1)*cc(:,1)';
%     yy=yy-yy_pred;
%     B(idx,idx)=t1'*u1;  
end;
P=Xloadings;


Bpls = Weights*Yloadings';
Bpls = [meanY - meanX*Bpls; Bpls];

res=y-[ones(size(x,1),1) x]*Bpls;

%making prediction
if(~isempty(X_pred))
    
    
     Y_pred = [ones(size(X_pred,1),1) X_pred]*Bpls;
    
    
    
    %for x_pred_idx=1:size(X_pred,1)
    %    Y_pred(x_pred_idx,:)=X_pred(x_pred_idx,:)*(P*inv(P'*P))*B*C';
    %end;
end;
%PLS regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return;
