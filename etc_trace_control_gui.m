function varargout = etc_trace_control_gui(varargin)
% ETC_TRACE_CONTROL_GUI MATLAB code for etc_trace_control_gui.fig
%      ETC_TRACE_CONTROL_GUI, by itself, creates a new ETC_TRACE_CONTROL_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_CONTROL_GUI returns the handle to a new ETC_TRACE_CONTROL_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_CONTROL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_CONTROL_GUI.M with the given input arguments.
%
%      ETC_TRACE_CONTROL_GUI('Property','Value',...) creates a new ETC_TRACE_CONTROL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_control_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_control_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_control_gui

% Last Modified by GUIDE v2.5 19-Apr-2020 02:00:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @etc_trace_control_gui_OpeningFcn, ...
    'gui_OutputFcn',  @etc_trace_control_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_control_gui is made visible.
function etc_trace_control_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_control_gui (see VARARGIN)

% Choose default command line output for etc_trace_control_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_trace_control_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_trace_obj;

%etc_trace_obj.fig_trace=gcf;

etc_trace_obj.axis_trace=findobj('tag','axis_trace');

handles.output=gcf;

% Update handles structure
guidata(hObject, handles);

%set view
set(handles.listbox_colormap,'Value',1);
set(handles.listbox_colormap,'Visible','off');
set(handles.listbox_view_style,'String',{'trace','butterfly','image'});
set(handles.listbox_view_style,'Value',1); %default style: trace
if(isfield(etc_trace_obj,'view_style'))
    if(~isempty(etc_trace_obj.view_style))
        switch lower(etc_trace_obj.view_style)
            case 'trace'
                set(handles.listbox_view_style,'Value',1); %default style: trace
            case 'butterfly'
                set(handles.listbox_view_style,'Value',2); %default style: trace
            case 'image'
                set(handles.listbox_view_style,'Value',3); %default style: trace
        end
    else
        etc_trace_obj.view_style='trace';
    end;
else
    etc_trace_obj.view_style='trace';
end;

%trigger loading
str={};
if(~isempty(etc_trace_obj.trigger))
    fprintf('trigger loaded...\n');
    str=unique(etc_trace_obj.trigger.event);
    set(handles.listbox_trigger,'string',str);
else
    set(handles.listbox_trigger,'string',{});
end;%
if(isfield(etc_trace_obj,'trigger_now'))
    if(isempty(etc_trace_obj.trigger_now))
        
    else
        IndexC = strcmp(str,etc_trace_obj.trigger_now);
        set(handles.listbox_trigger,'Value',find(IndexC));
    end;
else
    if(isempty(str))
        etc_trace_obj.trigger_now='';
    else
        etc_trace_obj.trigger_now=str{1};
        set(handles.listbox_trigger,'Value',1);
    end;
end;
%guidata(hObject, handles);


duration=[0.1 0.5 1 2 5 10 30];
set(handles.listbox_time_duration,'string',{duration(:)});

[dummy,idx]=min(abs(duration-etc_trace_obj.time_duration_idx./etc_trace_obj.fs));
%set(handles.listbox_time_duration,'value',5); %default: 5 s
set(handles.listbox_time_duration,'value',idx); %default: 5 s
etc_trace_obj.time_duration_idx=round(etc_trace_obj.fs*duration(idx));
%guidata(hObject, handles);

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


%threshold
hObject=findobj('tag','edit_threshold');
set(hObject,'String',num2str(mean(abs(etc_trace_obj.ylim))));

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

% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_control_gui_OutputFcn(hObject, eventdata, handles)
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

if(isempty(etc_trace_obj.trigger)) return; end;

contents = cellstr(get(hObject,'String'));
etc_trace_obj.trigger_now=contents{get(hObject,'Value')};
fprintf('selected trigger = {%s}.\n',etc_trace_obj.trigger_now);

%update the default event/trigger name in the event/trigger window
hObject=findobj('tag','edit_local_trigger_class');
if(~isempty(hObject))
    set(hObject,'string',etc_trace_obj.trigger_now);
end;


