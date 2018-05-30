function varargout = etc_trace_trigger_gui(varargin)
% ETC_TRACE_TRIGGER_GUI MATLAB code for etc_trace_trigger_gui.fig
%      ETC_TRACE_TRIGGER_GUI, by itself, creates a new ETC_TRACE_TRIGGER_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_TRIGGER_GUI returns the handle to a new ETC_TRACE_TRIGGER_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_TRIGGER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_TRIGGER_GUI.M with the given input arguments.
%
%      ETC_TRACE_TRIGGER_GUI('Property','Value',...) creates a new ETC_TRACE_TRIGGER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_trigger_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_trigger_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_trigger_gui

% Last Modified by GUIDE v2.5 28-May-2018 10:46:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_trigger_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_trigger_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_trigger_gui is made visible.
function etc_trace_trigger_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_trigger_gui (see VARARGIN)

% Choose default command line output for etc_trace_trigger_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_trace_trigger_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_trace_obj;
if(~isempty(etc_trace_obj.trigger))
    fprintf('events loaded...\n');
    set(handles.listbox_time,'string',{etc_trace_obj.trigger.time(:)});
    set(handles.listbox_class,'string',{etc_trace_obj.trigger.event(:)});
    guidata(hObject, handles);
    
    %update trace window
    hObject=findobj('tag','listbox_time');
    if(~isempty(get(hObject,'String')))
        all_trigger=cellfun(@str2num,get(hObject,'String'));
    else
        all_trigger=[];
    end;
    obj_time=findobj('Tag','listbox_time');
    contents_time = cellstr(get(obj_time,'String'));
    time_idx_now=str2num(contents_time{1});

    obj_class=findobj('Tag','listbox_class');
    contents_class = cellstr(get(obj_class,'String'));
    class_now=str2num(contents_class{1});

    set(handles.edit_time,'Value',time_idx_now);
    set(handles.edit_class,'Value',class_now);
    set(handles.edit_time,'String',time_idx_now);
    set(handles.edit_class,'String',class_now);
    
    if(isfield(etc_trace_obj,'trigger_time_idx'))
        if(~isempty(etc_trace_obj.trigger_time_idx))
            idx=find(all_trigger==etc_trace_obj.trigger_time_idx);
            set(hObject,'Value',idx);
            hObject=findobj('tag','listbox_class');
            set(hObject,'Value',idx);
            
            set(handles.edit_time,'Value',etc_trace_obj.trigger_time_idx);
            set(handles.edit_class,'Value',etc_trace_obj.trigger_now);
            set(handles.edit_time,'String',etc_trace_obj.trigger_time_idx);
            set(handles.edit_class,'String',etc_trace_obj.trigger_now);
        end;
    end;
else
    set(handles.listbox_time,'string',{});
    set(handles.listbox_class,'string',{});
    guidata(hObject, handles);
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_trigger_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_time.
function listbox_time_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

obj=findobj('tag','listbox_class');
obj.Value=get(hObject,'Value');

contents_time = cellstr(get(hObject,'String'));
contents_class = cellstr(get(obj,'String'));

figure(etc_trace_obj.fig_trace);

