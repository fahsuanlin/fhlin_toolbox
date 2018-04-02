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

% Last Modified by GUIDE v2.5 02-Apr-2018 20:45:49

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
etc_trace_obj.axis_trace=findobj('tag','axis_trace');

handles.output=gcf;

% Update handles structure
guidata(hObject, handles);

%trigger loading
if(~isempty(etc_trace_obj.trigger))
    fprintf('trigger loaded...\n');
    tmp=sort(etc_trace_obj.trigger.event);
    trigger_type=tmp([find(diff(sort(tmp))) length(tmp)]);
    
    set(handles.listbox_trigger,'string',{trigger_type(:)});
    guidata(hObject, handles);
end;


duration=[0.1 0.5 1 2 5 10 30];
set(handles.listbox_time_duration,'string',{duration(:)});
set(handles.listbox_time_duration,'value',4); %default: 5 s
guidata(hObject, handles);


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

if(etc_trace_obj.time_begin_idx-etc_trace_obj.time_duration_idx>1)
    etc_trace_obj.time_begin_idx=etc_trace_obj.time_begin_idx-etc_trace_obj.time_duration_idx; %5 s advance
    etc_trace_obj.time_end_idx=etc_trace_obj.time_end_idx-etc_trace_obj.time_duration_idx; %5 s advance
    etc_trace_handle('redraw');
else
    etc_trace_obj.time_begin_idx=1; %back to the beginneing
    etc_trace_obj.time_end_idx=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx-1; %back to the beginning
    etc_trace_handle('redraw');
end;

%time slider
hObject_slider=findobj('tag','slider_time_idx');
v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
set(hObject_slider,'value',v);

%time edit
hObject=findobj('tag','edit_time_begin_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
hObject=findobj('tag','edit_time_end_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
hObject=findobj('tag','edit_time_begin');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
hObject=findobj('tag','edit_time_end');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));

% --- Executes on button press in pushbutton_rr.
function pushbutton_rr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

if(etc_trace_obj.time_begin_idx-etc_trace_obj.fs.*1>1)
    etc_trace_obj.time_begin_idx=etc_trace_obj.time_begin_idx-round(etc_trace_obj.time_duration_idx./5); %1 s advance
    etc_trace_obj.time_end_idx=etc_trace_obj.time_end_idx-round(etc_trace_obj.time_duration_idx./5); %1 s advance
    etc_trace_handle('redraw');
else
    etc_trace_obj.time_begin_idx=1; %back to the beginneing
    etc_trace_obj.time_end_idx=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx-1; %back to the beginning
    etc_trace_handle('redraw');
end;

%time slider
hObject_slider=findobj('tag','slider_time_idx');
v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
set(hObject_slider,'value',v);

%time edit
hObject=findobj('tag','edit_time_begin_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
hObject=findobj('tag','edit_time_end_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
hObject=findobj('tag','edit_time_begin');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
hObject=findobj('tag','edit_time_end');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));

% --- Executes on button press in pushbutton_ff.
function pushbutton_ff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

if(etc_trace_obj.time_end_idx+etc_trace_obj.fs.*1<size(etc_trace_obj.data,2))
    etc_trace_obj.time_begin_idx=etc_trace_obj.time_begin_idx+round(etc_trace_obj.time_duration_idx./5); %1 s advance
    etc_trace_obj.time_end_idx=etc_trace_obj.time_end_idx+round(etc_trace_obj.time_duration_idx./5); %1 s advance
    etc_trace_handle('redraw');
else
    etc_trace_obj.time_begin_idx=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx+1; %go to the end
    etc_trace_obj.time_end_idx=size(etc_trace_obj.data,2); %go to the end
    etc_trace_handle('redraw');
end;

%time slider
hObject_slider=findobj('tag','slider_time_idx');
v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
set(hObject_slider,'value',v);

%time edit
hObject=findobj('tag','edit_time_begin_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
hObject=findobj('tag','edit_time_end_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
hObject=findobj('tag','edit_time_begin');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
hObject=findobj('tag','edit_time_end');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));

% --- Executes on button press in pushbutton_fffast.
function pushbutton_fffast_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fffast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

if(etc_trace_obj.time_end_idx+etc_trace_obj.time_duration_idx<size(etc_trace_obj.data,2))
    etc_trace_obj.time_begin_idx=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx; %5 s advance
    etc_trace_obj.time_end_idx=etc_trace_obj.time_end_idx+etc_trace_obj.time_duration_idx; %5 s advance
    etc_trace_handle('redraw');
else
    etc_trace_obj.time_begin_idx=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx+1; %go to the end
    etc_trace_obj.time_end_idx=size(etc_trace_obj.data,2); %go to the end
    etc_trace_handle('redraw');
end;

%time slider
hObject_slider=findobj('tag','slider_time_idx');
v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
set(hObject_slider,'value',v);

%time edit
hObject=findobj('tag','edit_time_begin_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
hObject=findobj('tag','edit_time_end_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
hObject=findobj('tag','edit_time_begin');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
hObject=findobj('tag','edit_time_end');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));


