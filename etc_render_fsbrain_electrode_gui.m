function varargout = etc_render_fsbrain_electrode_gui(varargin)
% ETC_RENDER_FSBRAIN_ELECTRODE_GUI MATLAB code for etc_render_fsbrain_electrode_gui.fig
%      ETC_RENDER_FSBRAIN_ELECTRODE_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_ELECTRODE_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_ELECTRODE_GUI returns the handle to a new ETC_RENDER_FSBRAIN_ELECTRODE_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_ELECTRODE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_ELECTRODE_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_ELECTRODE_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_ELECTRODE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_electrode_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_electrode_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_electrode_gui

% Last Modified by GUIDE v2.5 18-Mar-2019 00:41:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_electrode_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_electrode_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_electrode_gui is made visible.
function etc_render_fsbrain_electrode_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_electrode_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_electrode_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_electrode_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_render_fsbrain;

set(handles.slider_alpha,'value',get(etc_render_fsbrain.h,'facealpha'));

if(~isempty(etc_render_fsbrain.electrode))
    fprintf('electrodes specified...\n');
    for e_idx=1:length(etc_render_fsbrain.electrode)
        str{e_idx}=etc_render_fsbrain.electrode(e_idx).name;
    end;
    set(handles.listbox_electrode,'string',str);
    guidata(hObject, handles);
    
    %set default electrode and contact to the first one
    etc_render_fsbrain.electrode_idx=1;
    etc_render_fsbrain.electrode_contact_idx=1;
    
    %update the electrode contact list box
    hObject=findobj('tag','listbox_contact');
    for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
        str{c_idx}=sprintf('%d',c_idx);
    end;
    set(handles.listbox_contact,'string',str);
    guidata(hObject, handles);
    
    %initialize contact coordinates
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        flag_init=1;
        if(isfield(etc_render_fsbrain.electrode(e_idx),'coord'))
            if(~isempty(etc_render_fsbrain.electrode(e_idx).coord))
                flag_init=0;
            end;
        end;
        
        if(flag_init)
            for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                etc_render_fsbrain.electrode(e_idx).coord(c_idx,1)=0;
                etc_render_fsbrain.electrode(e_idx).coord(c_idx,2)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing.*(c_idx-1).*1;
                etc_render_fsbrain.electrode(e_idx).coord(c_idx,3)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing.*(e_idx-1).*1;

                etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                etc_render_fsbrain.aux2_point_name{count}=sprintf('%s_%d',etc_render_fsbrain.electrode(e_idx).name, c_idx);;
                count=count+1;
            end;            
        else
            for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                count=count+1;
            end;
        end;
    end;
    
    
    
    %initialize contact mask
    etc_render_fsbrain.electrode_mask=zeros(length(etc_render_fsbrain.electrode),size(etc_render_fsbrain.aux2_point_coords,1));
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            etc_render_fsbrain.electrode_mask(e_idx,count)=1;
            count=count+1;
        end;
    end;
    
    
    %update coordinates for electrode contacts
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
            count=count+1;
        end;
    end;
    
    
    %uncheck electrod contact locking
    set(handles.checkbox_electrode_contact_lock,'value',0);
    etc_render_fsbrain.electrode_contact_lock_flag=0;
    guidata(hObject, handles);
    
    count=0;
    for e_idx=1:etc_render_fsbrain.electrode_idx-1
        count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
    end;
    count=count+etc_render_fsbrain.electrode_contact_idx;
    
    surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
    click_vertex_vox=round(v(1:3))';
    
    etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
    
    vv=etc_render_fsbrain.orig_vertex_coords;
    dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
    [min_dist,min_dist_idx]=min(dist);
    surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    


                
    etc_render_fsbrain_handle('redraw');

else
    set(handles.listbox_electrode,'string',{});
    guidata(hObject, handles);
end;

%uncheck electrod contact locking
set(handles.checkbox_electrode_contact_lock,'value',0);
etc_render_fsbrain.electrode_contact_lock_flag=0;
guidata(hObject, handles);


if(isempty(etc_render_fsbrain.electrode))
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            if(strcmp(c{i}.Tag,'button_electrode_add'))
                c{i}.Enable='on';
            else
                c{i}.Enable='off';
            end;
        end;
    end;
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_electrode_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_electrode.
function listbox_electrode_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_electrode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_electrode
global etc_render_fsbrain

etc_render_fsbrain.electrode_idx=get(hObject,'Value');

