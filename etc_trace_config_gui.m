function varargout = etc_trace_config_gui(varargin)
% ETC_TRACE_CONFIG_GUI MATLAB code for etc_trace_config_gui.fig
%      ETC_TRACE_CONFIG_GUI, by itself, creates a new ETC_TRACE_CONFIG_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_CONFIG_GUI returns the handle to a new ETC_TRACE_CONFIG_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_CONFIG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_CONFIG_GUI.M with the given input arguments.
%
%      ETC_TRACE_CONFIG_GUI('Property','Value',...) creates a new ETC_TRACE_CONFIG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_config_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_config_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_config_gui

% Last Modified by GUIDE v2.5 23-Feb-2019 07:41:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_config_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_config_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_config_gui is made visible.
function etc_trace_config_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_config_gui (see VARARGIN)

% Choose default command line output for etc_trace_config_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);




% UIWAIT makes etc_trace_config_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_config_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_config_trace_center_frac_Callback(hObject, eventdata, handles)
% hObject    handle to edit_config_trace_center_frac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_config_trace_center_frac as text
%        str2double(get(hObject,'String')) returns contents of edit_config_trace_center_frac as a double

%update trace GUI
global etc_trace_obj;

etc_trace_obj.config_trace_center_frac=str2double(get(hObject,'String'));
etc_trace_handle('redraw');



% --- Executes during object creation, after setting all properties.
function edit_config_trace_center_frac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_config_trace_center_frac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_config_trace_width_Callback(hObject, eventdata, handles)
% hObject    handle to edit_config_trace_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_config_trace_width as text
%        str2double(get(hObject,'String')) returns contents of edit_config_trace_width as a double
global etc_trace_obj;

etc_trace_obj.config_trace_width=round(str2double(get(hObject,'String')));
etc_trace_handle('redraw');



% --- Executes during object creation, after setting all properties.
function edit_config_trace_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_config_trace_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_config_trace_color.
function pushbutton_config_trace_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_config_trace_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

color = uisetcolor(etc_trace_obj.config_trace_color);

if((length(color)==1)&&(color<eps))
else
    obj=findobj('tag','pushbutton_config_trace_color');
    set(obj,'backgroundcolor',color);
    etc_trace_obj.config_trace_color=color;
    etc_trace_handle('redraw');
end;


% --- Executes on button press in pushbutton_config_current_time_color.
function pushbutton_config_current_time_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_config_current_time_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

color = uisetcolor(etc_trace_obj.config_current_time_color);

if((length(color)==1)&&(color<eps))
else
    obj=findobj('tag','pushbutton_config_current_time_color');
    set(obj,'backgroundcolor',color);
    etc_trace_obj.config_current_time_color=color;
    etc_trace_handle('redraw');
end;


% --- Executes on button press in pushbutton_config_current_trigger_color.
function pushbutton_config_current_trigger_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_config_current_trigger_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

color = uisetcolor(etc_trace_obj.config_current_trigger_color);

if((length(color)==1)&&(color<eps))
else
    obj=findobj('tag','pushbutton_config_current_trigger_color');
    set(obj,'backgroundcolor',color);
    etc_trace_obj.config_current_trigger_color=color;
    etc_trace_handle('redraw');
end;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_trace_obj;

%update trace GUI
%hObject=findobj(gca,'tag','edit_config_trace_center_frac');
%set(hObject,'String',sprintf('%2.2f',etc_trace_obj.config_trace_center_frac));
set(findobj(hObject,'tag','edit_config_trace_center_frac'),'String',sprintf('%2.2f',etc_trace_obj.config_trace_center_frac));


%hObject=findobj(gca,'tag','edit_config_trace_width');
%set(hObject,'String',sprintf('%d',etc_trace_obj.config_trace_width));
set(findobj(hObject,'tag','edit_config_trace_width'),'String',sprintf('%2.2f',etc_trace_obj.config_trace_width));

%hObject=findobj(gca,'tag','pushbutton_config_trace_color');
%set(hObject,'BackgroundColor',etc_trace_obj.config_trace_color);
set(findobj(hObject,'tag','pushbutton_config_trace_color'),'BackgroundColor',etc_trace_obj.config_trace_color);

%hObject=findobj(gca,'tag','pushbutton_config_trace_color');
%set(hObject,'BackgroundColor',etc_trace_obj.config_current_time_color);
set(findobj(hObject,'tag','pushbutton_config_current_time_color'),'BackgroundColor',etc_trace_obj.config_current_time_color);

%hObject=findobj(gca,'tag','pushbutton_config_trigger_color');
%set(hObject,'BackgroundColor',etc_trace_obj.config_current_trigger_color);
set(findobj(hObject,'tag','pushbutton_config_current_trigger_color'),'BackgroundColor',etc_trace_obj.config_current_trigger_color);
