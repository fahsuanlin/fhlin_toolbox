function varargout = etc_render_fsbrain_subject(varargin)
% ETC_RENDER_FSBRAIN_SUBJECT MATLAB code for etc_render_fsbrain_subject.fig
%      ETC_RENDER_FSBRAIN_SUBJECT, by itself, creates a new ETC_RENDER_FSBRAIN_SUBJECT or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_SUBJECT returns the handle to a new ETC_RENDER_FSBRAIN_SUBJECT or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_SUBJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_SUBJECT.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_SUBJECT('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_SUBJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_subject_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_subject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_subject

% Last Modified by GUIDE v2.5 21-Mar-2020 17:29:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_subject_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_subject_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_subject is made visible.
function etc_render_fsbrain_subject_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_subject (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_subject
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_subject wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_render_fsbrain

if(isfield(etc_render_fsbrain,'subjects_dir'))
    set(handles.text_subjectsdir,'string',sprintf('%s',etc_render_fsbrain.subjects_dir));
elseif(~isempty(getenv('SUBJECTS_DIR')))
    set(handles.text_subjectsdir,'string',sprintf('%s',getenv('SUBJECTS_DIR')));
    etc_render_fsbrain.subjects_dir=getenv('SUBJECTS_DIR');
end;


d=dir(sprintf('%s',getenv('SUBJECTS_DIR')));
str={};
count=1;
for idx=1:length(d)
    if(~strcmp(d(idx).name,'.'))
        if(~strcmp(d(idx).name,'.'))
            if(d(idx).name(1)~='.')
                str{count}=d(idx).name;
                if(strcmp(str{count},etc_render_fsbrain.subject))
                    subject_idx=count;
                end;
                count=count+1;
            end;
        end;
    end;
end;
set(handles.listbox_subject,'string',str);
set(handles.listbox_subject,'value',subject_idx);
guidata(hObject, handles);


d=dir(sprintf('%s/%s/mri',getenv('SUBJECTS_DIR'),etc_render_fsbrain.subject));
str={};
count=1;
for idx=1:length(d)
    if(~strcmp(d(idx).name,'.'))
        if(~strcmp(d(idx).name,'.'))
            if(d(idx).name(1)~='.')
                str{count}=d(idx).name;
                [dummy,ff,stem]=fileparts(etc_render_fsbrain.vol.fspec);
                if(strcmp(str{count},sprintf('%s%s',ff,stem)))
                    vol_idx=count;
                end;
                count=count+1;
            end;
        end;
    end;
end;
set(handles.listbox_vol,'string',str);
set(handles.listbox_vol,'value',vol_idx);
guidata(hObject, handles);

d=dir(sprintf('%s/%s/surf',getenv('SUBJECTS_DIR'),etc_render_fsbrain.subject));
str={};
count=1;
for idx=1:length(d)
    if(~strcmp(d(idx).name,'.'))
        if(~strcmp(d(idx).name,'.'))
            if(d(idx).name(1)~='.')
                str{count}=d(idx).name;
                if(strcmp(str{count},sprintf('%s.%s',etc_render_fsbrain.hemi,etc_render_fsbrain.surf)))
                    surf_idx=count;
                end;
                count=count+1;
            end;
        end;
    end;
end;
set(handles.listbox_surf,'string',str);
set(handles.listbox_surf,'value',surf_idx);
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_subject_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_subjectsdir.
function button_subjectsdir_Callback(hObject, eventdata, handles)
% hObject    handle to button_subjectsdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
[baseName] = uigetdir();
if(baseName >0)
    set(handles.text_subjectsdir,'string',baseName);
    etc_render_fsbrain.subjects_dir=baseName;
    fprintf('$SUBJECTS_DIR = %s\n',baseName);
end;
return;
% --- Executes on selection change in listbox_subject.
function listbox_subject_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_subject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_subject


% --- Executes during object creation, after setting all properties.
function listbox_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_surf.
function listbox_surf_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_surf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_surf contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_surf

global etc_render_fsbrain;

try
    contents = cellstr(get(hObject,'String'));
    [dummy,hemi,surf]=fileparts(contents{get(hObject,'Value')});
    etc_render_fsbrain.hemi=hemi;
    etc_render_fsbrain.surf=surf(2:end);
    
    etc_render_fsbrain.subjects_dir=getenv('SUBJECTS_DIR');
    file_surf=sprintf('%s/%s/surf/%s.%s',etc_render_fsbrain.subjects_dir,etc_render_fsbrain.subject,etc_render_fsbrain.hemi,etc_render_fsbrain.surf);
    fprintf('reading [%s]...\n',file_surf);
    
    [etc_render_fsbrain.vertex_coords, etc_render_fsbrain.faces] = read_surf(file_surf);
    
    etc_render_fsbrain.vertex_coords_hemi=etc_render_fsbrain.vertex_coords;
    etc_render_fsbrain.faces_hemi=etc_render_fsbrain.faces;
    
    file_orig_surf=sprintf('%s/%s/surf/%s.%s',etc_render_fsbrain.subjects_dir,etc_render_fsbrain.subject,etc_render_fsbrain.hemi,'orig');
    fprintf('reading orig [%s]...\n',file_orig_surf);
    
    [orig_vertex_coords, orig_faces] = read_surf(file_orig_surf);
    
    etc_render_fsbrain.orig_vertex_coords_hemi=orig_vertex_coords;
    etc_render_fsbrain.orig_faces_hemi=orig_faces;
    
    %loading vertices/faces for both hemispheres.
    for hemi_idx=1:2
        switch hemi_idx
            case 1
                hemi_str='lh';
            case 2
                hemi_str='rh';
        end;
        
        file_surf=sprintf('%s/%s/surf/%s.%s',etc_render_fsbrain.subjects_dir,etc_render_fsbrain.subject,hemi_str,etc_render_fsbrain.surf);
        %fprintf('reading [%s]...\n',file_surf);
        [hemi_vertex_coords{hemi_idx}, hemi_faces{hemi_idx}] = read_surf(file_surf);
        
        file_orig_surf=sprintf('%s/%s/surf/%s.%s',etc_render_fsbrain.subjects_dir,etc_render_fsbrain.subject,hemi_str,'orig');
        %fprintf('reading orig [%s]...\n',file_orig_surf);
        [hemi_orig_vertex_coords{hemi_idx}, hemi_orig_faces{hemi_idx}] = read_surf(file_orig_surf);
    end;
    
    
    file_curv=sprintf('%s/%s/surf/%s.%s',etc_render_fsbrain.subjects_dir,etc_render_fsbrain.subject,etc_render_fsbrain.hemi,'curv');
    [etc_render_fsbrain.curv]=read_curv(file_curv);
    etc_render_fsbrain.curv_hemi=etc_render_fsbrain.curv;
    
    etc_render_fsbrain_handle('redraw');
    etc_render_fsbrain_handle('draw_pointer','surface_coord',[],'min_dist_idx',[],'click_vertex_vox',[]);

    xmin=min(etc_render_fsbrain.vertex_coords(:,1));
    xmax=max(etc_render_fsbrain.vertex_coords(:,1));
    ymin=min(etc_render_fsbrain.vertex_coords(:,2));
    ymax=max(etc_render_fsbrain.vertex_coords(:,2));
    zmin=min(etc_render_fsbrain.vertex_coords(:,3));
    zmax=max(etc_render_fsbrain.vertex_coords(:,3));
    set(etc_render_fsbrain.brain_axis,'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax]);
    axis off vis3d equal tight;
    
catch ME
end;
    

% --- Executes during object creation, after setting all properties.
function listbox_surf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_surf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_vol.
function listbox_vol_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_vol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_vol
global etc_render_fsbrain;

try
    contents = cellstr(get(hObject,'String'));
    vol_name=contents{get(hObject,'Value')};
    fn=sprintf('%s/%s/mri/%s',etc_render_fsbrain.subjects_dir,etc_render_fsbrain.subject,vol_name);
    fprintf('loading [%s]...\n',fn);
    etc_render_fsbrain.vol=MRIread(fn);

    etc_render_fsbrain_handle('redraw');
    etc_render_fsbrain_handle('draw_pointer','surface_coord',[],'min_dist_idx',[],'click_vertex_vox',[]);
catch ME
end;
    

% --- Executes during object creation, after setting all properties.
function listbox_vol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_vol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
