function etc_trcae_gui_update_time(varargin)

global etc_trace_obj;

% need to control the following variables before calling this function:
%
% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
% etc_trace_obj.flag_time_window_auto_adjust=1;
%

flag_redraw=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'flag_redraw'
            flag_redraw=option_value;
        otherwise
            fprintf('unknown option [%s].error!\n',option);
    end;
end;

if(isempty(etc_trace_obj))
    return;
end;

try
    %time now
    hObject=findobj('tag','edit_time_now_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_select_idx));
    
    time_now=(etc_trace_obj.time_select_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin;
    hObject=findobj('tag',' edit_time_now');
    set(hObject,'String',sprintf('%1.4f',time_now));
    
    %time slider
    %v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
    v=etc_trace_obj.time_select_idx/size(etc_trace_obj.data,2);
    hObject_slider=findobj('tag','slider_time_idx');
    for i=1:length(hObject)
        if(v<=hObject_slider(i).Max&&v>=hObject_slider(i).Min)
            set(hObject_slider(i),'value',v);
        end;
    end;
    
    if(etc_trace_obj.time_duration_idx<=size(etc_trace_obj.data,2))
        %time window now
        if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
            
            %OK
            
        elseif(etc_trace_obj.time_window_begin_idx<1)
            
            etc_trace_obj.time_window_begin_idx=1;
            
        else
            
            etc_trace_obj.time_window_begin_idx=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx+1;
            
        end;
    else
        etc_trace_obj.time_window_begin_idx=1;
    end;
    
    if(etc_trace_obj.flag_time_window_auto_adjust)
        if((etc_trace_obj.time_select_idx>=etc_trace_obj.time_window_begin_idx)&&(etc_trace_obj.time_select_idx<=etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1))
            
            %ok!
            
        elseif(etc_trace_obj.time_select_idx<etc_trace_obj.time_window_begin_idx) %move window backward; place the selected time index at the specified location
            
            etc_trace_obj.time_window_begin_idx=etc_trace_obj.time_select_idx-round(etc_trace_obj.time_duration_idx*etc_trace_obj.config_trace_center_frac);
            if(etc_trace_obj.time_window_begin_idx<1)
                etc_trace_obj.time_window_begin_idx=1;
            end;
        else %move window forward; place the selected time index at the specified location
            
            etc_trace_obj.time_window_begin_idx=etc_trace_obj.time_select_idx-round(etc_trace_obj.time_duration_idx*etc_trace_obj.config_trace_center_frac);
            if(etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1>size(etc_trace_obj.data,2))
                etc_trace_obj.time_window_begin_idx=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx+1;
                if(etc_trace_obj.time_window_begin_idx<1)
                    etc_trace_obj.time_window_begin_idx=1;
                end;
            end;
            
        end;
    end;
    
    %time edit
    hObject=findobj('tag','edit_time_begin_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_window_begin_idx));
    hObject=findobj('tag','edit_time_end_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1));
    hObject=findobj('tag','edit_time_begin');
    set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.time_window_begin_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
    hObject=findobj('tag','edit_time_end');
    set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
    hObject=findobj('tag','listbox_time_duration');
    contents = cellstr(get(hObject(1),'String'));
    t=round(cellfun(@str2num,contents).*etc_trace_obj.fs);
    [dummy,idx]=min(abs(etc_trace_obj.time_duration_idx-t));
    set(hObject,'Value',idx);
    
    %trigger GUI
    hObject=findobj('tag','edit_time');
    if(~isempty(hObject))
        set(hObject,'String',sprintf('%d',etc_trace_obj.time_select_idx));
    end;
        
    if(flag_redraw)
        etc_trace_handle('redraw');
        etc_trace_handle('bd','time_idx',etc_trace_obj.time_select_idx);
    end;
catch ME
end;