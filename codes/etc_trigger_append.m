function trigger_out=etc_trigger_append(trigger_orig,varargin)
%
% etc_trigger_append    add custom trigger information 
%
% trigger_out = etc_trigger_append(trigger_orig,[trigger_add1, trigger_add2, ...]);
%
% trigger_orig: the original trigger object
%
% trigger_add1: the trigger object to be appended
%
% NOTE: each trigger object is a struct with two fields
%   time: a 1-D array of timing (in samples)
%   event: a -D array of event coded by integer
%
%   the length of 'time' and 'event' must be identical.
%
% fhlin@sep. 7 2019
%

if(~iscell(trigger_orig.event))
    str={};
    for idx=1:length(trigger_orig.event)
        str{idx}=sprintf('%d',trigger_orig.event(idx));
    end;
    trigger_orig.event=str;
end;

trigger_out=trigger_orig;


if(~iscell(trigger_orig.event))
    str={};
    for idx=1:length(trigger_orig.event)
        str{idx}=sprintf('%d',trigger_orig.event(idx));
    end;
    trigger_orig.event=str;
end;
    
for i=1:length(varargin)
    
    %    fprintf('appenediing trigger [%s]...\n',varargin{i});
    if(~iscell(varargin{i}.event))
        str={};
        for idx=1:length(varargin{i}.event)
            str{idx}=sprintf('%d',varargin{i}.event(idx));
        end;
        varargin{i}.event=str;
    end;
    
    
    time_old=trigger_out.time;
    event_old=trigger_out.event;
    
    
    time_new=varargin{i}.time;
    event_new=varargin{i}.event;
    
    for ii=1:length(time_old)+length(time_new)
        if(isempty(time_old))
            idx(ii)=2;
            time_new(1)=[];
        elseif(isempty(time_new))
            idx(ii)=1;
            time_old(1)=[];
        else
            if(time_old(1)<time_new(1))
                idx(ii)=1;
                time_old(1)=[];
            else
                idx(ii)=2;
                time_new(1)=[];
            end;
        end;
    end;
    
    idx1=find(idx==1); %old 
    idx2=find(idx==2); %new
    
%     buffer_time(idx1)=trigger_out.time;
%     buffer_time(idx2)=varargin{i}.time;
%     buffer_event(idx1)=trigger_out.event;
%     buffer_event(idx2)=varargin{i}.event;

    
    fields=fieldnames(varargin{i});
    
    for field_idx=1:length(fields)
        cmd=sprintf('buffer_%s(idx1)=trigger_out.%s;',fields{field_idx},fields{field_idx});
        eval(cmd);
        cmd=sprintf('buffer_%s(idx2)=varargin{%d}.%s;',fields{field_idx},i,fields{field_idx});
        eval(cmd);
        cmd=sprintf('trigger_out.%s=buffer_%s;',fields{field_idx},fields{field_idx});
        eval(cmd);
    end;
    
    for field_idx=1:length(fields)
        cmd=sprintf('clear buffer_%s;',fields{field_idx});
    end;
%     %update the 'trigger_out'
%     trigger_out.time=buffer_time;
%     trigger_out.event=buffer_event;
   
end;

return;

