function [granger]=etc_granger_report(granger,ts_name,varargin)
% etc_granger_report   summarize granger causality based on AR model 
%
% []=etc_granger_report(granger,ts);
%   granger: [m,m]  m-nodes granger causality matrix
%   ts_name: {m} string cells for the name of the nodes.
%
%   option:
%       'ar_order': the order of the AR model
%       'g_threshold': the threshold of the granger causlity to be
%       considered significant.
%       'g_threshold_p': the p-value threshold of the granger causlity to be
%       considered significant.
%   granger: [m,m] granger causality matrix. each entry is the variance ratio: (res_orig^2/res_additional_timeseries^2)
%
% fhlin@aug 8 2005
%

flag_display=1;
g_threshold=[];
g_threshold_p=[];
n_time=[];
ar_order=[];
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch option
        case 'flag_display'
            flag_display=option_value;
        case 'ts_name'
            ts_name=option_value;
        case 'n_time'
            n_time=option_value;
        case 'ar_order'
            ar_order=option_value;
        case 'g_threshold'
            g_threshold=option_value;
        case 'g_threshold_p'
            g_threshold_p=option_value;
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
    
    
    if(iscell(granger))
        for to_idx=1:size(granger,1)
            for from_idx=1:size(granger,2)
                GR(to_idx,from_idx)=mean(granger{to_idx,from_idx});
            end;
        end;
    else
        GR=granger;
    end;
    
    if(isempty(g_threshold))
        if(isempty(g_threshold_p))
            g_threshold_p=0.01;
        end;
        if(~iscell(granger))
            g_threshold=1./finv(g_threshold_p,n_time-ar_order,n_time);
        else
            g_threshold=1./finv(g_threshold_p,n_time-ar_order,n_time);
        end;
        fprintf('setting p-value at %3.3f: threshold at [%3.3f]\n',g_threshold_p,g_threshold);
    end;
    
    [s_granger,s_idx]=sort(GR(:));
    for i=length(s_idx):-1:1
        [r(i),c(i)]=ind2sub(size(GR),s_idx(i));
        if(s_granger(i)>g_threshold)
            fprintf('<<%d>> from [%s] ---> to [%s] [(%d,%d)]: %3.3f\n',length(s_idx)-i+1,ts_name{c(i)},ts_name{r(i)},r(i),c(i),s_granger(i));
        end;
    end;
end;
