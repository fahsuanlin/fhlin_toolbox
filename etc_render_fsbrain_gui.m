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

% Last Modified by GUIDE v2.5 23-Mar-2020 21:19:09

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
set(handles.text_timeVec_unit,'String',etc_render_fsbrain.overlay_stc_timeVec_unit);


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

%truncate overlay flags
set(handles.checkbox_overlay_truncate_pos,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.checkbox_overlay_truncate_pos,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_overlay_truncate_pos,'enable','on');
    end;
end;
set(handles.checkbox_overlay_truncate_neg,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.checkbox_overlay_truncate_neg,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_overlay_truncate_neg,'enable','on');
    end;
end;

%auto threshold button
set(handles.pushbutton_auto_threshold,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.pushbutton_auto_threshold,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.pushbutton_auto_threshold,'enable','on');
    end;
end;

%threshold min/max
set(handles.edit_threshold_min,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_threshold_min,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_threshold_min,'enable','on');
    end;
end;
set(handles.edit_threshold_max,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_threshold_max,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_threshold_max,'enable','on');
    end;
end;

%colorbar check box
set(handles.checkbox_show_colorbar,'value',0);
if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
    if(~isempty(etc_render_fsbrain.h_colorbar_pos))
        set(handles.checkbox_show_colorbar,'value',1);
    end;
end;

if(get(handles.checkbox_show_colorbar,'value'))
%if(~isempty(etc_render_fsbrain.overlay_value)||~isempty(etc_render_fsbrain.overlay_stc))
    set(handles.checkbox_show_colorbar,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
end;

if(~isempty(etc_render_fsbrain.overlay_value)||~isempty(etc_render_fsbrain.overlay_stc))
    set(handles.checkbox_show_colorbar,'enable','on');
    set(handles.checkbox_show_overlay,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
    set(handles.checkbox_show_overlay,'enable','off');
end;

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
set(handles.checkbox_brain_surface,'value',etc_render_fsbrain.show_brain_surface_location_flag);
set(handles.pushbutton_click_vertex_point_color,'BackgroundColor',etc_render_fsbrain.click_vertex_point_color);
set(handles.edit_click_vertex_point_size,'string',sprintf('%d',etc_render_fsbrain.click_vertex_point_size));

set(handles.checkbox_overlay_truncate_neg,'value',etc_render_fsbrain.flag_overlay_truncate_neg);
set(handles.checkbox_overlay_truncate_pos,'value',etc_render_fsbrain.flag_overlay_truncate_pos);

set(handles.checkbox_selected_contact,'value',etc_render_fsbrain.selected_contact_flag);
set(handles.pushbutton_selected_contact_color,'BackgroundColor',etc_render_fsbrain.selected_contact_color);
set(handles.edit_selected_contact_size,'string',sprintf('%d',etc_render_fsbrain.selected_contact_size));

set(handles.checkbox_selected_electrode,'value',etc_render_fsbrain.selected_electrode_flag);
set(handles.pushbutton_selected_electrode_color,'BackgroundColor',etc_render_fsbrain.selected_electrode_color);
set(handles.edit_selected_electrode_size,'string',sprintf('%d',etc_render_fsbrain.selected_electrode_size));

if(isempty(etc_render_fsbrain.lut))
    set(handles.listbox_overlay_vol_mask,'string',{});
    set(handles.listbox_overlay_vol_mask,'enable','off');
else
    set(handles.listbox_overlay_vol_mask,'string',etc_render_fsbrain.lut.name);
    set(handles.listbox_overlay_vol_mask,'enable','on');
    set(handles.checkbox_overlay_aux_vol,'enable','on');                                                        
end;                            

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
%etc_render_fsbrain_handle('draw_pointer','surface_coord',[],'min_dist_idx',[],'click_vertex_vox',[]);    
etc_render_fsbrain_handle('redraw');
if(~isempty(etc_render_fsbrain.h_colorbar_pos))
    etc_render_fsbrain_handle('kb','c0','c0'); %update colorbar
end;
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
%etc_render_fsbrain_handle('draw_pointer','surface_coord',[],'min_dist_idx',[],'click_vertex_vox',[]);    
etc_render_fsbrain_handle('redraw');
if(~isempty(etc_render_fsbrain.h_colorbar_pos))
    etc_render_fsbrain_handle('kb','c0','c0'); %update colorbar
end;


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
if(isfield(etc_render_fsbrain,'click_coord'))
    if(isfield(etc_render_fsbrain,'click_vertex_vox'))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
    end;
end;
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

h=findobj('tag','slider_alpha');
set(h,'value',get(hObject,'Value'));

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
    %if(isfield(etc_render_fsbrain,'click_coord')&&(isfield(etc_render_fsbrain,'click_vertex_vox')))
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
    %else
        %etc_render_fsbrain_handle('draw_pointer');        
        etc_render_fsbrain_handle('redraw');        
    %end;
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
try
    %if(isfield(etc_render_fsbrain,'click_coord')&&(isfield(etc_render_fsbrain,'click_vertex_vox')))
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    %else
        %etc_render_fsbrain_handle('draw_pointer');
        etc_render_fsbrain_handle('redraw');
    %end;
catch ME
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



function edit_selected_electrode_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_selected_electrode_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_selected_electrode_size as text
%        str2double(get(hObject,'String')) returns contents of edit_selected_electrode_size as a double
global etc_render_fsbrain;

etc_render_fsbrain.selected_electrode_size=str2double(get(hObject,'String'));
%etc_render_fsbrain_handle('draw_pointer');
try
    %if(isfield(etc_render_fsbrain,'click_coord')&&(isfield(etc_render_fsbrain,'click_vertex_vox')))
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    %else
        %etc_render_fsbrain_handle('draw_pointer');
        etc_render_fsbrain_handle('redraw');
    %end;
catch ME
end;


% --- Executes during object creation, after setting all properties.
function edit_selected_electrode_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_selected_electrode_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_selected_electrode_color.
function pushbutton_selected_electrode_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_selected_electrode_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.selected_electrode_color,'Select a color');
etc_render_fsbrain.selected_electrode_color=c;
set(handles.pushbutton_selected_electrode_color,'BackgroundColor',etc_render_fsbrain.selected_electrode_color);
%etc_render_fsbrain_handle('draw_pointer');
try
    %if(isfield(etc_render_fsbrain,'click_coord')&&(isfield(etc_render_fsbrain,'click_vertex_vox')))
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);    
    %else
        %etc_render_fsbrain_handle('draw_pointer');        
        etc_render_fsbrain_handle('redraw');        
    %end;
