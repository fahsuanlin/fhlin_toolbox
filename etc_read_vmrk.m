function trigger=etc_read_vmrk(markerFile,varargin)


flag_auto_event=1;
event_code_empty=999; %default code for "empty" event


token_R128=1000;
token_SYNC=100;
token_ECG=33;
token_EKG=33;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'flag_auto_event'
            flag_auto_event=option_value;
        case 'event_code_empty'
            event_code_empty=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

fprintf('\treading triggers...\n');
trigger=[];
mk=textread(markerFile,'%s','delimiter','\n');
if(~isempty(mk))
    mk_idx=1;
    
    
    trigger_idx=1;
    trigger_str=sprintf('Mk%d',trigger_idx);
    
    while(mk_idx<=size(mk,1))
        if(length(mk{mk_idx})>length(trigger_str))
            if(strcmp(mk{mk_idx}(1:length(trigger_str)),trigger_str)) %found the trigger
                tmp=strfind(mk{mk_idx},',');
                
                %mk{mk_idx}(1:length(trigger_str))
                
                for tmp_idx=1:length(tmp)+1
                    if(tmp_idx==1)
                        bb=1;
                    else
                        bb=tmp(tmp_idx-1)+1;
                    end;
                    if(tmp_idx==length(tmp)+1)
                        ee=length(mk{mk_idx});
                    else
                        ee=tmp(tmp_idx)-1;
                    end;
                    mk_tmp{tmp_idx}=mk{mk_idx}(bb:ee);
                end;
                trigger.status_str{trigger_idx}=mk_tmp{1}(length(trigger_str)+2:end);
                trigger.event_str{trigger_idx}=mk_tmp{2};
                trigger.time(trigger_idx)=str2num(mk_tmp{3});
                trigger_idx=trigger_idx+1;
                
                %update for the next trigger
                trigger_str=sprintf('Mk%d',trigger_idx);
                
            end;
        end;
        mk_idx=mk_idx+1;
    end;
    
    
    fprintf('\t\ttotal [%d] events found\n',length(trigger));
end;

%find unique trigger event
all_events=unique(trigger.event_str);
fprintf('[%d] event(s) found!\n',length(all_events));
for e_idx=1:length(all_events)
    if((~isempty(all_events{e_idx})))
        if(strcmp(lower(all_events{e_idx}),'r128'))
            fprintf('event {%s} --> [%d]\n',all_events{e_idx},token_R128);
        elseif(strcmp(lower(all_events{e_idx}),'sync'))
            fprintf('event {%s} --> [%d]\n',all_events{e_idx},token_SYNC);
        elseif(strcmp(lower(all_events{e_idx}),'ECG'))
            fprintf('event {%s} --> [%d]\n',all_events{e_idx},token_ECG);
        elseif(strcmp(lower(all_events{e_idx}),'EKG'))
            fprintf('event {%s} --> [%d]\n',all_events{e_idx},token_EKG);
        else
            fprintf('event {%s} --> [%d]\n',all_events{e_idx},e_idx);
        end;
    else
        fprintf('event {''''} --> [%d]\n',event_code_empty);
    end;
end;

if(flag_auto_event)
    fprintf('automatic assigning event number...\n');
    for trigger_idx=1:length(trigger.time)
        if(~isempty(trigger.event_str{trigger_idx}))
            if(strcmp(lower(trigger.event_str{trigger_idx}),'r128'))
                trigger.event(trigger_idx)=token_R128;
            elseif(strcmp(lower(trigger.event_str{trigger_idx}),'sync'))
                trigger.event(trigger_idx)=token_SYNC;
            elseif(strcmp(lower(trigger.event_str{trigger_idx}),'ECG'))
                trigger.event(trigger_idx)=token_ECG;
            elseif(strcmp(lower(trigger.event_str{trigger_idx}),'EKG'))
                trigger.event(trigger_idx)=token_EKG;
            else
                trigger.event(trigger_idx)=find(cellfun(@(s) ~isempty(strfind(trigger.event_str{trigger_idx}, s)), all_events));
            end;
        else
            trigger.event(trigger_idx)=event_code_empty;
        end;
    end;
end;

