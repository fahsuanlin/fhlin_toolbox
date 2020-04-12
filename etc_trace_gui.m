function varargout = etc_trace_gui(varargin)
% ETC_TRACE_GUI MATLAB code for etc_trace_gui.fig
%      ETC_TRACE_GUI, by itself, creates a new ETC_TRACE_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_GUI returns the handle to a new ETC_TRACE_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_GUI.M with the given input arguments.
%
%      ETC_TRACE_GUI('Property','Value',...) creates a new ETC_TRACE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_gui

% Last Modified by GUIDE v2.5 11-Apr-2020 20:27:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @etc_trace_gui_OpeningFcn, ...
    'gui_OutputFcn',  @etc_trace_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before etc_trace_gui is made visible.
function etc_trace_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_gui (see VARARGIN)

% Choose default command line output for etc_trace_gui

%cla(handles.axis_trace);
global etc_trace_obj;

etc_trace_obj.fig_trace=gcf;

etc_trace_obj.axis_trace=findobj('tag','axis_trace');

handles.output=gcf;

% Update handles structure
guidata(hObject, handles);

%set view
set(handles.listbox_view_style,'String',{'trace','butterfly','image'});
set(handles.listbox_view_style,'Value',1); %default style: trace


%trigger loading
if(~isempty(etc_trace_obj.trigger))
    fprintf('trigger loaded...\n');
    str=unique(etc_trace_obj.trigger.event);
    set(handles.listbox_trigger,'string',str);
else
    set(handles.listbox_trigger,'string',{});
end;%
guidata(hObject, handles);


duration=[0.1 0.5 1 2 5 10 30];
set(handles.listbox_time_duration,'string',{duration(:)});

[dummy,idx]=min(abs(duration-etc_trace_obj.time_duration_idx./etc_trace_obj.fs));
%set(handles.listbox_time_duration,'value',5); %default: 5 s
set(handles.listbox_time_duration,'value',idx); %default: 5 s
guidata(hObject, handles);

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



            %create a context menu....not successful....
            cm = uicontextmenu;
            m1 = uimenu(cm,'Text','test');
            handles.axis_trac.UIContextMenu = cm;

etc_trace_obj.data;
etc_trace_obj.fs;
etc_trace_obj.time_begin;
etc_trace_obj.time_select_idx;
etc_trace_obj.time_window_begin_idx;
etc_trace_obj.time_duration_idx;
etc_trace_obj.flag_time_window_auto_adjust=1;

%etc_trace_handle('redraw');

etc_trcae_gui_update_time('flag_redraw',0);
%etc_trcae_gui_update_time();



% UIWAIT makes etc_trace_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_rrfast.
function pushbutton_rrfast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rrfast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.time_select_idx-etc_trace_obj.time_duration_idx;
if(etc_trace_obj.time_select_idx<1)
    etc_trace_obj.time_select_idx=1;
end;
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;

% --- Executes on button press in pushbutton_rr.
function pushbutton_rr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.time_select_idx-round(etc_trace_obj.time_duration_idx./10);
if(etc_trace_obj.time_select_idx<1)
    etc_trace_obj.time_select_idx=1;
end;
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;

% --- Executes on button press in pushbutton_ff.
function pushbutton_ff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.time_select_idx+round(etc_trace_obj.time_duration_idx./10);
if(etc_trace_obj.time_select_idx>size(etc_trace_obj.data,2))
    etc_trace_obj.time_select_idx=size(etc_trace_obj.data,2);
end;
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;



% --- Executes on button press in pushbutton_fffast.
function pushbutton_fffast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fffast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.time_select_idx+etc_trace_obj.time_duration_idx;
if(etc_trace_obj.time_select_idx>size(etc_trace_obj.data,2))
    etc_trace_obj.time_select_idx=size(etc_trace_obj.data,2);
end;
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;


% --- Executes on slider movement.
function slider_time_idx_Callback(hObject, eventdata, handles)
% hObject    handle to slider_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
v=get(hObject,'Value');
etc_trace_obj.time_select_idx=round((size(etc_trace_obj.data,2)-1)*v+1);
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;


