function [granger]=etc_granger_freq(v,ar_order,sf,freqVec,varargin)
% etc_granger   use AR model for granger causality test on frequency domain
%
% [granger]=etc_granger(v,ar_order,sf,freqVec,[option, option_value,...]);
%   v: [n,m] timeseries of n-timepoint and m-nodes OR
%   v: {n} cells of timeseries, each one has [n,k] timeseries of
%   n-timepoint and k-observations
%
%   ar_order: the order of the AR model
%   sf: sampling frequency
%   freqVec: sweeping frequency range for granger causality test
%
%   option:
%       'ts_name': names for time series, in string cells
%       'g_threshold': the threshold of the granger causlity to be
%       considered significant.
%       'g_threshold_p': the p-value threshold of the granger causlity to be
%       considered significant.
%   granger: [m,m] granger causality matrix. each entry is the variance ratio: (res_orig^2/res_additional_timeseries^2)
%
% fhlin@aug 12 2005
%

flag_display=1;
ts_name={};
g_threshold=[];
g_threshold_p=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch option
        case 'flag_display'
            flag_display=option_value;
        case 'ts_name'
            ts_name=option_value;
        case 'g_threshold'
            g_threshold=option_value;
        case 'g_threshold_p'
            g_threshold_p=option_value;
    end;
end;

if(~iscell(v))
    granger=zeros(2,2,length(freqVec));
    for to_idx=1:size(v,2)
        for from_idx=1:size(v,2)
            if(to_idx==from_idx)
                granger(to_idx,from_idx,[1:length(freqVec)])=0;
            else
                [w_12,A_12,C_12,SBC_12,FPE_12,th_12]=arfit([v(:,to_idx), v(:,from_idx)],ar_order,ar_order);
                
                T=size(v,1);
                
                H=zeros(2,2,length(freqVec));
                S=zeros(2,2,length(freqVec));
                for ff=1:length(freqVec)
                    hh=eye(2);
                    for idx=1:ar_order
                        hh=hh-A_12(:,(idx-1)*2+1:idx*2).*exp(-sqrt(-1).*2.*pi.*(idx).*freqVec(ff)./sf); 
                    end;
                    H(:,:,ff)=inv(hh);
                    S(:,:,ff)=inv(hh)*C_12*inv(hh)';
                    
                    granger(to_idx,from_idx,ff)=abs(S(1,1,ff))./(S(1,1,ff)-H(1,2,ff)*(C_12(2,2)-C_12(1,2).^2./C_12(1,1))*H(1,2,ff)');
                    granger(to_idx,from_idx,ff)=real(log(granger(to_idx,from_idx,ff)));
%                    granger_F(to_idx,from_idx,ff)=(T-ar_order)./(ar_order).*(exp(granger(to_idx,from_idx,ff))-(T-2*ar_order)/(T-ar_order));
                    granger_F(to_idx,from_idx,ff)=(T-2*ar_order)/(ar_order).*(-exp(-granger(to_idx,from_idx,ff)));
                    granger_pvalue(to_idx,from_idx)=1-fcdf(granger_F(to_idx,from_idx,ff), ar_order, T-2*ar_order);                                        
                end;
            end;
        end;
    end;
else
    if(flag_display) fprintf('[%d] time-series ...\n',length(v)); end;
        
    for to_idx=1:length(v)
        for from_idx=1:length(v)
            if(flag_display) fprintf('.'); end;
            if(to_idx==from_idx)
                granger{to_idx,from_idx}=0;
            else
                count=1;
                for to_ts_idx=1:size(v{to_idx},2)
                    to_ts=v{to_idx}(:,to_ts_idx);
                    for from_ts_idx=1:size(v{from_idx},2)
                        from_ts=v{from_idx}(:,from_ts_idx);
                        [w_1,A_1,C_1,SBC_1,FPE_1,th_1]=arfit(to_ts,ar_order,ar_order);
                        [w_12,A_12,C_12,SBC_12,FPE_12,th_12]=arfit([to_ts, from_ts],ar_order,ar_order);
                        
                        [siglev_1,res_1]=arres(w_1,A_1,to_ts);
                        [siglev_12,res_12]=arres(w_12,A_12,[to_ts, from_ts]);            
                        
                        granger{to_idx,from_idx}(count)=(res_1(:,1)'*res_1(:,1))/(res_12(:,1)'*res_12(:,1));
                        count=count+1;
                    end;
                end;
            end;
        end;
    end;
    if(flag_display) fprintf('\n'); end;
end;

return;

if(flag_display)
    if(isempty(ts_name))
        for i=1:size(granger,1)
            ts_name{i}=sprintf('node%2d',i);
        end;
    end;
    
    fprintf('\n\nSummarizing static Granger Causality...\n');
    fprintf('list from the most significant connection...\n\n');
    
    
    if(iscell(v))
        for to_idx=1:length(v)
            for from_idx=1:length(v)
                GR(to_idx,from_idx)=mean(granger{to_idx,from_idx});
                GR_p(to_idx,from_idx)=mean(granger_pvalue{to_idx,from_idx});
            end;
        end;
    else
        GR=granger;
        GR_p=granger_pvalue;
    end;
    
    if(isempty(g_threshold_p))
        g_threshold_p=0.01;
    end;
    
%     if(isempty(g_threshold))
%         if(isempty(g_threshold_p))
%             g_threshold_p=0.01;
%         end;
%         if(~iscell(v))
%             g_threshold=1./finv(g_threshold_p,size(v,1)-ar_order,size(v,1));
%         else
%             g_threshold=1./finv(g_threshold_p,size(v{1},1)-ar_order,size(v{1},1));
%         end;
%         fprintf('setting p-value at %3.3f: threshold at [%3.3f]\n',g_threshold_p,g_threshold);
%     end;
    
    [s_granger,s_idx]=sort(GR(:));
    for i=length(s_idx):-1:1
        [r(i),c(i)]=ind2sub(size(GR),s_idx(i));
        if(s_granger(i)>g_threshold)
            fprintf('<<%d>> from [%s] ---> to [%s] [(%d,%d)]: %3.3f (p-value=%3.3f)\n',length(s_idx)-i+1,ts_name{c(i)},ts_name{r(i)},r(i),c(i),s_granger(i),GR_p(s_idx(i)));
        end;
    end;
end;
