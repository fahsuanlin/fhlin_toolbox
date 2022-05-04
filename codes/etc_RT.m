function [rt_avg, rt_std, rt_out]=etc_RT(rt,varargin)


flag_display=0;
std_exclude=3;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'std_exclude'
            std_exclude=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            return;
    end;
end;

%include only RT entries within 3 STD.
if(isempty(std_exclude))
    std_exclude=3;
end;

rt0=rt;
cont=1;
while(cont)
    if(flag_display)
        fprintf('[%d] RT entries...\n',length(rt));
    end;
    
    rt_avg=mean(rt);
    rt_std=std(rt);
    
    idx=find((rt>(rt_avg+std_exclude*rt_std))|(rt<(rt_avg-std_exclude*rt_std)));
    if(isempty(idx))
        cont=0; %done; all RT entries are within the specified range
    else
        rt(idx)=[];
    end;
    if(isempty(rt))
        cont=0;
        if(flag_display)
            fprintf('no entries in RT remains after excluding all RTs beyond [%1.1f] std!\nenforced exit!\n',std_exclude);
        end;
    end;
end;
rt_out=rt;

return;