%IndexC = strfind(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
%trigger_match_idx = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
trigger_match_idx = find(IndexC);
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

%update average window
hObject=findobj('tag','listbox_avg_trigger');
str=get(hObject,'String');
for i=1:length(str)
    if(strcmp(str{i},etc_trace_obj.trigger_now))
        break;
    end;
end;
set(hObject,'Value',i);


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

if(isempty(etc_trace_obj.trigger)) return; end;

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
if(~isempty(hObject))
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
end;

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

if(isempty(etc_trace_obj.trigger)) return; end;

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
if(~isempty(hObject))
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
end;

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
global etc_trace_obj;

contents = cellstr(get(hObject,'String'));
etc_trace_obj.view_style=contents{get(hObject,'Value')};

if(strcmp(etc_trace_obj.view_style,'image'))
    etc_trace_obj.colormap=colormap(parula);
    if(~isfield(etc_trace_obj,'axis_colorbar')) etc_trace_obj.axis_colorbar=[]; end;
    if(isempty(etc_trace_obj.axis_colorbar))
        etc_trace_obj.axis_colorbar=axes;
        set(etc_trace_obj.axis_colorbar,'pos',[0.64 0.65 0.01 0.2],'xtick',[],'ytick',[],'xcolor','none','ycolor','none');
    end;
    axes(etc_trace_obj.axis_colorbar); hold on;
    
    etc_trace_obj.h_colorbar=image(etc_trace_obj.axis_colorbar,([1,1:size(etc_trace_obj.colormap,1)])'); colormap(etc_trace_obj.colormap);
    
    obj=findobj('Tag','listbox_colormap');
    set(obj,'visible','on');
    set(obj,'String',{'parula','jet','rb'});
    set(obj,'value',1);
    
    axes(etc_trace_obj.axis_trace);
else
    try
        delete(etc_trace_obj.axis_colorbar);
        etc_trace_obj.axis_colorbar=[];
        obj=findobj('Tag','listbox_colormap');
        set(obj,'visible','off');
    catch ME
    end;
    axes(etc_trace_obj.axis_trace);
end;

etc_trace_handle('redraw');

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


% --- Executes on button press in checkbox_trigger_avg.
function checkbox_trigger_avg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_trigger_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_trigger_avg
global etc_trace_obj;


if(~isfield(etc_trace_obj,'flag_trigger_avg'))
    etc_trace_obj.flag_trigger_avg=0;
end;

if(~etc_trace_obj.flag_trigger_avg)
    set(hObject,'Value',0);
    etc_trace_obj.flag_trigger_avg=get(hObject,'Value');
    
    etc_trace_obj.fig_avg=etc_trace_avg_gui;
    pos0=get(etc_trace_obj.fig_trace,'pos');
    pos1=get(etc_trace_obj.fig_avg,'pos');
    set(etc_trace_obj.fig_avg,'pos',[pos0(1)+pos0(3) pos1(2) pos1(3) pos1(4)]);
    
else %restore the original un-averaged trace.
    
    %update data
    etc_trace_obj.data=etc_trace_obj.buffer.data;
    etc_trace_obj.aux_data=etc_trace_obj.buffer.aux_data;
    etc_trace_obj.trigger_now=etc_trace_obj.buffer.trigger_now;
    etc_trace_obj.trigger=etc_trace_obj.buffer.trigger;
    etc_trace_obj.time_begin=etc_trace_obj.buffer.time_begin;
    etc_trace_obj.time_select_idx=etc_trace_obj.buffer.time_select_idx;
    etc_trace_obj.time_window_begin_idx=etc_trace_obj.buffer.time_window_begin_idx;
    etc_trace_obj.time_duration_idx=etc_trace_obj.buffer.time_duration_idx;
    etc_trace_obj.ylim=etc_trace_obj.buffer.ylim;
    
    
    etc_trcae_gui_update_time;
    
    etc_trace_obj.buffer=[];
    
    hObject=findobj('tag','listbox_trigger');
    set(hObject,'Enable','on');
    hObject=findobj('tag','pushbutton_trigger_rr');
    set(hObject,'Enable','on');
    hObject=findobj('tag','pushbutton_trigger_ff');
    set(hObject,'Enable','on');
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'Enable','on');
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'Enable','on');
    
    hObject=findobj('tag','edit_threshold');
    set(hObject,'String',num2str(mean(abs(etc_trace_obj.ylim))));
    
    etc_trace_obj.flag_trigger_avg=0;
    
end;



function edit_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold as a double
global etc_trace_obj;

%fprintf('current limits = %s\n',mat2str(etc_trace_obj.ylim));
%def={num2str(etc_trace_obj.ylim)};
%answer=inputdlg('change limits',sprintf('current threshold = %s',mat2str(etc_trace_obj.ylim)),1,def);
answer=str2double(get(hObject,'String')) ;
if(~isempty(answer))
    %etc_trace_obj.ylim=str2num(answer{1});
    etc_trace_obj.ylim=[-abs(answer) abs(answer)];
    fprintf('updated time course limits = %s\n',mat2str(etc_trace_obj.ylim));
    
    global etc_render_fsbrain
    if(~isempty(etc_render_fsbrain))
        etc_render_fsbrain.overlay_threshold=[abs(diff(etc_trace_obj.ylim))/4 abs(diff(etc_trace_obj.ylim))/2 ];
        etc_trace_handle('bd');
    end;
    
    etc_trace_handle('redraw');
end;



