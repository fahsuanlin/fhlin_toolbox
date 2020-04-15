function varargout = etc_trace_avg_gui(varargin)
% ETC_TRACE_AVG_GUI MATLAB code for etc_trace_avg_gui.fig
%      ETC_TRACE_AVG_GUI, by itself, creates a new ETC_TRACE_AVG_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_AVG_GUI returns the handle to a new ETC_TRACE_AVG_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_AVG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_AVG_GUI.M with the given input arguments.
%
%      ETC_TRACE_AVG_GUI('Property','Value',...) creates a new ETC_TRACE_AVG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_avg_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_avg_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_avg_gui

% Last Modified by GUIDE v2.5 14-Apr-2020 19:24:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_avg_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_avg_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_avg_gui is made visible.
function etc_trace_avg_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_avg_gui (see VARARGIN)

% Choose default command line output for etc_trace_avg_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


global etc_trace_obj;


if(isfield(etc_trace_obj,'avg'))
    if(~isempty(etc_trace_obj.avg))
        
    else
        etc_trace_obj.avg.time_pre=0.2; %0.2 s baseline
        etc_trace_obj.avg.time_post=1.0; %0.2 s baseline
        etc_trace_obj.avg.flag_baseline_correct=0; %no baseline correction
        etc_trace_obj.avg.flag_trials=0;
    end
else
    etc_trace_obj.avg.time_pre=0.2; %0.2 s baseline
    etc_trace_obj.avg.time_post=1.0; %0.2 s baseline
    etc_trace_obj.avg.flag_baseline_correct=0; %no baseline correction
    etc_trace_obj.avg.flag_trials=0;
end;

hObject=findobj('tag','edit_avg_time_pre');
set(hObject,'String',sprintf('%1.1f',etc_trace_obj.avg.time_pre));
hObject=findobj('tag','edit_avg_time_post');
set(hObject,'String',sprintf('%1.1f',etc_trace_obj.avg.time_post));
hObject=findobj('tag','checkbox_avg_baseline_correct');
set(hObject,'Value',etc_trace_obj.avg.flag_baseline_correct);


%trigger loading
str={};
if(~isempty(etc_trace_obj.trigger))
    fprintf('trigger loaded...\n');
    str=unique(etc_trace_obj.trigger.event);
    set(handles.listbox_avg_trigger,'string',str);
else
    set(handles.listbox_avg_trigger,'string',{});
end;

for i=1:length(str)
    if(strcmp(etc_trace_obj.trigger_now,str{i}))
        break;
    end;
end;
set(handles.listbox_avg_trigger,'Value',i);


% UIWAIT makes etc_trace_avg_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_avg_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in checkbox_avg_baseline_correct.
function checkbox_avg_baseline_correct_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_avg_baseline_correct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_avg_baseline_correct

global etc_trace_obj;

etc_trace_obj.avg.flag_baseline_correct=get(hObject,'Value'); %no baseline correction



function edit_avg_time_pre_Callback(hObject, eventdata, handles)
% hObject    handle to edit_avg_time_pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_avg_time_pre as text
%        str2double(get(hObject,'String')) returns contents of edit_avg_time_pre as a double
global etc_trace_obj;

