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

% Last Modified by GUIDE v2.5 04-Dec-2021 13:08:28

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
set(handles.edit_alpha,'string',sprintf('%1.1f',get(etc_render_fsbrain.h,'facealpha')));

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

%volume in orthogonal slices
if(~isempty(etc_render_fsbrain.vol))
    set(handles.slider_orthogonal_slice_x,'min',1);
    set(handles.slider_orthogonal_slice_x,'max',etc_render_fsbrain.vol.volsize(2));
    set(handles.slider_orthogonal_slice_x,'enable','on');
    if(isfield(etc_render_fsbrain,'click_vertex_vox_round'))
        set(handles.slider_orthogonal_slice_x,'Value',etc_render_fsbrain.click_vertex_vox_round(1));
        set(handles.edit_orthogonal_slice_x,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(1),'%1.0f'));
    else
        set(handles.slider_orthogonal_slice_x,'Value',1);
        set(handles.slider_orthogonal_slice_x,'enable','off');
        set(handles.edit_orthogonal_slice_x,'String','1');
        set(handles.edit_orthogonal_slice_x,'enable','off');
    end;

    set(handles.slider_orthogonal_slice_y,'min',1);
    set(handles.slider_orthogonal_slice_y,'max',etc_render_fsbrain.vol.volsize(1));
    set(handles.slider_orthogonal_slice_y,'enable','on');
    if(isfield(etc_render_fsbrain,'click_vertex_vox_round'))
        set(handles.slider_orthogonal_slice_y,'Value',etc_render_fsbrain.click_vertex_vox_round(2));
        set(handles.edit_orthogonal_slice_y,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(2),'%1.0f'));
    else
        set(handles.slider_orthogonal_slice_y,'Value',1);
        set(handles.slider_orthogonal_slice_y,'enable','off');
        set(handles.edit_orthogonal_slice_y,'String','1');
        set(handles.edit_orthogonal_slice_y,'enable','off');
    end;
    
    set(handles.slider_orthogonal_slice_z,'min',1);
    set(handles.slider_orthogonal_slice_z,'max',etc_render_fsbrain.vol.volsize(3));
    set(handles.slider_orthogonal_slice_z,'enable','on');
    if(isfield(etc_render_fsbrain,'click_vertex_vox_round'))
        set(handles.slider_orthogonal_slice_z,'Value',etc_render_fsbrain.click_vertex_vox_round(3));
        set(handles.edit_orthogonal_slice_z,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(3),'%1.0f'));
    else
        set(handles.slider_orthogonal_slice_z,'Value',1);
        set(handles.slider_orthogonal_slice_z,'enable','off');
        set(handles.edit_orthogonal_slice_z,'String','1');
        set(handles.edit_orthogonal_slice_z,'enable','off');
    end;
    
    set(handles.edit_orthogonal_slice_x,'enable','on');
    set(handles.edit_orthogonal_slice_y,'enable','on');
    set(handles.edit_orthogonal_slice_z,'enable','on');    

    
    if(~isfield(etc_render_fsbrain,'flag_orthogonal_slice_cor'))
        etc_render_fsbrain.flag_orthogonal_slice_cor=0;
    end;
    set(handles.checkbox_orthogonal_slice_cor,'enable','on');
    set(handles.checkbox_orthogonal_slice_cor,'Value',etc_render_fsbrain.flag_orthogonal_slice_cor);

    if(~isfield(etc_render_fsbrain,'flag_orthogonal_slice_sag'))
        etc_render_fsbrain.flag_orthogonal_slice_sag=0;
    end;
    set(handles.checkbox_orthogonal_slice_sag,'enable','on');
    set(handles.checkbox_orthogonal_slice_sag,'Value',etc_render_fsbrain.flag_orthogonal_slice_sag);
    
    if(~isfield(etc_render_fsbrain,'flag_orthogonal_slice_ax'))
        etc_render_fsbrain.flag_orthogonal_slice_ax=0;
    end;
    set(handles.checkbox_orthogonal_slice_ax,'enable','on');
    set(handles.checkbox_orthogonal_slice_ax,'Value',etc_render_fsbrain.flag_orthogonal_slice_ax);
else
    set(handles.slider_orthogonal_slice_x,'enable','off');
    set(handles.slider_orthogonal_slice_y,'enable','off');
    set(handles.slider_orthogonal_slice_z,'enable','off');
    set(handles.edit_orthogonal_slice_x,'enable','off');
    set(handles.edit_orthogonal_slice_y,'enable','off');
    set(handles.edit_orthogonal_slice_z,'enable','off');

    set(handles.checkbox_orthogonal_slice_cor,'enable','off');
    etc_render_fsbrain.flag_orthogonal_slice_cor=0;
    set(handles.checkbox_orthogonal_slice_cor,'Value',etc_render_fsbrain.flag_orthogonal_slice_cor);
    set(handles.checkbox_orthogonal_slice_sag,'enable','off');
    etc_render_fsbrain.flag_orthogonal_slice_sag=0;
    set(handles.checkbox_orthogonal_slice_sag,'Value',etc_render_fsbrain.flag_orthogonal_slice_sag);
    set(handles.checkbox_orthogonal_slice_ax,'enable','off');
    etc_render_fsbrain.flag_orthogonal_slice_ax=0;
    set(handles.checkbox_orthogonal_slice_ax,'Value',etc_render_fsbrain.flag_orthogonal_slice_ax);

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
set(handles.checkbox_show_colorbar,'enable','off');
set(handles.checkbox_show_vol_colorbar,'value',0);
set(handles.checkbox_show_vol_colorbar,'enable','off');
if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
    if(~isempty(etc_render_fsbrain.h_colorbar_pos))
        set(handles.checkbox_show_colorbar,'value',1);
        if(~isempty(etc_render_fsbrain.fig_vol))
            set(handles.checkbox_show_vol_colorbar,'value',1);
            set(handles.checkbox_show_vol_colorbar,'enable','on');
        end;
    end;