% --- Executes during object creation, after setting all properties.
function edit_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_colormap.
function listbox_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_colormap

global etc_trace_obj;


contents = cellstr(get(hObject,'String'));
switch lower(contents{get(hObject,'Value')})
    case 'parula'
        etc_trace_obj.colormap=colormap(parula);
    case 'jet'
        etc_trace_obj.colormap=jet;
    case 'rb'
        a1=ones(1,64);
        ag=linspace(0,1,64);
        
        rr=[a1,a1,fliplr(ag)];
        gg=[ag,a1,fliplr(ag)];
        bb=[ag,a1,a1];
        
        cmap=[rr(:),gg(:),bb(:)];
        etc_trace_obj.colormap=cmap;
end;


etc_trace_handle('redraw');


% --- Executes during object creation, after setting all properties.
function listbox_colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

etc_trace_obj.fig_load=etc_trace_load_gui;


% --- Executes on button press in pushbutton_loadfile.
function pushbutton_loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

%etc_trace_obj.fig_load=etc_trace_load_gui;

[file,path] = uigetfile({'*.eeg; *.vhdr; *.vmrk','EEG'; '*.*','All files'},'Select a file');
[dummy,fstem,ext]=fileparts(file);
switch lower(ext)
    case {'.eeg','.vmrk','.vhdr'}
        fprintf('reading EEG file....\n');
        
        headerFile=sprintf('%s/%s%s',path,fstem,'.vhdr');
        % first get the continuous data as a matlab array
        etc_trace_obj.data = double(bva_loadeeg(headerFile));
        
        % meta information such as samplingRate (fs), labels, etc
        [etc_trace_obj.fs etc_trace_obj.ch_names etc_trace_obj.meta] = bva_readheader(headerFile);
        
        %read maker file
        markerFile=sprintf('%s/%s%s',path,fstem,'.vmrk');
        etc_trace_obj.trigger=etc_read_vmrk(markerFile);
       
        flag_reref=0;
        %re-referencing
        if(flag_reref)
            fprintf('\treferencing...\n');
            eeg_ref=mean(etc_trace_obj.data ,1);
            for ch_idx=1:size(etc_trace_obj.data,1)
                etc_trace_obj.data (ch_idx,:)=etc_trace_obj.data -eeg_ref{f_idx};
            end;
        else
            eeg_ref=[];
        end;
        
        flag_hp=0;
        %high-pass filtering
        if(flag_hp)
            fprintf('\tHP...\n');
            %high-pass filtering (0.1 Hz)
            Wn = 0.1*2/fs(f_idx);
            N = 3; % order of 3 less processing
            [a,b] = butter(N,Wn,'high'); %bandpass filtering
            for ch_idx=1:size(etc_trace_obj.data,1)
                etc_trace_obj.data(ch_idx,:) = filtfilt(a,b,etc_trace_obj.data(ch_idx,:));
            end;
        end;
        
        
        time_trim=[];
        %remove first few seconds (if needed....)
        if(~isempty(time_trim))
            time_trim_idx=round(time_trim*etc_trace_obj.fs);
            
            fprintf('trimming [%1.1f] s data {(%d) samples}....\n',time_trim, time_trim_idx);
            etc_trace_obj.data=etc_trace_obj.data(:,time_trim_idx+1:end);
            
        end;
        
        hObject=findobj('tag','listbox_time_duration');
        contents = cellstr(get(hObject,'String'));
        ii=round(cellfun(@str2num,contents).*etc_trace_obj.fs);
        [dummy,vv]=min(abs(ii-size(etc_trace_obj.data,2)));
        round(str2num(contents{vv})*etc_trace_obj.fs);
        etc_trace_obj.time_duration_idx=round(str2num(contents{vv})*etc_trace_obj.fs);
        
        etc_trace_obj.load.montage=[];
        etc_trace_obj.load.select=[];
        etc_trace_obj.load.scale=[];
        
        ok=etc_trace_update_loaded_data(etc_trace_obj.load.montage,etc_trace_obj.load.select,etc_trace_obj.load.scale);
        
        etc_trace_obj.load_output=ok;
        
        if(etc_trace_obj.load_output) %if everything is ok...
            etc_trcae_gui_update_time();
            %etc_trace_handle('redraw');
        end;
        
    otherwise
        fprintf('unknown format...\nerror!\n');
end;

