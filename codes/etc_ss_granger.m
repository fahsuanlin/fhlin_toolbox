function [granger, granger_chi2_stat, granger_pvalue, granger_chi2_dof, granger_inst, opt_order]=etc_ss_granger(v,n_order_max,varargin)
% etc_ss_granger   use state-space for granger causality test on timeseries
%
% [granger, granger_chi2_stat, granger_pvalue, granger_chi2_dof, granger_inst]=etc_ss_granger(v,n_order_max,[option, option_value,...]);
%   v: [n,m] timeseries of n-timepoint and m-nodes OR
%   n-timepoint and k-observations
%
%   n_order_max: the maximal order for Hankel matrix in state-space model
%   estimation
%
%   option:
%       'ts_name': names for time series, in string cells
%       'g_threshold': the threshold of the granger causlity to be
%       considered significant.
%       'g_threshold_p': the p-value threshold of the granger causlity to be
%       considered significant.
%   granger: [m,m] granger causality matrix. each entry is the variance ratio: (res_orig^2/res_additional_timeseries^2)
%
% fhlin@may 19 2008
%

flag_display=1;
ts_name={};
g_threshold=[];
g_threshold_p=[];
flag_pairwise=1;

subsample=[];

A=[];
B=[];
C=[];
E=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'ts_name'
            ts_name=option_value;
        case 'g_threshold'
            g_threshold=option_value;
        case 'g_threshold_p'
            g_threshold_p=option_value;
        case 'flag_pairwise'
            flag_pairwise=option_value;
        case 'subsample'
            subsample=option_value;
        case 'a'
            A=option_value;
        case 'b'
            B=option_value;
        case 'c'
            C=option_value;
        case 'e'
            E=option_value;
            
    end;
end;

if(~iscell(v)) %univariate version
    for to_idx=1:size(v,2)
        for from_idx=1:size(v,2)
            if(to_idx==from_idx)
                granger(to_idx,from_idx)=0;
                granger_chi2_stat(to_idx,from_idx)=nan;
                granger_pvalue(to_idx,from_idx)=0.5;
            else
                op=v(:,[to_idx from_idx]);
                
                %estimate state-space model (with subsampling)
                %if(isempty(A)&isempty(B)&isempty(C)&isempty(E))
                    [A,B,C,E,opt_order]=etc_statespace_hankel_2(op,n_order_max,'flag_display',flag_display);
                %end;
                
                
                if(~isempty(subsample)&(subsample>0)) %after subsampling, state space model becomes [Am, Bm, Cm, Em]
                %if(~isempty(subsample)&(subsample>1)) %after subsampling, state space model becomes [Am, Bm, Cm, Em]
                    % stability test
                    [V,D]=eig(A);
                    [Vi,Di]=eig(A');  % so A=V*D*Vi
                    % get inverse V^{-1} by rescaling
                    Del=Vi'*V;
                    Vi=Del\Vi;
                    %
                    em=max(abs(D));
                    if em>=1
                        fprintf('unstable A matrix in subsampling [%d]',subsample(sub_idx))
                        return
                    end
                    %
                    [p,p]=size(A);
                    Lr=(chol(E))';
                    Lo=B*Lr;
                    
                    Id=eye(p,p);
                    Am=Id;
                    
                    for i=1:subsample
                        Am=Am*A;         % this gives A^(m-1)
                        
                        M=[A*Lo B*Lr];    % get Qm via cholesky update: Qm=(A*Lo)*(A*Lo)'+(B*Lr)*(B*Lr)'
                        [Q,U]=qr(M',0);    % => Qm=M*M'=U'*Q'*Q*U=U'*U
                        Lo=U';           % => Qm=Lo*Lo';
                    end
                    %
                    Qm=Lo*Lo';
                    
                    Sm=Am*B*E;
                    Am=Am*A;             % gets A^m
                    %
                    [Pm,L,G]=DARE(Am',C',Qm,E,Sm,Id);
                    Lm=(chol(Pm))';
                    CLm=C*Lm;
                    Em=E+CLm*CLm';  %Vm=R+C*Pm*C';
                    Bm=G';
                    %Dm=(chol(Vm))';
                    
                    %update after subsampling
                    A=Am;
                    B=Bm;
                    C=C;
                    E=Em;
                end;
                
                
                E_1_1=E(1,1);
                E_1_2=E(1,2);
                E_2_1=E(2,1);
                E_2_2=E(2,2);
                
                E_0=E_1_1-E_1_2*inv(E_2_2)*E_2_1;
                
                R=E_1_1;
                
                Bx=B(:,1);
                By=B(:,2);
                B0=Bx+By*E_2_1*inv(E_1_1);
                
                S=B0*E_1_1;
                
                Cx=C(1,:);
                Cy=C(2,:);
                
                [RR]=chol(E);
                O=(B*RR'*RR*B');
                [P, L, K] =dare(A',Cx',O,R,S,eye(opt_order));
                
                V=R+Cx*P*Cx';
                
                granger(to_idx,from_idx)=log(det(V))-log(det(E_1_1));
                granger_inst(to_idx,from_idx)=log(det(E_1_1))-log(det(E_0)); %instantaneous causality
                
                p=size(op,2); T=size(op,1);
                granger_chi2_stat(to_idx,from_idx)=(T-2*opt_order+1)*granger(to_idx,from_idx);
                granger_chi2_dof=2*opt_order*1*1;
                granger_pvalue(to_idx,from_idx)=1-chi2cdf(granger_chi2_stat(to_idx,from_idx), granger_chi2_dof);
                
            end;
        end;
    end;
end;

if(flag_display)
    if(isempty(ts_name))
        for i=1:size(granger,1)
            ts_name{i}=sprintf('node%2d',i);
        end;
    end;
    
    fprintf('\n\nSummarizing static Granger Causality...\n');
    fprintf('list from the most significant connection...\n\n');
    
    
    GR=granger;
    GR_p=granger_pvalue;
    
    if(isempty(g_threshold_p))
        g_threshold_p=0.01;
    end;
    
    [s_granger,s_idx]=sort(GR(:));
    for i=length(s_idx):-1:1
        [r(i),c(i)]=ind2sub(size(GR),s_idx(i));
        if(s_granger(i)>g_threshold)
            fprintf('<<%d>> from [%s] ---> to [%s] [(%d,%d)]: %3.3f (p-value=%3.3f)\n',length(s_idx)-i+1,ts_name{c(i)},ts_name{r(i)},r(i),c(i),s_granger(i),GR_p(s_idx(i)));
        end;
    end;
end;
