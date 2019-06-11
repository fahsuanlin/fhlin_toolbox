function varargout = etc_render_fsbrain_sensor_add_gui(varargin)
% ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI MATLAB code for etc_render_fsbrain_sensor_add_gui.fig
%      ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI returns the handle to a new ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_SENSOR_ADD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_sensor_add_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_sensor_add_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_sensor_add_gui

% Last Modified by GUIDE v2.5 11-Jun-2019 03:09:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_sensor_add_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_sensor_add_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_sensor_add_gui is made visible.
function etc_render_fsbrain_sensor_add_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_sensor_add_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_sensor_add_gui
handles.output = hObject;

global etc_render_fsbrain;

if(isfield(etc_render_fsbrain,'sensor_modify_flag'))
    if(etc_render_fsbrain.sensor_modify_flag)
        %initialization as an existed sensor
        set(handles.figure_sensor_add_gui,'name','modify a sensor');
        set(handles.edit_name,'string',sprintf('%s',etc_render_fsbrain.aux_point_name{etc_render_fsbrain.aux_point_idx})); 
    else
        %initialization as a new sensor to be added
        set(handles.figure_sensor_add_gui,'name','add a sensor');
        set(handles.edit_name,'string','');
    end;
else
    %initialization as a new sensor to be added
    set(handles.figure_sensor_add_gui,'name','add a sensor');
    set(handles.edit_name,'string',''); 
end;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_sensor_add_gui wait for user response (see UIRESUME)
% uiwait(handles.figure_sensor_add_gui);



% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_sensor_add_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_name as text
%        str2double(get(hObject,'String')) returns contents of edit_name as a double


% --- Executes during object creation, after setting all properties.
function edit_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_n_contact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_n_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_n_contact as text
%        str2double(get(hObject,'String')) returns contents of edit_n_contact as a double


% --- Executes during object creation, after setting all properties.
function edit_n_contact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_n_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_spacing_Callback(hObject, eventdata, handles)
% hObject    handle to edit_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_spacing as text
%        str2double(get(hObject,'String')) returns contents of edit_spacing as a double


% --- Executes during object creation, after setting all properties.
function edit_spacing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_spacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_ok.
function pushbutton_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

etc_render_fsbrain.sensor_add_gui_ok=1;


if(isfield(etc_render_fsbrain,'sensor_modify_flag'))
    if(etc_render_fsbrain.sensor_modify_flag)
        etc_render_fsbrain.new_sensor.name=get(handles.edit_name,'String');
        
        %check if electrode name empty
        if(isempty(etc_render_fsbrain.new_sensor.name))
            etc_render_fsbrain.sensor_add_gui_ok=0;
            fprintf('sensor name cannot be empty!\n');
        end;
        
        %check if sensor name duplicates
        flag_duplicate=0;
        for e_idx=1:length(etc_render_fsbrain.aux_point_name)
            if(e_idx~=etc_render_fsbrain.aux_point_idx)
                if(strcmp(etc_render_fsbrain.aux_point_name{e_idx},etc_render_fsbrain.new_sensor.name))
                    flag_duplicate=1;
                end;
            end;
        end;
        if(flag_duplicate)
            etc_render_fsbrain.sensor_add_gui_ok=0;
            fprintf('sensor [%s] is in the list already!\n',etc_render_fsbrain.new_sensor.name);
        end;
        
        uiresume(etc_render_fsbrain.sensor_add_gui_h);
        
    else
        etc_render_fsbrain.new_sensor.name=get(handles.edit_name,'String');
        
        %check if sensor name empty
        if(isempty(etc_render_fsbrain.new_sensor.name))
            etc_render_fsbrain.sensor_add_gui_ok=0;
            fprintf('sensor name cannot be empty!\n');
        end;
        
        %check if electrode name duplicates
        flag_duplicate=0;
        for e_idx=1:length(etc_render_fsbrain.aux_point_name)
            if(strcmp(etc_render_fsbrain.aux_point_name{e_idx},etc_render_fsbrain.new_sensor.name))
                flag_duplicate=1;
            end;
        end;
        if(flag_duplicate)
            etc_render_fsbrain.sensor_add_gui_ok=0;
            fprintf('sensor [%s] is in the list already!\n',etc_render_fsbrain.new_sensor.name);
        end;
        
        uiresume(etc_render_fsbrain.sensor_add_gui_h);
    end;
else
    etc_render_fsbrain.new_sensor.name=get(handles.edit_name,'String');
    
    %check if sensor name empty
    if(isempty(etc_render_fsbrain.new_sensor.name))
        etc_render_fsbrain.sensor_add_gui_ok=0;
        fprintf('sensor name cannot be empty!\n');
    end;
    
    %check if sensor name duplicates
    flag_duplicate=0;
    for e_idx=1:length(etc_render_fsbrain.aux_point_name)
        if(strcmp(etc_render_fsbrain.aux_point_name{e_idx},etc_render_fsbrain.new_sensor.name))
            flag_duplicate=1;
        end;
    end;
    if(flag_duplicate)
        etc_render_fsbrain.sensor_add_gui_ok=0;
        fprintf('sensor [%s] is in the list already!\n',etc_render_fsbrain.new_sensor.name);
    end;
        
    uiresume(etc_render_fsbrain.sensor_add_gui_h);
end;

% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

etc_render_fsbrain.sensor_add_gui_ok=0;
uiresume(etc_render_fsbrain.sensor_add_gui_h);
