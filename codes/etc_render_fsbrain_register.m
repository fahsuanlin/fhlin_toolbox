function varargout = etc_render_fsbrain_register(varargin)
% ETC_RENDER_FSBRAIN_REGISTER MATLAB code for etc_render_fsbrain_register.fig
%      ETC_RENDER_FSBRAIN_REGISTER, by itself, creates a new ETC_RENDER_FSBRAIN_REGISTER or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_REGISTER returns the handle to a new ETC_RENDER_FSBRAIN_REGISTER or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_REGISTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_REGISTER.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_REGISTER('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_REGISTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_register_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_register_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_register

% Last Modified by GUIDE v2.5 25-Jun-2022 13:43:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_register_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_register_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_register is made visible.
function etc_render_fsbrain_register_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_register (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_register
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_register wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_render_fsbrain;
if(isfield(etc_render_fsbrain,'aux_point_coords'))
    etc_render_fsbrain.aux_point_coords_orig=etc_render_fsbrain.aux_point_coords;
else
    etc_render_fsbrain.aux_point_coords_orig=[];
    etc_render_fsbrain.aux_point_coords=[];
end;

if(isfield(etc_render_fsbrain,'overlay_vol'))
    etc_render_fsbrain.overlay_vol_orig=etc_render_fsbrain.overlay_vol;
    if(~isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        etc_render_fsbrain.overlay_vol_xfm=eye(4);
    end;
    etc_render_fsbrain.overlay_vol_xfm_orig=etc_render_fsbrain.overlay_vol_xfm;
else
    etc_render_fsbrain.overlay_vol_orig=[];
    etc_render_fsbrain.overlay_vol_xfm_orig=[];
end;

if(isempty(etc_render_fsbrain.aux_point_coords)&&isempty(etc_render_fsbrain.overlay_vol))
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            c{i}.Enable='off';
        end;
    end;
else
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            c{i}.Enable='on';
        end;
    end;
    
    %initialize the transformation matrix if necessary
    if(~isempty(etc_render_fsbrain.overlay_vol))
        if(~isfield(etc_render_fsbrain,'overlay_vol_xfm'))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
    end;    
end;

if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
    handles.checkbox_paint_on_cortex.Value=etc_render_fsbrain.overlay_flag_paint_on_cortex;
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_register_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_rotate_cc.
function pushbutton_rotate_cc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);

theta=(etc_render_fsbrain.register_rotate_angle).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix

if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=(R*etc_render_fsbrain.aux_point_coords.').';
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(isempty(etc_render_fsbrain.overlay_vol_xfm))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
        Rtmp=R;
        Rtmp(4,:)=0;
        Rtmp(:,4)=0;
        Rtmp(4,4)=1;
        etc_render_fsbrain.overlay_vol_xfm=(Rtmp)*etc_render_fsbrain.overlay_vol_xfm;
        
        etc_render_fsbrain.overlay_vol=MRIvol2vol(etc_render_fsbrain.overlay_vol,etc_render_fsbrain.overlay_vol,inv(Rtmp));
        
        if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
            if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                etc_render_fsbrain_overlay_vol_update;
                etc_render_fsbrain_handle('update_overlay_vol');
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    etc_render_fsbrain.aux2_point_coords=(R*etc_render_fsbrain.aux2_point_coords.').';
end;
etc_render_fsbrain_handle('redraw');
% --- Executes on button press in pushbutton_rotate_c.
function pushbutton_rotate_c_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);

theta=-(etc_render_fsbrain.register_rotate_angle).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix

if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=(R*etc_render_fsbrain.aux_point_coords.').';
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(isempty(etc_render_fsbrain.overlay_vol_xfm))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
        Rtmp=R;
        Rtmp(4,:)=0;
        Rtmp(:,4)=0;
        Rtmp(4,4)=1;
        etc_render_fsbrain.overlay_vol_xfm=(Rtmp)*etc_render_fsbrain.overlay_vol_xfm;
        
        etc_render_fsbrain.overlay_vol=MRIvol2vol(etc_render_fsbrain.overlay_vol,etc_render_fsbrain.overlay_vol,inv(Rtmp));
        
        if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
            if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                etc_render_fsbrain_overlay_vol_update;
                etc_render_fsbrain_handle('update_overlay_vol');
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    etc_render_fsbrain.aux2_point_coords=(R*etc_render_fsbrain.aux2_point_coords.').';
end;
etc_render_fsbrain_handle('redraw');


% --- Executes during object creation, after setting all properties.
function pushbutton_rotate_cc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain
if(isempty(etc_render_fsbrain.aux_point_coords))
    set(hObject,'Enable','off');
end;


% --- Executes during object creation, after setting all properties.
function pushbutton_rotate_c_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global etc_render_fsbrain
if(isempty(etc_render_fsbrain.aux_point_coords))
    set(hObject,'Enable','off');
end;


% --- Executes on button press in pushbutton_translate_up.
function pushbutton_translate_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=etc_render_fsbrain.register_translate_dist;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(isempty(etc_render_fsbrain.overlay_vol_xfm))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
        Rtmp=eye(4);
        Rtmp(1:3,4)=(uu.'.*dist.*1e3)';
        etc_render_fsbrain.overlay_vol_xfm=(Rtmp)*etc_render_fsbrain.overlay_vol_xfm;
        
        etc_render_fsbrain.overlay_vol=MRIvol2vol(etc_render_fsbrain.overlay_vol,etc_render_fsbrain.overlay_vol,inv(Rtmp));
        
        if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
            if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                etc_render_fsbrain_overlay_vol_update;
                etc_render_fsbrain_handle('update_overlay_vol');
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;
etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_translate_down.
function pushbutton_translate_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=-1.*etc_render_fsbrain.register_translate_dist;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(isempty(etc_render_fsbrain.overlay_vol_xfm))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
        Rtmp=eye(4);
        Rtmp(1:3,4)=(uu.'.*dist.*1e3)';
        etc_render_fsbrain.overlay_vol_xfm=(Rtmp)*etc_render_fsbrain.overlay_vol_xfm;
        
        etc_render_fsbrain.overlay_vol=MRIvol2vol(etc_render_fsbrain.overlay_vol,etc_render_fsbrain.overlay_vol,inv(Rtmp));
        
        if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
            if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                etc_render_fsbrain_overlay_vol_update;
                etc_render_fsbrain_handle('update_overlay_vol');
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;
etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_translate_left.
function pushbutton_translate_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=-1.*etc_render_fsbrain.register_translate_dist;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(isempty(etc_render_fsbrain.overlay_vol_xfm))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
        Rtmp=eye(4);
        Rtmp(1:3,4)=(rr.'.*dist.*1e3)';
        etc_render_fsbrain.overlay_vol_xfm=(Rtmp)*etc_render_fsbrain.overlay_vol_xfm;
        
        etc_render_fsbrain.overlay_vol=MRIvol2vol(etc_render_fsbrain.overlay_vol,etc_render_fsbrain.overlay_vol,inv(Rtmp));
        
        if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
            if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                etc_render_fsbrain_overlay_vol_update;
                etc_render_fsbrain_handle('update_overlay_vol');
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;
etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_translate_right.
function pushbutton_translate_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=etc_render_fsbrain.register_translate_dist;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        if(isempty(etc_render_fsbrain.overlay_vol_xfm))
            etc_render_fsbrain.overlay_vol_xfm=eye(4);
        end;
        Rtmp=eye(4);
        Rtmp(1:3,4)=(rr.'.*dist.*1e3)';
        etc_render_fsbrain.overlay_vol_xfm=(Rtmp)*etc_render_fsbrain.overlay_vol_xfm;
        
        etc_render_fsbrain.overlay_vol=MRIvol2vol(etc_render_fsbrain.overlay_vol,etc_render_fsbrain.overlay_vol,inv(Rtmp));
        
        if(isfield(etc_render_fsbrain,'overlay_flag_paint_on_cortex'))
            if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
                etc_render_fsbrain_overlay_vol_update;
                etc_render_fsbrain_handle('update_overlay_vol');
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;

if(~isempty(etc_render_fsbrain.aux2_point_coords))
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;
etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain

if(~isempty(etc_render_fsbrain.aux_point_coords))
    points_all=etc_render_fsbrain.aux_point_coords;
    points=points_all;
    
    %remove auxillary points
    idx=find(strcmp(etc_render_fsbrain.aux_point_name,'.'));
    points(idx,:)=[];
    
    assignin('base','points',points);
    assignin('base','points_all',points_all);
    fprintf('variables "points" and "points_all" exported\n');
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    overlay_xfm=inv(etc_render_fsbrain.overlay_vol_xfm);

    assignin('base','overlay_xfm',overlay_xfm);
    fprintf('variables "overlay_xfm" exported\n');
end;


function edit_translate_dist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_translate_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_translate_dist as text
%        str2double(get(hObject,'String')) returns contents of edit_translate_dist as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
etc_render_fsbrain.register_translate_dist=mm./1e3;

% --- Executes during object creation, after setting all properties.
function edit_translate_dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_translate_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global etc_render_fsbrain;
etc_render_fsbrain.register_translate_dist=1e-3; %default: 1 mm
set(hObject,'value',etc_render_fsbrain.register_translate_dist);
set(hObject,'string',sprintf('%1.0f',etc_render_fsbrain.register_translate_dist.*1e3));


function edit_rotate_angle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotate_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotate_angle as text
%        str2double(get(hObject,'String')) returns contents of edit_rotate_angle as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
etc_render_fsbrain.register_rotate_angle=mm;



% --- Executes during object creation, after setting all properties.
function edit_rotate_angle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rotate_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global etc_render_fsbrain;
etc_render_fsbrain.register_rotate_angle=3; %default: 3 degrees
set(hObject,'value',etc_render_fsbrain.register_rotate_angle);
set(hObject,'string',sprintf('%1.0f',etc_render_fsbrain.register_rotate_angle));


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords_orig;
    etc_render_fsbrain_handle('redraw');
end;

if(~isempty(etc_render_fsbrain.overlay_vol))
    if(isfield(etc_render_fsbrain,'overlay_vol_xfm'))
        etc_render_fsbrain.overlay_vol_xfm=etc_render_fsbrain.overlay_vol_xfm_orig;
        
        etc_render_fsbrain.overlay_vol=etc_render_fsbrain.overlay_vol_orig;
        
        etc_render_fsbrain_overlay_vol_update;
        etc_render_fsbrain_handle('update_overlay_vol');
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
        etc_render_fsbrain_handle('redraw');
        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
            etc_render_fsbrain_handle('draw_stc');
        end;
    end;
end;


% --- Executes on button press in pushbutton_exportsave.
function pushbutton_exportsave_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_exportsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain

if(~isempty(etc_render_fsbrain.aux_point_coords)||~isempty(etc_render_fsbrain.overlay_vol))
    assignin('base','points',etc_render_fsbrain.aux_point_coords);
    filename = uigetfile;
    if(filename)
        
        if(~isempty(etc_render_fsbrain.aux_point_coords))
            points=etc_render_fsbrain.aux_point_coords;
            points_label=etc_render_fsbrain.aux_point_name;
            hsp=etc_render_fsbrain.aux2_point_coords;
            
            save(filename,'-append','points','points_label','hsp');
            fprintf('variable "points" and "points_label" exported and saved in [%s]\n',filename);
        end;
        
        if(~isempty(etc_render_fsbrain.aux2_point_coords))
            hsp=etc_render_fsbrain.aux2_point_coords;
            
            save(filename,'-append','hsp');
            fprintf('variable "hsp" exported and saved in [%s]\n',filename);
        end;
        
        if(~isempty(etc_render_fsbrain.overlay_vol))
            overlay_xfm=inv(etc_render_fsbrain.overlay_vol_xfm);
            
            assignin('base','overlay_xfm',overlay_xfm);
            save(filename,'-append','overlay_xfm');
            fprintf('variable "overlay_xfm" exported and saved in [%s]\n',filename);
        end;
    end;
end;


% --- Executes on button press in checkbox_paint_on_cortex.
function checkbox_paint_on_cortex_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_paint_on_cortex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_paint_on_cortex
global etc_render_fsbrain;

etc_render_fsbrain.overlay_flag_paint_on_cortex= get(hObject,'Value');

if(isfield(etc_render_fsbrain,'overlay_vol_backup'))
    etc_render_fsbrain.overlay_vol=etc_render_fsbrain.overlay_vol_backup;
else
    etc_render_fsbrain.overlay_vol_backup=etc_render_fsbrain.overlay_vol;   
end;

if(etc_render_fsbrain.overlay_flag_paint_on_cortex)
    etc_render_fsbrain_overlay_vol_update;
    etc_render_fsbrain_handle('update_overlay_vol');
else
    if(isfield(etc_render_fsbrain,'overlay_vol_backup'))
        etc_render_fsbrain.overlay_vol=etc_render_fsbrain.overlay_vol_backup;
    end;
end;
etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',[]);
etc_render_fsbrain_handle('redraw');
if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
    etc_render_fsbrain_handle('draw_stc');
end;


