function varargout = etc_trace_analyze_gui(varargin)
% ETC_TRACE_ANALYZE_GUI MATLAB code for etc_trace_analyze_gui.fig
%      ETC_TRACE_ANALYZE_GUI, by itself, creates a new ETC_TRACE_ANALYZE_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_ANALYZE_GUI returns the handle to a new ETC_TRACE_ANALYZE_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_ANALYZE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_ANALYZE_GUI.M with the given input arguments.
%
%      ETC_TRACE_ANALYZE_GUI('Property','Value',...) creates a new ETC_TRACE_ANALYZE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_analyze_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_analyze_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_analyze_gui

% Last Modified by GUIDE v2.5 05-Jun-2022 18:51:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_analyze_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_analyze_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_analyze_gui is made visible.
function etc_trace_analyze_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_analyze_gui (see VARARGIN)

% Choose default command line output for etc_trace_analyze_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_trace_analyze_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_trace_obj;

if(isempty(etc_trace_obj.trigger)) return; end;

if(~isempty(etc_trace_obj.trigger.time))
    fprintf('events loaded...\n');
    
    %convert trigger names from numbers/integers to strings
    try
        if(~iscell(etc_trace_obj.trigger.event))
            ev=etc_trace_obj.trigger.event;
            str={};
            for idx=1:length(ev)
                str{idx}=sprintf('%d',ev(idx));
            end;
            etc_trace_obj.trigger.event=str;
        end;
    catch ME
    end;
    
    %update time/class listboxes
    str=[];
    for i=1:length(etc_trace_obj.trigger.time)
        str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
    end;
    set(handles.listbox_time_idx,'string',str);
    str=[];
    for i=1:length(etc_trace_obj.trigger.time)
        str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
    end;
    set(handles.listbox_time,'string',str);
    set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
    
    %set time/class edits
    set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger.time(1)));
    set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger.time(1)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
    set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger.event{1});
    etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
    set(handles.edit_local_trigger_time_idx,'min',0);
    set(handles.edit_local_trigger_time_idx,'max',length(etc_trace_obj.trigger.time));
    set(handles.edit_local_trigger_time,'min',0);
    set(handles.edit_local_trigger_time,'max',length(etc_trace_obj.trigger.time));
    set(handles.edit_local_trigger_class,'min',0);
    set(handles.edit_local_trigger_class,'max',length(etc_trace_obj.trigger.time));
    

    %update time/class edits and listboxes if the current selected time matches a trigger   
    if(isfield(etc_trace_obj,'trigger_time_idx'))
        if(~isempty(etc_trace_obj.trigger_time_idx))
            idx=find(etc_trace_obj.trigger.time==etc_trace_obj.trigger_time_idx(1));
            if(~isempty(idx))
                hObject=findobj('tag','listbox_time_idx');
                set(hObject,'Value',idx(1));
                hObject=findobj('tag','listbox_time');
                set(hObject,'Value',idx(1));
                hObject=findobj('tag','listbox_class');
                set(hObject,'Value',idx(1));
            end;
            
            set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
            set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
            set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger_now);
        end;
    end;
else
    set(handles.listbox_time_idx,'string',{});
    set(handles.listbox_time,'string',{});
    set(handles.listbox_class,'string',{});
    
    time_idx_now=etc_trace_obj.time_select_idx;

    class_now='def_0'; %default event name
    
    etc_trace_obj.trigger_now=class_now;

    set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',time_idx_now));
    set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(time_idx_now-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
    set(handles.edit_local_trigger_class,'String',class_now);

    guidata(hObject, handles);
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_analyze_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_time_idx.
function listbox_time_idx_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hints: contents = cellstr(get(hObject,'String')) returns listbox_class contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_class

global etc_trace_obj;

contents = cellstr(get(hObject,'String')); if(isempty(contents)) return; end;

obj_listbox_time_idx=hObject;
obj_listbox_time=findobj('tag','listbox_time');
obj_listbox_class=findobj('tag','listbox_class');
selected_value=get(obj_listbox_time_idx,'Value');

%set class listbox
obj_listbox_class.Value=selected_value;
obj_listbox_time.Value=selected_value;
obj_listbox_time_idx.Value=selected_value;

contents = cellstr(get(obj_listbox_time_idx,'String'));
etc_trace_obj.time_select_idx=str2num(contents{get(obj_listbox_time_idx,'Value')});
etc_trace_obj.trigger_time_idx=str2num(contents{get(obj_listbox_time_idx,'Value')});
contents = cellstr(get(obj_listbox_class,'String'));
etc_trace_obj.trigger_now=contents{selected_value};


hObject=findobj('tag','edit_local_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_local_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_local_trigger_class');
set(hObject,'String',etc_trace_obj.trigger_now);

%update trigger info in the trace window
% trigger list box
all_trigger=get(obj_listbox_class,'String');
obj_listbox_trigger=findobj('tag','listbox_trigger');
set(obj_listbox_trigger,'string',unique(all_trigger));
all_trigger=unique(all_trigger);
%IndexC = strfind(all_trigger,etc_trace_obj.trigger_now);
%Index = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(all_trigger,etc_trace_obj.trigger_now);
Index = find(IndexC);
set(obj_listbox_trigger,'Value',Index);

hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));

