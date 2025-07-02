function etc_trace_add_data(data,name)

cc=[
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0    0.4470    0.7410
    ]; %color order


global etc_trace_obj;

etc_trace_obj.tmp=data;

%adjust all data such that nan is appended when necessary.
for ii=1:length(etc_trace_obj.all_data)
    ll(ii)=size(etc_trace_obj.all_data{ii},2);
end;
ll(end+1)=size(etc_trace_obj.tmp,2);
mll=max(ll);
for ii=1:length(etc_trace_obj.all_data)
    fprintf('\tAppending NaN to the end of data [%d]...\n',ii);
    etc_trace_obj.all_data{ii}(:,end+1:mll)=nan;
end;
etc_trace_obj.tmp(:,end+1:mll)=nan;
if(~isfield(etc_trace_obj,'all_data_color'))
    for ii=1:length(etc_trace_obj.all_data)
        etc_trace_obj.all_data_color(ii,:)=cc(mod(ii-1,7)+1,:);
    end;
end;
etc_trace_obj.all_data{end+1}=etc_trace_obj.tmp;
etc_trace_obj.all_data_color(end+1,:)=cc(mod(length(etc_trace_obj.all_data)-1,7)+1,:);

etc_trace_obj.all_data_name{end+1}=name;
etc_trace_obj.all_data_aux_idx=cat(2,etc_trace_obj.all_data_aux_idx,1);


update_data;


%obj=findobj('Tag','text_load_var');
%set(obj,'String',sprintf('%s',var));

%data listbox in the info window
obj=findobj('Tag','listbox_info_data');
if(~isempty(obj))
    set(obj,'String',etc_trace_obj.all_data_name);
    set(obj,'Min',0);
    set(obj,'Max',length(etc_trace_obj.all_data_name));
    set(obj,'Value',etc_trace_obj.all_data_main_idx);
end;

%aux. data listbox in the info window
obj=findobj('Tag','listbox_info_auxdata');
if(~isempty(obj))
    set(obj,'String',etc_trace_obj.all_data_name);
    set(obj,'Min',0);
    set(obj,'Max',length(etc_trace_obj.all_data_name));
    set(obj,'Value',find(etc_trace_obj.all_data_aux_idx));
end;

%data listbox in the control window
obj=findobj('Tag','listbox_data');
if(~isempty(obj))
    set(obj,'String',etc_trace_obj.all_data_name);
    set(obj,'Min',0);
    set(obj,'Max',length(etc_trace_obj.all_data_name));
    set(obj,'Value',etc_trace_obj.all_data_main_idx); %choose the last one; popup menu limits only one option
end;

%data listbox in the analyze window
obj=findobj('Tag','listbox_data');
if(~isempty(obj))
    set(obj,'String',etc_trace_obj.all_data_name);
    set(obj,'Min',0);
    set(obj,'Max',length(etc_trace_obj.all_data_name));
    set(obj,'Value',etc_trace_obj.all_data_main_idx); %choose the last one; popup menu limits only one option
end;
fprintf('auxillary data [%s] loaded!\n',name);



function update_data()
global etc_trace_obj;

if(~isempty(etc_trace_obj.all_data_main_idx))
    if(~etc_trace_obj.flag_trigger_avg)
        etc_trace_obj.data=etc_trace_obj.all_data{etc_trace_obj.all_data_main_idx};
    else
        etc_trace_obj.buffer.data=etc_trace_obj.all_data{etc_trace_obj.all_data_main_idx};
    end;
else
    if(~etc_trace_obj.flag_trigger_avg)
        etc_trace_obj.data=[];
    else
        etc_trace_obj.buffer.data=[];        
    end;
end;

etc_trace_obj.aux_data={};
idx=find(etc_trace_obj.all_data_aux_idx);

if(~etc_trace_obj.flag_trigger_avg)
    for i=1:length(idx)
        etc_trace_obj.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
        etc_trace_obj.aux_data_color(i,:)=etc_trace_obj.all_data_color(idx(i),:);
    end;
    etc_trace_obj.aux_data_idx=idx;
else
    for i=1:length(idx)
        etc_trace_obj.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
        etc_trace_obj.aux_data_color(i,:)=etc_trace_obj.all_data_color(idx(i),:);
    end;
    etc_trace_obj.aux_data_idx=idx;
    
    etc_trace_obj.buffer.aux_data={};
    etc_trace_obj.buffer.aux_data_name={};
    etc_trace_obj.buffer.aux_data_color=[];   
    for i=1:length(idx)
        etc_trace_obj.buffer.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.buffer.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
        etc_trace_obj.buffer.aux_data_color(i,:)=etc_trace_obj.all_data_color(idx(i),:);
    end;
    etc_trace_obj.buffer.aux_data_idx=idx;    

    etc_trace_avg();
end;

%GUI
obj=findobj('Tag','listbox_info_data');
if(~isempty(obj))
    if(~isempty(etc_trace_obj.all_data_name))
        set(obj,'String',etc_trace_obj.all_data_name);
        set(obj,'Value',etc_trace_obj.all_data_main_idx);
    else
        set(obj,'String','[none]');
        set(obj,'Value',1);
    end;
end;

obj=findobj('Tag','listbox_info_auxdata');
if(~isempty(obj))
    if(~isempty(etc_trace_obj.all_data_name))
        set(obj,'String',etc_trace_obj.all_data_name);
        set(obj,'min',0);
        if(length(etc_trace_obj.all_data_name)<2)
            set(obj,'max',2);
        else
            set(obj,'max',length(etc_trace_obj.all_data_name));
        end;
        set(obj,'Value',find(etc_trace_obj.all_data_aux_idx));
    else
        set(obj,'String','[none]');
        set(obj,'min',0);
        set(obj,'max',2);
        set(obj,'Value',[]);        
    end
end;

obj=findobj('Tag','listbox_data');
if(~isempty(obj))
    if(~isempty(etc_trace_obj.all_data_name))
        set(obj,'String',etc_trace_obj.all_data_name);
        set(obj,'Value',etc_trace_obj.all_data_main_idx);
    else
        set(obj,'String','[none]');
        set(obj,'Value',1);      
    end;
end;



return;