try
    etc_trace_obj.trigger_now=str2num(contents_class{get(hObject,'Value')});
    trigger_time_idx=str2num(contents_time{get(hObject,'Value')});
    %trigger_idx=find(etc_trace_obj.trigger.event==str2num(etc_trace_obj.trigger_now));
    %trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    [tmp,mmidx]=min(abs(trigger_time_idx-etc_trace_obj.time_begin_idx-round(etc_trace_obj.time_duration_idx./5)));
    
    %trigger time
    %etc_trace_obj.trigger_time_idx=trigger_time_idx(mmidx);
    etc_trace_obj.trigger_time_idx=trigger_time_idx;
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));

    %trigger class
    hObject=findobj('tag','listbox_class');
    all_trigger =cellfun(@str2num,get(hObject,'String'));
    obj_listbox_trigger=findobj('tag','listbox_trigger');
    set(obj_listbox_trigger,'string',{unique(all_trigger)});
    all_trigger=unique(all_trigger);
    set(obj_listbox_trigger,'Value',find(all_trigger==etc_trace_obj.trigger_now));

    if(mmidx>=1)
        
        a=trigger_time_idx(mmidx)-round(etc_trace_obj.time_duration_idx/5)+1;
        b=a+etc_trace_obj.time_duration_idx;
        
        if(a<1) 
            a=1;
            b=a+etc_trace_obj.time_duration_idx;
        end;
        if(b>size(etc_trace_obj.data,2))
            a=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx;
            b=size(etc_trace_obj.data,2);
        end;
                    
        if(a>=1&&b<=size(etc_trace_obj.data,2))
            etc_trace_obj.time_begin_idx=a;
            etc_trace_obj.time_end_idx=b;
            
            %time slider
            hObject_slider=findobj('tag','slider_time_idx');
            v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
            set(hObject_slider,'value',v);
            
            %time edit
            hObject=findobj('tag','edit_time_begin_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
            hObject=findobj('tag','edit_time_end_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
            hObject=findobj('tag','edit_time_begin');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
            hObject=findobj('tag','edit_time_end');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
            
            etc_trace_handle('redraw');
            etc_trace_handle('bd','time_idx',trigger_time_idx);
        end;
    end;
    
    figure(etc_trace_obj.fig_trigger);
   
catch ME
end;


% Hints: contents = cellstr(get(hObject,'String')) returns listbox_time contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_time


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


% --- Executes on selection change in listbox_class.
function listbox_class_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_class contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_class

global etc_trace_obj;

obj=findobj('tag','listbox_time');
obj.Value=get(hObject,'Value');

contents_class = cellstr(get(hObject,'String'));
contents_time = cellstr(get(obj,'String'));

figure(etc_trace_obj.fig_trace);

try
    etc_trace_obj.trigger_now=str2num(contents_class{get(hObject,'Value')});
    trigger_time_idx=str2num(contents_time{get(hObject,'Value')});
    %trigger_idx=find(etc_trace_obj.trigger.event==str2num(etc_trace_obj.trigger_now));
    %trigger_time_idx=etc_trace_obj.trigger.time(trigger_idx);
    [tmp,mmidx]=min(abs(trigger_time_idx-etc_trace_obj.time_begin_idx-round(etc_trace_obj.time_duration_idx./5)));
    
    %trigger time
    %etc_trace_obj.trigger_time_idx=trigger_time_idx(mmidx);
    etc_trace_obj.trigger_time_idx=trigger_time_idx;
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));

    %trigger class
    hObject=findobj('tag','listbox_class');
    all_trigger =cellfun(@str2num,get(hObject,'String'));
    obj_listbox_trigger=findobj('tag','listbox_trigger');
    set(obj_listbox_trigger,'string',{unique(all_trigger)});
    all_trigger=unique(all_trigger);
    set(obj_listbox_trigger,'Value',find(all_trigger==etc_trace_obj.trigger_now));
    
    if(mmidx>=1)
        
        a=trigger_time_idx(mmidx)-round(etc_trace_obj.time_duration_idx/5)+1;
        b=a+etc_trace_obj.time_duration_idx;
        
        if(a<1) 
            a=1;
            b=a+etc_trace_obj.time_duration_idx;
        end;
        if(b>size(etc_trace_obj.data,2))
            a=size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx;
            b=size(etc_trace_obj.data,2);
        end;
        
        if(a>=1&&b<=size(etc_trace_obj.data,2))
            etc_trace_obj.time_begin_idx=a;
            etc_trace_obj.time_end_idx=b;
            
            %time slider
            hObject_slider=findobj('tag','slider_time_idx');
            v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
            set(hObject_slider,'value',v);
            
            %time edit
            hObject=findobj('tag','edit_time_begin_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
            hObject=findobj('tag','edit_time_end_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
            hObject=findobj('tag','edit_time_begin');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
            hObject=findobj('tag','edit_time_end');
            set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
            
            etc_trace_handle('redraw');
            etc_trace_handle('bd','time_idx',trigger_time_idx);

        end;
    end;

    figure(etc_trace_obj.fig_trigger);

catch ME
end;


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



function edit_time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_time as text
%        str2double(get(hObject,'String')) returns contents of edit_time as a double


% --- Executes during object creation, after setting all properties.
function edit_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_time (see GCBO)
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
        hObject=findobj('tag','edit_time');
        time_idx_now=str2num(get(hObject,'String'));
        hObject=findobj('tag','edit_class');
        str=get(hObject,'String');
        if(iscell(str))
            class_now=str2num(str{1}); 
        else
            class_now=str2num(str);
        end;
        
        obj_time=findobj('tag','listbox_time');
        obj_class=findobj('tag','listbox_class');
        
        if(~isempty(get(obj_time,'String')))
            all_time_idx =cellfun(@str2num,get(obj_time,'String'));
        else
            all_time_idx=[];
        end;
        if(~isempty(get(obj_class,'String')))
            all_class=cellfun(@str2num,get(obj_class,'String'));
        else
            all_class=[];
        end;
        
        idx=find(all_time_idx==time_idx_now);
        found=0;
        if(~isempty(idx))
            if(all_class(idx(1))==class_now)
                found=1;
            end;
        end;
        
        if(~found)
            fprintf('adding [%d] (sample) in class <%d>...\n',time_idx_now,class_now);

            if(isempty(etc_trace_obj.trigger))
                etc_trace_obj.trigger.time=time_idx_now
                etc_trace_obj.trigger.event=class_now;                
            else
                etc_trace_obj.trigger.time=cat(2,time_idx_now, etc_trace_obj.trigger.time);
                etc_trace_obj.trigger.event=cat(2,class_now, etc_trace_obj.trigger.event);
            end;
            set(obj_time,'string',{etc_trace_obj.trigger.time(:)});
            set(obj_class,'string',{etc_trace_obj.trigger.event(:)});
            
            %update trace trigger
            hObject=findobj('tag','listbox_trigger');
            set(hObject,'string',{unique(etc_trace_obj.trigger.event(:))});


        else
            fprintf('duplicated [%d] (sample) in class <%d>...\n',all_time_idx(idx),class_now);
            
            obj_time.Value=idx;
            obj_class.Value=idx;
        end;

catch ME
end;


function edit_class_Callback(hObject, eventdata, handles)
% hObject    handle to edit_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_class as text
%        str2double(get(hObject,'String')) returns contents of edit_class as a double


% --- Executes during object creation, after setting all properties.
function edit_class_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_class (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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
            
            if(~isempty(etc_trace_obj.trigger.time(:)))
                set(handles.listbox_time,'string',{etc_trace_obj.trigger.time(:)});
                set(handles.listbox_class,'string',{etc_trace_obj.trigger.event(:)});
            else
                set(handles.listbox_time,'string',{});
                set(handles.listbox_class,'string',{});
            end;
            
            guidata(hObject, handles);
            
            %update trace window
            hObject=findobj('tag','listbox_class');
            all_trigger =cellfun(@str2num,get(hObject,'String'));
            obj_listbox_trigger=findobj('tag','listbox_trigger');
            set(obj_listbox_trigger,'string',{unique(all_trigger)});
            all_trigger=unique(all_trigger);
            
            contents = cellstr(get(hObject,'String'));
            etc_trace_obj.trigger_now=str2num(contents{get(handles.listbox_class,'Value')});
            set(obj_listbox_trigger,'Value',find(all_trigger==etc_trace_obj.trigger_now));
            
            obj_listbox_time=findobj('tag','listbox_time');
            contents = cellstr(get(obj_listbox_time,'String'));
            etc_trace_obj.trigger_time_idx=str2num(contents{get(obj_listbox_time,'Value')});
            hObject=findobj('tag','edit_trigger_time_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
            hObject=findobj('tag','edit_trigger_time');
            set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));
            
            
            set(handles.edit_time,'Value',etc_trace_obj.trigger_time_idx);
            set(handles.edit_class,'Value',etc_trace_obj.trigger_now);
            set(handles.edit_time,'String',etc_trace_obj.trigger_time_idx);
            set(handles.edit_class,'String',etc_trace_obj.trigger_now);
            
            a=etc_trace_obj.trigger_time_idx-round(etc_trace_obj.time_duration_idx/5)+1;
            b=a+etc_trace_obj.time_duration_idx;
            
            if(a>=1&&b<=size(etc_trace_obj.data,2))
                etc_trace_obj.time_begin_idx=a;
                etc_trace_obj.time_end_idx=b;
                
                %time slider
                hObject_slider=findobj('tag','slider_time_idx');
                v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
                set(hObject_slider,'value',v);
                
                %time edit
                hObject=findobj('tag','edit_time_begin_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
                hObject=findobj('tag','edit_time_end_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
                hObject=findobj('tag','edit_time_begin');
                set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
                hObject=findobj('tag','edit_time_end');
                set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
                
                etc_trace_handle('redraw');
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
            
            if(~isempty(etc_trace_obj.trigger.time(:)))
                set(handles.listbox_time,'string',{etc_trace_obj.trigger.time(:)});
                set(handles.listbox_class,'string',{etc_trace_obj.trigger.event(:)});
            else
                set(handles.listbox_time,'string',{});
                set(handles.listbox_class,'string',{});
            end;
            guidata(hObject, handles);
            
            %update trace window
            hObject=findobj('tag','listbox_class');
            all_trigger =cellfun(@str2num,get(hObject,'String'));
            obj_listbox_trigger=findobj('tag','listbox_trigger');
            set(obj_listbox_trigger,'string',{unique(all_trigger)});
            all_trigger=unique(all_trigger);
            
            contents = cellstr(get(hObject,'String'));
            etc_trace_obj.trigger_now=str2num(contents{get(handles.listbox_class,'Value')});
            set(obj_listbox_trigger,'Value',find(all_trigger==etc_trace_obj.trigger_now));
            
            obj_listbox_time=findobj('tag','listbox_time');
            contents = cellstr(get(obj_listbox_time,'String'));
            etc_trace_obj.trigger_time_idx=str2num(contents{get(obj_listbox_time,'Value')});
            hObject=findobj('tag','edit_trigger_time_idx');
            set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
            hObject=findobj('tag','edit_trigger_time');
            set(hObject,'String',sprintf('%1.3f',etc_trace_obj.trigger_time_idx./etc_trace_obj.fs));
            
            set(handles.edit_time,'Value',etc_trace_obj.trigger_time_idx);
            set(handles.edit_class,'Value',etc_trace_obj.trigger_now);
            set(handles.edit_time,'String',etc_trace_obj.trigger_time_idx);
            set(handles.edit_class,'String',etc_trace_obj.trigger_now);
            
            a=etc_trace_obj.trigger_time_idx-round(etc_trace_obj.time_duration_idx/5)+1;
            b=a+etc_trace_obj.time_duration_idx;
            
            if(a>=1&&b<=size(etc_trace_obj.data,2))
                etc_trace_obj.time_begin_idx=a;
                etc_trace_obj.time_end_idx=b;
                
                %time slider
                hObject_slider=findobj('tag','slider_time_idx');
                v=(etc_trace_obj.time_begin_idx-1)/(size(etc_trace_obj.data,2)-etc_trace_obj.time_duration_idx);
                set(hObject_slider,'value',v);
                
                %time edit
                hObject=findobj('tag','edit_time_begin_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.time_begin_idx));
                hObject=findobj('tag','edit_time_end_idx');
                set(hObject,'String',sprintf('%d',etc_trace_obj.time_end_idx));
                hObject=findobj('tag','edit_time_begin');
                set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_begin_idx-1))./etc_trace_obj.fs));
                hObject=findobj('tag','edit_time_end');
                set(hObject,'String',sprintf('%1.3f',((etc_trace_obj.time_end_idx-1))./etc_trace_obj.fs));
                
                etc_trace_handle('redraw');
            end;
            
            %get focus back to trigger window
            figure(etc_trace_obj.fig_tigger);
            
        catch ME
        end;
    end;
end;