%
% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
% etc_trace_obj.flag_time_window_auto_adjust=1;
%
etc_trcae_gui_update_time;

figure(etc_trace_obj.fig_trigger);



% Hints: contents = cellstr(get(hObject,'String')) returns listbox_time_idx contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_time_idx


% --- Executes during object creation, after setting all properties.
function listbox_time_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_class.
function listbox_class_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_class contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_class


global etc_trace_obj;

contents = cellstr(get(hObject,'String')); if(isempty(contents)) return; end;

obj_listbox_time_idx=findobj('tag','listbox_time_idx');
obj_listbox_time=findobj('tag','listbox_time');
obj_listbox_class=hObject;
selected_value=get(obj_listbox_class,'Value');

%set class listbox
obj_listbox_class.Value=selected_value;
obj_listbox_time.Value=selected_value;
obj_listbox_time_idx.Value=selected_value;

contents = cellstr(get(obj_listbox_time_idx,'String'));
etc_trace_obj.time_select_idx=str2num(contents{get(obj_listbox_time_idx,'Value')});
etc_trace_obj.trigger_time_idx=str2num(contents{get(obj_listbox_time_idx,'Value')});
contents = cellstr(get(obj_listbox_class,'String'));
etc_trace_obj.trigger_now=contents{selected_value};


hObject=findobj('tag','edit_local_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_local_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_loca_trigger_class');
set(hObject,'String',etc_trace_obj.trigger_now);

%update trigger info in the trace window
% trigger list box
all_trigger=get(obj_listbox_class,'String');
obj_listbox_trigger=findobj('tag','listbox_trigger');
set(obj_listbox_trigger,'string',unique(all_trigger));
all_trigger=unique(all_trigger);
%IndexC = strfind(all_trigger,etc_trace_obj.trigger_now);
%Index = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(all_trigger,etc_trace_obj.trigger_now);
Index = find(IndexC);
set(obj_listbox_trigger,'Value',Index);

hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));


%
% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
% etc_trace_obj.flag_time_window_auto_adjust=1;
%
etc_trcae_gui_update_time;

figure(etc_trace_obj.fig_trigger);


% --- Executes during object creation, after setting all properties.
function listbox_class_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_local_trigger_time_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_local_trigger_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_local_trigger_time_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_local_trigger_time_idx as a double
global etc_trace_obj;

if(isempty(etc_trace_obj))
    return;
end;

