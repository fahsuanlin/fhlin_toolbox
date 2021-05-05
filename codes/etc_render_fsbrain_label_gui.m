function varargout = etc_render_fsbrain_label_gui(varargin)
% ETC_RENDER_FSBRAIN_LABEL_GUI MATLAB code for etc_render_fsbrain_label_gui.fig
%      ETC_RENDER_FSBRAIN_LABEL_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_LABEL_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_LABEL_GUI returns the handle to a new ETC_RENDER_FSBRAIN_LABEL_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_LABEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_LABEL_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_LABEL_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_LABEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_label_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_label_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_label_gui

% Last Modified by GUIDE v2.5 18-Mar-2019 11:42:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_label_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_label_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_label_gui is made visible.
function etc_render_fsbrain_label_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_label_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_label_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_label_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
    fprintf('annotated label loaded...\n');
    %set(handles.listbox_label,'value',4);
    set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
    set(handles.listbox_label,'min',0);
    set(handles.listbox_label,'max',max([2 length(etc_render_fsbrain.label_ctab.struct_names)]));
    set(handles.listbox_label,'value',[]);
    guidata(hObject, handles);
end;

set(hObject,'KeyPressFcn',@etc_render_fsbrain_kbhandle);




% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_label_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_label.
function listbox_label_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_label contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_label

global etc_render_fsbrain;
try
    if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
        contents = cellstr(get(hObject,'String'));
        select_idx=get(hObject,'Value');
        
        etc_render_fsbrain.label_register(select_idx)=1-etc_render_fsbrain.label_register(select_idx);
        set(hObject,'Value',find(etc_render_fsbrain.label_register));
        %etc_render_fsbrain.label_register(:)=0;
        %etc_render_fsbrain.label_register(select_idx)=1;
        
        try
            %for ss=1:length(select_idx)
            for ss=1:length(etc_render_fsbrain.label_register)    
                %label_number=etc_render_fsbrain.label_ctab.table(select_idx(ss),5);
                label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                vidx=find((etc_render_fsbrain.label_value)==label_number);
                %figure(etc_render_fsbrain.fig_brain);
                
%fprintf('%s: [%d] =%d\n',mat2str(etc_render_fsbrain.label_register),ss,etc_render_fsbrain.label_register(select_idx(ss)));

                %if(etc_render_fsbrain.label_register(select_idx(ss))==1)
                if(etc_render_fsbrain.label_register(ss)==1)
                    %cc=etc_render_fsbrain.label_ctab.table(select_idx(ss),1:3)./255;
                    cc=etc_render_fsbrain.label_ctab.table(ss,1:3)./255;
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
                    %etc_render_fsbrain.label_register(select_idx(ss))=1;
                else
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                    %etc_render_fsbrain.label_register(select_idx(ss))=0;
                    
                    %v=setdiff(select_idx,select_idx(ss));
                    %set(hObject,'Value',v);
                end;

%                 if(etc_render_fsbrain.label_register(select_idx(ss))==0)
%                     cc=etc_render_fsbrain.label_ctab.table(select_idx(ss),1:3)./255;
%                     etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
%                     etc_render_fsbrain.label_register(select_idx(ss))=1;
%                 else
%                     etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
%                     etc_render_fsbrain.label_register(select_idx(ss))=0;
%                     
%                     v=setdiff(select_idx,select_idx(ss));
%                     set(hObject,'Value',v);
%                 end;
            end;

            figure(etc_render_fsbrain.fig_label_gui);
            
        catch ME
        end;
    end;
catch ME
end;

% --- Executes during object creation, after setting all properties.
function listbox_label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listbox_label and none of its controls.
function listbox_label_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_label (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

eventdata.Key;
if(strcmp(eventdata.Key,'backspace')|strcmp(eventdata.Key,'delete'))
    contents = cellstr(get(hObject,'String'));
    select_idx=get(hObject,'Value');
    
    if(~isempty(select_idx))
        try
            
            %delete highlighted label
            if(isfield(etc_render_fsbrain,'label_h'))
                if(~isempty(etc_render_fsbrain.label_h))
                    delete(etc_render_fsbrain.label_h);
                    etc_render_fsbrain.label_h=[];
                    
                    etc_render_fsbrain.label_idx=[];

                    etc_render_fsbrain.h.FaceVertexCData=etc_render_fsbrain.fvcdata_old;
                end;
            end;
            
            label_number=etc_render_fsbrain.label_ctab.table(select_idx,5);
            vidx=find(etc_render_fsbrain.label_value==label_number);
            etc_render_fsbrain.label_value(vidx)=0;
            
            
            etc_render_fsbrain.label_ctab.numEntries=etc_render_fsbrain.label_ctab.numEntries-1;
            etc_render_fsbrain.label_ctab.table(select_idx,:)=[];
            etc_render_fsbrain.label_ctab.struct_names(select_idx)=[];
            
            
            if(~isempty(etc_render_fsbrain.label_h))
                delete(etc_render_fsbrain.label_h(:));
                etc_render_fsbrain.label_h=[];
            end;
            
            
            set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
            if(etc_render_fsbrain.label_ctab.numEntries>0)
                if(select_idx>1)
                    set(handles.listbox_label,'value',select_idx-1);
                    etc_render_fsbrain.label_select_idx=select_idx-1;
                else
                    set(handles.listbox_label,'value',select_idx);
                    etc_render_fsbrain.label_select_idx=select_idx;
                end;
            else
                set(handles.listbox_label,'value',[]);
            end;
            guidata(hObject, handles);
            
            figure(etc_render_fsbrain.fig_label_gui);
            
        catch ME
        end;
    end;
end;
