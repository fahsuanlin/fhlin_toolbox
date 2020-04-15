function varargout = etc_trace_load_gui(varargin)
% ETC_TRACE_LOAD_GUI MATLAB code for etc_trace_load_gui.fig
%      ETC_TRACE_LOAD_GUI, by itself, creates a new ETC_TRACE_LOAD_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_LOAD_GUI returns the handle to a new ETC_TRACE_LOAD_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_LOAD_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_LOAD_GUI.M with the given input arguments.
%
%      ETC_TRACE_LOAD_GUI('Property','Value',...) creates a new ETC_TRACE_LOAD_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_load_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_load_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_load_gui

% Last Modified by GUIDE v2.5 15-Apr-2020 01:34:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_load_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_load_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_load_gui is made visible.
function etc_trace_load_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_load_gui (see VARARGIN)

% Choose default command line output for etc_trace_load_gui
%handles.output = hObject;

% Update handles structure
%guidata(hObject, handles);

global etc_trace_obj;


%initialization
if(~isempty(etc_trace_obj.data))
    set(handles.text_load_var,'String',mat2str(size(etc_trace_obj.data)));
else
    set(handles.text_load_var,'String','');
end;
if(~isempty(etc_trace_obj.fs))
    set(handles.edit_load_sf,'String',num2str(etc_trace_obj.fs));
else
    set(handles.edit_load_sf,'String','');
end;
if(~isempty(etc_trace_obj.time_begin))
    set(handles.edit_load_time_begin,'String',num2str(etc_trace_obj.time_begin));
else
    set(handles.edit_load_time_begin,'String','0.0');
end;
if(~isempty(etc_trace_obj.trigger))
    set(handles.text_load_trigger,'String',sprintf('[%d] event/time',length(etc_trace_obj.trigger.time)));
else
    set(handles.text_load_trigger,'String','');
end;
if(~isempty(etc_trace_obj.ch_names))
    set(handles.text_load_label,'String',sprintf('[%d] channel(s)',length(etc_trace_obj.ch_names)));
else
    set(handles.text_load_label,'String','');
end;
if(~isempty(etc_trace_obj.montage))
    set(handles.text_load_montage,'String',sprintf('[%d] montage',length(etc_trace_obj.montage)));
else
    set(handles.text_load_montage,'String','');
end;
if(~isempty(etc_trace_obj.select))
    set(handles.text_load_select,'String',mat2str(size(etc_trace_obj.select)));
else
    set(handles.text_load_select,'String','');
end;
if(~isempty(etc_trace_obj.scaling))
    set(handles.text_load_scale,'String',sprintf('[%d] scaling',length(etc_trace_obj.scaling)));
else
    set(handles.text_load_scale,'String','');
end;
etc_trace_obj.load.montage=[];
etc_trace_obj.load.select=[];
etc_trace_obj.load.scale=[];


% UIWAIT makes etc_trace_load_gui wait for user response (see UIRESUME)
% uiwait(handles.figure_load_gui);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_load_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

global etc_trace_obj;

waitfor(handles.figure_load_gui);

%varargout{1} = handles.output;
varargout{1} =etc_trace_obj.load_output;

% --- Executes on button press in pushbutton_load_ok.
function pushbutton_load_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;



%check variables....
evalin('base',sprintf('etc_trace_obj.data=%s;',get(handles.text_load_var,'String')));
if(~isempty(get(handles.edit_load_sf,'String')))
    evalin('base',sprintf('etc_trace_obj.fs=%s;',get(handles.edit_load_sf,'String')));
end;
evalin('base',sprintf('etc_trace_obj.time_begin=%s;',get(handles.edit_load_time_begin,'String')));
if(~isempty(get(handles.text_load_trigger,'String')))
    evalin('base',sprintf('etc_trace_obj.trigger=%s;',get(handles.text_load_trigger,'String')));
end;
if(~isempty(get(handles.text_load_trigger,'String')))
    evalin('base',sprintf('etc_trace_obj.trigger=%s;',get(handles.text_load_trigger,'String')));
end;
if(~isempty(get(handles.text_load_label,'String')))
    evalin('base',sprintf('etc_trace_obj.ch_names=%s;',get(handles.text_load_label,'String')));
