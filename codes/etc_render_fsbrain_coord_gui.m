function varargout = etc_render_fsbrain_coord_gui(varargin)
% ETC_RENDER_FSBRAIN_COORD_GUI MATLAB code for etc_render_fsbrain_coord_gui.fig
%      ETC_RENDER_FSBRAIN_COORD_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_COORD_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_COORD_GUI returns the handle to a new ETC_RENDER_FSBRAIN_COORD_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_COORD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_COORD_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_COORD_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_COORD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_coord_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_coord_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_coord_gui

% Last Modified by GUIDE v2.5 13-Feb-2022 22:09:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_coord_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_coord_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_coord_gui is made visible.
function etc_render_fsbrain_coord_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_coord_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_coord_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global etc_render_fsbrain;

try
    h=findobj('tag','edit_surf_x');
    set(h,'String',num2str(etc_render_fsbrain.click_coord(1),'%1.1f'));
    h=findobj('tag','edit_surf_y');
    set(h,'String',num2str(etc_render_fsbrain.click_coord(2),'%1.1f'));
    h=findobj('tag','edit_surf_z');
    set(h,'String',num2str(etc_render_fsbrain.click_coord(3),'%1.1f'));
catch ME
    h=findobj('tag','edit_surf_x');
    set(h,'String','');
    h=findobj('tag','edit_surf_y');
    set(h,'String','');
    h=findobj('tag','edit_surf_z');
    set(h,'String','');
end;

try
    h=findobj('tag','edit_surf_x_round');
    set(h,'String',num2str(etc_render_fsbrain.click_coord_round(1),'%1.1f'));
    h=findobj('tag','edit_surf_y_round');
    set(h,'String',num2str(etc_render_fsbrain.click_coord_round(2),'%1.1f'));
    h=findobj('tag','edit_surf_z_round');
    set(h,'String',num2str(etc_render_fsbrain.click_coord_round(3),'%1.1f'));
catch ME
    h=findobj('tag','edit_surf_x_round');
    set(h,'String','');
    h=findobj('tag','edit_surf_y_round');
    set(h,'String','');
    h=findobj('tag','edit_surf_z_round');
    set(h,'String','');
end;

try
    h=findobj('tag','edit_vox_x');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(1),'%1.0f'));
    h=findobj('tag','edit_vox_y');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(2),'%1.0f'));
    h=findobj('tag','edit_vox_z');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(3),'%1.0f'));
catch ME
    h=findobj('tag','edit_vox_x');
    set(h,'String','');
    h=findobj('tag','edit_vox_y');
    set(h,'String','');
    h=findobj('tag','edit_vox_z');
    set(h,'String','');
end;

try
    h=findobj('tag','edit_vox_x_round');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(1),'%1.0f'));
    h=findobj('tag','edit_vox_y_round');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(2),'%1.0f'));
    h=findobj('tag','edit_vox_z_round');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(3),'%1.0f'));
catch ME
    h=findobj('tag','edit_vox_x_round');
    set(h,'String','');
    h=findobj('tag','edit_vox_y_round');
    set(h,'String','');
    h=findobj('tag','edit_vox_z_round');
    set(h,'String','');
end;


try
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(~isempty(etc_render_fsbrain.overlay_vol_xfm))
            tcrs=[etc_render_fsbrain.click_vertex_vox_round(:); 1];
            
            mcrs = round(etc_render_fsbrain.overlay_vol_xfm * tcrs);
            
            h=findobj('tag','edit_vox_overlay_x_round');
            set(h,'String',num2str(mcrs(1),'%1.0f'));
            h=findobj('tag','edit_vox_overlay_y_round');
            set(h,'String',num2str(mcrs(2),'%1.0f'));
            h=findobj('tag','edit_vox_overlay_z_round');
            set(h,'String',num2str(mcrs(3),'%1.0f'));
        end;
    end;
catch ME
    h=findobj('tag','edit_vox_overlay_x_round');
    set(h,'String','');
    h=findobj('tag','edit_vox_overlay_y_round');
    set(h,'String','');
    h=findobj('tag','edit_vox_overlay_z_round');
    set(h,'String','');
end;

try
    h=findobj('tag','edit_mni_x');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(1),'%1.0f'));
    h=findobj('tag','edit_mni_y');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(2),'%1.0f'));
    h=findobj('tag','edit_mni_z');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(3),'%1.0f'));
catch ME
    h=findobj('tag','edit_mni_x');
    set(h,'String','');
    h=findobj('tag','edit_mni_y');
    set(h,'String','');
    h=findobj('tag','edit_mni_z');
    set(h,'String','');
end;

try
    h=findobj('tag','edit_mni_x_round');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(1),'%1.0f'));
    h=findobj('tag','edit_mni_y_round');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(2),'%1.0f'));
    h=findobj('tag','edit_mni_z_round');
    set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(3),'%1.0f'));