end;
if(etc_render_fsbrain.flag_colorbar)
    handles.button_overlay_surface.Value=1;
    handles.button_overlay_volume.Value=1;
else
    handles.button_overlay_surface.Value=0;
    handles.button_overlay_volume.Value=0; 
end;


%overlay listboxes
str={};
for str_idx=1:length(etc_render_fsbrain.overlay_buffer) str{str_idx}=etc_render_fsbrain.overlay_buffer(str_idx).name; end;
if(isempty(str))
    set(findobj('tag','listbox_overlay_main'),'string','[none]');
    set(findobj('tag','listbox_overlay_main'),'value',1);
else
    set(handles.listbox_overlay_main,'string',str);
    set(handles.listbox_overlay_main,'value',etc_render_fsbrain.overlay_buffer_main_idx);
end;
set(handles.listbox_overlay,'string',str);
set(handles.listbox_overlay,'min',0);
if(length(etc_render_fsbrain.overlay_buffer)==1)
    set(handles.listbox_overlay,'max',2);
else
    set(handles.listbox_overlay,'max',length(etc_render_fsbrain.overlay_buffer));
end;
set(handles.listbox_overlay,'value',etc_render_fsbrain.overlay_buffer_idx);

if(get(handles.checkbox_show_colorbar,'value'))
    set(handles.checkbox_show_colorbar,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
end;
if(get(handles.checkbox_show_vol_colorbar,'value'))
    set(handles.checkbox_show_vol_colorbar,'enable','on');
else
    set(handles.checkbox_show_vol_colorbar,'enable','off');
end;

if(~isempty(etc_render_fsbrain.overlay_value)||~isempty(etc_render_fsbrain.overlay_stc))
    set(handles.checkbox_show_colorbar,'enable','on');
    set(handles.checkbox_show_overlay,'enable','on');
else
    set(handles.checkbox_show_colorbar,'enable','off');
    set(handles.checkbox_show_overlay,'enable','off');
end;


if(~isempty(etc_render_fsbrain.overlay_vol_value)||~isempty(etc_render_fsbrain.overlay_vol_stc))
    set(handles.checkbox_show_vol_colorbar,'enable','on');
    set(handles.checkbox_show_vol_overlay,'enable','on');
    set(handles.checkbox_show_vol_colorbar,'enable','on');
else
    set(handles.checkbox_show_vol_colorbar,'enable','off');
    set(handles.checkbox_show_vol_overlay,'enable','off');
    set(handles.checkbox_show_vol_colorbar,'enable','off');
end;


if(~isempty(etc_render_fsbrain.aux_point_coords))
    set(handles.pushbutton_aux_point_color,'BackgroundColor',etc_render_fsbrain.aux_point_color);
    set(handles.edit_aux_point_size,'string',sprintf('%3.3f',etc_render_fsbrain.aux_point_size));
    if(~isfield(etc_render_fsbrain,'aux_point_label_flag'))
        etc_render_fsbrain.aux_point_label_flag=1;
    end;
    set(handles.checkbox_aux_point_label,'value',etc_render_fsbrain.aux_point_label_flag);
    set(handles.pushbutton_aux_point_text_color,'BackgroundColor',etc_render_fsbrain.aux_point_text_color);
    set(handles.edit_aux_point_text_size,'string',sprintf('%d',etc_render_fsbrain.aux_point_text_size));

else
    set(handles.pushbutton_aux_point_color,'enable','off');
    set(handles.edit_aux_point_size,'enable','off');
    set(handles.checkbox_aux_point_label,'enable','off');
    set(handles.pushbutton_aux_point_text_color,'enable','off');
    set(handles.edit_aux_point_text_size,'enable','off');
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    set(handles.pushbutton_aux2_point_color,'BackgroundColor',etc_render_fsbrain.aux2_point_color);
    set(handles.edit_aux2_point_size,'string',sprintf('%d',etc_render_fsbrain.aux2_point_size));
    v1=etc_render_fsbrain.show_all_contacts_mri_flag;
    v2=etc_render_fsbrain.show_all_contacts_brain_surface_flag;
    %set(handles.checkbox_electrode_contacts,'value',v1|v2);
    set(handles.checkbox_electrode_contacts,'value',etc_render_fsbrain.all_electrode_flag);
    
    set(handles.checkbox_selected_contact,'value',etc_render_fsbrain.selected_contact_flag);
    set(handles.pushbutton_selected_contact_color,'BackgroundColor',etc_render_fsbrain.selected_contact_color);
    set(handles.edit_selected_contact_size,'string',sprintf('%d',etc_render_fsbrain.selected_contact_size));
    
    set(handles.checkbox_selected_electrode,'value',etc_render_fsbrain.selected_electrode_flag);
    set(handles.pushbutton_selected_electrode_color,'BackgroundColor',etc_render_fsbrain.selected_electrode_color);
    set(handles.edit_selected_electrode_size,'string',sprintf('%d',etc_render_fsbrain.selected_electrode_size));
else
    set(handles.pushbutton_aux2_point_color,'enable','off');
    set(handles.edit_aux2_point_size,'enable','off');
    set(handles.checkbox_electrode_contacts,'enable','off');

    set(handles.checkbox_selected_contact,'enable','off');
    set(handles.pushbutton_selected_contact_color,'enable','off');
    set(handles.edit_selected_contact_size,'enable','off');
    
    set(handles.checkbox_selected_electrode,'enable','off');
    set(handles.pushbutton_selected_electrode_color,'enable','off');
    set(handles.edit_selected_electrode_size,'enable','off');
end;


set(handles.checkbox_nearest_brain_surface,'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);
set(handles.checkbox_brain_surface,'value',etc_render_fsbrain.show_brain_surface_location_flag);
set(handles.pushbutton_click_vertex_point_color,'BackgroundColor',etc_render_fsbrain.click_vertex_point_color);
set(handles.edit_click_vertex_point_size,'string',sprintf('%d',etc_render_fsbrain.click_vertex_point_size));
set(handles.pushbutton_click_point_color,'BackgroundColor',etc_render_fsbrain.click_point_color);
set(handles.edit_click_point_size,'string',sprintf('%d',etc_render_fsbrain.click_point_size));

set(handles.checkbox_overlay_truncate_neg,'value',etc_render_fsbrain.flag_overlay_truncate_neg);
set(handles.checkbox_overlay_truncate_pos,'value',etc_render_fsbrain.flag_overlay_truncate_pos);

if(~isempty(etc_render_fsbrain.curv_neg_color))
    set(handles.pushbutton_neg_curv_color,'BackgroundColor',etc_render_fsbrain.curv_neg_color);
end;
if(~isempty(etc_render_fsbrain.curv_pos_color))
    set(handles.pushbutton_pos_curv_color,'BackgroundColor',etc_render_fsbrain.curv_pos_color);
end;

if(~isempty(etc_render_fsbrain.lut))
    set(handles.listbox_overlay_vol_mask,'string',etc_render_fsbrain.lut.name);
    
    set(handles.checkbox_overlay_aux_vol,'enable','on');
    set(handles.slider_overlay_aux_vol,'enable','on');
    set(handles.pushbutton_overlay_aux_vol,'enable','on');
    set(handles.listbox_overlay_vol_mask,'enable','on');
else
    set(handles.listbox_overlay_vol_mask,'string',{});
    
    set(handles.checkbox_overlay_aux_vol,'enable','off');
    set(handles.slider_overlay_aux_vol,'enable','off');
    set(handles.pushbutton_overlay_aux_vol,'enable','off');
end;

%cortical labels
if(isfield(etc_render_fsbrain,'flag_show_cort_label'))
    set(handles.checkbox_show_cort_label,'value',etc_render_fsbrain.flag_show_cort_label);
end;
if(isfield(etc_render_fsbrain,'flag_show_cort_label_boundary'))
    set(handles.checkbox_show_cort_label_boundary,'value',etc_render_fsbrain.flag_show_cort_label_boundary);
end;
if(isfield(etc_render_fsbrain,'cort_label_boundary_color'))
    set(handles.pushbotton_cort_label_boundary_color,'BackgroundColor',etc_render_fsbrain.cort_label_boundary_color);
end;

if(isempty(etc_render_fsbrain.fig_vol))
        set(handles.checkbox_show_vol_colorbar,'enable','off');
        set(handles.checkbox_show_vol_overlay,'enable','off');                                                        
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

global etc_trace_obj;

if(~isempty(etc_trace_obj))
    etc_trace_obj.time_select_idx=etc_render_fsbrain.overlay_stc_timeVec_idx;
    etc_trcae_gui_update_time;
end;


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
if(~isempty(etc_render_fsbrain.h_colorbar_pos)|~isempty(etc_render_fsbrain.h_colorbar_neg))
    etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar
end;
if(~isempty(etc_render_fsbrain.h_colorbar_vol_pos)|~isempty(etc_render_fsbrain.h_colorbar_vol_neg))
    etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar
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
if(~isempty(etc_render_fsbrain.h_colorbar_pos)|~isempty(etc_render_fsbrain.h_colorbar_neg))
    etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar
end;
if(~isempty(etc_render_fsbrain.h_colorbar_vol_pos)|~isempty(etc_render_fsbrain.h_colorbar_vol_neg))
    etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar
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

global etc_trace_obj;

if(~isempty(etc_trace_obj))
    etc_trace_obj.time_select_idx=etc_render_fsbrain.overlay_stc_timeVec_idx;
    etc_trcae_gui_update_time;
end;



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

etc_render_fsbrain.flag_colorbar=get(hObject,'Value');
                
set(etc_render_fsbrain.fig_brain,'currentchar','c');
%etc_render_fsbrain_handle('kb','cc','c');
etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar

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

etc_render_fsbrain.alpha=get(hObject,'Value');

set(etc_render_fsbrain.h,'facealpha',etc_render_fsbrain.alpha);

set(handles.slider_alpha,'value',etc_render_fsbrain.alpha);
set(handles.edit_alpha,'string',sprintf('%1.1f',get(etc_render_fsbrain.h,'facealpha')));
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

set(findobj('Tag','checkbox_nearest_brain_surface'),'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);


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
etc_render_fsbrain.overlay_value_flag_neg=~etc_render_fsbrain.flag_overlay_truncate_neg;


etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar
if(~isempty(etc_render_fsbrain.fig_vol))
    etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar
end;
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
etc_render_fsbrain.overlay_value_flag_pos=~etc_render_fsbrain.flag_overlay_truncate_pos;

etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar
if(~isempty(etc_render_fsbrain.fig_vol))
    etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar
end;
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

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    end;
end
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

etc_render_fsbrain_handle('draw_pointer');



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

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    end;
end
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

%etc_render_fsbrain_handle('kb','cc','f');
etc_render_fsbrain_handle('kb','cs','cs'); %update colorbar

%timeVec slider
try
    set(handles.slider_timeVec,'Enable','off');
    set(handles.edit_timeVec,'Enable','off');
    
    if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'))
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
            if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                set(handles.slider_timeVec,'Enable','on');
                %set(handles.slider_timeVec,'min',1);
                %set(handles.slider_timeVec,'max',size(etc_render_fsbrain.overlay_stc,2));
                set(handles.slider_timeVec,'min',etc_render_fsbrain.overlay_stc_timeVec(1));
                set(handles.slider_timeVec,'max',etc_render_fsbrain.overlay_stc_timeVec(end));
                if(etc_render_fsbrain.overlay_stc_timeVec_idx<=size(etc_render_fsbrain.overlay_stc,2))
                else
                    fprintf('reseting timeVec index...\n');
                    etc_render_fsbrain.overlay_stc_timeVec_idx=1;
                end;
                set(handles.slider_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                %set(handles.slider_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec_idx);
                
                set(handles.edit_timeVec,'Enable','on');
                set(handles.edit_timeVec,'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                set(handles.edit_timeVec,'string',sprintf('%1.1f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
            end;
        end;
    end;
catch
end;
set(handles.text_timeVec_unit,'String',etc_render_fsbrain.overlay_stc_timeVec_unit);



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
    set(handles.checkbox_show_vol_overlay,'enable','on');
    set(handles.checkbox_show_vol_overlay,'value',1);
    etc_render_fsbrain.overlay_flag_render=1;
else
    set(handles.checkbox_show_colorbar,'enable','off');
    set(handles.checkbox_show_overlay,'enable','off');
    set(handles.checkbox_show_overlay,'value',0);
    set(handles.checkbox_show_vol_overlay,'enable','off');
    set(handles.checkbox_show_vol_overlay,'value',0);
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

[filename, pathname, filterindex] = uigetfile({'*.mgh; *.mgz; *.nii; *.gz','mgh/mgz volume'});
if(filename>0)
    etc_render_fsbrain.overlay_value=[];
    etc_render_fsbrain.overlay_stc=[];
    
    fprintf('loading [%s]...\n',filename);
    etc_render_fsbrain.overlay_vol=MRIread(sprintf('%s/%s',pathname,filename));
    
    
    
    %timeVec slider
    try
        set(handles.slider_timeVec,'Enable','off');
        set(handles.edit_timeVec,'Enable','off');
        
        if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'))
            if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                    set(handles.slider_timeVec,'Enable','on');
                    set(handles.slider_timeVec,'min',1);
                    set(handles.slider_timeVec,'max',size(etc_render_fsbrain.overlay_vol.vol,4));
                    if(etc_render_fsbrain.overlay_stc_timeVec_idx<=size(etc_render_fsbrain.overlay_vol.vol,4))
                    else
                        fprintf('reseting timeVec index...\n');
                        etc_render_fsbrain.overlay_stc_timeVec_idx=1;
                    end;
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
        etc_render_fsbrain.overlay_vol_stc=[];
        for hemi_idx=1:2
            
            %choose 10,242 sources arbitrarily for cortical soruces
            %etc_render_fsbrain.vol_A(hemi_idx).v_idx=[1:10242]-1;
            etc_render_fsbrain.vol_A(hemi_idx).v_idx=[1:10:size(etc_render_fsbrain.orig_vertex_coords,1)]-1;
            
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
                        
            etc_render_fsbrain.overlay_vol_value=reshape(etc_render_fsbrain.overlay_vol.vol,[size(etc_render_fsbrain.overlay_vol.vol,1)*size(etc_render_fsbrain.overlay_vol.vol,2)*size(etc_render_fsbrain.overlay_vol.vol,3), size(etc_render_fsbrain.overlay_vol.vol,4)]);
            
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
        set(handles.checkbox_show_vol_overlay,'enable','on');
        set(handles.checkbox_show_vol_overlay,'value',1);
        etc_render_fsbrain.overlay_flag_render=1;
    else
        set(handles.checkbox_show_colorbar,'enable','off');
        set(handles.checkbox_show_overlay,'enable','off');
        set(handles.checkbox_show_overlay,'value',0);
        set(handles.checkbox_show_vol_overlay,'enable','off');
        set(handles.checkbox_show_vol_overlay,'value',0);
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

if(isempty(etc_render_fsbrain.overlay_vol_mask))
    etc_render_fsbrain_handle('kb','cc','l');
else
    etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    etc_render_fsbrain_handle('draw_stc');
end;
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


% --- Executes on button press in checkbox_electrode_contacts.
function checkbox_electrode_contacts_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_electrode_contacts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_electrode_contacts
global etc_render_fsbrain;

%set(findobj('Tag','checkbox_mri_view'),'Value',get(hObject,'Value'));
%set(findobj('Tag','checkbox_brain_surface'),'Value',get(hObject,'Value'));

%etc_render_fsbrain.show_all_contacts_brain_surface_flag=get(hObject,'Value');
%etc_render_fsbrain.show_all_contacts_mri_flag=get(hObject,'Value');
etc_render_fsbrain.all_electrode_flag=get(hObject,'Value');

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
%etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord);

etc_render_fsbrain_handle('redraw');
  



function edit_aux_point_text_size_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aux_point_text_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aux_point_text_size as text
%        str2double(get(hObject,'String')) returns contents of edit_aux_point_text_size as a double
global etc_render_fsbrain;

etc_render_fsbrain.aux_point_text_size=str2double(get(hObject,'String'));
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
function edit_aux_point_text_size_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aux_point_text_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_aux_point_text_color.
function pushbutton_aux_point_text_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_aux_point_text_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.aux_point_text_color,'Select a color');
etc_render_fsbrain.aux_point_text_color=c;
set(handles.pushbutton_aux_point_text_color,'BackgroundColor',etc_render_fsbrain.aux_point_text_color);
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


% --- Executes on button press in pushbutton_overlay_aux_vol.
function pushbutton_overlay_aux_vol_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_overlay_aux_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_show_vol_overlay.
function checkbox_show_vol_overlay_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_vol_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_vol_overlay
global etc_render_fsbrain
etc_render_fsbrain.overlay_vol_flag_render=get(hObject,'value');
%etc_render_fsbrain_handle('redraw');
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar

% --- Executes on button press in checkbox_show_vol_colorbar.
function checkbox_show_vol_colorbar_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_vol_colorbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_vol_colorbar
global etc_render_fsbrain

etc_render_fsbrain.flag_colorbar_vol=get(hObject,'Value');

set(etc_render_fsbrain.fig_brain,'currentchar','c');
%etc_render_fsbrain_handle('kb','cc','c');
etc_render_fsbrain_handle('kb','cv','cv'); %update colorbar



function edit_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to edit_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_alpha as text
%        str2double(get(hObject,'String')) returns contents of edit_alpha as a double
global etc_render_fsbrain;

etc_render_fsbrain.alpha=str2double(get(hObject,'String'));

set(etc_render_fsbrain.h,'facealpha',etc_render_fsbrain.alpha);

set(findobj('Tag','slider_alpha'),'value',etc_render_fsbrain.alpha);
set(handles.edit_alpha,'string',sprintf('%1.1f',get(etc_render_fsbrain.h,'facealpha')));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_overlay_main.
function listbox_overlay_main_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_overlay_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_overlay_main contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_overlay_main


global etc_render_fsbrain;

contents = cellstr(get(hObject,'String'));
etc_render_fsbrain.overlay_buffer_main_idx=get(hObject,'Value');
if(~strcmp(contents{etc_render_fsbrain.overlay_buffer_main_idx},'[none]'))
    etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).stc;
    etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).vertex;
    etc_render_fsbrain.overlay_stc_timeVec=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).timeVec;
    etc_render_fsbrain.stc_hemi=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).hemi;
    
    
    etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_stc;
    
    
    v=get(handles.listbox_overlay,'value');
    v=setdiff(v,etc_render_fsbrain.overlay_buffer_main_idx);
    
    etc_render_fsbrain.overlay_aux_stc=[];  
    count=1;
    for v_idx=1:length(v)
        if(size(etc_render_fsbrain.overlay_stc)==size(etc_render_fsbrain.overlay_buffer(v(v_idx)).stc))
            etc_render_fsbrain.overlay_aux_stc(:,:,count)=etc_render_fsbrain.overlay_buffer(v(v_idx)).stc;
            count=count+1;
        else
            fprintf('size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',contents{v(v_idx)},contents{etc_render_fsbrain.overlay_buffer_main_idx});
        end;
    end;
    
    
    etc_render_fsbrain.overlay_stc_timeVec_unit='ms';
    set(findobj('tag','text_timeVec_unit'),'string',etc_render_fsbrain.overlay_stc_timeVec_unit);
    
    [tmp,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(etc_render_fsbrain.overlay_stc.^2,1));
    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
    etc_render_fsbrain.overlay_stc_hemi=etc_render_fsbrain.overlay_stc;
    
    etc_render_fsbrain.overlay_flag_render=1;
    etc_render_fsbrain.overlay_value_flag_pos=1;
    etc_render_fsbrain.overlay_value_flag_neg=1;
    
    etc_render_fsbrain_handle('update_overlay_vol');
    etc_render_fsbrain_handle('draw_pointer');
    etc_render_fsbrain_handle('redraw');
    etc_render_fsbrain_handle('draw_stc');
