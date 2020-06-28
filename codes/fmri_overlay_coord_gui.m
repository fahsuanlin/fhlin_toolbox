function varargout = fmri_overlay_coord_gui(varargin)
% FMRI_OVERLAY_COORD_GUI MATLAB code for fmri_overlay_coord_gui.fig
%      FMRI_OVERLAY_COORD_GUI, by itself, creates a new FMRI_OVERLAY_COORD_GUI or raises the existing
%      singleton*.
%
%      H = FMRI_OVERLAY_COORD_GUI returns the handle to a new FMRI_OVERLAY_COORD_GUI or the handle to
%      the existing singleton*.
%
%      FMRI_OVERLAY_COORD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FMRI_OVERLAY_COORD_GUI.M with the given input arguments.
%
%      FMRI_OVERLAY_COORD_GUI('Property','Value',...) creates a new FMRI_OVERLAY_COORD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fmri_overlay_coord_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fmri_overlay_coord_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fmri_overlay_coord_gui

% Last Modified by GUIDE v2.5 29-Dec-2017 13:52:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fmri_overlay_coord_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @fmri_overlay_coord_gui_OutputFcn, ...
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


% --- Executes just before fmri_overlay_coord_gui is made visible.
function fmri_overlay_coord_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fmri_overlay_coord_gui (see VARARGIN)

% Choose default command line output for fmri_overlay_coord_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

if(~isempty(click_vertex_vox))
    h=findobj('tag','edit_vox_x');
    set(h,'String',num2str(click_vertex_vox(1),'%1.0f'));
    h=findobj('tag','edit_vox_y');
    set(h,'String',num2str(click_vertex_vox(2),'%1.0f'));
    h=findobj('tag','edit_vox_z');
    set(h,'String',num2str(click_vertex_vox(3),'%1.0f'));
else
    h=findobj('tag','edit_vox_x');
    set(h,'String','');
    h=findobj('tag','edit_vox_y');
    set(h,'String','');
    h=findobj('tag','edit_vox_z');
    set(h,'String','');   
end;


if(~isempty(click_vertex_point_mni))
    h=findobj('tag','edit_mni_x');
    set(h,'String',num2str(click_vertex_point_mni(1),'%1.0f'));
    h=findobj('tag','edit_mni_y');
    set(h,'String',num2str(click_vertex_point_mni(2),'%1.0f'));
    h=findobj('tag','edit_mni_z');
    set(h,'String',num2str(click_vertex_point_mni(3),'%1.0f'));
else
    h=findobj('tag','edit_mni_x');
    set(h,'String','');
    h=findobj('tag','edit_mni_y');
    set(h,'String','');
    h=findobj('tag','edit_mni_z');
    set(h,'String','');   
end;

if(~isempty(click_vertex_point_tal))
    h=findobj('tag','edit_tal_x');
    set(h,'String',num2str(click_vertex_point_tal(1),'%1.0f'));
    h=findobj('tag','edit_tal_y');
    set(h,'String',num2str(click_vertex_point_tal(2),'%1.0f'));
    h=findobj('tag','edit_tal_z');
    set(h,'String',num2str(click_vertex_point_tal(3),'%1.0f'));
else
    h=findobj('tag','edit_tal_x');
    set(h,'String','');
    h=findobj('tag','edit_tal_y');
    set(h,'String','');
    h=findobj('tag','edit_tal_z');
    set(h,'String','');
end;
    