catch ME
    h=findobj('tag','edit_mni_x_round');
    set(h,'String','');
    h=findobj('tag','edit_mni_y_round');
    set(h,'String','');
    h=findobj('tag','edit_mni_z_round');
    set(h,'String','');
end;


% UIWAIT makes etc_render_fsbrain_coord_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_coord_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_mni_z_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_z_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_z_round as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_z_round as a double


% --- Executes during object creation, after setting all properties.
function edit_mni_z_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mni_z_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edit_mni_y_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_y_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_y_round as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_y_round as a double


% --- Executes during object creation, after setting all properties.
function edit_mni_y_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mni_y_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mni_x_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_x_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_x_round as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_x_round as a double


% --- Executes during object creation, after setting all properties.
function edit_mni_x_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mni_x_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mni_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_z as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_z as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        mni=[etc_render_fsbrain.click_vertex_point_tal(1) etc_render_fsbrain.click_vertex_point_tal(2)  str2double(get(hObject,'String')) 1]';
        click_vertex_vox=inv(etc_render_fsbrain.vol.vox2ras)*inv(etc_render_fsbrain.vol_pre_xfm)*inv(etc_render_fsbrain.talxfm)*mni;
        %click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*inv(etc_render_fsbrain.vol_pre_xfm)*inv(etc_render_fsbrain.talxfm)*mni;
        click_vertex_vox=click_vertex_vox(1:3)';
        
        surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
        surface_coord=surface_coord(1:3);
        
        vv=etc_render_fsbrain.orig_vertex_coords;
        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_mni_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mni_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mni_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_y as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_y as a double
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.click_vertex))
    try
        mni=[etc_render_fsbrain.click_vertex_point_tal(1) str2double(get(hObject,'String')) etc_render_fsbrain.click_vertex_point_tal(3) 1]';
        click_vertex_vox=inv(etc_render_fsbrain.vol.vox2ras)*inv(etc_render_fsbrain.vol_pre_xfm)*inv(etc_render_fsbrain.talxfm)*mni;
        %click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*inv(etc_render_fsbrain.vol_pre_xfm)*inv(etc_render_fsbrain.talxfm)*mni;
        click_vertex_vox=click_vertex_vox(1:3)';
        
        surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
        surface_coord=surface_coord(1:3);
        
        vv=etc_render_fsbrain.orig_vertex_coords;
        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_mni_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mni_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mni_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_x as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_x as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        mni=[str2double(get(hObject,'String')) etc_render_fsbrain.click_vertex_point_tal(2)  etc_render_fsbrain.click_vertex_point_tal(3) 1]';
        click_vertex_vox=inv(etc_render_fsbrain.vol.vox2ras)*inv(etc_render_fsbrain.vol_pre_xfm)*inv(etc_render_fsbrain.talxfm)*mni;
        %click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*inv(etc_render_fsbrain.vol_pre_xfm)*inv(etc_render_fsbrain.talxfm)*mni;
        click_vertex_vox=click_vertex_vox(1:3)';
        
        surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[click_vertex_vox(:); 1];
        surface_coord=surface_coord(1:3);
        
        vv=etc_render_fsbrain.orig_vertex_coords;
        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_mni_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mni_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vox_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vox_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vox_x as text
%        str2double(get(hObject,'String')) returns contents of edit_vox_x as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        click_vertex_vox=[str2double(get(hObject,'String')) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
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
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_vox_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vox_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vox_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vox_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vox_y as text
%        str2double(get(hObject,'String')) returns contents of edit_vox_y as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
    click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1)  str2double(get(hObject,'String')) etc_render_fsbrain.click_vertex_vox(3)];
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
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_vox_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vox_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vox_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vox_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vox_z as text
%        str2double(get(hObject,'String')) returns contents of edit_vox_z as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2) str2double(get(hObject,'String'))];
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
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_vox_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vox_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vox_x_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vox_x_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vox_x_round as text
%        str2double(get(hObject,'String')) returns contents of edit_vox_x_round as a double


% --- Executes during object creation, after setting all properties.
function edit_vox_x_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vox_x_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vox_y_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vox_y_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vox_y_round as text
%        str2double(get(hObject,'String')) returns contents of edit_vox_y_round as a double


% --- Executes during object creation, after setting all properties.
function edit_vox_y_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vox_y_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_vox_z_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_vox_z_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_vox_z_round as text
%        str2double(get(hObject,'String')) returns contents of edit_vox_z_round as a double


% --- Executes during object creation, after setting all properties.
function edit_vox_z_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_vox_z_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_surf_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_surf_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_surf_x as text
%        str2double(get(hObject,'String')) returns contents of edit_surf_x as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        surface_coord=[str2double(get(hObject,'String')) etc_render_fsbrain.click_coord(2)  etc_render_fsbrain.click_coord(3)];
        tmp=[surface_coord 1]';
        click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*tmp;
        click_vertex_vox=click_vertex_vox(1:3)';
        
        vv=etc_render_fsbrain.orig_vertex_coords;
        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_surf_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_surf_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_surf_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_surf_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_surf_y as text