end;


% --- Executes during object creation, after setting all properties.
function listbox_overlay_main_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_overlay_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox_overlay.
function listbox_overlay_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_overlay contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_overlay

global etc_render_fsbrain;
v=get(handles.listbox_overlay,'value');

contents = cellstr(get(hObject,'String'));

% if(isempty(etc_render_fsbrain.overlay_vol)||isempty(etc_render_fsbrain.overlay))
%     etc_render_fsbrain_handle('kb','cc','l');
% else
%     etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
%     etc_render_fsbrain_handle('draw_stc');
% end;
% return;
etc_render_fsbrain.overlay_aux_stc=[];
count=1;
for v_idx=1:length(v)
    if(size(etc_render_fsbrain.overlay_stc)==size(etc_render_fsbrain.overlay_buffer(v(v_idx)).stc))
        etc_render_fsbrain.overlay_aux_stc(:,:,count)=etc_render_fsbrain.overlay_buffer(v(v_idx)).stc;
        count=count+1;
    else
        fprintf('size for [%s] not compatible to the main layer [%s]. Data are not rendered until being seleted as the main layer.\n',contents{v(v_idx)},contents{etc_render_fsbrain.overlay_buffer_main_idx});
    end;
end;


f=gcf;
etc_render_fsbrain_handle('draw_stc');
figure(f);

