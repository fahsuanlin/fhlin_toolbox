function varargout = etc_trace_montage_gui(varargin)
% ETC_TRACE_MONTAGE_GUI MATLAB code for etc_trace_montage_gui.fig
%      ETC_TRACE_MONTAGE_GUI, by itself, creates a new ETC_TRACE_MONTAGE_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_MONTAGE_GUI returns the handle to a new ETC_TRACE_MONTAGE_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_MONTAGE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_MONTAGE_GUI.M with the given input arguments.
%
%      ETC_TRACE_MONTAGE_GUI('Property','Value',...) creates a new ETC_TRACE_MONTAGE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_montage_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_montage_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_montage_gui

% Last Modified by GUIDE v2.5 29-May-2018 17:21:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_montage_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_montage_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_montage_gui is made visible.
function etc_trace_montage_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_montage_gui (see VARARGIN)

% Choose default command line output for etc_trace_montage_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_trace_montage_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_trace_obj;

if(~isempty(etc_trace_obj.montage))
    fprintf('montage loaded...\n');
    str={};
    for idx=1:length(etc_trace_obj.montage)
        str{idx}=etc_trace_obj.montage{idx}.name;
    end;
    set(handles.listbox_montage,'string',str);
    guidata(hObject, handles);
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_montage_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_load_montage.
function pushbutton_load_montage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

[filename, pathname, filterindex] = uigetfile({'*.mat','montage Matlab file'}, 'Pick a montage definition data file');
if(filename>0)
    try
        montage=[];
        load(sprintf('%s/%s',pathname,filename));
        
        for idx=1:length(montage)
            found=0;
            for ii=1:length(etc_trace_obj.montage)
                if(strcmp(etc_trace_obj.montage{ii}.name,montage{idx}.name))
                    found=1;
                end;
            end;
            if(~found)
                etc_trace_obj.montage{end+1}=montage{idx};
                
                %creating montage matrix
                M=[];
                ecg_idx=[];
                for idx=1:size(etc_trace_obj.montage{end}.config,1)
                    m=zeros(1,length(etc_trace_obj.ch_names));
                    if(~isempty(etc_trace_obj.montage{end}.config{idx,1}))
                        m(find(strcmp(lower(etc_trace_obj.ch_names),lower(etc_trace_obj.montage{end}.config{idx,1}))))=1;
                        if((strcmp(lower(etc_trace_obj.montage{end}.config{idx,1}),'ecg')|strcmp(lower(etc_trace_obj.montage{end}.config{idx,1}),'ekg')))
                            ecg_idx=union(ecg_idx,idx);
                        end;                            
                    end;
                    if(~isempty(etc_trace_obj.montage{end}.config{idx,2}))
                        m(find(strcmp(lower(etc_trace_obj.ch_names),lower(etc_trace_obj.montage{end}.config{idx,2}))))=-1;;
                        if((strcmp(lower(etc_trace_obj.montage{end}.config{idx,2}),'ecg')|strcmp(lower(etc_trace_obj.montage{end}.config{idx,2}),'ekg')))
                            ecg_idx=union(ecg_idx,idx);
                        end;
                    end;
                    M=cat(1,M,m);
                end;
                M(end+1,end+1)=1;
                
                etc_trace_obj.montage{end}.config_matrix=M;
                
                S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
                S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
                etc_trace_obj.scaling{end+1}=S;
            end;
        end;
        
        str={};
        for idx=1:length(etc_trace_obj.montage)
            str{idx}=etc_trace_obj.montage{idx}.name;
        end;
        
        obj=findobj('Tag','listbox_montage');
        set(obj,'String',str);
    catch ME
    end;
end;

% --- Executes on selection change in listbox_montage.
function listbox_montage_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_montage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_montage
global etc_trace_obj;

etc_trace_obj.montage_idx=get(hObject,'Value');
etc_trace_obj.trace_selected_idx=[];

            etc_trace_handle('redraw');
%            etc_trace_handle('bd','time_idx',etc_trace_obj.trigger_time_idx);

% --- Executes during object creation, after setting all properties.
function listbox_montage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