catch ME
end;



% --- Executes on button press in checkbox_selected_electrode.
function checkbox_selected_electrode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_selected_electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_selected_electrode
global etc_render_fsbrain

etc_render_fsbrain.selected_electrode_flag=get(hObject,'Value');

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in checkbox_brain_surface.
function checkbox_brain_surface_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_brain_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_brain_surface
global etc_render_fsbrain

etc_render_fsbrain.show_brain_surface_location_flag=get(hObject,'Value');

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    end;
end;


% --- Executes on button press in button_overlay_surface.
function button_overlay_surface_Callback(hObject, eventdata, handles)
% hObject    handle to button_overlay_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

etc_render_fsbrain_handle('kb','cc','f');

    
etc_render_fsbrain.overlay_vol=[];
etc_render_fsbrain.overlay_vol_stc=[];
etc_render_fsbrain.overlay_aux_vol=[];
etc_render_fsbrain.overlay_aux_vol_stc=[];


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

%truncate overlay flags
set(handles.checkbox_overlay_truncate_pos,'enable','off');
set(handles.checkbox_overlay_truncate_pos,'value',etc_render_fsbrain.flag_overlay_truncate_pos);
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.checkbox_overlay_truncate_pos,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_overlay_truncate_pos,'enable','on');
    end;
end;
set(handles.checkbox_overlay_truncate_neg,'enable','off');
set(handles.checkbox_overlay_truncate_neg,'value',etc_render_fsbrain.flag_overlay_truncate_neg);
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.checkbox_overlay_truncate_neg,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_overlay_truncate_neg,'enable','on');
    end;
end;

%auto threshold button
set(handles.pushbutton_auto_threshold,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.pushbutton_auto_threshold,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.pushbutton_auto_threshold,'enable','on');
    end;
end;

%threshold min/max
set(handles.edit_threshold_min,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_threshold_min,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_threshold_min,'enable','on');
    end;
end;
set(handles.edit_threshold_max,'enable','off');
if(isfield(etc_render_fsbrain,'overlay_value'))
    if(~isempty(etc_render_fsbrain.overlay_value))
        set(handles.edit_threshold_max,'enable','on');
    end;
end;
if(isfield(etc_render_fsbrain,'overlay_stc'))
    if(~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.edit_threshold_max,'enable','on');
    end;
end;

%colorbar/overlay check box
%colorbar/overlay check box
if(~isempty(etc_render_fsbrain.overlay_value)||~isempty(etc_render_fsbrain.overlay_stc))
    set(handles.checkbox_show_colorbar,'enable','on');
    set(handles.checkbox_show_overlay,'enable','on');
    set(handles.checkbox_show_overlay,'value',1);
    etc_render_fsbrain.overlay_flag_render=1;