% --- Executes during object creation, after setting all properties.
function slider_time_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%global etc_trace_obj;
%v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
%set(hObject,'value',v);

% --- Executes on selection change in listbox_trigger.
function listbox_trigger_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_trigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_trigger
global etc_trace_obj;

if(isempty(etc_trace_obj))
    return;
end;

contents = cellstr(get(hObject,'String'));
etc_trace_obj.trigger_now=contents{get(hObject,'Value')};
fprintf('selected trigger = {%s}.\n',etc_trace_obj.trigger_now);

%update the default event/trigger name in the event/trigger window
hObject=findobj('tag','edit_local_trigger_class');
if(~isempty(hObject))
    set(hObject,'string',etc_trace_obj.trigger_now);
end;


IndexC = strfind(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
trigger_match_idx = find(not(cellfun('isempty',IndexC)));
trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
trigger_match_time_idx=sort(trigger_match_time_idx);
fprintf('[%d] trigger {%s} found at time index [%s].\n',length(trigger_match_idx),etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx));

%find the nearest one
[dummy,idx]=min(abs(trigger_match_time_idx-etc_trace_obj.time_select_idx));
if(idx<=1) idx=1; end;
etc_trace_obj.time_select_idx=trigger_match_time_idx(idx);
fprintf('now at the [%d]-th trigger {%s} found at time index [%s] <%1.3f s>.\n',idx,etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx(idx)),trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin);

hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',trigger_match_time_idx(idx)));


%update even/trigger window
hObject=findobj('tag','edit_local_trigger_time');
set(hObject,'String',sprintf('%1.3f',trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_local_trigger_time_idx');
set(hObject,'String',sprintf('%d',trigger_match_time_idx(idx)));

for ii=1:length(etc_trace_obj.trigger.time)
    if((etc_trace_obj.trigger.time(ii)==trigger_match_time_idx(idx))&&(strcmp(etc_trace_obj.trigger.event{ii},etc_trace_obj.trigger_now)))
        break;
    end;
end;
hObject=findobj('tag','listbox_time');
set(hObject,'Value',ii);
hObject=findobj('tag','listbox_time_idx');
set(hObject,'Value',ii);
hObject=findobj('tag','listbox_class');
set(hObject,'Value',ii);

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin).*etc_trace_obj.fs)+1;
% etc_trace_obj.time_duration_idx
% etc_trace_obj.flag_time_window_auto_adjust=0;
% if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
     etc_trcae_gui_update_time;
% end;




% --- Executes during object creation, after setting all properties.
function listbox_trigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit_time_begin_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_begin_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_begin_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_time_begin_idx as a double

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
etc_trace_obj.time_window_begin_idx=round(str2double(get(hObject,'String')));
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;



% --- Executes during object creation, after setting all properties.
function edit_time_begin_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_begin_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%global etc_trace_obj;
%set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));


function edit_time_end_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_end_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_end_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_time_end_idx as a double

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
etc_trace_obj.time_window_begin_idx=round(str2double(get(hObject,'String')))-etc_trace_obj.time_duration_idx;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;


% --- Executes during object creation, after setting all properties.
function edit_time_end_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_end_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%global etc_trace_obj;
%set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));


function edit_time_end_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_end as text
%        str2double(get(hObject,'String')) returns contents of edit_time_end as a double

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
etc_trace_obj.time_window_begin_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin)*etc_trace_obj.fs+1)-etc_trace_obj.time_duration_idx+1;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;



% --- Executes during object creation, after setting all properties.
function edit_time_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% global etc_trace_obj;
% set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));


function edit_time_begin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_begin as text
%        str2double(get(hObject,'String')) returns contents of edit_time_begin as a double

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
etc_trace_obj.time_window_begin_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin).*etc_trace_obj.fs)+1;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;

% --- Executes during object creation, after setting all properties.
function edit_time_begin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% global etc_trace_obj;
% set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));


% --- Executes on button press in pushbutton_trigger_rr.
function pushbutton_trigger_rr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trigger_rr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

if(isempty(etc_trace_obj))
    return;
end;