% --- Executes during object creation, after setting all properties.
function listbox_overlay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_overlay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listbox_overlay and none of its controls.
function listbox_overlay_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_overlay (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;


if(strcmp(eventdata.Key,'backspace')|strcmp(eventdata.Key,'delete'))
    contents = cellstr(get(hObject,'String'));
    select_idx=get(hObject,'Value');
    
    if(~isempty(select_idx))
        try
            etc_render_fsbrain.overlay_buffer(select_idx)=[];
            
            str0=get(findobj('tag','listbox_overlay_main'),'string'); 
            str0=str0{etc_render_fsbrain.overlay_buffer_main_idx};
            str={};
            for str_idx=1:length(etc_render_fsbrain.overlay_buffer) str{str_idx}=etc_render_fsbrain.overlay_buffer(str_idx).name; end;
            if(isempty(str))
                set(findobj('tag','listbox_overlay_main'),'string','[none]');
                set(findobj('tag','listbox_overlay_main'),'value',1);
                etc_render_fsbrain.overlay_buffer_main_idx=[];
            else
                set(findobj('tag','listbox_overlay_main'),'string',str);
                s_idx=strfind(str,str0);
                IndexC = strcmp(str,str0);
                s_idx = find(IndexC);
                if(isempty(s_idx))
                    set(findobj('tag','listbox_overlay_main'),'value',1);
                    etc_render_fsbrain.overlay_buffer_main_idx=1;
                else
                    set(findobj('tag','listbox_overlay_main'),'value',s_idx);
                    etc_render_fsbrain.overlay_buffer_main_idx=s_idx;
                end;
            end;
            
            etc_render_fsbrain.overlay_stc=[];
            etc_render_fsbrain.overlay_vol_stc=[];
            etc_render_fsbrain.overlay_value=[];
            etc_render_fsbrain.overlay_vertex=[];
            etc_render_fsbrain.overlay_stc_timeVec=[];
            etc_render_fsbrain.stc_hemi=[];
            etc_render_fsbrain.overlay_stc_timeVec_unit='';
            etc_render_fsbrain.overlay_stc_hemi=[];
            etc_render_fsbrain.overlay_flag_render=0;
            etc_render_fsbrain.overlay_value_flag_pos=0;
            etc_render_fsbrain.overlay_value_flag_neg=0;
            etc_render_fsbrain.overlay_vol_stc=[];
            if(~isempty(etc_render_fsbrain.overlay_buffer_main_idx))
                etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).stc;
                etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).vertex;
                etc_render_fsbrain.overlay_stc_timeVec=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).timeVec;
                etc_render_fsbrain.stc_hemi=etc_render_fsbrain.overlay_buffer(etc_render_fsbrain.overlay_buffer_main_idx).hemi;
                etc_render_fsbrain.overlay_stc_timeVec_unit='ms';
                set(findobj('tag','text_timeVec_unit'),'string',etc_render_fsbrain.overlay_stc_timeVec_unit);
                [tmp,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(etc_render_fsbrain.overlay_stc.^2,1));
                etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                etc_render_fsbrain.overlay_stc_hemi=etc_render_fsbrain.overlay_stc;
                etc_render_fsbrain.overlay_flag_render=1;
                etc_render_fsbrain.overlay_value_flag_pos=1;
                etc_render_fsbrain.overlay_value_flag_neg=1;
                etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_stc;
            end;
            etc_render_fsbrain_gui_update(handles);
            
            %etc_render_fsbrain_gui_OpeningFcn(hObject, eventdata, handle);
            
            if(isempty(etc_render_fsbrain.overlay_stc))
                if(~isempty(etc_render_fsbrain.fig_stc))
                    if(isvalid(etc_render_fsbrain.fig_stc))
                        delete(etc_render_fsbrain.fig_stc);
                        etc_render_fsbrain.fig_stc=[];
                    end;
                end;
            end;
            
            v0=get(findobj('tag','listbox_overlay'),'value');
            set(findobj('tag','listbox_overlay'),'string',str);
            set(findobj('tag','listbox_overlay'),'min',0);
            if(length(etc_render_fsbrain.overlay_buffer)==1)
                set(findobj('tag','listbox_overlay'),'max',2);
            else
                set(findobj('tag','listbox_overlay'),'max',length(etc_render_fsbrain.overlay_buffer));
            end;
            v0=setdiff(v0,select_idx);
            set(findobj('tag','listbox_overlay'),'Value',v0);
            
            v=etc_render_fsbrain.overlay_buffer_main_idx;
            etc_render_fsbrain.overlay_aux_stc=[];
            for v_idx=1:length(v)
                etc_render_fsbrain.overlay_aux_stc(:,:,v_idx)=etc_render_fsbrain.overlay_buffer(v(v_idx)).stc;
            end;
                        
            etc_render_fsbrain_handle('update_overlay_vol');
            etc_render_fsbrain_handle('draw_pointer');
            etc_render_fsbrain_handle('redraw');
            etc_render_fsbrain_handle('draw_stc');
            
        catch ME
        end;
    end;
