function d_corr=etc_shiftcorr(d,varargin)

d_corr=[];

dim=1; %correction along the data dimenion
flag_display=0;

threshold=[];
threshold_std=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'threshold'
            threshold=option_value;
        case 'threshold_std'
            threshold_std=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'dim'
            dim=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

if(ndims(d)>2)
    fprintf('only work for 1D or 2D signals! error!\n');
    return;
end;


if(dim==2)
    d=d.';
end;

if(min(size(d))==1)
    if(size(d,1)==1)
        d=d.';
    end;
end;


d_corr=d;

threshold_orig=threshold;
for ch_idx=1:size(d,2)
    %threshold for detecting signal discontinuity
    df=diff(d(:,ch_idx));
    threshold=threshold_orig;
    if(isempty(threshold))
        if(isempty(threshold_std))
            threshold=5.*std(df);
        else
            threshold=threshold_std.*std(df);
        end;
    end;
    
    idx=find(abs(df)>threshold);
    
    if(flag_display)
        fprintf('<%02d> [%d] discontinuity found at threshold [%2.2f].\n',ch_idx,length(idx),threshold);
    end;
    
    tmp=d(:,ch_idx);
    
    for i=1:length(idx)
        tmp(idx(i)+1:end)=tmp(idx(i)+1:end)-df(idx(i));
    end;
    d_corr(:,ch_idx)=tmp;
end;


if(flag_display)
    plot(d); hold on;
    plot(d_corr);
end;

if(dim==2)
    d_corr=d_corr.';
end;

if(min(size(d))==1)
    if(size(d,1)==1)
        d_corr=d_corr.';
    end;
end;


return;