else
    set(handles.checkbox_show_colorbar,'enable','off');
    set(handles.checkbox_show_overlay,'enable','off');
    set(handles.checkbox_show_overlay,'value',0);
    etc_render_fsbrain.overlay_flag_render=0;
end;
%colorbar check box
set(handles.checkbox_show_colorbar,'value',0);
if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
    if(~isempty(etc_render_fsbrain.h_colorbar_pos))
        set(handles.checkbox_show_colorbar,'value',1);
    end;
end;

%timeVec slider
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
    
return;

% --- Executes on button press in button_overlay_volume.
function button_overlay_volume_Callback(hObject, eventdata, handles)
% hObject    handle to button_overlay_volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

if(isempty(etc_render_fsbrain.vol))
    fprintf('load a volume first.\n');
    return;
end;

[filename, pathname, filterindex] = uigetfile({'*.mgz; *.mgz; *.COR; *.nii; *.gz','volume'}, 'Pick a file');

if(filename>0)
    etc_render_fsbrain.overlay_value=[];
    etc_render_fsbrain.overlay_stc=[];
    
    fprintf('loading [%s]...\n',filename);
    etc_render_fsbrain.overlay_vol=MRIread(sprintf('%s/%s',pathname,filename));
    
    sz=size(etc_render_fsbrain.overlay_vol.vol);
    if(ndims(etc_render_fsbrain.overlay_vol.vol)==4)
        tmp=reshape(etc_render_fsbrain.overlay_vol.vol,[sz(1)*sz(2)*sz(3),sz(4)]);
        [dd,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(tmp.^2,1),[],2);
    else
        etc_render_fsbrain.overlay_stc_timeVec_idx=1;
    end;

    
    %prepare mapping overlay values from "overlay_vol"
    if(~isempty(etc_render_fsbrain.overlay_vol))
        
        fprintf('preparing volume overlay...');
        
        offset=0;
        for hemi_idx=1:2
            
            %choose 10,242 sources arbitrarily for cortical soruces
            etc_render_fsbrain.vol_A(hemi_idx).v_idx=[1:10242]-1;
            
            etc_render_fsbrain.vol_A(hemi_idx).vertex_coords=etc_render_fsbrain.vertex_coords;
            etc_render_fsbrain.vol_A(hemi_idx).faces=etc_render_fsbrain.faces;
            etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords=etc_render_fsbrain.orig_vertex_coords;
            %vol_A(hemi_idx).vertex_coords=hemi_vertex_coords{hemi_idx};
            %vol_A(hemi_idx).faces=hemi_faces{hemi_idx};
            %vol_A(hemi_idx).orig_vertex_coords=hemi_orig_vertex_coords{hemi_idx};
            
            SurfVertices=cat(2,etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords(etc_render_fsbrain.vol_A(hemi_idx).v_idx+1,:),ones(length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),1));
            
            vol_vox_tmp=(inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*(SurfVertices.')).';
            vol_vox_tmp=round(vol_vox_tmp(:,1:3));
            
            %separate data into "cort_idx" and "non_cort_idx" entries; the
            %former ones are for cortical locations (defined for ONLY one selected
            %hemisphere. the latter ones are for non-cortical locations (may
            %include the cortical locations of the other non-selected
            %hemisphere).
            all_idx=[1:prod(etc_render_fsbrain.overlay_vol.volsize(1:3))];
            %[cort_idx,ii]=unique(sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3)));
            
            cort_idx=sub2ind(etc_render_fsbrain.overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3));
            ii=[1:length(cort_idx)];
            etc_render_fsbrain.vol_A(hemi_idx).v_idx=etc_render_fsbrain.vol_A(hemi_idx).v_idx(ii);
            non_cort_idx=setdiff(all_idx,cort_idx);
            
            n_source(hemi_idx)=length(non_cort_idx)+length(cort_idx);
            n_dip(hemi_idx)=n_source(hemi_idx)*3;
            
            
            [C,R,S] = meshgrid([1:size(etc_render_fsbrain.overlay_vol.vol,2)],[1:size(etc_render_fsbrain.overlay_vol.vol,1)],[1:size(etc_render_fsbrain.overlay_vol.vol,3)]);
            CRS=[C(:) R(:) S(:)];
            CRS=cat(2,CRS,ones(size(CRS,1),1))';
            
            all_coords=inv(etc_render_fsbrain.vol_reg)*etc_render_fsbrain.vol.tkrvox2ras*CRS;
            all_coords=all_coords(1:3,:)';
            etc_render_fsbrain.vol_A(hemi_idx).loc=all_coords(cort_idx,:);
            etc_render_fsbrain.vol_A(hemi_idx).wb_loc=all_coords(non_cort_idx,:)./1e3;
            
            
            %%%%crs=[44 59 44];
            %%%surface_coord=[   -14   -21   -33]';
            %%%
            %%%loc_rh=cat(1,vol_A(hemi_idx).loc,vol_A(hemi_idx).wb_loc.*1e3);
            %%%loc=loc_rh;
            %%%dist=sqrt(sum((loc-repmat(surface_coord(:)',[size(loc,1),1])).^2,2));
            %%%[dummy,loc_min_idx]=min(dist)
            %%%
            %%%figure; plot(squeeze(overlay_vol.vol(59,44,44,:))); hold on;
            
            etc_render_fsbrain.overlay_vol_value=reshape(etc_render_fsbrain.overlay_vol.vol,[size(etc_render_fsbrain.overlay_vol.vol,1)*size(etc_render_fsbrain.overlay_vol.vol,2)*size(etc_render_fsbrain.overlay_vol.vol,3), size(etc_render_fsbrain.overlay_vol.vol,4)]);
            
            %overlay_vol_stc(offset+1:offset+length(vol_A(hemi_idx).v_idx),:)=overlay_vol_value(cort_idx,:);
            %overlay_vol_stc(offset+length(vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:)=overlay_vol_value(non_cort_idx,:);
            
            midx=[cort_idx(:)' non_cort_idx(:)'];
            etc_render_fsbrain.overlay_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),:)=etc_render_fsbrain.overlay_vol_value(midx(1:length(cort_idx)),:);
            etc_render_fsbrain.overlay_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:)=etc_render_fsbrain.overlay_vol_value(midx(length(cort_idx)+1:end),:);
            
            etc_render_fsbrain.overlay_aux_vol_value=[];
            for vv_idx=1:length(etc_render_fsbrain.overlay_aux_vol)
                etc_render_fsbrain.overlay_aux_vol_value(:,:,vv_idx)=reshape(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,[size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,1)*size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,2)*size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,3), size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,4)]);
                etc_render_fsbrain.overlay_aux_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),:,vv_idx)=etc_render_fsbrain.overlay_aux_vol_value(midx(1:length(cort_idx)),:,vv_idx);
                etc_render_fsbrain.overlay_aux_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:,vv_idx)=etc_render_fsbrain.overlay_aux_vol_value(midx(length(cort_idx)+1:end),:,vv_idx);
            end;
            
            offset=offset+n_source(hemi_idx);
            
            %%%plot(overlay_vol_stc(loc_min_idx,:));
            
            X_hemi_cort{hemi_idx}=etc_render_fsbrain.overlay_vol_value(cort_idx,:);
            X_hemi_subcort{hemi_idx}=etc_render_fsbrain.overlay_vol_value(non_cort_idx,:);
            
            if(~isempty(etc_render_fsbrain.overlay_aux_vol_value))
                aux_X_hemi_cort{hemi_idx}=etc_render_fsbrain.overlay_aux_vol_value(cort_idx,:,:);
                aux_X_hemi_subcort{hemi_idx}=oetc_render_fsbrain.verlay_aux_vol_value(non_cort_idx,:,:);
            end;
        end;
        
        
        if(strcmp(etc_render_fsbrain.hemi,'lh'))
            etc_render_fsbrain.overlay_stc=X_hemi_cort{1};
            etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.vol_A(1).v_idx;
            if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                etc_render_fsbrain.overlay_aux_stc=aux_X_hemi_cort{1};
            end;
        else
            etc_render_fsbrain.overlay_stc=X_hemi_cort{2};
            etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.vol_A(2).v_idx;
            if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                etc_render_fsbrain.overlay_aux_stc=aux_X_hemi_cort{2};
            end;
        end;
        etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
  
        etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];

        etc_render_fsbrain.overlay_flag_render=1;
        
        fprintf('Done!\n');

        
        
        %h=findobj('tag','slider_alpha');
        %set(h,'value',get(hObject,'Value'));
        
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
    
    %truncate overlay flags
    set(handles.checkbox_overlay_truncate_pos,'enable','off');
    set(handles.checkbox_overlay_truncate_pos,'value',etc_render_fsbrain.flag_overlay_truncate_pos);
    if(isfield(etc_render_fsbrain,'overlay_value'))
        if(~isempty(etc_render_fsbrain.overlay_value))
            set(handles.checkbox_overlay_truncate_pos,'enable','on');
        end;
    end;
    if(isfield(etc_render_fsbrain,'overlay_stc'))
        if(~isempty(etc_render_fsbrain.overlay_stc))
            set(handles.checkbox_overlay_truncate_pos,'enable','on');
        end;
    end;
    set(handles.checkbox_overlay_truncate_neg,'enable','off');
    set(handles.checkbox_overlay_truncate_neg,'value',etc_render_fsbrain.flag_overlay_truncate_neg);
    if(isfield(etc_render_fsbrain,'overlay_value'))
        if(~isempty(etc_render_fsbrain.overlay_value))
            set(handles.checkbox_overlay_truncate_neg,'enable','on');
        end;
    end;
    if(isfield(etc_render_fsbrain,'overlay_stc'))
        if(~isempty(etc_render_fsbrain.overlay_stc))
            set(handles.checkbox_overlay_truncate_neg,'enable','on');
        end;
    end;
    
    %auto threshold button
    set(handles.pushbutton_auto_threshold,'enable','off');
    if(isfield(etc_render_fsbrain,'overlay_value'))
        if(~isempty(etc_render_fsbrain.overlay_value))
            set(handles.pushbutton_auto_threshold,'enable','on');
        end;
    end;
    if(isfield(etc_render_fsbrain,'overlay_stc'))
        if(~isempty(etc_render_fsbrain.overlay_stc))
            set(handles.pushbutton_auto_threshold,'enable','on');
        end;
    end;
    
    %threshold min/max
    set(handles.edit_threshold_min,'enable','off');
    if(isfield(etc_render_fsbrain,'overlay_value'))
        if(~isempty(etc_render_fsbrain.overlay_value))
            set(handles.edit_threshold_min,'enable','on');
        end;
    end;
    if(isfield(etc_render_fsbrain,'overlay_stc'))
        if(~isempty(etc_render_fsbrain.overlay_stc))
            set(handles.edit_threshold_min,'enable','on');
        end;
    end;
    set(handles.edit_threshold_max,'enable','off');
    if(isfield(etc_render_fsbrain,'overlay_value'))
        if(~isempty(etc_render_fsbrain.overlay_value))
            set(handles.edit_threshold_max,'enable','on');
        end;
    end;
    if(isfield(etc_render_fsbrain,'overlay_stc'))
        if(~isempty(etc_render_fsbrain.overlay_stc))
            set(handles.edit_threshold_max,'enable','on');
        end;
    end;    
    %colorbar/overlay check box
    if(~isempty(etc_render_fsbrain.overlay_value)||~isempty(etc_render_fsbrain.overlay_stc))
        set(handles.checkbox_show_colorbar,'enable','on');
        set(handles.checkbox_show_overlay,'enable','on');
        set(handles.checkbox_show_overlay,'value',1);
        etc_render_fsbrain.overlay_flag_render=1;
    else
        set(handles.checkbox_show_colorbar,'enable','off');
        set(handles.checkbox_show_overlay,'enable','off');
        set(handles.checkbox_show_overlay,'value',0);
        etc_render_fsbrain.overlay_flag_render=0;
    end;
    %colorbar check box
    set(handles.checkbox_show_colorbar,'value',0);
    if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
        if(~isempty(etc_render_fsbrain.h_colorbar_pos))
            set(handles.checkbox_show_colorbar,'value',1);
        end;
    end;    
    
    %timeVec slider
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
    
    etc_render_fsbrain_handle('redraw');        
end;
return;


% --- Executes on slider movement.
function slider_overlay_aux_vol_Callback(hObject, eventdata, handles)
% hObject    handle to slider_overlay_aux_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain;

etc_render_fsbrain.overlay_vol_mask_alpha=get(hObject,'Value');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);


% --- Executes during object creation, after setting all properties.
function slider_overlay_aux_vol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_overlay_aux_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_overlay_aux_vol.
function checkbox_overlay_aux_vol_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_overlay_aux_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_overlay_aux_vol
global etc_render_fsbrain;

etc_render_fsbrain.overlay_flag_vol_mask=get(hObject,'Value');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);


% --- Executes on selection change in listbox_overlay_vol_mask.
function listbox_overlay_vol_mask_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_overlay_vol_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_overlay_vol_mask contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_overlay_vol_mask
global etc_render_fsbrain;

%obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
%                    idx=get(obj,'value');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);

% --- Executes during object creation, after setting all properties.
function listbox_overlay_vol_mask_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_overlay_vol_mask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
