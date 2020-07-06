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

% Last Modified by GUIDE v2.5 15-Apr-2020 13:52:35

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

etc_trace_obj.fig_load_gui=gcf;
set(etc_trace_obj.fig_load_gui,'Name','Load data');

%initialization
etc_trace_obj.load_output=0;

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
if(~isempty(etc_trace_obj.data)) set(handles.edit_load_sf,'enable','off'); end;

if(~isempty(etc_trace_obj.time_begin))
    set(handles.edit_load_time_begin,'String',num2str(etc_trace_obj.time_begin));
else
    set(handles.edit_load_time_begin,'String','0.0');
end;
if(~isempty(etc_trace_obj.data)) set(handles.edit_load_time_begin,'enable','off'); end;


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
    set(handles.text_load_select,'String',mat2str(size(etc_trace_obj.select{etc_trace_obj.select_idx})));
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

pos0=get(etc_trace_obj.fig_trace,'outerpos');
pos1=get(handles.figure_load_gui,'outerpos');
set(handles.figure_load_gui,'outerpos',[pos0(1)+pos0(3) pos0(2)+pos0(4)-pos1(4) pos1(3) pos1(4)]);

set(handles.figure_load_gui,'WindowStyle','modal')

%waitfor(handles.figure_load_gui);

% UIWAIT makes etc_trace_load_gui wait for user response (see UIRESUME)
uiwait(handles.figure_load_gui);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_load_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

global etc_trace_obj;

% pos0=get(etc_trace_obj.fig_trace,'outerpos');
% pos1=get(handles.figure_load_gui,'outerpos');
% set(handles.figure_load_gui,'outerpos',[pos0(1)+pos0(3) pos0(2)+pos0(4)-pos1(4) pos1(3) pos1(4)]);
%
%
% waitfor(handles.figure_load_gui);

%varargout{1} = handles.output;
varargout{1} =etc_trace_obj.load_output;

% --- Executes on button press in pushbutton_load_ok.
function pushbutton_load_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;


%check variables....
if(~isempty(get(handles.edit_load_sf,'String')))
    str=get(handles.edit_load_sf,'String');
    if(str(1)~='[')
        evalin('base',sprintf('etc_trace_obj.fs=%s;',get(handles.edit_load_sf,'String')));
    end;
end;


 %info 
 obj=findobj('tag','text_info_datasize');
 if(~isempty(obj))
     set(obj,'String',mat2str(size(etc_trace_obj.data)));
 end;
 
 obj=findobj('tag','text_info_fs');
 if(~isempty(obj))
     set(obj,'String',mat2str(etc_trace_obj.fs));
 end;
 
 obj=findobj('tag','text_info_time_begin');
 if(~isempty(obj))
     set(obj,'String',mat2str(etc_trace_obj.time_begin));
 end;
 
 obj=findobj('tag','listbox_info_chnames');
 if(~isempty(obj))
     set(obj,'String',etc_trace_obj.ch_names);
 end;
 
%  obj=findobj('tag','listbox_info_auxdata');
%  if(~isempty(obj))
%      set(obj,'String','');
%  end;
%  
%  obj=findobj('tag','listbox_info_data');
%  if(~isempty(obj))
%      set(obj,'String','');
%  end;
        
        
etc_trace_obj.time_begin=str2num(get(handles.edit_load_time_begin,'String'));

obj=findobj('Tag','listbox_time_duration');
str=get(obj,'String');
idx=get(obj,'Value');
etc_trace_obj.time_duration_idx=round(etc_trace_obj.fs*str2double(str{idx}));
if(etc_trace_obj.time_duration_idx<2)
    if(idx<length(str))
        %select next wider span
        etc_trace_obj.time_duration_idx=round(etc_trace_obj.fs*str2double(str{idx+1}));
        set(obj,'Value',idx+1);
    else
        fprintf('the duration [%1.1f] (s) has less than 2 data samples!\nerror!\n',str{idx});
    end;