end;


% --- Executes on slider movement.
function slider_orthogonal_slice_x_Callback(hObject, eventdata, handles)
% hObject    handle to slider_orthogonal_slice_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(1)=get(hObject,'Value');
            
            tmp=[click_vertex_vox 1]';
            mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*tmp;
            %mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.tkrvox2ras*tmp;
            mni=min(1:3)';
            
            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
            surface_coord=surface_coord(1:3);
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        else
            
        end;
    end;
end;

% --- Executes during object creation, after setting all properties.
function slider_orthogonal_slice_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_orthogonal_slice_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_orthogonal_slice_y_Callback(hObject, eventdata, handles)
% hObject    handle to slider_orthogonal_slice_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(2)=get(hObject,'Value');
            
            tmp=[click_vertex_vox 1]';
            mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*tmp;
            %mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.tkrvox2ras*tmp;
            mni=min(1:3)';
            
            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
            surface_coord=surface_coord(1:3);
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        else
            
        end;
    end;
end;

% --- Executes during object creation, after setting all properties.
function slider_orthogonal_slice_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_orthogonal_slice_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_orthogonal_slice_z_Callback(hObject, eventdata, handles)
% hObject    handle to slider_orthogonal_slice_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(3)=get(hObject,'Value');
            
            tmp=[click_vertex_vox 1]';
            mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*tmp;
            %mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.tkrvox2ras*tmp;
            mni=min(1:3)';
            
            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
            surface_coord=surface_coord(1:3);
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        else
            
        end;
    end;