etc_trace_obj.trigger_time_idx=round(str2double(get(hObject,'String')));
hObject=findobj('tag','edit_local_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_local_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_local_trigger_class');
set(hObject,'String',etc_trace_obj.trigger_now);

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.trigger_time_idx;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
etc_trace_obj.flag_time_window_auto_adjust=1;
if((etc_trace_obj.time_select_idx)>=1&&(etc_trace_obj.time_select_idx<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;



% --- Executes during object creation, after setting all properties.
function edit_local_trigger_time_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_local_trigger_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

try
        hObject=findobj('tag','edit_local_trigger_time_idx');
        time_idx_now=str2num(get(hObject,'String'));
        hObject=findobj('tag','edit_local_trigger_class');
        str=get(hObject,'String');
        if(iscell(str))
            class_now=str{1}; 
        else
            class_now=str;
        end;
        etc_trace_obj.trigger_now=class_now;
        
        if(~isempty(etc_trace_obj.trigger))
            all_class=etc_trace_obj.trigger.event;
            all_time_idx=etc_trace_obj.trigger.time;
        else
            all_class={};
            all_time_idx=[];
        end;

        idx=find(all_time_idx==time_idx_now);
        found=0;
        if(~isempty(idx))
            for i=1:length(idx)
                if(strcmp(all_class{idx(i)},class_now))
                    found=1;
                    break;
                end;
            end;
        end;
        
        obj_time_idx=findobj('tag','listbox_time_idx');
        obj_time=findobj('tag','listbox_time');
        obj_class=findobj('tag','listbox_class');
        
        if(~found)
            fprintf('adding [%d] (sample) in class {%s}...\n',time_idx_now,class_now);
            
            if(isempty(etc_trace_obj.trigger))
                etc_trace_obj.trigger.time=time_idx_now;
                etc_trace_obj.trigger.event{1}=class_now;                
            else
                etc_trace_obj.trigger.time=cat(1,time_idx_now, etc_trace_obj.trigger.time(:));
                for i=1:length(etc_trace_obj.trigger.event)
                    tmp{i+1}=etc_trace_obj.trigger.event{i};
                end;
                tmp{1}=class_now;
                etc_trace_obj.trigger.event=tmp;
            end;
            
            str={};
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
            end;
            set(obj_time_idx,'string',str);
            
            str={};
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin);
            end;
            set(obj_time,'string',str);
            
            set(obj_class,'string',etc_trace_obj.trigger.event);
            
            %update trace trigger
            hObject=findobj('tag','listbox_trigger');
            set(hObject,'string',unique(etc_trace_obj.trigger.event));


        else
            fprintf('duplicated [%d] (sample) in class {%s}...\n',all_time_idx(idx),class_now);
            
            obj_time.Value=idx;
            obj_class.Value=idx;
            obj_time_idx.Value=idx;
        end;

catch ME
end;


function edit_local_trigger_class_Callback(hObject, eventdata, handles)
% hObject    handle to edit_local_trigger_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_local_trigger_class as text
%        str2double(get(hObject,'String')) returns contents of edit_local_trigger_class as a double


% --- Executes during object creation, after setting all properties.
function edit_local_trigger_class_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_local_trigger_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listbox_time_idx and none of its controls.
function listbox_time_idx_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_time_idx (see GCBO)
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
            etc_trace_obj.trigger.event(select_idx)=[];
            etc_trace_obj.trigger.time(select_idx)=[];
            
            %update time/class listboxes
            str=[];
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
            end;
            set(handles.listbox_time_idx,'string',str);
            set(handles.listbox_time_idx,'Value',1);

            str=[];
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin);
            end;
            set(handles.listbox_time,'string',str);
            set(handles.listbox_time,'Value',1);

            set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
            set(handles.listbox_class,'Value',1);

            etc_trace_obj.trigger_time_idx=etc_trace_obj.trigger.time(1);
            etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
            hObject=findobj('tag','edit_local_trigger_time_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
            hObject=findobj('tag','edit_local_trigger_time');
            set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
            hObject=findobj('tag','edit_local_trigger_class');
            set(hObject,'String',etc_trace_obj.trigger_now);
            
            if(~isempty(etc_trace_obj.trigger.time))
                %set time/class edits
                set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger.time(1)));
                set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger.time(1)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger.event{1});
                %etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
                etc_trace_obj.trigger_time_idx=etc_trace_obj.time_select_idx;
                
                %update time/class edits and listboxes if the current selected time matches a trigger
                if(isfield(etc_trace_obj,'trigger_time_idx'))
                    if(~isempty(etc_trace_obj.trigger_time_idx))
                        idx=find(etc_trace_obj.trigger.time==etc_trace_obj.trigger_time_idx);
                        if(~isempty(idx))
                            hObject=findobj('tag','listbox_time');
                            set(hObject,'Value',idx);
                            hObject=findobj('tag','listbox_time_idx');
                            set(hObject,'Value',idx);
                            hObject=findobj('tag','listbox_class');
                            set(hObject,'Value',idx);
                        end;
                        
                        set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
                        set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                        set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger_now);
                    end;
                end;
                
                
                obj_listbox_time=findobj('tag','listbox_time');
                obj_listbox_time_idx=findobj('tag','listbox_time_idx');
                obj_listbox_class=findobj('tag','listbox_class');
                %update trigger info in the trace window
                % trigger list box
                all_trigger=get(obj_listbox_class,'String');
                obj_listbox_trigger=findobj('tag','listbox_trigger');
                set(obj_listbox_trigger,'string',unique(all_trigger));
                all_trigger=unique(all_trigger);
                %IndexC = strfind(all_trigger,etc_trace_obj.trigger_now);
                %Index = find(not(cellfun('isempty',IndexC)));
                IndexC = strcmp(all_trigger,etc_trace_obj.trigger_now);
                Index = find(IndexC);
                set(obj_listbox_trigger,'Value',Index);
                
                hObject=findobj('tag','edit_trigger_time_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
                hObject=findobj('tag','edit_trigger_time');
                set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
                
            else
                set(handles.edit_local_trigger_time_idx,'String','');
                set(handles.edit_local_trigger_time,'String','');
                set(handles.edit_local_trigger_class,'String','');
                etc_trace_obj.trigger_now='';
                etc_trace_obj.trigger_time_idx=[];

                obj_listbox_trigger=findobj('tag','listbox_trigger');
                set(obj_listbox_trigger,'String','');
                hObject=findobj('tag','edit_local_trigger_time_idx');
                set(hObject,'String','');
                hObject=findobj('tag','edit_local_trigger_time');
                set(hObject,'String','');
                hObject=findobj('tag','edit_local_trigger_class');
                set(hObject,'String','');
            end;

            
            %get focus back to trigger window
            figure(etc_trace_obj.fig_tigger);
            
        catch ME
        end;
    end;
end;


% --- Executes on key press with focus on listbox_class and none of its controls.
function listbox_class_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_class (see GCBO)
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
            etc_trace_obj.trigger.event(select_idx)=[];
            etc_trace_obj.trigger.time(select_idx)=[];
            
            %update time/class listboxes
            str=[];
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
            end;
            set(handles.listbox_time_idx,'string',str);
            set(handles.listbox_time_idx,'Value',1);

            str=[];
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin);
            end;
            set(handles.listbox_time,'string',str);
            set(handles.listbox_time,'Value',1);

            set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
            set(handles.listbox_class,'Value',1);
            
            etc_trace_obj.trigger_time_idx=etc_trace_obj.trigger.time(1);
            etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
            hObject=findobj('tag','edit_local_trigger_time_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
            hObject=findobj('tag','edit_local_trigger_time');
            set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
            hObject=findobj('tag','edit_local_trigger_class');
            set(hObject,'String',etc_trace_obj.trigger_now);
            
            if(~isempty(etc_trace_obj.trigger.time))
                %set time/class edits
                set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger.time(1)));
                set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger.time(1)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger.event{1});
                %etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
                etc_trace_obj.trigger_time_idx=etc_trace_obj.time_select_idx;
                
                %update time/class edits and listboxes if the current selected time matches a trigger
                if(isfield(etc_trace_obj,'trigger_time_idx'))
                    if(~isempty(etc_trace_obj.trigger_time_idx))
                        idx=find(etc_trace_obj.trigger.time==etc_trace_obj.trigger_time_idx);
                        if(~isempty(idx))
                            hObject=findobj('tag','listbox_time');
                            set(hObject,'Value',idx);
                            hObject=findobj('tag','listbox_time_idx');
                            set(hObject,'Value',idx);
                            hObject=findobj('tag','listbox_class');
                            set(hObject,'Value',idx);
                        end;
                        
                        set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
                        set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                        set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger_now);
                    end;
                end;
                
                
                obj_listbox_time=findobj('tag','listbox_time');
                obj_listbox_time_idx=findobj('tag','listbox_time_idx');
                obj_listbox_class=findobj('tag','listbox_class');
                %update trigger info in the trace window
                % trigger list box
                all_trigger=get(obj_listbox_class,'String');
                obj_listbox_trigger=findobj('tag','listbox_trigger');
                set(obj_listbox_trigger,'string',unique(all_trigger));
                all_trigger=unique(all_trigger);
                %IndexC = strfind(all_trigger,etc_trace_obj.trigger_now);
                %Index = find(not(cellfun('isempty',IndexC)));
                IndexC = strcmp(all_trigger,etc_trace_obj.trigger_now);
                Index = find(IndexC);
                set(obj_listbox_trigger,'Value',Index);
                
                hObject=findobj('tag','edit_trigger_time_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
                hObject=findobj('tag','edit_trigger_time');
                set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
                
            else
                set(handles.edit_local_trigger_time_idx,'String','');
                set(handles.edit_local_trigger_time,'String','');
                set(handles.edit_local_trigger_class,'String','');
                etc_trace_obj.trigger_now='';
                etc_trace_obj.trigger_time_idx=[];

                obj_listbox_trigger=findobj('tag','listbox_trigger');
                set(obj_listbox_trigger,'String','');
                hObject=findobj('tag','edit_local_trigger_time_idx');
                set(hObject,'String','');
                hObject=findobj('tag','edit_local_trigger_time');
                set(hObject,'String','');
                hObject=findobj('tag','edit_local_trigger_class');
                set(hObject,'String','');
            end;

            
            %get focus back to trigger window
            figure(etc_trace_obj.fig_tigger);
            
        catch ME
        end;
    end;
end;


% --- Executes on button press in button_trigger_loadfile.
function button_trigger_loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to button_trigger_loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;


[filename, pathname, filterindex] = uigetfile(fullfile(pwd,'*.mat'),'select a trigger matlab data file...');
if(filename==0) return; end;

tmp=load(filename);
                
fn=fieldnames(tmp);


fprintf('load a variable with fields ''time'' and ''event''\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        evalin('base',sprintf('global etc_trace_obj; if(isfield(%s,''time'')&&isfield(%s,''event'')) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        fprintf('Trying to load variable [%s] as the trigger...',var);
        if(etc_trace_obj.tmp)
            %evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.aux_point_name=%s;',var));
            evalin('base',sprintf('etc_trace_obj.trigger.time=%s.time; etc_trace_obj.trigger.event=%s.event;',var,var));

            fprintf('Done!\n');
        else
            fprintf('Rejected!\n');
        end;
        
    catch ME
    end;
end;

if(etc_trace_obj.tmp)
    
    %update list boxes
    str=[];
    for i=1:length(etc_trace_obj.trigger.time)
        str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
    end;
    set(handles.listbox_time_idx,'string',str);
    set(handles.listbox_time_idx,'Value',1);
    
    str=[];
    for i=1:length(etc_trace_obj.trigger.time)
        str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
    end;
    set(handles.listbox_time,'string',str);
    set(handles.listbox_time,'Value',1);
    
    set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
    set(handles.listbox_class,'Value',1);
end;



% --- Executes on button press in button_trigger_save.
function button_trigger_save_Callback(hObject, eventdata, handles)
% hObject    handle to button_trigger_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

[file, path] = uiputfile({'*.mat'});
if isequal(file,0) || isequal(path,0)
    
else
    fn=fullfile(path,file);
    fprintf('saving trigger as [%s]...\n',fullfile(path,file));
    trigger=etc_trace_obj.trigger;
    save(fullfile(path,file),'trigger');
end

% --- Executes on selection change in listbox_time.
function listbox_time_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_time contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_time
global etc_trace_obj;

contents = cellstr(get(hObject,'String')); if(isempty(contents)) return; end;

obj_listbox_time_idx=findobj('tag','listbox_time_idx');
obj_listbox_time=hObject;
obj_listbox_class=findobj('tag','listbox_class');
selected_value=get(obj_listbox_time,'Value');

%set class listbox
obj_listbox_class.Value=selected_value;
obj_listbox_time.Value=selected_value;
obj_listbox_time_idx.Value=selected_value;

contents = cellstr(get(obj_listbox_time_idx,'String'));
etc_trace_obj.time_select_idx=str2num(contents{get(obj_listbox_time_idx,'Value')});
etc_trace_obj.trigger_time_idx=str2num(contents{get(obj_listbox_time_idx,'Value')});
contents = cellstr(get(obj_listbox_class,'String'));
etc_trace_obj.trigger_now=contents{selected_value};


hObject=findobj('tag','edit_local_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_local_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_local_trigger_class');
set(hObject,'String',etc_trace_obj.trigger_now);

%update trigger info in the trace window
% trigger list box
all_trigger=get(obj_listbox_class,'String');
obj_listbox_trigger=findobj('tag','listbox_trigger');
set(obj_listbox_trigger,'string',unique(all_trigger));
all_trigger=unique(all_trigger);
%IndexC = strfind(all_trigger,etc_trace_obj.trigger_now);
%Index = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(all_trigger,etc_trace_obj.trigger_now);
Index = find(IndexC);
set(obj_listbox_trigger,'Value',Index);

hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));