end;

%check loaded data entries...
ok=etc_trace_update_loaded_data(etc_trace_obj.load.montage,etc_trace_obj.load.select,etc_trace_obj.load.scale);

etc_trace_obj.load_output=ok;

delete(handles.figure_load_gui);

if(etc_trace_obj.load_output) %if everything is ok...
    etc_trcae_gui_update_time();
    etc_trace_handle('redraw');
end;

% --- Executes on button press in pushbutton_load_cancel.
function pushbutton_load_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

etc_trace_obj.load_output=0;

delete(handles.figure_load_gui);


% --- Executes on button press in pushbutton_load_var.
function pushbutton_load_var_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

cc=[
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0    0.4470    0.7410
    ]; %color order


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
            %             answer = questdlg('main or auxillary data?','Data',...
            %                 'main','auxillary','cancel','main');
            %             % Handle response
            %             switch answer
            %                 case 'main'
            %                     f_option = 1;
            %                 case 'auxillary'
            %                     f_option = 2;
            %                 case 'cancel'
            %                     f_option= 0;
            %             end
            
            
            prompt = {'name for the loaded data'};
            dlgtitle = '';
            dims = [1 35];
            %definput = {sprintf('data_%02d',length(etc_trace_obj.all_data)+1)};
            definput = {sprintf('%s',var)};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            name=answer{1};
            
            
            if(length(etc_trace_obj.all_data)<1) %main....
                evalin('base',sprintf('etc_trace_obj.tmp=%s; ',var));
                if(size(etc_trace_obj.tmp,1)~=length(etc_trace_obj.ch_names))
                    answer = questdlg('# of channel mis-match between data [%d] and channel name [%d]\nupdate channel name or abort?','Data',...
                        'update','abort','update');
                    % Handle response
                    switch answer
                        case 'update'
                            ch_names={};
                            for idx=1:size(etc_trace_obj.tmp,1)
                                ch_names{idx}=sprintf('%03d',idx);
                            end;
                            etc_trace_obj.ch_names=ch_names;
                            
                            set(handles.text_load_label,'String',sprintf('[%d] channel(s)',length(etc_trace_obj.ch_names)));
                            
                        case 'abort'
                            return;
                    end
                end;
                
                if(~etc_trace_obj.flag_trigger_avg)
                    evalin('base',sprintf('etc_trace_obj.data=%s; ',var));
                else
                    evalin('base',sprintf('etc_trace_obj.buffer.data=%s; ',var));
                end;
                evalin('base',sprintf('etc_trace_obj.all_data{1}=%s; ',var));
                %evalin('base',sprintf('etc_trace_obj.all_data_name{1}=%s; ',name));
                etc_trace_obj.all_data_color(1,:)=cc(mod(length(etc_trace_obj.all_data)-1,7)+1,:)
                etc_trace_obj.all_data_name{1}=name;
                etc_trace_obj.all_data_main_idx=1;
                etc_trace_obj.all_data_aux_idx=[0];
                
                obj=findobj('Tag','text_load_var');
                set(obj,'String',sprintf('%s',var));
                
                fprintf('main data loaded!\n');
                
                %data listbox in the control window
                obj=findobj('Tag','listbox_data');
                if(~isempty(obj))
                    %str=get(obj,'String');
                    str{1}=name;
                end;
                set(obj,'String',str);
                set(obj,'value',1);
 
                %data listbox in the info window
                obj=findobj('Tag','listbox_info_data');
                if(~isempty(obj))
                    %str=get(obj,'String');
                    str{1}=name;
                end;
                set(obj,'String',str);
                set(obj,'value',1);
                
                %aux. data listbox in the info window
                obj=findobj('Tag','listbox_info_auxdata');
                if(~isempty(obj))
                    %str=get(obj,'String');
                    str{1}=name;
                end;
                set(obj,'String',str);
                set(obj,'value',1);
                
                update_data;
                
                select=diag(ones(1,size(etc_trace_obj.data,1)));
                scaling=diag(ones(1,size(etc_trace_obj.data,1)));
                
                %append a selection and scaling variable for the imported
                %data
                etc_trace_update_loaded_data([],select,scaling,'select_name',sprintf('select_%s',name));
                
            else
                
                %                 %name = auxdatad_name_dialog;
                %                 prompt = {'name for the aux. data'};
                %                 dlgtitle = '';
                %                 dims = [1 35];
                %                 definput = {sprintf('aux_%02d',length(etc_trace_obj.aux_data)+1)};
                %                 answer = inputdlg(prompt,dlgtitle,dims,definput);
                %                 name=answer{1};
                
                %evalin('base',sprintf('etc_trace_obj.all_data{end+1}=%s; ',var));
                evalin('base',sprintf('etc_trace_obj.tmp=%s; ',var));
                
                
                %adjust all data such that nan is appended when necessary.
                for ii=1:length(etc_trace_obj.all_data)
                    ll(ii)=size(etc_trace_obj.all_data{ii},2);
                end;
                ll(end+1)=size(etc_trace_obj.tmp,2);
                mll=max(ll);
                for ii=1:length(etc_trace_obj.all_data)
                    etc_trace_obj.all_data{ii}(:,end+1:mll)=nan;
                end;
                etc_trace_obj.tmp(:,end+1:mll)=nan;
                etc_trace_obj.all_data{end+1}=etc_trace_obj.tmp;
                etc_trace_obj.all_data_color(end+1,:)=cc(mod(length(etc_trace_obj.all_data)-1,7)+1,:)
                
                etc_trace_obj.all_data_name{end+1}=name;
                etc_trace_obj.all_data_aux_idx=cat(2,etc_trace_obj.all_data_aux_idx,1);
                
                %evalin('base',sprintf('if(size(%s,1)~=size(etc_trace_obj.data,1)) etc_trace_obj.tmp=0; else etc_trace_obj.tmp=1; end',var));
                
                %if(etc_trace_obj.tmp==1)
                
                update_data;
                