end;



% --- Executes during object creation, after setting all properties.
function slider_orthogonal_slice_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_orthogonal_slice_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox_orthogonal_slice_cor.
function checkbox_orthogonal_slice_cor_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_orthogonal_slice_cor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_orthogonal_slice_cor
global etc_render_fsbrain;

etc_render_fsbrain.flag_orthogonal_slice_cor=get(hObject,'Value');

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord);



function edit_orthogonal_slice_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_orthogonal_slice_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_orthogonal_slice_x as text
%        str2double(get(hObject,'String')) returns contents of edit_orthogonal_slice_x as a double
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(1)=str2double(get(hObject,'String'));
            
            tmp=[click_vertex_vox 1]';
            mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*tmp;
            %mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.tkrvox2ras*tmp;
            mni=min(1:3)';
            
            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
            surface_coord=surface_coord(1:3);
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        else
            
        end;
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_orthogonal_slice_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_orthogonal_slice_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_orthogonal_slice_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_orthogonal_slice_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_orthogonal_slice_y as text
%        str2double(get(hObject,'String')) returns contents of edit_orthogonal_slice_y as a double
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(2)=str2double(get(hObject,'String'));
            
            tmp=[click_vertex_vox 1]';
            mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*tmp;
            %mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.tkrvox2ras*tmp;
            mni=min(1:3)';
            
            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
            surface_coord=surface_coord(1:3);
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        else
            
        end;
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_orthogonal_slice_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_orthogonal_slice_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_orthogonal_slice_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_orthogonal_slice_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_orthogonal_slice_z as text
%        str2double(get(hObject,'String')) returns contents of edit_orthogonal_slice_z as a double
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(3)=str2double(get(hObject,'String'));
            
            tmp=[click_vertex_vox 1]';
            mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*tmp;
            %mni=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.tkrvox2ras*tmp;
            mni=min(1:3)';
            
            surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
            surface_coord=surface_coord(1:3);
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        else
            
        end;
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_orthogonal_slice_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_orthogonal_slice_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_orthogonal_slice_sag.
function checkbox_orthogonal_slice_sag_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_orthogonal_slice_sag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_orthogonal_slice_sag
global etc_render_fsbrain;