% --- Executes on slider movement.
function slider_time_idx_Callback(hObject, eventdata, handles)
% hObject    handle to slider_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global etc_trace_obj;

set(hObject,'enable','off');

v=get(hObject,'Value');
etc_trace_obj.time_begin_idx=round(v*(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx))+1;
etc_trace_obj.time_end_idx=round(v*(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx))+etc_trace_obj.time_duration_idx;
etc_trace_handle('redraw');

set(hObject,'enable','on');

%time edit
hObject=findobj('tag','edit_time_begin_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
hObject=findobj('tag','edit_time_end_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
hObject=findobj('tag','edit_time_begin');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
hObject=findobj('tag','edit_time_end');
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));

% --- Executes during object creation, after setting all properties.
function slider_time_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

global etc_trace_obj;

v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);

set(hObject,'value',v);

% --- Executes on selection change in listbox_trigger.
function listbox_trigger_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_trigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_trigger
global etc_trace_obj;

contents = cellstr(get(hObject,'String'));
select_idx=get(hObject,'Value');

try
    etc_trace_obj.trigger_now=contents{select_idx};
    trigger_idx=find(etc_trace_obj.trigger.event==str2num(contents{select_idx}));
    trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    [tmp,mmidx]=min(abs(trigger_time_idx-etc_trace_obj.time_begin_idx));
    
    %trigger time
    etc_trace_obj.trigger_time_idx=trigger_time_idx(mmidx);
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));
    
    %a=trigger_time_idx(mmidx)-etc_trace_obj.fs+1;
    a=trigger_time_idx(mmidx)-round(etc_trace_obj.time_duration_idx/5)+1;
    b=a+etc_trace_obj.time_duration_idx;
    
    if(a>=1&&b<=size(etc_trace_obj.data,2))
        etc_trace_obj.time_begin_idx=a;
        etc_trace_obj.time_end_idx=b;
        
        %time slider
        hObject_slider=findobj('tag','slider_time_idx');
        v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
        set(hObject_slider,'value',v);
        
        %time edit
        hObject=findobj('tag','edit_time_begin_idx');
        set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
        hObject=findobj('tag','edit_time_end_idx');
        set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
        hObject=findobj('tag','edit_time_begin');
        set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
        hObject=findobj('tag','edit_time_end');
        set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
        
        etc_trace_handle('redraw');
    end;
    
catch ME
end;


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

a=str2double(get(hObject,'String'));
b=str2double(get(hObject,'String'))+etc_trace_obj.time_duration_idx-1;

if(a>=1&&b<=size(etc_trace_obj.data,2))
    etc_trace_obj.time_begin_idx=str2double(get(hObject,'String'));
    etc_trace_obj.time_end_idx=str2double(get(hObject,'String'))+etc_trace_obj.time_duration_idx-1;
    
    %time slider
    hObject_slider=findobj('tag','slider_time_idx');
    v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
    set(hObject_slider,'value',v);
    
    %time edit
    %hObject=findobj('tag','edit_time_begin_idx');
    %set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
    hObject=findobj('tag','edit_time_end_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
    hObject=findobj('tag','edit_time_begin');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
    hObject=findobj('tag','edit_time_end');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
    
    etc_trace_handle('redraw');
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

global etc_trace_obj;
set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));


function edit_time_end_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_end_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_end_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_time_end_idx as a double

global etc_trace_obj;

a=str2double(get(hObject,'String'))-etc_trace_obj.time_duration_idx-1;
b=str2double(get(hObject,'String'));

if(a>=1&&b<=size(etc_trace_obj.data,2))
    etc_trace_obj.time_begin_idx=str2double(get(hObject,'String'))-etc_trace_obj.time_duration_idx-1;
    etc_trace_obj.time_end_idx=str2double(get(hObject,'String'));
    
    %time slider
    hObject_slider=findobj('tag','slider_time_idx');
    v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
    set(hObject_slider,'value',v);
    
    %time edit
    hObject=findobj('tag','edit_time_begin_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
    %hObject=findobj('tag','edit_time_end_idx');
    %set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
    hObject=findobj('tag','edit_time_begin');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
    hObject=findobj('tag','edit_time_end');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
    
    etc_trace_handle('redraw');
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

global etc_trace_obj;
set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));


function edit_time_end_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_end as text
%        str2double(get(hObject,'String')) returns contents of edit_time_end as a double

global etc_trace_obj;

a=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)-etc_trace_obj.time_duration_idx+1;
b=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)+1;
if(a>=1&&b<=size(etc_trace_obj.data,2))
    etc_trace_obj.time_begin_idx=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)-etc_trace_obj.time_duration_idx+1;
    etc_trace_obj.time_end_idx=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)+1;
    
    %time slider
    hObject_slider=findobj('tag','slider_time_idx');
    v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
    set(hObject_slider,'value',v);
    
    %time edit
    hObject=findobj('tag','edit_time_begin_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
    hObject=findobj('tag','edit_time_end_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
    hObject=findobj('tag','edit_time_begin');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
    %hObject=findobj('tag','edit_time_end');
    %set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
    
    etc_trace_handle('redraw');
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

global etc_trace_obj;
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));