%                 if(~etc_trace_obj.flag_trigger_avg)
%                     evalin('base',sprintf('tmp=length(etc_trace_obj.aux_data); etc_trace_obj.aux_data{tmp+1}=%s;',var));
%                     evalin('base',sprintf('if(~isfield(etc_trace_obj,''aux_data_name'')) etc_trace_obj.aux_data_name={}; end;',name));
%                     evalin('base',sprintf('etc_trace_obj.aux_data_name{tmp+1}=''%s'';',name));
%                 else
%                     evalin('base',sprintf('tmp=length(etc_trace_obj.buffer.aux_data); etc_trace_obj.buffer.aux_data{tmp+1}=%s;',var));
%                     evalin('base',sprintf('if(~isfield(etc_trace_obj.buffer,''aux_data_name'')) etc_trace_obj.buffer.aux_data_name={}; end;',name));
%                     evalin('base',sprintf('etc_trace_obj.buffer.aux_data_name{tmp+1}=''%s'';',name));
%                 end;
%                 
%                 if(~etc_trace_obj.flag_trigger_avg)
%                     if(size(etc_trace_obj.aux_data{end},2)<=size(etc_trace_obj.data,2)) %append 'nan' if aux data is too short....
%                         etc_trace_obj.aux_data{end}(:,end+1:size(etc_trace_obj.data,2))=nan;
%                         fprintf('Warning!! [nan] is added to the aux. data [%s].\n',name);
%                     end;
%                     
%                     
%                     %etc_trace_obj.aux_data_idx=zeros(1,length(etc_trace_obj.aux_data));
%                     etc_trace_obj.aux_data_idx(end+1)=1;
%                     
%                 else
%                     if(size(etc_trace_obj.buffer.aux_data{end},2)<=size(etc_trace_obj.buffer.data,2)) %append 'nan' if aux data is too short....
%                         etc_trace_obj.buffer.aux_data{end}(:,end+1:size(etc_trace_obj.buffer.data,2))=nan;
%                         fprintf('Wrning!! [nan] is added to the aux. data [%s].\n',name);
%                     end;
%                     
%                     %etc_trace_obj.buffer.aux_data_idx=zeros(1,length(etc_trace_obj.buffer.aux_data));
%                     etc_trace_obj.buffer.aux_data_idx(end+1)=1;
%                 end;
                
                obj=findobj('Tag','text_load_var');
                set(obj,'String',sprintf('%s',var));
                
                