end;
obj=findobj('Tag','listbox_time_duration');
str=get(obj,'String');
idx=get(obj,'Value');
etc_trace_obj.time_duration_idx=round(etc_trace_obj.fs*str2double(str{idx}));

%check loaded data entries...
ok=update_loaded_data(etc_trace_obj.load.montage,etc_trace_obj.load.select,etc_trace_obj.load.scale);

etc_trace_obj.load_output=ok;

close(handles.figure_load_gui);

if(etc_trace_obj.load_output) %if everything is ok...
    etc_trcae_gui_update_time();
    %etc_trace_handle('redraw');
end;

% --- Executes on button press in pushbutton_load_cancel.
function pushbutton_load_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

etc_trace_obj.load_output=0;

close(handles.figure_load_gui);


% --- Executes on button press in pushbutton_load_var.
function pushbutton_load_var_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable for data...\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        evalin('base',sprintf('global etc_trace_obj; if(ndims(%s)==2) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        fprintf('Trying to load variable [%s] as the data...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.data=%s; ',var));

            obj=findobj('Tag','text_load_var');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('The chosen variable [%s] is not a 2D matrix. Rejected!\n',var);
        end;
        
    catch ME
    end;
end;






function edit_load_sf_Callback(hObject, eventdata, handles)
% hObject    handle to edit_load_sf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_load_sf as text
%        str2double(get(hObject,'String')) returns contents of edit_load_sf as a double


% --- Executes during object creation, after setting all properties.
function edit_load_sf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_load_sf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_load_time_begin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_load_time_begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_load_time_begin as text
%        str2double(get(hObject,'String')) returns contents of edit_load_time_begin as a double


% --- Executes during object creation, after setting all properties.
function edit_load_time_begin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_load_time_begin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_load_trigger.
function pushbutton_load_trigger_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable for trigger...\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        %evalin('base',sprintf('global etc_trace_obj; if(ndims(%s)==2) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        evalin('base',sprintf('etc_trace_obj.tmp=1;',var,var));
        fprintf('Trying to load variable [%s] as the trigger...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.data=%s; ',var));

            obj=findobj('Tag','text_load_trigger');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('error in loading the trigger variable...\n',var);
        end;
        
    catch ME
    end;
end;




% --- Executes on button press in pushbutton_load_label.
function pushbutton_load_label_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable for labels...\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        %evalin('base',sprintf('global etc_trace_obj; if(ndims(%s)==2) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        evalin('base',sprintf('etc_trace_obj.tmp=1;',var,var));
        fprintf('Trying to load variable [%s] as channel labels...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.data=%s; ',var));

            obj=findobj('Tag','text_load_label');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('error in loading the channel variable...\n',var);
        end;
        
    catch ME
    end;
end;


% --- Executes on button press in pushbutton_load_montage.
function pushbutton_load_montage_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable for data montage...\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        %evalin('base',sprintf('global etc_trace_obj; if(ndims(%s)==2) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        evalin('base',sprintf('etc_trace_obj.tmp=1;'));
        fprintf('Trying to load variable [%s] as montage...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.load.montage=%s; ',var));

            obj=findobj('Tag','text_load_montage');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('error in loading montage variable....\n',var);
        end;
        
    catch ME
    end;
end;


% --- Executes on button press in pushbutton_load_select.
function pushbutton_load_select_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable for data selection...\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        %evalin('base',sprintf('global etc_trace_obj; if(ndims(%s)==2) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        evalin('base',sprintf('etc_trace_obj.tmp=1;'));
        fprintf('Trying to load variable [%s] as select...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.load.select=%s; ',var));

            obj=findobj('Tag','text_load_select');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('error in loading select variable....\n',var);
        end;
        
    catch ME
    end;
end;

% --- Executes on button press in pushbutton_load_scale.
function pushbutton_load_scale_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

v = evalin('base', 'whos');
fn={v.name};

fprintf('load a variable for data scaling...\n');

[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
etc_trace_obj.tmp=0;
if(indx)
    try
        var=fn{indx};
        %evalin('base',sprintf('global etc_trace_obj; if(ndims(%s)==2) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        evalin('base',sprintf('etc_trace_obj.tmp=1;'));
        fprintf('Trying to load variable [%s] as scale...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.load.scale=%s; ',var));

            obj=findobj('Tag','text_load_scale');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('error in loading scale variable....\n',var);
        end;
        
    catch ME
    end;
end;


function ok=update_loaded_data(montage,select,scaling)

ok=0;

global etc_trace_obj;

try
    if(isempty(etc_trace_obj.ch_names))
        for idx=1:size(etc_trace_obj.data,1)
            etc_trace_obj.ch_names{idx}=sprintf('%03d',idx);
        end;
    end;
    
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

   
    if(length(etc_trace_obj.ch_names)~=size(etc_trace_obj.data,1)) return; end; %channel does not match data...
    
    %if(isempty(montage))
    mm=eye(size(etc_trace_obj.data,1));
    montage_name='original';
    
    config={};
    for idx=1:length(etc_trace_obj.ch_names);
        config{end+1,1}=etc_trace_obj.ch_names{idx};
        config{end,2}='';
    end;
    %end;
    etc_trace_obj.montage{1}.config_matrix=[mm, zeros(size(mm,1),1)
        zeros(1,size(mm,2)), 1];
    etc_trace_obj.montage{1}.config=config;
    etc_trace_obj.montage{1}.name=montage_name;
    etc_trace_obj.montage_idx=1;
    
    
    
    if(~isempty(montage))
        for m_idx=1:length(montage)
            
            M=[];
            ecg_idx=[];
            for idx=1:size(montage{m_idx}.config,1)
                m=zeros(1,length(etc_trace_obj.ch_names));
                if(~isempty(montage{m_idx}.config{idx,1}))
                    m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,1}))))=1;
                    if((strcmp(lower(montage{m_idx}.config{idx,1}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,1}),'ekg')))
                        ecg_idx=union(ecg_idx,idx);
                    end;
                end;
                if(~isempty(montage{m_idx}.config{idx,2}))
                    m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,2}))))=-1;;
                    if((strcmp(lower(montage{m_idx}.config{idx,2}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,2}),'ekg')))
                        ecg_idx=union(ecg_idx,idx);
                    end;
                end;
                M=cat(1,M,m);
            end;
            M(end+1,end+1)=1;
            
            etc_trace_obj.montage{m_idx+1}.config_matrix=M;
            etc_trace_obj.montage{m_idx+1}.config=montage{m_idx}.config;
            etc_trace_obj.montage{m_idx+1}.name=montage{m_idx}.name;
            
            S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
            S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
            etc_trace_obj.scaling{m_idx+1}=S;
        end;
        etc_trace_obj.montage_idx=m_idx+1;
    end;    
    
    
    if(isempty(select))
        select=eye(size(etc_trace_obj.data,1));
        select_name='all';
    end;
    etc_trace_obj.select=[select, zeros(size(select,1),1)
        zeros(1,size(select,2)), 1];
    etc_trace_obj.select_name=select_name;
    
    if(isempty(scaling))
        scaling{1}=eye(size(etc_trace_obj.data,1));
    else
        scaling{1}=scaling;
    end;
    ecg_idx=find(strcmp(lower(etc_trace_obj.ch_names),'ecg')|strcmp(lower(etc_trace_obj.ch_names),'ekg'));
    scaling{1}(ecg_idx,ecg_idx)=scaling{1}(ecg_idx,ecg_idx)./10;
    etc_trace_obj.scaling{1}=[scaling{1}, zeros(size(scaling{1},1),1)
        zeros(1,size(scaling{1},2)), 1];
    
    
    
    
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
            set(obj,'Value',find(IndexC));
        end;
    else
        if(isempty(str))
            etc_trace_obj.trigger_now='';
        else
            etc_trace_obj.trigger_now=str{1};
            set(obj,'Value',1);
        end;
    end;
    %guidata(hObject, handles);
    
    if(isfield(etc_trace_obj,'trigger_time_idx'))
        hObject=findobj('tag','edit_trigger_time_idx');
        set(hObject,'String',sprintf('%d',etc_trace_obj.trigger_time_idx));
        hObject=findobj('tag','edit_trigger_time');
        set(hObject,'String',sprintf('%1.3f',(etc_trace_obj.trigger_time_idx-1)./etc_trace_obj.fs+etc_trace_obj.time_begin));
    else
        hObject=findobj('tag','edit_trigger_time_idx');
        set(hObject,'String','');
        hObject=findobj('tag','edit_trigger_time');
        set(hObject,'String','');
    end;

    
    ok=1;
catch ME
    ok=0;
end;

return;

