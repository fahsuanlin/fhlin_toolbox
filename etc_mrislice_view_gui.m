function varargout = etc_mrislice_view_gui(varargin)
% ETC_MRISLICE_VIEW_GUI MATLAB code for etc_mrislice_view_gui.fig
%      ETC_MRISLICE_VIEW_GUI, by itself, creates a new ETC_MRISLICE_VIEW_GUI or raises the existing
%      singleton*.
%
%      H = ETC_MRISLICE_VIEW_GUI returns the handle to a new ETC_MRISLICE_VIEW_GUI or the handle to
%      the existing singleton*.
%
%      ETC_MRISLICE_VIEW_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_MRISLICE_VIEW_GUI.M with the given input arguments.
%
%      ETC_MRISLICE_VIEW_GUI('Property','Value',...) creates a new ETC_MRISLICE_VIEW_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_mrislice_view_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_mrislice_view_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_mrislice_view_gui

% Last Modified by GUIDE v2.5 07-Oct-2017 00:44:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_mrislice_view_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_mrislice_view_gui_OutputFcn, ...
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


% --- Executes just before etc_mrislice_view_gui is made visible.
function etc_mrislice_view_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_mrislice_view_gui (see VARARGIN)

% Choose default command line output for etc_mrislice_view_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_mrislice_view_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etc_mrislice_view_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider_vol_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to slider_vol_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_mrislice_view;

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

etc_mrislice_view.vol_alpha(f_idx)=get(hObject,'Value');
set(etc_mrislice_view.h_vol(f_idx),'facealpha',etc_mrislice_view.vol_alpha(f_idx));

set(hObject,'enable','on');


% --- Executes during object creation, after setting all properties.
function slider_vol_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_vol_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
global etc_mrislice_view;

f_idx=etc_mrislice_view.f_idx;

set(hObject,'value',etc_mrislice_view.vol_alpha(f_idx));


% --- Executes on button press in pushbutton_rotate_cc.
function pushbutton_rotate_cc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_mrislice_view

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

figure(etc_mrislice_view.fig_vol(f_idx));
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);

theta=(etc_mrislice_view.rotate_angle(f_idx)).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix

d=[etc_mrislice_view.hsp(f_idx).XData(:) etc_mrislice_view.hsp(f_idx).YData(:)  etc_mrislice_view.hsp(f_idx).ZData(:)]'; 
d=R*d;
etc_mrislice_view.hsp(f_idx).XData=reshape(d(1,:),size(etc_mrislice_view.hsp(f_idx).XData));
etc_mrislice_view.hsp(f_idx).YData=reshape(d(2,:),size(etc_mrislice_view.hsp(f_idx).YData));
etc_mrislice_view.hsp(f_idx).ZData=reshape(d(3,:),size(etc_mrislice_view.hsp(f_idx).ZData));

etc_mrislice_view_handle('redraw',f_idx);

set(hObject,'enable','on');


% --- Executes on button press in pushbutton_rotate_c.
function pushbutton_rotate_c_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_mrislice_view

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

figure(etc_mrislice_view.fig_vol(f_idx));
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);

theta=-(etc_mrislice_view.rotate_angle(f_idx)).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix

d=[etc_mrislice_view.hsp(f_idx).XData(:) etc_mrislice_view.hsp(f_idx).YData(:)  etc_mrislice_view.hsp(f_idx).ZData(:)]'; 
d=R*d;
etc_mrislice_view.hsp(f_idx).XData=reshape(d(1,:),size(etc_mrislice_view.hsp(f_idx).XData));
etc_mrislice_view.hsp(f_idx).YData=reshape(d(2,:),size(etc_mrislice_view.hsp(f_idx).YData));
etc_mrislice_view.hsp(f_idx).ZData=reshape(d(3,:),size(etc_mrislice_view.hsp(f_idx).ZData));

etc_mrislice_view_handle('redraw',f_idx);

set(hObject,'enable','on');



function edit_rotate_angle_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotate_angle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotate_angle as text
%        str2double(get(hObject,'String')) returns contents of edit_rotate_angle as a double
global etc_mrislice_view

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

mm=str2double(get(hObject,'string'));
etc_mrislice_view.rotate_angle=mm;


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
global etc_mrislice_view;

f_idx=etc_mrislice_view.f_idx;

if(isfield(etc_mrislice_view,'rotate_angle'))
    if(isempty(etc_mrislice_view.rotate_angle(f_idx))|(etc_mrislice_view.rotate_angle(f_idx)<eps))
        etc_mrislice_view.rotate_angle(f_idx)=3; %default: 3 degrees
    end;
else
    etc_mrislice_view.rotate_angle(f_idx)=3; %default: 3 degrees
end;
set(hObject,'value',etc_mrislice_view.rotate_angle);
set(hObject,'string',sprintf('%1.0f',etc_mrislice_view.rotate_angle(f_idx)));



% --- Executes on button press in pushbutton_translate_up.
function pushbutton_translate_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_mrislice_view

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

figure(etc_mrislice_view.fig_vol(f_idx));
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=1.*etc_mrislice_view.translate_dist(f_idx);