%        str2double(get(hObject,'String')) returns contents of edit_surf_y as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        surface_coord=[etc_render_fsbrain.click_coord(1) str2double(get(hObject,'String')) etc_render_fsbrain.click_coord(3)];
        tmp=[surface_coord 1]';
        click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*tmp;
        click_vertex_vox=click_vertex_vox(1:3)';
        
        vv=etc_render_fsbrain.orig_vertex_coords;
        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
end;


% --- Executes during object creation, after setting all properties.
function edit_surf_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_surf_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_surf_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_surf_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_surf_z as text
%        str2double(get(hObject,'String')) returns contents of edit_surf_z as a double
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.click_vertex))
    try
        surface_coord=[etc_render_fsbrain.click_coord(1) etc_render_fsbrain.click_coord(2) str2double(get(hObject,'String'))];
        tmp=[surface_coord 1]';
        click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*tmp;
        click_vertex_vox=click_vertex_vox(1:3)';
        
        vv=etc_render_fsbrain.orig_vertex_coords;
        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
end;

% --- Executes during object creation, after setting all properties.
function edit_surf_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_surf_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_surf_x_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_surf_x_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_surf_x_round as text
%        str2double(get(hObject,'String')) returns contents of edit_surf_x_round as a double


% --- Executes during object creation, after setting all properties.
function edit_surf_x_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_surf_x_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_surf_y_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_surf_y_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_surf_y_round as text
%        str2double(get(hObject,'String')) returns contents of edit_surf_y_round as a double


% --- Executes during object creation, after setting all properties.
function edit_surf_y_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_surf_y_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_surf_z_round_Callback(hObject, eventdata, handles)
% hObject    handle to edit_surf_z_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_surf_z_round as text
%        str2double(get(hObject,'String')) returns contents of edit_surf_z_round as a double


% --- Executes during object creation, after setting all properties.
function edit_surf_z_round_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_surf_z_round (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in pushbutton_xless.
function pushbutton_xless_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_xless (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)>1)
            click_vertex_vox(1)=click_vertex_vox(1)-1;
            
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

% --- Executes on button press in pushbutton_xmore.
function pushbutton_xmore_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_xmore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(1)<=size(etc_render_fsbrain.vol.vol,2))
            click_vertex_vox(1)=click_vertex_vox(1)+1;
            
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

% --- Executes on button press in pushbutton_yless.
function pushbutton_yless_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_yless (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(2)>1)
            click_vertex_vox(2)=click_vertex_vox(2)-1;
            
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

% --- Executes on button press in pushbutton_ymore.
function pushbutton_ymore_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ymore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(2)<=size(etc_render_fsbrain.vol.vol,1))
            click_vertex_vox(2)=click_vertex_vox(2)+1;
            
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

% --- Executes on button press in pushbutton_zless.
function pushbutton_zless_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zless (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(3)>1)
            click_vertex_vox(3)=click_vertex_vox(3)-1;
            
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

% --- Executes on button press in pushbutton_zmore.
function pushbutton_zmore_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zmore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~isempty(etc_render_fsbrain.click_vertex))
    if(~isempty(etc_render_fsbrain.click_vertex_vox))
        click_vertex_vox=[etc_render_fsbrain.click_vertex_vox(1) etc_render_fsbrain.click_vertex_vox(2)  etc_render_fsbrain.click_vertex_vox(3)];
        if(click_vertex_vox(3)<=size(etc_render_fsbrain.vol.vol,3))
            click_vertex_vox(3)=click_vertex_vox(3)+1;
            
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


% --- Executes on button press in pushbutton_overlay_vol_xfm.
function pushbutton_overlay_vol_xfm_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_overlay_vol_xfm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

fprintf('\nload overlay volume transformation matrix...\n');
[filename, pathname, filterindex] = uigetfile({'*.dat','registration matrix'}, 'Pick a registration matrix file');
if(filename==0) return; end;
%[filename1, pathname1, filterindex1] = uigetfile({'*.mgz','overlay volume (MGZ)'; '*.mgh','overlay volume (MGH)'; '*.nii','overlay volume (nii)'}, 'Pick an overlay volume');
[filename1, pathname1, filterindex1] = uigetfile({'*.*','overlay volume (*.mgz, *.mgh, *.nii)'}, 'Pick an overlay volume');
if(filename1==0) return; end;

try
    xfm=etc_read_xfm('file_xfm',sprintf('%s/%s',pathname,filename));
    
    [dumm, fstem,fext]=fileparts(filename1);
    switch(fext)
        case '.mgh'
            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
        case '.mgz'
            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
        case '.nii'
            mov=MRIread(sprintf('%s/%s',pathname1,filename1));
    end;
    
    Tt = etc_render_fsbrain.vol.tkrvox2ras;
    Tm = mov.tkrvox2ras;
    etc_render_fsbrain.overlay_vol_xfm = inv(Tm)*xfm*Tt;
    
    fprintf('overlay volume registration matrix updated!\n');
catch ME
end;