etc_render_fsbrain.flag_orthogonal_slice_sag=get(hObject,'Value');

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord);


% --- Executes on button press in checkbox_orthogonal_slice_ax.
function checkbox_orthogonal_slice_ax_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_orthogonal_slice_ax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_orthogonal_slice_ax
global etc_render_fsbrain;

etc_render_fsbrain.flag_orthogonal_slice_ax=get(hObject,'Value');

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord);


% --- Executes on button press in pushbutton_pos_curv_color.
function pushbutton_pos_curv_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pos_curv_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.curv_pos_color,'Select a color');
etc_render_fsbrain.curv_pos_color=c;
set(handles.pushbutton_pos_curv_color,'BackgroundColor',etc_render_fsbrain.curv_pos_color);
%etc_render_fsbrain_handle('draw_pointer');
try
        etc_render_fsbrain_handle('redraw');        
catch ME
end;



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_neg_curv_color.
function pushbutton_neg_curv_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_neg_curv_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

c = uisetcolor(etc_render_fsbrain.curv_neg_color,'Select a color');
etc_render_fsbrain.curv_neg_color=c;
set(handles.pushbutton_neg_curv_color,'BackgroundColor',etc_render_fsbrain.curv_neg_color);
%etc_render_fsbrain_handle('draw_pointer');
try
        etc_render_fsbrain_handle('redraw');        