get(hObject,'String');
etc_trace_obj.avg.time_pre=-str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_avg_time_pre_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_avg_time_pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_avg_time_post_Callback(hObject, eventdata, handles)
% hObject    handle to edit_avg_time_post (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_avg_time_post as text
%        str2double(get(hObject,'String')) returns contents of edit_avg_time_post as a double
global etc_trace_obj;

get(hObject,'String');
etc_trace_obj.avg.time_post=str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function edit_avg_time_post_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_avg_time_post (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_avg_go.
function pushbutton_avg_go_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_avg_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global etc_trace_obj;


if(isempty(etc_trace_obj.trigger)) return; end;
if(isempty(etc_trace_obj.trigger_now)) return; end;

if(~etc_trace_obj.flag_trigger_avg)
    IndexC = strcmp(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
    trigger_match_idx = find(IndexC);
    trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
    trigger_match_time_idx=sort(trigger_match_time_idx);
    fprintf('[%d] trigger {%s} found at time index [%s].\n',length(trigger_match_idx),etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx));
    
    
    
    
    tmp=[];
    aux_tmp={};
    
    trials=[];
    aux_trials={};
    for idx=1:length(etc_trace_obj.aux_data)
        aux_tmp{idx}=[];
    end;
    n_avg=0;
    
    time_pre_idx=round(etc_trace_obj.fs*etc_trace_obj.avg.time_pre);
    time_post_idx=round(etc_trace_obj.fs*etc_trace_obj.avg.time_post);
    
    
    %%% calculate AVG....
    for idx=1:length(trigger_match_time_idx)
        if((trigger_match_time_idx(idx)-time_pre_idx>=1)&&(trigger_match_time_idx(idx)+time_post_idx<=size(etc_trace_obj.data,2)))
            if(isempty(tmp))
                if(etc_trace_obj.avg.flag_baseline_correct)
                    tmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    tmp=tmp-repmat(mean(tmp(:,1:time_pre_idx),2),[1 size(tmp,2)]);
                else
                    tmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                end;
                
                if(etc_trace_obj.avg.flag_trials)
                    trials(:,:,n_avg+1)=tmp;
                end;
            else
                if(etc_trace_obj.avg.flag_baseline_correct)
                    ttmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]); 
                    tmp=tmp+ttmp;
                else
                    ttmp=etc_trace_obj.data(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                    tmp=tmp+ttmp;
                end;
                if(etc_trace_obj.avg.flag_trials)
                    trials(:,:,n_avg+1)=ttmp;
                end;
            end;
            
            for ii=1:length(etc_trace_obj.aux_data)
                if(isempty(aux_tmp{ii}))
                    if(etc_trace_obj.avg.flag_baseline_correct)
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]); 
                        aux_tmp{ii}=ttmp;
                    else
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        aux_tmp{ii}=ttmp;
                    end;
                    if(etc_trace_obj.avg.flag_trials)
                        aux_trials{ii}(:,:,n_avg+1)=ttmp;
                    end;
                else
                    if(etc_trace_obj.avg.flag_baseline_correct)
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        ttmp=ttmp-repmat(mean(ttmp(:,1:time_pre_idx),2),[1 size(ttmp,2)]); 
                        aux_tmp{ii}=aux_tmp{ii}+ttmp;
                    else
                        ttmp=etc_trace_obj.aux_data{ii}(:,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx);
                        aux_tmp{ii}=aux_tmp{ii}+ttmp;
                    end;
                    if(etc_trace_obj.avg.flag_trials)
                        aux_trials{ii}(:,:,n_avg+1)=ttmp;
                    end;
                end;
            end;
            
            %figure(10);
            %subplot(211); plot(etc_trace_obj.data(1:31,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx)'); subplot(212); plot(etc_trace_obj.aux_data{idx}(1:31,trigger_match_time_idx(idx)-time_pre_idx:trigger_match_time_idx(idx)+time_post_idx)');
            
            n_avg=n_avg+1;
        end;
    end;
    tmp=tmp./n_avg;
    for idx=1:length(etc_trace_obj.aux_data)
        aux_tmp{idx}=aux_tmp{idx}./n_avg;
    end;
    fprintf('[%d] trials averaged...\n',n_avg);
    etc_trace_obj.avg.n_avg=n_avg;
    
    etc_trace_obj.avg.trials=trials;
    etc_trace_obj.avg.aux_trials=aux_trials;

    %update data
    etc_trace_obj.buffer.data=etc_trace_obj.data;
    etc_trace_obj.buffer.aux_data=etc_trace_obj.aux_data;
    etc_trace_obj.buffer.trigger_now=etc_trace_obj.trigger_now;
    etc_trace_obj.buffer.trigger=etc_trace_obj.trigger;
    etc_trace_obj.buffer.time_begin=etc_trace_obj.time_begin;
    etc_trace_obj.buffer.time_select_idx=etc_trace_obj.time_select_idx;
    etc_trace_obj.buffer.time_window_begin_idx=etc_trace_obj.time_window_begin_idx;
    etc_trace_obj.buffer.time_duration_idx=etc_trace_obj.time_duration_idx;
    etc_trace_obj.buffer.ylim=etc_trace_obj.ylim;
    
    
    etc_trace_obj.data=tmp;
    etc_trace_obj.aux_data=aux_tmp;
    etc_trace_obj.trigger=[];
    etc_trace_obj.time_begin=-etc_trace_obj.avg.time_pre;
    etc_trace_obj.time_select_idx=1;
    etc_trace_obj.time_window_begin_idx=1;
    hObject=findobj('tag','listbox_time_duration');
    contents = cellstr(get(hObject,'String'));
    etc_trace_obj.time_duration_idx=round(str2num(contents{get(hObject,'Value')})*etc_trace_obj.fs);
    
    etc_trcae_gui_update_time;
    
    
    hObject=findobj('tag','checkbox_trigger_avg');
    set(hObject,'Value',1);
    
    hObject=findobj('tag','listbox_trigger');
    set(hObject,'Enable','off');
    hObject=findobj('tag','pushbutton_trigger_rr');
    set(hObject,'Enable','off');
    hObject=findobj('tag','pushbutton_trigger_ff');
    set(hObject,'Enable','off');    
    hObject=findobj('tag','edit_trigger_time_idx');
    set(hObject,'Enable','off');  
    hObject=findobj('tag','edit_trigger_time');
    set(hObject,'Enable','off');
    
    etc_trace_obj.flag_trigger_avg=1;