% 
% [dummy,fstem]=fileparts(headerFile{f_idx});
% fprintf('reading [%s]...\n',fstem);
% 
% 
% 
% 
% found_channel={};
% for s_idx=1:length(select_channel)
%     IndexC = strcmp(lower(label),lower(select_channel{s_idx})); %change all labels into lower case
%     Index = find(IndexC);
%     
%     if(~isempty(Index))
%         fprintf('\tChannel [%s] found:: index=%03d \r',select_channel{s_idx},Index);
%         if(strcmp(lower(select_channel{s_idx}),'ecg'))
%             ecg_channel=Index;
%         else
%             eeg_channel(s_idx)=Index;
%         end;
%         found_channel{end+1}=select_channel{s_idx};
%     else
%         fprintf('\tChannel [%s] not found! \r',select_channel{s_idx});
%     end;
% end;
% fprintf('\n');
% 
% ecg_orig=eeg{f_idx}(ecg_channel,:)';
% eeg_orig=eeg{f_idx}(eeg_channel,:);
% ecg{f_idx}=eeg{f_idx}(ecg_channel,:)';
% eeg{f_idx}=eeg{f_idx}(eeg_channel,:);
% 
% %re-referencing
% if(flag_reref(f_idx))
%     fprintf('\treferencing...\n');
%     eeg_ref{f_idx}=mean(eeg{f_idx},1);
%     for ch_idx=1:size(eeg{f_idx},1)
%         eeg{f_idx}(ch_idx,:)=eeg{f_idx}(ch_idx,:)-eeg_ref{f_idx};
%     end;
% else
%     eeg_ref{f_idx}=[];
% end;
% 
% 
% %read maker file
% fprintf('\treading triggers...\n');
% trigger{f_idx}=etc_read_vmrk(markerFile{f_idx});
% 
% 
% if(flag_aas(f_idx))
%     fprintf('\tAAS...\n');
%     gradient_trigger{f_idx}=zeros(size(eeg{f_idx},2),1);
%     iidx=find(trigger{f_idx}.event==trigger_token);
%     gradient_trigger{f_idx}(trigger{f_idx}.time(iidx))=1e3;
%     ecg{f_idx}=eeg_ga(ecg{f_idx},gradient_trigger{f_idx},TR,fs(f_idx),'flag_display',0,'flag_ma_aas',1,'flag_aas_svd',0,'flag_anchor_bnd',0,'n_ma_aas',7); %AAS on ECG
%     ecg{f_idx}=sgolayfilt(ecg{f_idx},6,301); %smoothing out residual GA in ECG
%     eeg{f_idx}=eeg_ga(eeg{f_idx},gradient_trigger{f_idx},TR,fs(f_idx),'flag_display',0,'flag_ma_aas',1,'flag_aas_svd',0,'flag_anchor_bnd',0,'n_ma_aas',7); %AAS on EEG
% end;
% 
% 
% %high-pass filtering
% if(flag_hp(f_idx))
%     fprintf('\tHP...\n');
%     %high-pass filtering (0.1 Hz)
%     Wn = 0.1*2/fs(f_idx);
%     N = 3; % order of 3 less processing
%     [a,b] = butter(N,Wn,'high'); %bandpass filtering
%     for ch_idx=1:size(eeg{f_idx},1)
%         eeg{f_idx}(ch_idx,:) = filtfilt(a,b,eeg{f_idx}(ch_idx,:));
%     end;
%     if(~isempty(eeg_ref{f_idx}))
%         eeg_ref{f_idx}=filtfilt(a,b,eeg_ref{f_idx}(:))';
%     end;
%     
%     ecg{f_idx}=filtfilt(a,b,ecg{f_idx}(:))';
% end;
% 
% 
% %remove first few seconds (if needed....)
% if(~isempty(time_trim))
%     time_trim_idx=round(time_trim*fs(f_idx));
%     
%     fprintf('trimming [%1.1f] s data {(%d) samples}....\n',time_trim, time_trim_idx);
%     ecg{f_idx}=ecg{f_idx}(time_trim_idx+1:end);
%     eeg{f_idx}=eeg{f_idx}(:,time_trim_idx+1:end);
%     %trigger{f_idx}.time=trigger{f_idx}.time-time_trim_idx;
%     
%     %%update trigger info
%     %idx=find(trigger{f_idx}.time<0);
%     %trigger{f_idx}.time(idx)=[];
%     %trigger{f_idx}.event(idx)=[];
% end;


% --- Executes on button press in pushbutton_trigger_window.
function pushbutton_trigger_window_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trigger_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

fprintf('show triggers/events....\n');
if(isfield(etc_trace_obj,'fig_trigger'))
    etc_trace_obj.fig_trigger=[];
end;
etc_trace_obj.fig_trigger=etc_trace_trigger_gui;

set(etc_trace_obj.fig_trigger,'Name','trigger','resize','off');

pp0=get(etc_trace_obj.fig_trigger,'outerpos');
pp1=get(etc_trace_obj.fig_trace,'outerpos');
set(etc_trace_obj.fig_trigger,'outerpos',[pp1(1)+pp1(3), pp1(2),pp0(3), pp0(4)]);
set(etc_trace_obj.fig_trigger,'Resize','off');