d=[etc_mrislice_view.hsp(f_idx).XData(:) etc_mrislice_view.hsp(f_idx).YData(:)  etc_mrislice_view.hsp(f_idx).ZData(:)]; 
d=d+repmat(uu.'.*dist,[size(d,1),1]);

etc_mrislice_view.hsp(f_idx).XData=reshape(d(:,1),size(etc_mrislice_view.hsp(f_idx).XData));
etc_mrislice_view.hsp(f_idx).YData=reshape(d(:,2),size(etc_mrislice_view.hsp(f_idx).YData));
etc_mrislice_view.hsp(f_idx).ZData=reshape(d(:,3),size(etc_mrislice_view.hsp(f_idx).ZData));

etc_mrislice_view_handle('redraw',f_idx)
set(hObject,'enable','on');

% --- Executes on button press in pushbutton_translate_down.
function pushbutton_translate_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_mrislice_view

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

figure(etc_mrislice_view.fig_vol(f_idx));
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=-1.*etc_mrislice_view.translate_dist(f_idx);

d=[etc_mrislice_view.hsp(f_idx).XData(:) etc_mrislice_view.hsp(f_idx).YData(:)  etc_mrislice_view.hsp(f_idx).ZData(:)]; 
d=d+repmat(uu.'.*dist,[size(d,1),1]);

etc_mrislice_view.hsp(f_idx).XData=reshape(d(:,1),size(etc_mrislice_view.hsp(f_idx).XData));
etc_mrislice_view.hsp(f_idx).YData=reshape(d(:,2),size(etc_mrislice_view.hsp(f_idx).YData));
etc_mrislice_view.hsp(f_idx).ZData=reshape(d(:,3),size(etc_mrislice_view.hsp(f_idx).ZData));

etc_mrislice_view_handle('redraw',f_idx);
set(hObject,'enable','on');


% --- Executes on button press in pushbutton_translate_left.
function pushbutton_translate_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_mrislice_view

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

figure(etc_mrislice_view.fig_vol(f_idx));
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=-1.*etc_mrislice_view.translate_dist(f_idx);

d=[etc_mrislice_view.hsp(f_idx).XData(:) etc_mrislice_view.hsp(f_idx).YData(:)  etc_mrislice_view.hsp(f_idx).ZData(:)]; 
d=d+repmat(rr.'.*dist,[size(d,1),1]);

etc_mrislice_view.hsp(f_idx).XData=reshape(d(:,1),size(etc_mrislice_view.hsp(f_idx).XData));
etc_mrislice_view.hsp(f_idx).YData=reshape(d(:,2),size(etc_mrislice_view.hsp(f_idx).YData));
etc_mrislice_view.hsp(f_idx).ZData=reshape(d(:,3),size(etc_mrislice_view.hsp(f_idx).ZData));

etc_mrislice_view_handle('redraw',f_idx);

set(hObject,'enable','on');


% --- Executes on button press in pushbutton_translate_right.
function pushbutton_translate_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_translate_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_mrislice_view

set(hObject,'enable','off');

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

figure(etc_mrislice_view.fig_vol(f_idx));
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=1.*etc_mrislice_view.translate_dist(f_idx);

d=[etc_mrislice_view.hsp(f_idx).XData(:) etc_mrislice_view.hsp(f_idx).YData(:)  etc_mrislice_view.hsp(f_idx).ZData(:)]; 
d=d+repmat(rr.'.*dist,[size(d,1),1]);

etc_mrislice_view.hsp(f_idx).XData=reshape(d(:,1),size(etc_mrislice_view.hsp(f_idx).XData));
etc_mrislice_view.hsp(f_idx).YData=reshape(d(:,2),size(etc_mrislice_view.hsp(f_idx).YData));
etc_mrislice_view.hsp(f_idx).ZData=reshape(d(:,3),size(etc_mrislice_view.hsp(f_idx).ZData));

etc_mrislice_view_handle('redraw',f_idx);

set(hObject,'enable','on');


function edit_translate_dist_Callback(hObject, eventdata, handles)
% hObject    handle to edit_translate_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_translate_dist as text
%        str2double(get(hObject,'String')) returns contents of edit_translate_dist as a double
global etc_mrislice_view

f_idx=ismember(etc_mrislice_view.fig_gui,gcf);

mm=str2double(get(hObject,'string'));
etc_mrislice_view.translate_dist(f_idx)=mm;

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

global etc_mrislice_view;

f_idx=etc_mrislice_view.f_idx;

if(isfield(etc_mrislice_view,'translate_dist'))
    if(isempty(etc_mrislice_view.translate_dist(f_idx))|(etc_mrislice_view.translate_dist(f_idx)<eps))
        etc_mrislice_view.translate_dist(f_idx)=1; %default: 1 mm
    end;
else
    etc_mrislice_view.translate_dist(f_idx)=1; %default: 1 mm
end;
set(hObject,'value',etc_mrislice_view.translate_dist(f_idx));
set(hObject,'string',sprintf('%1.0f',etc_mrislice_view.translate_dist(f_idx).*1));