end;


% --- Executes on button press in pushbutton_avg_export.
function pushbutton_avg_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_avg_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

if(etc_trace_obj.flag_trigger_avg)
    erp.data=etc_trace_obj.data;
    erp.aux_data=etc_trace_obj.aux_data;
    erp.timeVec=[0:size(etc_trace_obj.data,2)-1]./etc_trace_obj.fs+etc_trace_obj.time_begin;
    erp.label=etc_trace_obj.ch_names;
    erp.trigger=etc_trace_obj.trigger_now;
    erp.n_avg=etc_trace_obj.avg.n_avg;
    erp.trials=etc_trace_obj.avg.trials;
    erp.aux_trials=etc_trace_obj.avg.aux_trials;
    
    assignin('base','erp',erp);
    fprintf('variables "erp" exported\n');
else
    fprintf('erp not calculated yet.\nskip!\n');
end;

% --- Executes on button press in pushbutton_avg_save.
function pushbutton_avg_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_avg_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;

if(etc_trace_obj.flag_trigger_avg)
    erp.data=etc_trace_obj.data;
    erp.aux_data=etc_trace_obj.aux_data;
    erp.timeVec=[0:size(etc_trace_obj.data,2)-1]./etc_trace_obj.fs+etc_trace_obj.time_begin;
    erp.label=etc_trace_obj.ch_names;
    erp.trigger=etc_trace_obj.trigger_now;
    erp.n_avg=etc_trace_obj.avg.n_avg;
    erp.trials=etc_trace_obj.avg.trials;
    erp.aux_trials=etc_trace_obj.avg.aux_trials;
    
    tstr=datestr(datetime('now'),'mmddyy_HHMMss');
    fn=sprintf('erp_trigger%s_%s.mat',erp.trigger,tstr);
    fprintf('saving [%s]...',fn);
    save(fn,'erp');
    
    fprintf('done!\n');
else
    fprintf('erp not calculated yet.\nskip!\n');
end;


% --- Executes on selection change in listbox_avg_trigger.
function listbox_avg_trigger_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_avg_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_avg_trigger contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_avg_trigger

global etc_trace_obj;

if(isempty(etc_trace_obj))
    return;
end;

