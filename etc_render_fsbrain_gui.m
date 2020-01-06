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

% Last Modified by GUIDE v2.5 02-Jan-2020 15:17:32

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

global etc_render_fsbrain;

%surface opacity slider
set(handles.slider_alpha,'value',get(etc_render_fsbrain.h,'facealpha'));

%timeVec slider
try
    set(handles.slider_timeVec,'Enable','off');
    set(handles.edit_timeVec,'Enable','off');

    if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'))
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
            if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                set(handles.slider_timeVec,'Enable','on');
                set(handles.slider_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));

                set(handles.edit_timeVec,'Enable','on');
                set(handles.edit_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                set(handles.edit_timeVec,'string',sprintf('%1.1f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
            end;
        end;
    end;
catch
end;

%overlay smooth
set(handles.edit_smooth,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_smooth,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_smooth,'enable','on');
    end;
end;

%colorbar check box
set(handles.checkbox_show_colorbar,'value',0);
if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
    if(isempty(etc_render_fsbrain.h_colorbar_pos))
        set(handles.checkbox_show_colorbar,'value',1);
    end;
end;
if(get(handles.checkbox_show_colorbar,'value'))
    set(handles.checkbox_show_colorbar,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
end;

set(handles.checkbox_show_colorbar,'enable','off');

set(handles.pushbutton_aux_point_color,'BackgroundColor',etc_render_fsbrain.aux_point_color);
set(handles.edit_aux_point_size,'string',sprintf('%3.3f',etc_render_fsbrain.aux_point_size));
if(~isfield(etc_render_fsbrain,'aux_point_label_flag'))
    etc_render_fsbrain.aux_point_label_flag=1;
end;
set(handles.checkbox_aux_point_label,'value',etc_render_fsbrain.aux_point_label_flag);

set(handles.pushbutton_aux2_point_color,'BackgroundColor',etc_render_fsbrain.aux2_point_color);
set(handles.edit_aux2_point_size,'string',sprintf('%d',etc_render_fsbrain.aux2_point_size));

set(handles.pushbutton_click_point_color,'BackgroundColor',etc_render_fsbrain.click_point_color);
set(handles.edit_click_point_size,'string',sprintf('%d',etc_render_fsbrain.click_point_size));

set(handles.checkbox_nearest_brain_surface,'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);
set(handles.pushbutton_click_vertex_point_color,'BackgroundColor',etc_render_fsbrain.click_vertex_point_color);
set(handles.edit_click_vertex_point_size,'string',sprintf('%d',etc_render_fsbrain.click_vertex_point_size));

set(handles.checkbox_overlay_truncate_neg,'value',etc_render_fsbrain.flag_overlay_truncate_neg);
set(handles.checkbox_overlay_truncate_pos,'value',etc_render_fsbrain.flag_overlay_truncate_pos);


set(handles.checkbox_selected_contact,'value',etc_render_fsbrain.selected_contact_flag);
set(handles.pushbutton_selected_contact_color,'BackgroundColor',etc_render_fsbrain.selected_contact_color);
set(handles.edit_selected_contact_size,'string',sprintf('%d',etc_render_fsbrain.selected_contact_size));

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

etc_render_fsbrain_handle('update_overlay_vol');

if(~isempty(etc_render_fsbrain.overlay_stc))
    etc_render_fsbrain_handle('draw_stc');
end;

%etc_render_fsbrain_handle('draw_pointer');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

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
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
etc_render_fsbrain_handle('redraw');
etc_render_fsbrain_handle('kb','c0','c0'); %update colorbar

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
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
etc_render_fsbrain_handle('redraw');
etc_render_fsbrain_handle('kb','c0','c0'); %update colorbar



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


etc_render_fsbrain_handle('update_overlay_vol');

if(~isempty(etc_render_fsbrain.overlay_stc))
    etc_render_fsbrain_handle('draw_stc');
end;

%etc_render_fsbrain_handle('draw_pointer');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

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
% global etc_render_fsbrain
% 
% if(~isempty(etc_render_fsbrain.overlay_stc)|~isempty(etc_render_fsbrain.overlay_value))
%     set(hObject,'value',1);
%     if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
%         if(isempty(etc_render_fsbrain.h_colorbar_pos))
%             set(hObject,'value',0);
%         end;
%     end;
% else
%     set(hObject,'enable','off');
% end;



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


% --- Executes on slider movement.
function slider_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to slider_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain;

set(etc_render_fsbrain.h,'facealpha',get(hObject,'Value'));
etc_render_fsbrain.alpha=get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_aux_point_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aux_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aux_point_size as text
%        str2double(get(hObject,'String')) returns contents of edit_aux_point_size as a double
global etc_render_fsbrain;

etc_render_fsbrain.aux_point_size=str2double(get(hObject,'String'));
etc_render_fsbrain_handle('redraw');

% --- Executes during object creation, after setting all properties.
function edit_aux_point_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aux_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aux2_point_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aux2_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aux2_point_size as text
%        str2double(get(hObject,'String')) returns contents of edit_aux2_point_size as a double

global etc_render_fsbrain;

etc_render_fsbrain.aux2_point_size=str2double(get(hObject,'String'));
etc_render_fsbrain_handle('redraw');

% --- Executes during object creation, after setting all properties.
function edit_aux2_point_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aux2_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_aux_point_color.
function pushbutton_aux_point_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_aux_point_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.aux_point_color,'Select a color');
etc_render_fsbrain.aux_point_color=c;
set(handles.pushbutton_aux_point_color,'BackgroundColor',etc_render_fsbrain.aux_point_color);
etc_render_fsbrain_handle('redraw');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

% --- Executes on button press in pushbutton_aux2_point_color.
function pushbutton_aux2_point_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_aux2_point_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.aux2_point_color,'Select a color');
etc_render_fsbrain.aux2_point_color=c;
set(handles.pushbutton_aux2_point_color,'BackgroundColor',etc_render_fsbrain.aux2_point_color);
etc_render_fsbrain_handle('redraw');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    



% --- Executes on button press in pushbutton_click_vertex_point_color.
function pushbutton_click_vertex_point_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_click_vertex_point_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.click_vertex_point_color,'Select a color');
etc_render_fsbrain.click_vertex_point_color=c;
set(handles.pushbutton_click_vertex_point_color,'BackgroundColor',etc_render_fsbrain.click_vertex_point_color);
%etc_render_fsbrain_handle('draw_pointer');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

% --- Executes on button press in pushbutton_click_point_color.
function pushbutton_click_point_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_click_point_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.click_point_color,'Select a color');
etc_render_fsbrain.click_point_color=c;
set(handles.pushbutton_click_point_color,'BackgroundColor',etc_render_fsbrain.click_point_color);
%etc_render_fsbrain_handle('draw_pointer');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    


function edit_click_vertex_point_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_click_vertex_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_click_vertex_point_size as text
%        str2double(get(hObject,'String')) returns contents of edit_click_vertex_point_size as a double
global etc_render_fsbrain;

etc_render_fsbrain.click_vertex_point_size=str2double(get(hObject,'String'));
%etc_render_fsbrain_handle('draw_pointer');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

% --- Executes during object creation, after setting all properties.
function edit_click_vertex_point_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_click_vertex_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_click_point_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_click_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_click_point_size as text
%        str2double(get(hObject,'String')) returns contents of edit_click_point_size as a double
global etc_render_fsbrain;

etc_render_fsbrain.click_point_size=str2double(get(hObject,'String'));
%etc_render_fsbrain_handle('draw_pointer');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

% --- Executes during object creation, after setting all properties.
function edit_click_point_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_click_point_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_nearest_brain_surface.
function checkbox_nearest_brain_surface_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_nearest_brain_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_nearest_brain_surface
global etc_render_fsbrain

etc_render_fsbrain.show_nearest_brain_surface_location_flag=get(hObject,'Value');

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    end;
end;


% --- Executes on button press in checkbox_aux_point_label.
function checkbox_aux_point_label_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_aux_point_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_aux_point_label
global etc_render_fsbrain

etc_render_fsbrain.aux_point_label_flag=get(hObject,'Value');

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in checkbox_overlay_truncate_neg.
function checkbox_overlay_truncate_neg_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_overlay_truncate_neg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_overlay_truncate_neg
global etc_render_fsbrain

etc_render_fsbrain.flag_overlay_truncate_neg=get(hObject,'Value');

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

etc_render_fsbrain_handle('redraw');

% --- Executes on button press in checkbox_overlay_truncate_pos.
function checkbox_overlay_truncate_pos_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_overlay_truncate_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_overlay_truncate_pos
global etc_render_fsbrain

etc_render_fsbrain.flag_overlay_truncate_pos=get(hObject,'Value');

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_selected_contact_color.
function pushbutton_selected_contact_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selected_contact_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.selected_contact_color,'Select a color');
etc_render_fsbrain.selected_contact_color=c;
set(handles.pushbutton_selected_contact_color,'BackgroundColor',etc_render_fsbrain.selected_contact_color);
%etc_render_fsbrain_handle('draw_pointer');
try
    if(isfield(etc_render_fsbrain,'click_coord')&&(isfield(etc_render_fsbrain,'click_vertex_vox')))
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
    else
        %etc_render_fsbrain_handle('draw_pointer');        
        etc_render_fsbrain_handle('redraw');        
    end;