%IndexC = strfind(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
%trigger_match_idx = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
trigger_match_idx = find(IndexC);
trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
trigger_match_time_idx=sort(trigger_match_time_idx);
fprintf('[%d] trigger {%s} found at time index [%s].\n',length(trigger_match_idx),etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx));

if(isempty(find(trigger_match_time_idx==etc_trace_obj.time_select_idx))) %current time point is NOT inside trigger events
    %find the nearest one
    [dummy,idx]=min(abs(trigger_match_time_idx-etc_trace_obj.time_select_idx));
else
    tmp=trigger_match_time_idx-etc_trace_obj.time_select_idx+1;
    
    xx=find(tmp<0);
    if(isempty(xx))
        idx=1;
    else
        idx=xx(end);
    end;
    
   
    if(idx<=1) idx=1; end;
end;
etc_trace_obj.time_select_idx=trigger_match_time_idx(idx);
fprintf('now at the [%d]-th trigger {%s} found at time index [%s] <%1.3f s>.\n',idx,etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx(idx)),trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin);

hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',trigger_match_time_idx(idx)));

%update even/trigger window
hObject=findobj('tag','listbox_time_idx');
t_idx=cellfun(@str2num,hObject.String);
for ii=1:length(t_idx)
    if((t_idx(ii)==trigger_match_time_idx(idx))&&(strcmp(etc_trace_obj.trigger.event{ii},etc_trace_obj.trigger_now)))
        break;
    end;
end;
hObject=findobj('tag','listbox_time');
set(hObject,'Value',ii);
hObject=findobj('tag','listbox_time_idx');
set(hObject,'Value',ii);
hObject=findobj('tag','listbox_class');
set(hObject,'Value',ii);


% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin).*etc_trace_obj.fs)+1;
% etc_trace_obj.time_duration_idx
% etc_trace_obj.flag_time_window_auto_adjust=0;
% if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
     etc_trcae_gui_update_time;
% end;

return;


% --- Executes on button press in pushbutton_trigger_ff.
function pushbutton_trigger_ff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trigger_ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

if(isempty(etc_trace_obj))
    return;
end;

%IndexC = strfind(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
%trigger_match_idx = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
trigger_match_idx = find(IndexC);
trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
trigger_match_time_idx=sort(trigger_match_time_idx);
fprintf('[%d] trigger {%s} found at time index %s.\n',length(trigger_match_idx),etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx));

if(isempty(find(trigger_match_time_idx==etc_trace_obj.time_select_idx))) %current time point is NOT inside trigger events
    %find the nearest one
    [dummy,idx]=min(abs(trigger_match_time_idx-etc_trace_obj.time_select_idx));
else
    tmp=trigger_match_time_idx-etc_trace_obj.time_select_idx-1;
    
    xx=find(tmp>0);
    if(isempty(xx))
        idx=length(trigger_match_idx);
    else
        idx=xx(1);
    end;

    if(idx>=length(trigger_match_idx)) idx=length(trigger_match_idx); end;
end;
etc_trace_obj.time_select_idx=trigger_match_time_idx(idx);
fprintf('now at the [%d]-th trigger {%s} found at time index [%s] <%1.3f s>.\n',idx,etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx(idx)),trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin);

hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',trigger_match_time_idx(idx)));

%update even/trigger window
hObject=findobj('tag','listbox_time_idx');
t_idx=cellfun(@str2num,hObject.String);
for ii=1:length(t_idx)
    if((t_idx(ii)==trigger_match_time_idx(idx))&&(strcmp(etc_trace_obj.trigger.event{ii},etc_trace_obj.trigger_now)))
        break;
    end;
end;
hObject=findobj('tag','listbox_time');
set(hObject,'Value',ii);
hObject=findobj('tag','listbox_time_idx');
set(hObject,'Value',ii);
hObject=findobj('tag','listbox_class');
set(hObject,'Value',ii);

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin).*etc_trace_obj.fs)+1;
% etc_trace_obj.time_duration_idx
% etc_trace_obj.flag_time_window_auto_adjust=0;
% if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
     etc_trcae_gui_update_time;
% end;

return;