%                 %data listbox in the control window
%                 obj=findobj('Tag','listbox_data');
%                 if(~isempty(obj))
%                     set(obj,'String',etc_trace_obj.all_data_name);
%                 end;
                
                
                %data listbox in the info window
                obj=findobj('Tag','listbox_info_data');
                if(~isempty(obj))
                    set(obj,'String',etc_trace_obj.all_data_name);
                    set(obj,'Min',0);
                    set(obj,'Max',length(etc_trace_obj.all_data_name));
                    set(obj,'Value',etc_trace_obj.all_data_main_idx);
                end;

                %aux. data listbox in the info window
                obj=findobj('Tag','listbox_info_auxdata');
                if(~isempty(obj))
                    set(obj,'String',etc_trace_obj.all_data_name);
                    set(obj,'Min',0);
                    set(obj,'Max',length(etc_trace_obj.all_data_name));
                    set(obj,'Value',find(etc_trace_obj.all_data_aux_idx));
                end;
                
                %data listbox in the control window
                obj=findobj('Tag','listbox_data');
                if(~isempty(obj))
                    set(obj,'String',etc_trace_obj.all_data_name);
                    set(obj,'Min',0);
                    set(obj,'Max',length(etc_trace_obj.all_data_name));
                    set(obj,'Value',etc_trace_obj.all_data_main_idx); %choose the last one; popup menu limits only one option
                end;
                
                fprintf('auxillary data [%s] loaded!\n',name);
                %end;
            end;
            
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
        evalin('base',sprintf('global etc_trace_obj; if(isfield(%s,''time'')&&isfield(%s,''event'')) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var,var));
        
        fprintf('Trying to load variable [%s] as the trigger...',var);
        if(etc_trace_obj.tmp)
            
            answer = questdlg('take as new or merge with the existed trigger?','Menu',...
                'take as new','merge','cancel','take as new');
            % Handle response
            switch answer
                case 'take as new'
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
        evalin('base',sprintf('global etc_trace_obj; if(length(%s)==size(etc_trace_obj.data,1)) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var));
        %evalin('base',sprintf('etc_trace_obj.tmp=1;',var,var));
        if(etc_trace_obj.tmp)
            fprintf('Trying to load variable [%s] as channel labels...',var);
            evalin('base',sprintf('etc_trace_obj.ch_names=%s; ',var));
            
            obj=findobj('Tag','text_load_label');
            set(obj,'String',sprintf('%s',var));
            
            set(handles.text_load_label,'String',sprintf('[%d] channel(s)',length(etc_trace_obj.ch_names)));
            
            fprintf('Done!\n');
        else
            fprintf('the first dimension of [%s] (%d) does not match that of data (%d). Error in loading the channel variable...\n',var,length(var),size(etc_trace_obj.data,1));
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
        evalin('base',sprintf('global etc_trace_obj; if(length(%s)==size(etc_trace_obj.data,1)) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var));
        fprintf('Trying to load variable [%s] as a selection variable...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.tmp=%s; ',var));
            etc_trace_obj.load.select=diag(etc_trace_obj.tmp(:));
            
            obj=findobj('Tag','text_load_select');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('Error in loading select variable [%s]! ',var);
            fprintf('The select variable must be of size [%s]!!....\n',mat2str([1 size(etc_trace_obj.data,1)]));
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
        evalin('base',sprintf('global etc_trace_obj; if(length(%s)==size(etc_trace_obj.data,1)) etc_trace_obj.tmp=1; else etc_trace_obj.tmp=0; end;',var));
        fprintf('Trying to load variable [%s] as a scaling variable...',var);
        if(etc_trace_obj.tmp)
            evalin('base',sprintf('etc_trace_obj.load.scale=%s; ',var));
            evalin('base',sprintf('etc_trace_obj.tmp=%s; ',var));
            etc_trace_obj.load.scale=diag(etc_trace_obj.tmp(:));
            
            
            obj=findobj('Tag','text_load_scale');
            set(obj,'String',sprintf('%s',var));
            fprintf('Done!\n');
        else
            fprintf('Error in loading scaling variable [%s]! ',var);
            fprintf('The select variable must be of size [%s]!!....\n',mat2str([1 size(etc_trace_obj.data,1)]));
        end;
        
    catch ME
    end;
end;



function name = auxdatad_name_dialog
global etc_trace_obj;

pos0=get(etc_trace_obj.fig_load_gui,'outerpos');

d = dialog('OuterPosition',[pos0(1) pos0(2)-150 250 150],'Name','Name for the aux. data');

edit = uicontrol('Parent',d,...
    'Style','edit',...
    'Tag','edit',...
    'Position',[20 80 210 40],...
    'String',sprintf('aux_%02d', length(etc_trace_obj.aux_data)+1));

btn = uicontrol('Parent',d,...
    'Position',[89 20 70 25],...
    'String','Close',...
    'Callback',@btn_callback);

name='a';

uiwait(d);
return;

function btn_callback(btn,event)
obj=findobj(gcf,'Tag','edit');
name=get(obj,'String');
delete(gcf);
return;

function update_data()
global etc_trace_obj;

if(~isempty(etc_trace_obj.all_data_main_idx))
    if(~etc_trace_obj.flag_trigger_avg)
        etc_trace_obj.data=etc_trace_obj.all_data{etc_trace_obj.all_data_main_idx};
    else
        etc_trace_obj.buffer.data=etc_trace_obj.all_data{etc_trace_obj.all_data_main_idx};
    end;
else
    if(~etc_trace_obj.flag_trigger_avg)
        etc_trace_obj.data=[];
    else
        etc_trace_obj.buffer.data=[];        
    end;
end;

etc_trace_obj.aux_data={};
idx=find(etc_trace_obj.all_data_aux_idx);

if(~etc_trace_obj.flag_trigger_avg)
    for i=1:length(idx)
        etc_trace_obj.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
        etc_trace_obj.aux_data_color(i,:)=etc_trace_obj.all_data_color(idx(i),:);
    end;
    etc_trace_obj.aux_data_idx=idx;
else
    for i=1:length(idx)
        etc_trace_obj.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
        etc_trace_obj.aux_data_color(i,:)=etc_trace_obj.all_data_color(idx(i),:);
    end;
    etc_trace_obj.aux_data_idx=idx;
    
    etc_trace_obj.buffer.aux_data={};
    etc_trace_obj.buffer.aux_data_name={};
    etc_trace_obj.buffer.aux_data_color=[];   
    for i=1:length(idx)
        etc_trace_obj.buffer.aux_data{i}=etc_trace_obj.all_data{idx(i)};
        etc_trace_obj.buffer.aux_data_name{i}=etc_trace_obj.all_data_name{idx(i)};
        etc_trace_obj.buffer.aux_data_color(i,:)=etc_trace_obj.all_data_color(idx(i),:);
    end;
    etc_trace_obj.buffer.aux_data_idx=idx;    

    etc_trace_avg();
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

