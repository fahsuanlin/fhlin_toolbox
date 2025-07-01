function etc_trace_add_data(data)

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


obj=findobj('Tag','text_load_var');
set(obj,'String',sprintf('%s',var));

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

fprintf('auxillary data [%s] loaded!\n',name);