% --- Executes on selection change in listbox_time_duration.
function listbox_time_duration_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_time_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_time_duration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_time_duration

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx;
contents = cellstr(get(hObject,'String'));
etc_trace_obj.time_duration_idx=round(str2num(contents{get(hObject,'Value')})*etc_trace_obj.fs);
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;


% --- Executes during object creation, after setting all properties.
function listbox_time_duration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_time_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trigger_time_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trigger_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trigger_time_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_trigger_time_idx as a double


% --- Executes during object creation, after setting all properties.
function edit_trigger_time_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trigger_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trigger_time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trigger_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trigger_time as text
%        str2double(get(hObject,'String')) returns contents of edit_trigger_time as a double


% --- Executes during object creation, after setting all properties.
function edit_trigger_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trigger_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_time_now_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_now_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_now_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_time_now_idx as a double

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=round(str2double(get(hObject,'String')));
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
etc_trace_obj.flag_time_window_auto_adjust=1;
if((etc_trace_obj.time_select_idx)>=1&&(etc_trace_obj.time_select_idx<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;


% --- Executes during object creation, after setting all properties.
function edit_time_now_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_now_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_time_now_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_now (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_now as text
%        str2double(get(hObject,'String')) returns contents of edit_time_now as a double

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin)*etc_trace_obj.fs)+1;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
etc_trace_obj.flag_time_window_auto_adjust=1;

if((etc_trace_obj.time_select_idx)>=1&&(etc_trace_obj.time_select_idx<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;

% --- Executes during object creation, after setting all properties.
function edit_time_now_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time_now (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbutton_r.
function pushbutton_r_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.time_select_idx-1;
if(etc_trace_obj.time_select_idx<1)
    etc_trace_obj.time_select_idx=1;
end;
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;

% --- Executes on button press in pushbutton_f.
function pushbutton_f_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_f (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.time_select_idx+1;
if(etc_trace_obj.time_select_idx>size(etc_trace_obj.data,2))
    etc_trace_obj.time_select_idx=size(etc_trace_obj.data,2);
end;
% etc_trace_obj.time_window_begin_idx
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=1;
etc_trcae_gui_update_time;


% --- Executes on button press in pushbutton_window_rr.
function pushbutton_window_rr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_window_rr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx
% etc_trace_obj.time_window_begin_idx
etc_trace_obj.time_window_begin_idx=etc_trace_obj.time_window_begin_idx-round(etc_trace_obj.time_duration_idx./10);
if(etc_trace_obj.time_window_begin_idx<1)
    etc_trace_obj.time_window_begin_idx=1;
end;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
etc_trcae_gui_update_time;


% --- Executes on button press in pushbutton_window_ff.
function pushbutton_window_ff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_window_ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx
% etc_trace_obj.time_window_begin_idx
etc_trace_obj.time_window_begin_idx=etc_trace_obj.time_window_begin_idx+round(etc_trace_obj.time_duration_idx./10);
if(etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1>size(etc_trace_obj.data,2))
    etc_trace_obj.time_window_begin_idx=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx+1;
end;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
etc_trcae_gui_update_time;


% --- Executes on button press in pushbutton_window_rrfast.
function pushbutton_window_rrfast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_window_rrfast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx
% etc_trace_obj.time_window_begin_idx
etc_trace_obj.time_window_begin_idx=etc_trace_obj.time_window_begin_idx-etc_trace_obj.time_duration_idx;
if(etc_trace_obj.time_window_begin_idx<1)
    etc_trace_obj.time_window_begin_idx=1;
end;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
etc_trcae_gui_update_time;

% --- Executes on button press in pushbutton_window_fffast.
function pushbutton_window_fffast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_window_fffast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx
% etc_trace_obj.time_window_begin_idx
etc_trace_obj.time_window_begin_idx=etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx;
if(etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1>size(etc_trace_obj.data,2))
    etc_trace_obj.time_window_begin_idx=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx+1;
end;
% etc_trace_obj.time_duration_idx
etc_trace_obj.flag_time_window_auto_adjust=0;
etc_trcae_gui_update_time;


% --- Executes on selection change in listbox_view_style.
function listbox_view_style_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_view_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_view_style contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_view_style


% --- Executes during object creation, after setting all properties.
function listbox_view_style_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_view_style (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