%
% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
% etc_trace_obj.flag_time_window_auto_adjust=1;
%
etc_trcae_gui_update_time;

figure(etc_trace_obj.fig_trigger);


% --- Executes during object creation, after setting all properties.
function edit_local_trigger_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_local_trigger_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function listbox_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_local_trigger_time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_local_trigger_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_local_trigger_time as text
%        str2double(get(hObject,'String')) returns contents of edit_local_trigger_time as a double
global etc_trace_obj;

if(isempty(etc_trace_obj))
    return;
end;


etc_trace_obj.trigger_time_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin)*etc_trace_obj.fs)+1;
hObject=findobj('tag','edit_local_trigger_time_idx');
set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
hObject=findobj('tag','edit_local_trigger_time');
set(hObject,'String',get(hObject,'String'));
hObject=findobj('tag','edit_local_trigger_class');
set(hObject,'String',etc_trace_obj.trigger_now);

% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
etc_trace_obj.time_select_idx=etc_trace_obj.trigger_time_idx;
% etc_trace_obj.time_window_begin_idx;
% etc_trace_obj.time_duration_idx;
etc_trace_obj.flag_time_window_auto_adjust=1;
if((etc_trace_obj.time_select_idx)>=1&&(etc_trace_obj.time_select_idx<=size(etc_trace_obj.data,2)))
    etc_trcae_gui_update_time;
