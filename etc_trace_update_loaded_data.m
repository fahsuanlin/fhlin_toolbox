function ok=etc_trace_update_loaded_data(montage,select,scaling)

ok=0;

global etc_trace_obj;

try
    %update channel names
    if(isempty(etc_trace_obj.ch_names))
        for idx=1:size(etc_trace_obj.data,1)
            etc_trace_obj.ch_names{idx}=sprintf('%03d',idx);
        end;
    end;
    
    if(~isempty(etc_trace_obj.trigger))
        if(isfield(etc_trace_obj.trigger,'event'))
            if(~iscell(etc_trace_obj.trigger.event))
                str={};
                for idx=1:length(etc_trace_obj.trigger.event)
                    str{idx}=sprintf('%d',etc_trace_obj.trigger.event(idx));
                end;
                etc_trace_obj.trigger.event=str;
            end;
        end;
    end;

   
    if(length(etc_trace_obj.ch_names)~=size(etc_trace_obj.data,1)) return; end; %channel does not match data...
    
    %if(isempty(montage))
    mm=eye(size(etc_trace_obj.data,1));
    montage_name='original';
    
    config={};
    for idx=1:length(etc_trace_obj.ch_names);
        config{end+1,1}=etc_trace_obj.ch_names{idx};
        config{end,2}='';
    end;
    %end;
    etc_trace_obj.montage{1}.config_matrix=[mm, zeros(size(mm,1),1)
        zeros(1,size(mm,2)), 1];
    etc_trace_obj.montage{1}.config=config;
    etc_trace_obj.montage{1}.name=montage_name;
    etc_trace_obj.montage_idx=1;
    
    
    
    if(~isempty(montage))
        for m_idx=1:length(montage)
            
            M=[];
            ecg_idx=[];
            for idx=1:size(montage{m_idx}.config,1)
                m=zeros(1,length(etc_trace_obj.ch_names));
                if(~isempty(montage{m_idx}.config{idx,1}))
                    m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,1}))))=1;
                    if((strcmp(lower(montage{m_idx}.config{idx,1}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,1}),'ekg')))
                        ecg_idx=union(ecg_idx,idx);
                    end;
                end;
                if(~isempty(montage{m_idx}.config{idx,2}))
                    m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,2}))))=-1;;
                    if((strcmp(lower(montage{m_idx}.config{idx,2}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,2}),'ekg')))
                        ecg_idx=union(ecg_idx,idx);
                    end;
                end;
                M=cat(1,M,m);
            end;
            M(end+1,end+1)=1;
            
            etc_trace_obj.montage{m_idx+length(etc_trace_obj.montage)}.config_matrix=M;
            etc_trace_obj.montage{m_idx+length(etc_trace_obj.montage)}.config=montage{m_idx}.config;
            etc_trace_obj.montage{m_idx+length(etc_trace_obj.montage)}.name=montage{m_idx}.name;
            
            S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
            S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
            etc_trace_obj.scaling{m_idx+length(etc_trace_obj.montage)}=S;
        end;
        %choose the last montage
        etc_trace_obj.montage_idx=m_idx+length(etc_trace_obj.montage);
    end;
    
    %update channel name info
    etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names={};
    for idx=1:size(etc_trace_obj.montage{etc_trace_obj.montage_idx}.config,1)
        m=etc_trace_obj.montage{etc_trace_obj.montage_idx}.config_matrix(idx,:);
        ii=find(m>eps);
        if(~isempty(ii))
            ss=etc_trace_obj.ch_names{ii(1)};
            if(length(ii)>1)
                for ii_idx=2:length(ii)
                    ss=sprintf('%s+%1.0fx%s',ss,m(ii(ii_idx)),etc_trace_obj.ch_names{ii(ii_idx)});
                end;
            end;
        end;
        
        ii=find(-m>eps);
        if(~isempty(ii))
            ss=sprintf('%s%1.0fx%s',ss,m(ii(1)),etc_trace_obj.ch_names{ii(1)});
            if(length(ii)>1)
                for ii_idx=2:length(ii)
                    ss=sprintf('%s-%1.0fx%s',ss,-m(ii(ii_idx)),etc_trace_obj.ch_names{ii(ii_idx)});
                end;
            end;
        end;
        etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names{idx}=ss;
    end;
    if(isempty(etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names)) etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names={'[none]'}; end;
    
    %montage listbox
    str={};
    for i=1:length(etc_trace_obj.montage)
        str{i}=etc_trace_obj.montage{i}.name;
    end;
    obj=findobj('tag','listbox_montage');
    if(~isempty(obj))
        set(obj,'String',str);
        set(obj,'Value',1);
    end;
    
    %channel listbox
    obj=findobj('Tag','listbox_channel');
    if(~isempty(obj))
        set(obj,'String',etc_trace_obj.montage_ch_name{etc_trace_obj.montage_idx}.ch_names);
    end;
    
    
    
    if(isempty(select))
        select=eye(size(etc_trace_obj.data,1));
        select_name='all';
    end;
    etc_trace_obj.select=[select, zeros(size(select,1),1)
        zeros(1,size(select,2)), 1];
    etc_trace_obj.select_name=select_name;
    
    if(isempty(scaling))
        scaling{1}=eye(size(etc_trace_obj.data,1));
    else
        scaling{1}=scaling;
    end;
    ecg_idx=find(strcmp(lower(etc_trace_obj.ch_names),'ecg')|strcmp(lower(etc_trace_obj.ch_names),'ekg'));
    scaling{1}(ecg_idx,ecg_idx)=scaling{1}(ecg_idx,ecg_idx)./10;
    etc_trace_obj.scaling{1}=[scaling{1}, zeros(size(scaling{1},1),1)
        zeros(1,size(scaling{1},2)), 1];
    
    %selection listbox
    str={};
    for i=1:length(etc_trace_obj.select)
        str{i}=sprintf('select%02d',i);
    end;
    obj=findobj('tag','listbox_select');
    if(~isempty(obj))
        set(obj,'String',str);
        set(obj,'Value',1);
    end;


    
    
    %trigger loading
    obj=findobj('Tag','listbox_trigger');
    str={};
    if(~isempty(etc_trace_obj.trigger))
        fprintf('trigger loaded...\n');
        str=unique(etc_trace_obj.trigger.event);
        set(obj,'string',str);
    else
        set(obj,'string',{'none'});
    end;%
    if(~isempty(str))
        if(isfield(etc_trace_obj,'trigger_now'))
            if(isempty(etc_trace_obj.trigger_now))
                
            else
                IndexC = strcmp(str,etc_trace_obj.trigger_now);
                if(isempty(find(IndexC)))
                    fprintf('current trigger [%s] not found in the loaded trigger...\n',etc_trace_obj.trigger_now);
                    fprintf('set current trigger to [%s]...\n',str{1});
                    etc_trace_obj.tigger_now=str{1};
                    set(obj,'Value',1);
                else
                    set(obj,'Value',find(IndexC));
                end;
            end;
        else
            if(isempty(str))
                etc_trace_obj.trigger_now='';
            else
                etc_trace_obj.trigger_now=str{1};
                set(obj,'Value',1);
            end;
        end;
    end;
    
    
    if(isfield(etc_trace_obj,'trigger_time_idx'))
        hObject=findobj('tag','edit_trigger_time_idx');
        set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
        hObject=findobj('tag','edit_trigger_time');
        set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
    else
        hObject=findobj('tag','edit_trigger_time_idx');
        set(hObject,'String','');
        hObject=findobj('tag','edit_trigger_time');
        set(hObject,'String','');
    end;

    
    ok=1;
catch ME
    ok=0;
end;

return;