function varargout = etc_trace_info_gui(varargin)
% ETC_TRACE_INFO_GUI MATLAB code for etc_trace_info_gui.fig
%      ETC_TRACE_INFO_GUI, by itself, creates a new ETC_TRACE_INFO_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_INFO_GUI returns the handle to a new ETC_TRACE_INFO_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_INFO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_INFO_GUI.M with the given input arguments.
%
%      ETC_TRACE_INFO_GUI('Property','Value',...) creates a new ETC_TRACE_INFO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_info_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_info_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_info_gui

% Last Modified by GUIDE v2.5 23-Jun-2020 01:24:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_info_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_info_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_info_gui is made visible.
function etc_trace_info_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_info_gui (see VARARGIN)

% Choose default command line output for etc_trace_info_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global etc_trace_obj;

set(handles.text_info_datasize,'String',mat2str(size(etc_trace_obj.data)));
set(handles.text_info_fs,'String',mat2str(etc_trace_obj.fs));
set(handles.text_info_time_begin,'String',mat2str(etc_trace_obj.time_begin));
set(handles.listbox_info_chnames,'String',etc_trace_obj.ch_names);

%main data
if(isempty(etc_trace_obj.all_data_name))
    set(handles.listbox_info_data,'String','[none]');
    set(handles.listbox_info_data,'Value',1);
else
    set(handles.listbox_info_data,'String',etc_trace_obj.all_data_name);
    set(handles.listbox_info_data,'Value',etc_trace_obj.all_data_main_idx);
end;

%aux. data
set(handles.listbox_info_auxdata,'String',etc_trace_obj.all_data_name);
set(handles.listbox_info_auxdata,'Min',0);
set(handles.listbox_info_auxdata,'Max',length(etc_trace_obj.all_data_name));
if(length(find(etc_trace_obj.all_data_aux_idx))>0)
     set(handles.listbox_info_auxdata,'Value',find(etc_trace_obj.all_data_aux_idx));
end;

str={};
try
    str=unique(etc_trace_obj.trigger.event);
    if(~iscell(str))
        for i=1:length(ev) ev_str{i}=num2str(ev(i)); end;
        str=ev_str;
    end;
catch ME
end;
set(handles.listbox_info_trigger,'String',str);
% UIWAIT makes etc_trace_info_gui wait for user response (see UIRESUME)
% uiwait(handles.figure_trace_obj_info);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_info_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_info_ok.
function pushbutton_info_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_info_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.figure_trace_obj_info);

% --- Executes on selection change in listbox_info_chnames.
function listbox_info_chnames_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_chnames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_chnames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_chnames
global etc_trace_obj;

str=get(handles.listbox_info_chnames,'String');
if(~isempty(str))
    str=str{get(handles.listbox_info_chnames,'Value')};
    IndexC = strcmp(str,etc_trace_obj.ch_names);
    
    str=set(handles.text_info_ch_number,'String',sprintf('#[%d] ch.',find(IndexC)));
end;

% --- Executes during object creation, after setting all properties.
function listbox_info_chnames_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_chnames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_info_auxdata.
function listbox_info_auxdata_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_auxdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_auxdata contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_auxdata
global etc_trace_obj;

str=get(handles.listbox_info_trigger,'String');
if(~isempty(str))
    str=str{get(handles.listbox_info_trigger,'Value')};    
end;

etc_trace_obj.all_data_aux_idx=zeros(1, length(etc_trace_obj.all_data));
etc_trace_obj.all_data_aux_idx(get(hObject,'Value'))=1;

update_data;

etc_trace_handle('redraw');

figure(etc_trace_obj.fig_info);


% --- Executes during object creation, after setting all properties.
function listbox_info_auxdata_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_auxdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_info_trigger.
function listbox_info_trigger_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_trigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_trigger
global etc_trace_obj;

str=get(handles.listbox_info_trigger,'String');
if(~isempty(str))
    str=str{get(handles.listbox_info_trigger,'Value')};
    IndexC = strcmp(str,etc_trace_obj.trigger.event);
    trigger_match_idx = find(IndexC);
    trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
    trigger_match_time_idx=sort(trigger_match_time_idx);
    fprintf('[%d] trigger {%s} found at time index [%s].\n',length(trigger_match_idx),str,mat2str(trigger_match_time_idx));
    
    str=set(handles.text_info_trigger_number,'String',sprintf('[%d] times',length(trigger_match_idx)));