end;


% --- Executes on key press with focus on listbox_time and none of its controls.
function listbox_time_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_time (see GCBO)
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
            etc_trace_obj.trigger.event(select_idx)=[];
            etc_trace_obj.trigger.time(select_idx)=[];
            
            %update time/class listboxes
            str=[];
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
            end;
            set(handles.listbox_time_idx,'string',str);
            set(handles.listbox_time_idx,'Value',1);

            str=[];
            for i=1:length(etc_trace_obj.trigger.time)
                str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin);
            end;
            set(handles.listbox_time,'string',str);
            set(handles.listbox_time,'Value',1);

            set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
            set(handles.listbox_class,'Value',1);
            
            etc_trace_obj.trigger_time_idx=etc_trace_obj.trigger.time(1);
            etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
            hObject=findobj('tag','edit_local_trigger_time_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
            hObject=findobj('tag','edit_local_trigger_time');
            set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
            hObject=findobj('tag','edit_local_trigger_class');
            set(hObject,'String',etc_trace_obj.trigger_now);
            
            if(~isempty(etc_trace_obj.trigger.time))
                %set time/class edits
                set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger.time(1)));
                set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger.time(1)-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger.event{1});
                %etc_trace_obj.trigger_now=etc_trace_obj.trigger.event{1};
                etc_trace_obj.trigger_time_idx=etc_trace_obj.time_select_idx;
                
                %update time/class edits and listboxes if the current selected time matches a trigger
                if(isfield(etc_trace_obj,'trigger_time_idx'))
                    if(~isempty(etc_trace_obj.trigger_time_idx))
                        idx=find(etc_trace_obj.trigger.time==etc_trace_obj.trigger_time_idx);
                        if(~isempty(idx))
                            hObject=findobj('tag','listbox_time');
                            set(hObject,'Value',idx);
                            hObject=findobj('tag','listbox_time_idx');
                            set(hObject,'Value',idx);
                            hObject=findobj('tag','listbox_class');
                            set(hObject,'Value',idx);
                        end;
                        
                        set(handles.edit_local_trigger_time_idx,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
                        set(handles.edit_local_trigger_time,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)/etc_trace_obj.fs+etc_trace_obj.time_begin));
                        set(handles.edit_local_trigger_class,'String',etc_trace_obj.trigger_now);
                    end;
                end;
                
                
                obj_listbox_time=findobj('tag','listbox_time');
                obj_listbox_time_idx=findobj('tag','listbox_time_idx');
                obj_listbox_class=findobj('tag','listbox_class');
                %update trigger info in the trace window
                % trigger list box
                all_trigger=get(obj_listbox_class,'String');
                obj_listbox_trigger=findobj('tag','listbox_trigger');
                set(obj_listbox_trigger,'string',unique(all_trigger));
                all_trigger=unique(all_trigger);
                IndexC = strfind(all_trigger,etc_trace_obj.trigger_now);
                Index = find(not(cellfun('isempty',IndexC)));
                set(obj_listbox_trigger,'Value',Index);
                
                hObject=findobj('tag','edit_trigger_time_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
                hObject=findobj('tag','edit_trigger_time');
                set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
                
            else
                set(handles.edit_local_trigger_time_idx,'String','');
                set(handles.edit_local_trigger_time,'String','');
                set(handles.edit_local_trigger_class,'String','');
                etc_trace_obj.trigger_now='';
                etc_trace_obj.trigger_time_idx=[];

                obj_listbox_trigger=findobj('tag','listbox_trigger');
                set(obj_listbox_trigger,'String','');
                hObject=findobj('tag','edit_local_trigger_time_idx');
                set(hObject,'String','');
                hObject=findobj('tag','edit_local_trigger_time');
                set(hObject,'String','');
                hObject=findobj('tag','edit_local_trigger_class');
                set(hObject,'String','');
            end;

            
            %get focus back to trigger window
            figure(etc_trace_obj.fig_tigger);
            
        catch ME
        end;
    end;
end;


% --- Executes on button press in pushbutton_listbox_time_idx.
function pushbutton_listbox_time_idx_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_listbox_time_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;


if(~isempty(etc_trace_obj.trigger))
    if(~isempty(etc_trace_obj.trigger.time))
        
        obj_listbox_time=findobj('tag','listbox_time');
        obj_listbox_time_idx=findobj('tag','listbox_time_idx');
        obj_listbox_class=findobj('tag','listbox_class');
        
        all_trigger=get(obj_listbox_class,'String');
        
        contents = cellstr(get(obj_listbox_time,'String'));
        all_time=cellfun(@str2double,contents);
        
        contents = cellstr(get(obj_listbox_time_idx,'String'));
        all_time_idx=cellfun(@str2double,contents);
        
        
        [dummy,idx]=sort(all_time_idx);
        
        all_trigger=all_trigger(idx);
        all_time=all_time(idx);
        all_time_idx=all_time_idx(idx);
        
        etc_trace_obj.trigger.time=all_time_idx;
        etc_trace_obj.trigger.event=all_trigger;
        
        %update time/class listboxes
        str=[];
        for i=1:length(etc_trace_obj.trigger.time)
            str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
        end;
        set(handles.listbox_time_idx,'string',str);
        str=[];
        for i=1:length(etc_trace_obj.trigger.time)
            str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
        end;
        set(handles.listbox_time,'string',str);
        set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
        
        
    end;
end;


% --- Executes on button press in pushbutton_listbox_time.
function pushbutton_listbox_time_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_listbox_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;


if(~isempty(etc_trace_obj.trigger))
    if(~isempty(etc_trace_obj.trigger.time))
        
        obj_listbox_time=findobj('tag','listbox_time');
        obj_listbox_time_idx=findobj('tag','listbox_time_idx');
        obj_listbox_class=findobj('tag','listbox_class');
        
        all_trigger=get(obj_listbox_class,'String');
        
        contents = cellstr(get(obj_listbox_time,'String'));
        all_time=cellfun(@str2double,contents);
        
        contents = cellstr(get(obj_listbox_time_idx,'String'));
        all_time_idx=cellfun(@str2double,contents);
        
        
        [dummy,idx]=sort(all_time);
        
        all_trigger=all_trigger(idx);
        all_time=all_time(idx);
        all_time_idx=all_time_idx(idx);
        
        etc_trace_obj.trigger.time=all_time_idx;
        etc_trace_obj.trigger.event=all_trigger;
        
        %update time/class listboxes
        str=[];
        for i=1:length(etc_trace_obj.trigger.time)
            str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
        end;
        set(handles.listbox_time_idx,'string',str);
        str=[];
        for i=1:length(etc_trace_obj.trigger.time)
            str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
        end;
        set(handles.listbox_time,'string',str);
        set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
        
        
    end;
end;


% --- Executes on button press in pushbutton_listbox_class.
function pushbutton_listbox_class_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_listbox_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;


if(~isempty(etc_trace_obj.trigger))
    if(~isempty(etc_trace_obj.trigger.time))
        
        obj_listbox_time=findobj('tag','listbox_time');
        obj_listbox_time_idx=findobj('tag','listbox_time_idx');
        obj_listbox_class=findobj('tag','listbox_class');
        
        all_trigger=get(obj_listbox_class,'String');
        
        contents = cellstr(get(obj_listbox_time,'String'));
        all_time=cellfun(@str2double,contents);
        
        contents = cellstr(get(obj_listbox_time_idx,'String'));
        all_time_idx=cellfun(@str2double,contents);
        
        
        [dummy,idx]=sort(all_trigger);
        
        all_trigger=all_trigger(idx);
        all_time=all_time(idx);
        all_time_idx=all_time_idx(idx);
        
        etc_trace_obj.trigger.time=all_time_idx;
        etc_trace_obj.trigger.event=all_trigger;
        
        %update time/class listboxes
        str=[];
        for i=1:length(etc_trace_obj.trigger.time)
            str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
        end;
        set(handles.listbox_time_idx,'string',str);
        str=[];
        for i=1:length(etc_trace_obj.trigger.time)
            str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
        end;
        set(handles.listbox_time,'string',str);
        set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
        
        
    end;
end;


% --- Executes on button press in button_trigger_loadvar.
function button_trigger_loadvar_Callback(hObject, eventdata, handles)
% hObject    handle to button_trigger_loadvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable with fields ''time'' and ''event''\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        evalin('base',sprintf('global etc_trace_obj; if(isfield(%s,''time'')&&isfield(%s,''event'')) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        fprintf('Trying to load variable [%s] as the trigger...',var);
        if(etc_trace_obj.tmp)
            
            
            answer = questdlg('replace or merge with the existed trigger?','Menu',...
                'replace','merge','cancel','replace');
            % Handle response
            switch answer
                case 'replace'
                    f_option = 1;
                case 'merge'
                    f_option = 2;
                case 'cancel'
                    f_option= 0;
            end
            if(f_option==1) %replace....
                evalin('base',sprintf('etc_trace_obj.trigger=%s; ',var));
                
                obj=findobj('Tag','text_load_trigger');
                set(obj,'String',sprintf('%s',var));                
                
                fprintf('trigger replaced/loaded!\n');
            elseif(f_option==2)
                evalin('base',sprintf('global trigger_tmp; trigger_tmp=%s; ',var));
                global trigger_tmp;
                
                if(isempty(etc_trace_obj.trigger))
                    etc_trace_obj.trigger=trigger_tmp;
                else
                    etc_trace_obj.trigger=etc_trigger_append(etc_trace_obj.trigger,trigger_tmp);
                end;
                clear trigger_tmp;
                
                obj=findobj('Tag','text_load_trigger');
                set(obj,'String',sprintf('%s',var));                
                
                fprintf('trigger merged!\n');
            end;
            

            %trigger formatting
            if(~isempty(etc_trace_obj.trigger))
                if(isfield(etc_trace_obj.trigger,'event'))
                    if(~iscell(etc_trace_obj.trigger.event))
                        str={};
                        for idx=1:length(etc_trace_obj.trigger.event)
                            str{idx}=sprintf('%d',etc_trace_obj.trigger.event(idx));
                        end;
                        etc_trace_obj.trigger.event=str;
                    end;
                end;
            end;
            
            %trigger loading
            obj=findobj('Tag','listbox_trigger');
            str={};
            if(~isempty(etc_trace_obj.trigger))
                fprintf('trigger loaded...\n');
                str=unique(etc_trace_obj.trigger.event);
                set(obj,'string',str);
            else
                set(obj,'string',{});
            end;%
            
            
            if(isfield(etc_trace_obj,'trigger_now'))
                if(isempty(etc_trace_obj.trigger_now))
                    
                else
                    IndexC = strcmp(str,etc_trace_obj.trigger_now);
                    if(isempty(find(IndexC)))
                        fprintf('current trigger [%s] not found in the loaded trigger...\n',etc_trace_obj.trigger_now);
                        fprintf('set current trigger to [%s]...\n',str{1});
                        etc_trace_obj.tigger_now=str{1};
                        set(obj,'Value',1);
                    else
                        set(obj,'Value',find(IndexC));
                    end;
                end;
            else
                if(isempty(str))
                    etc_trace_obj.trigger_now='';
                else
                    etc_trace_obj.trigger_now=str{1};
                    set(obj,'Value',1);
                end;
            end;
            
        else
            fprintf('Rejected!\n');
        end;
        
    catch ME
    end;
end;

if(etc_trace_obj.tmp)
    
    %update list boxes
    str=[];
    for i=1:length(etc_trace_obj.trigger.time)
        str{i}=sprintf('%d',etc_trace_obj.trigger.time(i));
    end;
    set(handles.listbox_time_idx,'string',str);
    set(handles.listbox_time_idx,'Value',1);
    
    str=[];
    for i=1:length(etc_trace_obj.trigger.time)
        str{i}=sprintf('%1.3f',(etc_trace_obj.trigger.time(i)-1)./etc_trace_obj.fs+etc_trace_obj.time_begin);
    end;
    set(handles.listbox_time,'string',str);
    set(handles.listbox_time,'Value',1);
    
    set(handles.listbox_class,'string',etc_trace_obj.trigger.event);
    set(handles.listbox_class,'Value',1);
end;


% --- Executes on button press in button_trigger_clearvar.
function button_trigger_clearvar_Callback(hObject, eventdata, handles)
% hObject    handle to button_trigger_clearvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

answer = questdlg('Clear all triggers?','Menu',...
    'clear','cancel','clear');
if(strcmp(answer,'clear'))
    etc_trace_obj.trigger=[];
    
    
    %trigger loading
    obj=findobj('Tag','listbox_trigger');
    set(obj,'string',{});
    set(obj,'Value',1);
      
    
    %update listboxes
    set(handles.listbox_time_idx,'string',{});
    set(handles.listbox_time_idx,'Value',1);
    
    set(handles.listbox_time,'string',{});
    set(handles.listbox_time,'Value',1);
    
    set(handles.listbox_class,'string',{});
    set(handles.listbox_class,'Value',1);
    
    %update listbox in the control window
    obj=findobj('Tag','listbox_trigger');
    set(obj,'string',{'[none]'});
    set(obj,'Value',1);
    
    
end;
