function varargout = etc_render_fsbrain_gui(varargin)
% ETC_RENDER_FSBRAIN_GUI MATLAB code for etc_render_fsbrain_gui.fig
%      ETC_RENDER_FSBRAIN_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_GUI returns the handle to a new ETC_RENDER_FSBRAIN_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_gui

% Last Modified by GUIDE v2.5 27-Dec-2016 16:39:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @etc_render_fsbrain_gui_OpeningFcn, ...
    'gui_OutputFcn',  @etc_render_fsbrain_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_gui is made visible.
function etc_render_fsbrain_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_timeVec_Callback(hObject, eventdata, handles)
% hObject    handle to slider_timeVec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain
time=get(hObject,'Value');
[dummy, etc_render_fsbrain.overlay_stc_timeVec_idx]=min(abs(etc_render_fsbrain.overlay_stc_timeVec-time));

if(~iscell(etc_render_fsbrain.overlay_value))
    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
else
    for h_idx=1:length(etc_render_fsbrain.overlay_value)
        etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
    end;
end;


%update time index edit
h=findobj('tag','edit_timeVec');
set(h,'value',time);
set(h,'string',sprintf('%1.1f',time));

if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
    fprintf('showing STC at time index [%d] (sample)\n',etc_render_fsbrain.overlay_stc_timeVec_idx);
else
    fprintf('showing STC at time [%2.2f] ms\n',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
end;

etc_render_fsbrain_handle('draw_stc');
etc_render_fsbrain_handle('redraw');




% --- Executes during object creation, after setting all properties.
function slider_timeVec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_timeVec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global etc_render_fsbrain
if(~isempty(etc_render_fsbrain.overlay_stc))
    if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
        set(hObject,'Min',min(etc_render_fsbrain.overlay_stc_timeVec));
        set(hObject,'Max',max(etc_render_fsbrain.overlay_stc_timeVec));
        if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'));
            set(hObject,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
        end;
    else
        etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
        set(hObject,'Min',min(etc_render_fsbrain.overlay_stc_timeVec));
        set(hObject,'Max',max(etc_render_fsbrain.overlay_stc_timeVec));
        if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'));
            set(hObject,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
        end;
    end;
else
    set(hObject,'enable','off');
end;


% --- Executes on button press in checkbox_show_overlay.
function checkbox_show_overlay_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_overlay
global etc_render_fsbrain
etc_render_fsbrain.overlay_flag_render=get(hObject,'value');
etc_render_fsbrain_handle('redraw');

function edit_threshold_min_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold_min as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold_min as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
mx=max(etc_render_fsbrain.overlay_threshold);
etc_render_fsbrain.overlay_threshold=[mm,mx];
etc_render_fsbrain_handle('redraw');


% --- Executes during object creation, after setting all properties.
function edit_threshold_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global etc_render_fsbrain
set(hObject,'string',sprintf('%1.1f',min(etc_render_fsbrain.overlay_threshold)));




function edit_threshold_max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold_max as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold_max as a double
global etc_render_fsbrain
mx=str2double(get(hObject,'string'));
mm=min(etc_render_fsbrain.overlay_threshold);
etc_render_fsbrain.overlay_threshold=[mm,mx];
etc_render_fsbrain_handle('redraw');


% --- Executes during object creation, after setting all properties.
function edit_threshold_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global etc_render_fsbrain
set(hObject,'string',sprintf('%1.1f',max(etc_render_fsbrain.overlay_threshold)));


% --- Executes during object creation, after setting all properties.
function text_timeVec_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_timeVec_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain
if(~isempty(etc_render_fsbrain.overlay_stc))
    if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
        etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
    end;
    set(hObject,'String',sprintf('%1.0f',min(etc_render_fsbrain.overlay_stc_timeVec)));
    set(hObject,'visible','on');
else
    set(hObject,'enable','off');
end;


% --- Executes during object creation, after setting all properties.
function text_timeVec_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_timeVec_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain
if(~isempty(etc_render_fsbrain.overlay_stc))
    if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
        etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
    end;
    set(hObject,'String',sprintf('%1.0f',max(etc_render_fsbrain.overlay_stc_timeVec)));
    set(hObject,'visible','on');
else
    set(hObject,'enable','off');
end;


% --- Executes during object creation, after setting all properties.
function checkbox_show_overlay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_show_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain
set(hObject,'value',etc_render_fsbrain.overlay_flag_render);
%keyboard;
if(~isempty(etc_render_fsbrain.overlay_stc)|~isempty(etc_render_fsbrain.overlay_value))
else
    set(hObject,'enable','off');
end;




function edit_timeVec_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timeVec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timeVec as text
%        str2double(get(hObject,'String')) returns contents of edit_timeVec as a double
global etc_render_fsbrain
time=str2double(get(hObject,'string'));
[dummy, etc_render_fsbrain.overlay_stc_timeVec_idx]=min(abs(etc_render_fsbrain.overlay_stc_timeVec-time));

if(~iscell(etc_render_fsbrain.overlay_value))
    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
else
    for h_idx=1:length(etc_render_fsbrain.overlay_value)
        etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
    end;
end;


%update time index edit
h=findobj('tag','slider_timeVec');
set(h,'value',time);

if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
    fprintf('showing STC at time index [%d] (sample)\n',etc_render_fsbrain.overlay_stc_timeVec_idx);
else
    fprintf('showing STC at time [%2.2f] ms\n',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
end;

etc_render_fsbrain_handle('draw_stc');
etc_render_fsbrain_handle('redraw');



% --- Executes during object creation, after setting all properties.
function edit_timeVec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timeVec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global etc_render_fsbrain
set(hObject,'string',etc_render_fsbrain.overlay_stc_timeVec_idx);


% --- Executes during object creation, after setting all properties.
function text11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain
set(hObject,'string',etc_render_fsbrain.overlay_stc_timeVec_unit);


% --- Executes on button press in checkbox_show_colorbar.
function checkbox_show_colorbar_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_colorbar
global etc_render_fsbrain
set(etc_render_fsbrain.fig_brain,'currentchar','c');
etc_render_fsbrain_handle('kb','cc','c');

% --- Executes during object creation, after setting all properties.
function checkbox_show_colorbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_show_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain

if(~isempty(etc_render_fsbrain.overlay_stc)|~isempty(etc_render_fsbrain.overlay_value))
    set(hObject,'value',1);
    if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
        if(isempty(etc_render_fsbrain.h_colorbar_pos))
            set(hObject,'value',0);
        end;
    end;
else
    set(hObject,'enable','off');
end;



function edit_smooth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_smooth as text
%        str2double(get(hObject,'String')) returns contents of edit_smooth as a double
global etc_render_fsbrain
etc_render_fsbrain.overlay_smooth=str2double(get(hObject,'string'));
etc_render_fsbrain_handle('redraw');

% --- Executes during object creation, after setting all properties.
function edit_smooth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smooth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global etc_render_fsbrain
if(~isempty(etc_render_fsbrain.overlay_stc)|~isempty(etc_render_fsbrain.overlay_value))
    set(hObject,'string',sprintf('%1.0f',etc_render_fsbrain.overlay_smooth));
else
    set(hObject,'enable','off');
end;