end;



% --- Executes during object creation, after setting all properties.
function listbox_info_trigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listbox_info_auxdata and none of its controls.
function listbox_info_auxdata_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_auxdata (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

if(strcmp(eventdata.Key,'backspace')|strcmp(eventdata.Key,'delete'))
    contents = cellstr(get(hObject,'String'));
    select_idx=get(hObject,'Value');
    
    if(~isempty(select_idx))
        try
            main_data_str=etc_trace_obj.all_data_name{etc_trace_obj.all_data_main_idx};
            
            etc_trace_obj.all_data(select_idx)=[];
            etc_trace_obj.all_data_name(select_idx)=[];
            etc_trace_obj.all_data_aux_idx(select_idx)=[];
            
            
            if(~isempty(etc_trace_obj.all_data))
                if(select_idx~=etc_trace_obj.all_data_main_idx)
                    IndexC=strfind(etc_trace_obj.all_data_name,main_data_str);
                    etc_trace_obj.all_data_main_idx=find(not(cellfun('isempty',IndexC)));                   
                else
                    etc_trace_obj.all_data_main_idx=1;
                end;
            else
                etc_trace_obj.all_data_name='';
                etc_trace_obj.all_data_main_idx=[];
            end;
            
            update_data;
            
            etc_trace_handle('redraw');
            
            %get focus back to trigger window
            figure(etc_trace_obj.fig_info);
            
        catch ME
        end;
    end;
end;


% --- Executes on selection change in listbox_info_data.
function listbox_info_data_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_info_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_info_data contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_info_data
global etc_trace_obj;

contents = cellstr(get(hObject,'String'));
if(~strcmp(contents{1},'[none]'))
    
    etc_trace_obj.all_data_main_idx=get(hObject,'Value');
    
    obj=findobj('Tag','listbox_data');
    if(~isempty(obj))
        set(obj,'Value',etc_trace_obj.all_data_main_idx);
    end;
    
    update_data;
    
    %etc_trace_obj.time_duration_idx=size(etc_trace_obj.data,2);
    
    etc_trcae_gui_update_time();
        
    etc_trace_handle('redraw');
    
    figure(etc_trace_obj.fig_info);
end;




% --- Executes during object creation, after setting all properties.
function listbox_info_data_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_info_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_data()
global etc_trace_obj;


if(~isempty(etc_trace_obj.all_data_main_idx))
    etc_trace_obj.data=etc_trace_obj.all_data{etc_trace_obj.all_data_main_idx};
else
    etc_trace_obj.data=[];
end;

etc_trace_obj.aux_data={};
idx=find(etc_trace_obj.all_data_aux_idx);

if(~etc_trace_obj.flag_trigger_avg)
    for i=1:length(idx)
        etc_trace_obj.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
    end;
    etc_trace_obj.aux_data_idx=idx;
else
    for i=1:length(idx)
        etc_trace_obj.buffer.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.buffer.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
    end;
    etc_trace_obj.buffer.aux_data_idx=idx;    
end;

%GUI
obj=findobj('Tag','listbox_info_data');
if(~isempty(obj))
    if(~isempty(etc_trace_obj.all_data_name))
        set(obj,'String',etc_trace_obj.all_data_name);
        set(obj,'Value',etc_trace_obj.all_data_main_idx);
    else
        set(obj,'String','[none]');
        set(obj,'Value',1);
    end;
end;

obj=findobj('Tag','listbox_info_auxdata');
if(~isempty(obj))
    if(~isempty(etc_trace_obj.all_data_name))
        set(obj,'String',etc_trace_obj.all_data_name);
        set(obj,'min',0);
        if(length(etc_trace_obj.all_data_name)<2)
            set(obj,'max',2);
        else
            set(obj,'max',length(etc_trace_obj.all_data_name));
        end;
        set(obj,'Value',find(etc_trace_obj.all_data_aux_idx));
    else
        set(obj,'String','[none]');
        set(obj,'min',0);
        set(obj,'max',2);
        set(obj,'Value',[]);        
    end
end;

obj=findobj('Tag','listbox_data');
if(~isempty(obj))
    if(~isempty(etc_trace_obj.all_data_name))
        set(obj,'String',etc_trace_obj.all_data_name);
        set(obj,'Value',etc_trace_obj.all_data_main_idx);
    else
        set(obj,'String','[none]');
        set(obj,'Value',1);      
    end;
end;

return;