hObject=findobj('tag','listbox_contact');
for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
    str{c_idx}=sprintf('%d',c_idx);
end;
set(handles.listbox_contact,'string',str);

etc_render_fsbrain.electrode_contact_idx=1;
hObject=findobj('tag','listbox_contact');
set(hObject,'Value',1);

guidata(hObject, handles);

%uncheck electrod contact locking
set(handles.checkbox_electrode_contact_lock,'value',0);
etc_render_fsbrain.electrode_contact_lock_flag=0;
guidata(hObject, handles);

count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');



% --- Executes during object creation, after setting all properties.
function listbox_electrode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_electrode_add.
function button_electrode_add_Callback(hObject, eventdata, handles)
% hObject    handle to button_electrode_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_electrode_del.
function button_electrode_del_Callback(hObject, eventdata, handles)
% hObject    handle to button_electrode_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    tmp=etc_render_fsbrain.aux2_point_coords.';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp-repmat(etc_render_fsbrain.electrode_contact_coord_now.',[1 size(tmp,2)]);
    end;
    tmp=(R*(mask.'.*tmp)).';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp+repmat(etc_render_fsbrain.electrode_contact_coord_now,[size(tmp,1),1]);
    end;
    
    etc_render_fsbrain.aux2_point_coords(find(mask(:)>eps))=tmp(find(mask(:)>eps));
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

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
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    tmp=etc_render_fsbrain.aux2_point_coords.';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp-repmat(etc_render_fsbrain.electrode_contact_coord_now.',[1 size(tmp,2)]);
    end;
    tmp=(R*(mask.'.*tmp)).';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp+repmat(etc_render_fsbrain.electrode_contact_coord_now,[size(tmp,1),1]);
    end;
    
    etc_render_fsbrain.aux2_point_coords(find(mask(:)>eps))=tmp(find(mask(:)>eps));
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_move_up.
function pushbutton_move_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_up (see GCBO)
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

dist=etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_move_left.
function pushbutton_move_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_left (see GCBO)
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

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(rr.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_move_right.
function pushbutton_move_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_right (see GCBO)
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

dist=etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(rr.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_move_down.
function pushbutton_move_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_down (see GCBO)
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

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');


function edit_rotate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotate as text
%        str2double(get(hObject,'String')) returns contents of edit_rotate as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
etc_render_fsbrain.register_rotate_angle=mm;

% --- Executes during object creation, after setting all properties.
function edit_rotate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rotate (see GCBO)
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


function edit_move_Callback(hObject, eventdata, handles)
% hObject    handle to edit_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_move as text
%        str2double(get(hObject,'String')) returns contents of edit_move as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
etc_render_fsbrain.register_translate_dist=mm./1e3;

% --- Executes during object creation, after setting all properties.
function edit_move_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_move (see GCBO)
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


% --- Executes on selection change in listbox_contact.
function listbox_contact_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_contact contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_contact
global etc_render_fsbrain

tmp=get(hObject,'Value');
if(tmp~=etc_render_fsbrain.electrode_contact_idx)
    etc_render_fsbrain.electrode_contact_idx=tmp;
    
    %uncheck electrod contact locking
    set(handles.checkbox_electrode_contact_lock,'value',0);
    etc_render_fsbrain.electrode_contact_lock_flag=0;
end;
guidata(hObject, handles);

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');


   
    
    

% --- Executes during object creation, after setting all properties.
function listbox_contact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_electrode_contact_lock.
function checkbox_electrode_contact_lock_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_electrode_contact_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_electrode_contact_lock
global etc_render_fsbrain

etc_render_fsbrain.electrode_contact_lock_flag=get(hObject,'Value');


% --- Executes on button press in pushbutton_move_more.
function pushbutton_move_more_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_more (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global etc_render_fsbrain
v1=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,:);
v2=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(end,:);
vv=v1-v2;
uu=vv.'./norm(vv);

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');




% --- Executes on button press in pushbutton_move_less.
function pushbutton_move_less_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_less (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
v1=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,:);
v2=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(end,:);
vv=v2-v1;
uu=vv.'./norm(vv);

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');

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


% --- Executes on button press in pushbutton_goto.
function pushbutton_goto_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_goto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain


%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord0=etc_render_fsbrain.aux2_point_coords(count,:); %current surface coord
surface_coord=etc_render_fsbrain.click_coord'; %clicked surface coord


mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat((surface_coord-surface_coord0),[size(etc_render_fsbrain.aux2_point_coords,1),1]);

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.orig_vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