% UIWAIT makes fmri_overlay_coord_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fmri_overlay_coord_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_mni_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mni_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mni_z as text
%        str2double(get(hObject,'String')) returns contents of edit_mni_z as a double
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_point_mni))
    %update MNE coordnate
    click_vertex_point_mni(3)=str2double(get(hObject,'String'));
    
    
    %update Talairach coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);  
    
    %update vox index
    click_vertex_vox=inv(fmri_under_vol.vox2ras)*inv(fmri_talxfm)*[click_vertex_point_mni(:)' 1]';
    click_vertex_vox=click_vertex_vox(1:3)';
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
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
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_point_mni))
    %update MNE coordnate
    click_vertex_point_mni(2)=str2double(get(hObject,'String'));
    
    
    %update Talairach coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);  
    
    %update vox index
    click_vertex_vox=inv(fmri_under_vol.vox2ras)*inv(fmri_talxfm)*[click_vertex_point_mni(:)' 1]';
    click_vertex_vox=click_vertex_vox(1:3)';
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
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
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_point_mni))
    %update MNE coordnate
    click_vertex_point_mni(1)=str2double(get(hObject,'String'));
    
    
    %update Talairach coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);  
    
    %update vox index
    click_vertex_vox=inv(fmri_under_vol.vox2ras)*inv(fmri_talxfm)*[click_vertex_point_mni(:)' 1]';
    click_vertex_vox=click_vertex_vox(1:3)';
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
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
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_vox))
    %update MNE coordnate
    click_vertex_vox(1)=str2double(get(hObject,'String'));
    
    %update MNI coordnate
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    
    %update Talairach coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);  
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
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
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_vox))
    %update MNE coordnate
    click_vertex_vox(2)=str2double(get(hObject,'String'));
    
    %update MNI coordnate
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    
    %update Talairach coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);  
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
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
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_vox))
    %update MNE coordnate
    click_vertex_vox(3)=str2double(get(hObject,'String'));
    
    %update MNI coordnate
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    
    %update Talairach coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);  
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
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



function edit_tal_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tal_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tal_x as text
%        str2double(get(hObject,'String')) returns contents of edit_tal_x as a double
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_point_tal))
    %update MNE coordnate
    click_vertex_point_tal(1)=str2double(get(hObject,'String'));
    
    %update MNI coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_mni = inv(T_mni2tal) * [click_vertex_point_tal(:)' 1]';
    click_vertex_point_mni=click_vertex_point_mni(1:3);  
    
    %update vox index
    click_vertex_vox=inv(fmri_under_vol.vox2ras)*inv(fmri_talxfm)*[click_vertex_point_mni(:)' 1]';
    click_vertex_vox=click_vertex_vox(1:3)';
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
end;

% --- Executes during object creation, after setting all properties.
function edit_tal_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tal_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tal_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tal_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tal_y as text
%        str2double(get(hObject,'String')) returns contents of edit_tal_y as a double
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_point_mni))
    %update MNE coordnate
    click_vertex_point_tal(2)=str2double(get(hObject,'String'));
    
    %update MNI coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_mni = inv(T_mni2tal) * [click_vertex_point_tal(:)' 1]';
    click_vertex_point_mni=click_vertex_point_mni(1:3);  
    
    %update vox index
    click_vertex_vox=inv(fmri_under_vol.vox2ras)*inv(fmri_talxfm)*[click_vertex_point_mni(:)' 1]';
    click_vertex_vox=click_vertex_vox(1:3)';
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
end;

% --- Executes during object creation, after setting all properties.
function edit_tal_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tal_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_tal_z_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tal_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tal_z as text
%        str2double(get(hObject,'String')) returns contents of edit_tal_z as a double
global fmri_under_vol;
global fmri_pointer;
global fmri_xfm;
global fmri_talxfm;

if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    click_vertex_point_tal=click_vertex_point_tal(1:3);
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(~isempty(click_vertex_point_mni))
    %update MNE coordnate
    click_vertex_point_tal(3)=str2double(get(hObject,'String'));
    
    %update MNI coordnate
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_mni = inv(T_mni2tal) * [click_vertex_point_tal(:)' 1]';
    click_vertex_point_mni=click_vertex_point_mni(1:3);  
    
    %update vox index
    click_vertex_vox=inv(fmri_under_vol.vox2ras)*inv(fmri_talxfm)*[click_vertex_point_mni(:)' 1]';
    click_vertex_vox=click_vertex_vox(1:3)';
    
    %update fmri_pointer
    fmri_pointer=fmri_xfm*[click_vertex_vox(:)' 1]';
    fmri_pointer=round(fmri_pointer(1:3));
    
    fmri_overlay_handle('draw_pointer');
end;

% --- Executes during object creation, after setting all properties.
function edit_tal_z_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tal_z (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