contents = cellstr(get(hObject,'String'));
etc_trace_obj.trigger_now=contents{get(hObject,'Value')};
fprintf('selected trigger = {%s}.\n',etc_trace_obj.trigger_now);

%update the default event/trigger name in the event/trigger window
hObject=findobj('tag','edit_local_trigger_class');
if(~isempty(hObject))
    set(hObject,'string',etc_trace_obj.trigger_now);
end;


%IndexC = strfind(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
%trigger_match_idx = find(not(cellfun('isempty',IndexC)));
IndexC = strcmp(etc_trace_obj.trigger.event,etc_trace_obj.trigger_now);
trigger_match_idx = find(IndexC);
trigger_match_time_idx=etc_trace_obj.trigger.time(trigger_match_idx);
trigger_match_time_idx=sort(trigger_match_time_idx);
fprintf('[%d] trigger {%s} found at time index [%s].\n',length(trigger_match_idx),etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx));

%find the nearest one
[dummy,idx]=min(abs(trigger_match_time_idx-etc_trace_obj.time_select_idx));
if(idx<=1) idx=1; end;
etc_trace_obj.time_select_idx=trigger_match_time_idx(idx);
fprintf('now at the [%d]-th trigger {%s} found at time index [%s] <%1.3f s>.\n',idx,etc_trace_obj.trigger_now,mat2str(trigger_match_time_idx(idx)),trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin);

hObject=findobj('tag','edit_trigger_time');
set(hObject,'String',sprintf('%1.3f',trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin));
hObject=findobj('tag','edit_trigger_time_idx');
set(hObject,'String',sprintf('%d',trigger_match_time_idx(idx)));


%update even/trigger window
hObject=findobj('tag','edit_local_trigger_time');
if(~isempty(hObject))
    set(hObject,'String',sprintf('%1.3f',trigger_match_time_idx(idx)./etc_trace_obj.fs+etc_trace_obj.time_begin));
end;
hObject=findobj('tag','edit_local_trigger_time_idx');
if(~isempty(hObject))
    set(hObject,'String',sprintf('%d',trigger_match_time_idx(idx)));
end;
for ii=1:length(etc_trace_obj.trigger.time)
    if((etc_trace_obj.trigger.time(ii)==trigger_match_time_idx(idx))&&(strcmp(etc_trace_obj.trigger.event{ii},etc_trace_obj.trigger_now)))
        break;
    end;
end;
hObject=findobj('tag','listbox_time');
if(~isempty(hObject))
    set(hObject,'Value',ii);
end;
hObject=findobj('tag','listbox_time_idx');
if(~isempty(hObject))
    set(hObject,'Value',ii);
end;
hObject=findobj('tag','listbox_class');
if(~isempty(hObject))
    set(hObject,'Value',ii);
end;

%update trace window
hObject=findobj('tag','listbox_trigger');
str=get(hObject,'String');
for i=1:length(str)
    if(strcmp(str{i},etc_trace_obj.trigger_now))
        break;
    end;
end;
set(hObject,'Value',i);


% etc_trace_obj.data
% etc_trace_obj.fs
% etc_trace_obj.time_begin
% etc_trace_obj.time_select_idx;
% etc_trace_obj.time_window_begin_idx=round((str2double(get(hObject,'String'))-etc_trace_obj.time_begin).*etc_trace_obj.fs)+1;
% etc_trace_obj.time_duration_idx
% etc_trace_obj.flag_time_window_auto_adjust=0;
% if((etc_trace_obj.time_window_begin_idx>=1)&&((etc_trace_obj.time_window_begin_idx+etc_trace_obj.time_duration_idx-1)<=size(etc_trace_obj.data,2)))
     etc_trcae_gui_update_time;
% end;




% --- Executes during object creation, after setting all properties.
function listbox_avg_trigger_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_avg_trigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_avg_keep_trials.
function checkbox_avg_keep_trials_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_avg_keep_trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_avg_keep_trials
global etc_trace_obj;

etc_trace_obj.avg.flag_trials=get(hObject,'Value'); %no baseline correction