catch ME
end;


function edit_selected_contact_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_selected_contact_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_selected_contact_size as text
%        str2double(get(hObject,'String')) returns contents of edit_selected_contact_size as a double
global etc_render_fsbrain;

etc_render_fsbrain.selected_contact_size=str2double(get(hObject,'String'));
%etc_render_fsbrain_handle('draw_pointer');
if(isfield(etc_render_fsbrain,'click_coord')&&(isfield(etc_render_fsbrain,'click_vertex_vox')))
    %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
else
    %etc_render_fsbrain_handle('draw_pointer');        
    etc_render_fsbrain_handle('redraw');        
end;

% --- Executes during object creation, after setting all properties.
function edit_selected_contact_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_selected_contact_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_selected_contact.
function checkbox_selected_contact_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_selected_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_selected_contact
global etc_render_fsbrain

etc_render_fsbrain.selected_contact_flag=get(hObject,'Value');

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_auto_threshold.
function pushbutton_auto_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_auto_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain

etc_render_fsbrain.overlay_threshold=[];

etc_render_fsbrain_handle('redraw');

set(handles.edit_threshold_min,'string',sprintf('%2.1e',min(etc_render_fsbrain.overlay_threshold)));
set(handles.edit_threshold_max,'string',sprintf('%2.1e',max(etc_render_fsbrain.overlay_threshold)));