catch ME
end;


function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_show_cort_label.
function checkbox_show_cort_label_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_cort_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_cort_label
global etc_render_fsbrain

etc_render_fsbrain.flag_show_cort_label=get(hObject,'Value');


if(isfield(etc_render_fsbrain,'label_register'))
    %cortical labels
    for ss=1:length(etc_render_fsbrain.label_register)
        if(~isempty(etc_render_fsbrain.label_ctab))
            label_number=etc_render_fsbrain.label_ctab.table(ss,5);
            vidx=find((etc_render_fsbrain.label_value)==label_number);
            if(etc_render_fsbrain.label_register(ss)==1)
                if(etc_render_fsbrain.flag_show_cort_label)
                    %plot label
                    cc=etc_render_fsbrain.label_ctab.table(ss,1:3)./255;
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
                else
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                end;
                if(etc_render_fsbrain.flag_show_cort_label_boundary)
                    %plot label boundary
                    figure(etc_render_fsbrain.fig_brain);
                    if(isfield(etc_render_fsbrain,'h_label_boundary'))
                        delete(etc_render_fsbrain.h_label_boundary(:));
                    end;
                    boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                    for b_idx=1:length(boundary_face_idx)
                        boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                        %hold on;
                        etc_render_fsbrain.h_label_boundary(b_idx)=line(...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');
                        
                        set(etc_render_fsbrain.h_label_boundary(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color);
                    end;
                else
                    if(isfield(etc_render_fsbrain,'h_label_boundary'))
                        delete(etc_render_fsbrain.h_label_boundary(:));
                    end;
                end;
            end;
        end;
    end;
end;

% --- Executes on button press in checkbox_show_cort_label_boundary.
function checkbox_show_cort_label_boundary_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_cort_label_boundary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_cort_label_boundary
global etc_render_fsbrain

etc_render_fsbrain.flag_show_cort_label_boundary=get(hObject,'Value');


if(isfield(etc_render_fsbrain,'label_register'))
    %cortical labels
    for ss=1:length(etc_render_fsbrain.label_register)
        if(~isempty(etc_render_fsbrain.label_ctab))
            label_number=etc_render_fsbrain.label_ctab.table(ss,5);
            vidx=find((etc_render_fsbrain.label_value)==label_number);
            if(etc_render_fsbrain.label_register(ss)==1)
                if(etc_render_fsbrain.flag_show_cort_label)
                    %plot label
                    cc=etc_render_fsbrain.label_ctab.table(ss,1:3)./255;
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
                else
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                end;
                if(etc_render_fsbrain.flag_show_cort_label_boundary)
                    %plot label boundary
                    figure(etc_render_fsbrain.fig_brain);
                    if(isfield(etc_render_fsbrain,'h_label_boundary'))
                        delete(etc_render_fsbrain.h_label_boundary(:));
                    end;
                    boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                    for b_idx=1:length(boundary_face_idx)
                        boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                        %hold on;
                        etc_render_fsbrain.h_label_boundary(b_idx)=line(...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');
                        
                        set(etc_render_fsbrain.h_label_boundary(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color);
                    end;
                else
                    if(isfield(etc_render_fsbrain,'h_label_boundary'))
                        delete(etc_render_fsbrain.h_label_boundary(:));
                    end;
                end;
            end;
        end;
    end;
end;
% --- Executes on button press in pushbotton_cort_label_boundary_color.
function pushbotton_cort_label_boundary_color_Callback(hObject, eventdata, handles)
% hObject    handle to pushbotton_cort_label_boundary_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain

c = uisetcolor(etc_render_fsbrain.cort_label_boundary_color,'Select a color');
etc_render_fsbrain.cort_label_boundary_color=c;
set(handles.pushbotton_cort_label_boundary_color,'BackgroundColor',etc_render_fsbrain.cort_label_boundary_color);


if(isfield(etc_render_fsbrain,'label_register'))
    %cortical labels
    for ss=1:length(etc_render_fsbrain.label_register)
        if(~isempty(etc_render_fsbrain.label_ctab))
            label_number=etc_render_fsbrain.label_ctab.table(ss,5);
            vidx=find((etc_render_fsbrain.label_value)==label_number);
            if(etc_render_fsbrain.label_register(ss)==1)
                if(etc_render_fsbrain.flag_show_cort_label)
                    %plot label
                    cc=etc_render_fsbrain.label_ctab.table(ss,1:3)./255;
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
                else
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                end;
                if(etc_render_fsbrain.flag_show_cort_label_boundary)
                    %plot label boundary
                    figure(etc_render_fsbrain.fig_brain);
                    if(isfield(etc_render_fsbrain,'h_label_boundary'))
                        delete(etc_render_fsbrain.h_label_boundary(:));
                    end;
                    boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
                    for b_idx=1:length(boundary_face_idx)
                        boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
                        %hold on;
                        etc_render_fsbrain.h_label_boundary(b_idx)=line(...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                            etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');
                        
                        set(etc_render_fsbrain.h_label_boundary(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color);
                    end;
                else
                    if(isfield(etc_render_fsbrain,'h_label_boundary'))
                        delete(etc_render_fsbrain.h_label_boundary(:));
                    end;
                end;
            end;
        end;
    end;
end;