function edit_time_begin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time_begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time_begin as text
%        str2double(get(hObject,'String')) returns contents of edit_time_begin as a double

global etc_trace_obj;

a=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)+1;
b=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)+etc_trace_obj.time_duration_idx+1;
if(a>=1&&b<=size(etc_trace_obj.data,2))
    etc_trace_obj.time_begin_idx=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)+1;
    etc_trace_obj.time_end_idx=round(str2double(get(hObject,'String')).*etc_trace_obj.fs)+etc_trace_obj.time_duration_idx+1;
    
    %time slider
    hObject_slider=findobj('tag','slider_time_idx');
    v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
    set(hObject_slider,'value',v);
    
    %time edit
    hObject=findobj('tag','edit_time_begin_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
    hObject=findobj('tag','edit_time_end_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
    %hObject=findobj('tag','edit_time_begin');
    %set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
    hObject=findobj('tag','edit_time_end');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
    
    etc_trace_handle('redraw');
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

global etc_trace_obj;
set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));


% --- Executes on button press in pushbutton_trigger_rr.
function pushbutton_trigger_rr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trigger_rr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

try
    trigger_idx=find(etc_trace_obj.trigger.event==str2num(etc_trace_obj.trigger_now));
    trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    [tmp,mmidx]=min(abs(trigger_time_idx-etc_trace_obj.time_begin_idx-round(etc_trace_obj.time_duration_idx./5)));
    mmidx=mmidx-1;
    
    %trigger time
    etc_trace_obj.trigger_time_idx=trigger_time_idx(mmidx);
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));

    if(mmidx>=1)
        
        a=trigger_time_idx(mmidx)-round(etc_trace_obj.time_duration_idx/5)+1;
        b=a+etc_trace_obj.time_duration_idx;
        
        if(a>=1&&b<=size(etc_trace_obj.data,2))
            etc_trace_obj.time_begin_idx=a;
            etc_trace_obj.time_end_idx=b;
            
            %time slider
            hObject_slider=findobj('tag','slider_time_idx');
            v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
            set(hObject_slider,'value',v);
            
            %time edit
            hObject=findobj('tag','edit_time_begin_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
            hObject=findobj('tag','edit_time_end_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
            hObject=findobj('tag','edit_time_begin');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
            hObject=findobj('tag','edit_time_end');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
            
            etc_trace_handle('redraw');
        end;
    end;
    
catch ME
end;

% --- Executes on button press in pushbutton_trigger_ff.
function pushbutton_trigger_ff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_trigger_ff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

try
    trigger_idx=find(etc_trace_obj.trigger.event==str2num(etc_trace_obj.trigger_now));
    trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    [tmp,mmidx]=min(abs(trigger_time_idx-etc_trace_obj.time_begin_idx-round(etc_trace_obj.time_duration_idx./5)));
    mmidx=mmidx+1;

    %trigger time
    etc_trace_obj.trigger_time_idx=trigger_time_idx(mmidx);
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));

    if(mmidx<=length(trigger_time_idx))
        
        a=trigger_time_idx(mmidx)-round(etc_trace_obj.time_duration_idx/5)+1;
        b=a+etc_trace_obj.time_duration_idx;
        
        if(a>=1&&b<=size(etc_trace_obj.data,2))
            etc_trace_obj.time_begin_idx=a;
            etc_trace_obj.time_end_idx=b;
            
            %time slider
            hObject_slider=findobj('tag','slider_time_idx');
            v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
            set(hObject_slider,'value',v);
            
            %time edit
            hObject=findobj('tag','edit_time_begin_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
            hObject=findobj('tag','edit_time_end_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
            hObject=findobj('tag','edit_time_begin');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
            hObject=findobj('tag','edit_time_end');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
            
            etc_trace_handle('redraw');
        end;
    end;
    
catch ME
end;


% --- Executes on selection change in listbox_time_duration.
function listbox_time_duration_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_time_duration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_time_duration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_time_duration
global etc_trace_obj;

contents = cellstr(get(hObject,'String'));
etc_trace_obj.time_duration_idx=round(str2num(contents{get(hObject,'Value')})*etc_trace_obj.fs);
b=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx-1;
if(b<size(etc_trace_obj.data,2))
    etc_trace_obj.time_end_idx=etc_trace_obj.time_begin_idx+etc_trace_obj.time_duration_idx-1;
    
    %time edit
    hObject=findobj('tag','edit_time_begin_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
    hObject=findobj('tag','edit_time_end_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
    hObject=findobj('tag','edit_time_begin');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
    hObject=findobj('tag','edit_time_end');
    set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
    
    etc_trace_handle('redraw');
end;


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
