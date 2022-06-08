function varargout = etc_trace_loadfile_gui(varargin)
% ETC_TRACE_LOADFILE_GUI MATLAB code for etc_trace_loadfile_gui.fig
%      ETC_TRACE_LOADFILE_GUI, by itself, creates a new ETC_TRACE_LOADFILE_GUI or raises the existing
%      singleton*.
%
%      H = ETC_TRACE_LOADFILE_GUI returns the handle to a new ETC_TRACE_LOADFILE_GUI or the handle to
%      the existing singleton*.
%
%      ETC_TRACE_LOADFILE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_TRACE_LOADFILE_GUI.M with the given input arguments.
%
%      ETC_TRACE_LOADFILE_GUI('Property','Value',...) creates a new ETC_TRACE_LOADFILE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_trace_loadfile_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_trace_loadfile_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_trace_loadfile_gui

% Last Modified by GUIDE v2.5 19-Apr-2020 14:34:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_trace_loadfile_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_trace_loadfile_gui_OutputFcn, ...
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


% --- Executes just before etc_trace_loadfile_gui is made visible.
function etc_trace_loadfile_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_trace_loadfile_gui (see VARARGIN)

% Choose default command line output for etc_trace_loadfile_gui
%handles.output = hObject;

% Update handles structure
%guidata(hObject, handles);

global etc_trace_obj;


%initialization


etc_trace_obj.loadfile.trim=0;
etc_trace_obj.loadfile.flag_hp=0;
etc_trace_obj.loadfile.flag_reref=0;
etc_trace_obj.loadfile.fstem='';
etc_trace_obj.loadfile.ext='';
etc_trace_obj.loadfile.path='';

set(handles.text_loadfile_filename,'String','');
set(handles.edit_loadfile_trim,'String','');
set(handles.checkbox_loadfile_hp,'Value',0);
set(handles.checkbox_loadfil_reference,'Value',0);

set(handles.figure_loadfile_gui,'units','pixel');

pos0=get(etc_trace_obj.fig_trace,'outerpos');
pos1=get(handles.figure_loadfile_gui,'outerpos');
set(handles.figure_loadfile_gui,'outerpos',[pos0(1)+pos0(3) pos0(2)+pos0(4)-pos1(4) pos1(3) pos1(4)]);
 
set(handles.figure_loadfile_gui,'WindowStyle','modal')
set(handles.figure_loadfile_gui,'Name','Load file');

%waitfor(handles.figure_loadfile_gui);

% UIWAIT makes etc_trace_loadfile_gui wait for user response (see UIRESUME)
uiwait(handles.figure_loadfile_gui);


% --- Outputs from this function are returned to the command line.
function varargout = etc_trace_loadfile_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

global etc_trace_obj;

% pos0=get(etc_trace_obj.fig_trace,'outerpos');
% pos1=get(handles.figure_loadfile_gui,'outerpos');
% set(handles.figure_loadfile_gui,'outerpos',[pos0(1)+pos0(3) pos0(2)+pos0(4)-pos1(4) pos1(3) pos1(4)]);
% 
% 
% waitfor(handles.figure_loadfile_gui);

%varargout{1} = handles.output;
varargout{1} =etc_trace_obj.load_output;

% --- Executes on button press in pushbutton_loadfile_ok.
function pushbutton_loadfile_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadfile_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_trace_obj;


if(isempty(etc_trace_obj.loadfile)) return; end;

fstem=etc_trace_obj.loadfile.fstem;
ext=etc_trace_obj.loadfile.ext;
path=etc_trace_obj.loadfile.path;


cc=[
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0    0.4470    0.7410
    ]; %color order


prompt = {'name for the loaded data'};
            dlgtitle = '';
            dims = [1 35];
            definput = {fstem};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            if(isempty(answer)) return; end;
            name=answer{1};

            
switch lower(ext)
    case {'.eeg','.vmrk','.vhdr'}
        fprintf('reading EEG file [%s]....\n',fstem);
        
        if(length(etc_trace_obj.all_data)<1)
            headerFile=sprintf('%s/%s%s',path,fstem,'.vhdr');
            % first get the continuous data as a matlab array
            etc_trace_obj.data = double(bva_loadeeg(headerFile));
            
            % meta information such as samplingRate (fs), labels, etc
            [etc_trace_obj.fs etc_trace_obj.ch_names etc_trace_obj.meta] = bva_readheader(headerFile);
            
            %read maker file
            markerFile=sprintf('%s/%s%s',path,fstem,'.vmrk');
            etc_trace_obj.trigger=etc_read_vmrk(markerFile);
            
        else
            headerFile=sprintf('%s/%s%s',path,fstem,'.vhdr');
            % first get the continuous data as a matlab array
            etc_trace_obj.tmp = double(bva_loadeeg(headerFile));
            
            
            [dummy1 ch_names_now ] = bva_readheader(headerFile);

            
            if(isfield(etc_trace_obj,'flag_topo_component'))
                if(etc_trace_obj.flag_topo_component) %PCA/ICA type topology
                    if(isfield(etc_trace_obj,'topo_component_ch'))
                        if(~isempty(etc_trace_obj.topo_component_ch))
                            topo_ch=etc_trace_obj.topo_component_ch;
                        end;
                    end;
                else
                    topo_ch=etc_trace_obj.ch_names; % time-domain topology
                end;
            else
                topo_ch=etc_trace_obj.ch_names; % time-domain topology
            end;
            
            Index=find(contains(ch_names_now,topo_ch));
            if(length(Index)<=length(topo_ch)) %all electrodes were found on topology
                for ii=1:length(topo_ch)
                    for idx=1:length(ch_names_now)
                        if(strcmp(ch_names_now{idx},topo_ch{ii}))
                            Index(ii)=idx;
                            electrode_data_idx(idx)=ii;
                        end;
                    end;
                end;
                if(isempty(Index))
                    fprintf('Cannot find corresponding channels!\nError in loading the data!\n');
                    return;
                end;
                etc_trace_obj.tmp=etc_trace_obj.tmp(electrode_data_idx,:);
            else
                etc_trace_obj.tmp=[];
                fprintf('Error in finding the corresponding channel names!\n'); return;
            end;
            
            
%            if(size(etc_trace_obj.tmp,1)~=size(etc_trace_obj.data,1))
%                fprintf('The number of the channedl of the loaded variable [%d] is not equal to the number of the channel of the existed data [%d]!Error!\n',size(etc_trace_obj.tmp,1), size(etc_trace_obj.data,1));
%                return;
%            end;
        end;
        
        
        
        flag_reref=etc_trace_obj.loadfile.flag_reref;
        %re-referencing
        if(flag_reref)
            fprintf('\tRe-referencing...\n');
            if(length(etc_trace_obj.all_data)<1)
                eeg_ref=mean(etc_trace_obj.data ,1);
                for ch_idx=1:size(etc_trace_obj.data,1)
                    etc_trace_obj.data(ch_idx,:)=etc_trace_obj.data(ch_idx,:)-eeg_ref;
                end;
            else
                eeg_ref=mean(etc_trace_obj.tmp ,1);
                for ch_idx=1:size(etc_trace_obj.tmp,1)
                    etc_trace_obj.tmp(ch_idx,:)=etc_trace_obj.tmp(ch_idx,:)-eeg_ref;
                end;
            end;
        else
            fprintf('\tNo re-referencing...\n');
            eeg_ref=[];
        end;
        
        flag_hp=etc_trace_obj.loadfile.flag_hp;
        %high-pass filtering
        if(flag_hp)
            fprintf('\tHigh-pass filtering at 0.1 Hz...\n');
            %high-pass filtering (0.1 Hz)
            Wn = 0.1*2/etc_trace_obj.fs;
            N = 3; % order of 3 less processing
            [a,b] = butter(N,Wn,'high'); %bandpass filtering
            if(length(etc_trace_obj.all_data)<1)
                for ch_idx=1:size(etc_trace_obj.data,1)
                    etc_trace_obj.data(ch_idx,:) = filtfilt(a,b,etc_trace_obj.data(ch_idx,:));
                end;
            else
                for ch_idx=1:size(etc_trace_obj.tmp,1)
                    etc_trace_obj.tmp(ch_idx,:) = filtfilt(a,b,etc_trace_obj.tmp(ch_idx,:));
                end;
            end;
        else
            fprintf('\tNo high-pass filtering...\n');
        end;
        
        
        time_trim=etc_trace_obj.loadfile.trim;
        %remove first few seconds (if needed....)
        if(~isempty(time_trim))
            time_trim_idx=round(time_trim*etc_trace_obj.fs);
            
            fprintf('\tData trimming [%1.1f] s data {(%d) samples}...\n',time_trim, time_trim_idx);
            if(length(etc_trace_obj.all_data)<1)
                etc_trace_obj.data=etc_trace_obj.data(:,time_trim_idx+1:end);
            else
                etc_trace_obj.tmp=etc_trace_obj.tmp(:,time_trim_idx+1:end);
            end;
        else
            fprintf('\tNo data trimming...\n');
        end;
        
        
        if(length(etc_trace_obj.all_data)<1)
            hObject=findobj('tag','listbox_time_duration');
            contents = cellstr(get(hObject,'String'));
            ii=round(cellfun(@str2num,contents).*etc_trace_obj.fs);
            [dummy,vv]=min(abs(ii-size(etc_trace_obj.data,2)));
            round(str2num(contents{vv})*etc_trace_obj.fs);
            etc_trace_obj.time_duration_idx=round(str2num(contents{vv})*etc_trace_obj.fs);
            
            %etc_trace_obj.time_duration_idx=round(etc_trace_obj.fs*str2double(str{6})); %default: 10-s
            
            etc_trace_obj.load.montage=[];
            etc_trace_obj.load.select=[];
            etc_trace_obj.load.scale=[];
            
            ok=etc_trace_update_loaded_data(etc_trace_obj.load.montage,etc_trace_obj.load.select,etc_trace_obj.load.scale);
            
            etc_trace_obj.load_output=ok;
            
            delete(handles.figure_loadfile_gui);
            
            if(etc_trace_obj.load_output) %if everything is ok...
                etc_trcae_gui_update_time();
                %etc_trace_handle('redraw');
            end;
            
            
        
            
            %if(~etc_trace_obj.flag_trigger_avg)
            %    evalin('base',sprintf('etc_trace_obj.data=%s; ',var));
            %else
            %    evalin('base',sprintf('etc_trace_obj.buffer.data=%s; ',var));
            %end;
            %evalin('base',sprintf('etc_trace_obj.all_data{1}=%s; ',var));
            
            etc_trace_obj.all_data{1}=etc_trace_obj.data;
            
            %evalin('base',sprintf('etc_trace_obj.all_data_name{1}=%s; ',name));
            etc_trace_obj.all_data_color(1,:)=cc(mod(length(etc_trace_obj.all_data)-1,7)+1,:)
            etc_trace_obj.all_data_name{1}=name;
            etc_trace_obj.all_data_main_idx=1;
            etc_trace_obj.all_data_aux_idx=[0];
            
            %obj=findobj('Tag','text_load_var');
            %set(obj,'String',sprintf('%s',var));
            
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
            
            %select=diag(ones(1,size(etc_trace_obj.data,1)));
            %scaling=diag(ones(1,size(etc_trace_obj.data,1)));
            
            %append a selection and scaling variable for the imported
            %data
            %etc_trace_update_loaded_data([],select,scaling,'select_name',sprintf('select_%s',name));
            
            
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
            
            
            
            %                 if(~isempty(montage))
            %                     for m_idx=1:length(montage)
            %
            %                         M=[];
            %                         ecg_idx=[];
            %                         for idx=1:size(montage{m_idx}.config,1)
            %                             m=zeros(1,length(etc_trace_obj.ch_names));
            %                             if(~isempty(montage{m_idx}.config{idx,1}))
            %                                 m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,1}))))=1;
            %                                 if((strcmp(lower(montage{m_idx}.config{idx,1}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,1}),'ekg')))
            %                                     ecg_idx=union(ecg_idx,idx);
            %                                 end;
            %                             end;
            %                             if(~isempty(montage{m_idx}.config{idx,2}))
            %                                 m(find(strcmp(lower(etc_trace_obj.ch_names),lower(montage{m_idx}.config{idx,2}))))=-1;;
            %                                 if((strcmp(lower(montage{m_idx}.config{idx,2}),'ecg')|strcmp(lower(montage{m_idx}.config{idx,2}),'ekg')))
            %                                     ecg_idx=union(ecg_idx,idx);
            %                                 end;
            %                             end;
            %                             M=cat(1,M,m);
            %                         end;
            %                         M(end+1,end+1)=1;
            %
            %                         etc_trace_obj.montage{m_idx+1}.config_matrix=M;
            %                         etc_trace_obj.montage{m_idx+1}.config=montage{m_idx}.config;
            %                         etc_trace_obj.montage{m_idx+1}.name=montage{m_idx}.name;
            %
            %                         S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
            %                         S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
            %                         etc_trace_obj.scaling{m_idx+1}=S;
            %
            %
            %                     end;
            %                     etc_trace_obj.montage_idx=m_idx+1;
            %                 end;
            
            
            
            
            %                if(isempty(select))
            select=eye(size(etc_trace_obj.data,1));
            select_name='all';
            %                end;
            etc_trace_obj.select{1}=[select, zeros(size(select,1),1)
                zeros(1,size(select,2)), 1];
            etc_trace_obj.select_name{1}=select_name;
            etc_trace_obj.select_idx=1;
            
            %                if(isempty(scaling))
            scaling{1}=eye(size(etc_trace_obj.data,1));
            %                else
            %                    scaling{1}=scaling;
            %                end;
            ecg_idx=find(strcmp(lower(etc_trace_obj.ch_names),'ecg')|strcmp(lower(etc_trace_obj.ch_names),'ekg'));
            scaling{1}(ecg_idx,ecg_idx)=scaling{1}(ecg_idx,ecg_idx)./10;
            etc_trace_obj.scaling{1}=[scaling{1}, zeros(size(scaling{1},1),1)
                zeros(1,size(scaling{1},2)), 1];
            etc_trace_obj.scaling_idx=1;
            
            
            
            
            
        else
            
            delete(handles.figure_loadfile_gui);

            %adjust all data such that nan is appended when necessary.
            for ii=1:length(etc_trace_obj.all_data)
                ll(ii)=size(etc_trace_obj.all_data{ii},2);
            end;
            ll(end+1)=size(etc_trace_obj.tmp,2);
            mll=max(ll);
            for ii=1:length(etc_trace_obj.all_data)
                fprintf('\tAppending NaN to the end of data [%d]...\n',ii);
                etc_trace_obj.all_data{ii}(:,end+1:mll)=nan;
            end;
            etc_trace_obj.tmp(:,end+1:mll)=nan;
                
            if(~isfield(etc_trace_obj,'all_data_color'))
                for ii=1:length(etc_trace_obj.all_data)
                    etc_trace_obj.all_data_color(ii,:)=cc(mod(ii-1,7)+1,:)
                end;
            end;
            etc_trace_obj.all_data{end+1}=etc_trace_obj.tmp;
            etc_trace_obj.all_data_color(end+1,:)=cc(mod(length(etc_trace_obj.all_data)-1,7)+1,:);
            
            etc_trace_obj.all_data_name{end+1}=name;
            etc_trace_obj.all_data_aux_idx=cat(2,etc_trace_obj.all_data_aux_idx,1);
            
            
            update_data;
            
            
            %obj=findobj('Tag','text_load_var');
            %set(obj,'String',sprintf('%s',var));
            
            
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
        
    otherwise
        fprintf('unknown format...\nerror!\n');
        
        delete(handles.figure_loadfile_gui);

end;


%etc_trace_obj.load_output=0;



% --- Executes on button press in pushbutton_loadfile_cancel.
function pushbutton_loadfile_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadfile_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

etc_trace_obj.load_output=0;

delete(handles.figure_loadfile_gui);


% --- Executes on button press in pushbutton_loadfile_filename.
function pushbutton_loadfile_filename_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadfile_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_trace_obj;

[file,path] = uigetfile({'*.eeg; *.vhdr; *.vmrk','EEG'; '*.*','All files'},'Select a file');
if(file~=0)
    [dummy,fstem,ext]=fileparts(file);
    
    obj=findobj('Tag','text_loadfile_filename');
    set(obj,'String',sprintf('%s%s',fstem,ext));
    
    etc_trace_obj.loadfile.path=path;
    etc_trace_obj.loadfile.file=file;
    etc_trace_obj.loadfile.fstem=fstem;
    etc_trace_obj.loadfile.ext=ext;

end;

  



function edit_loadfile_trim_Callback(hObject, eventdata, handles)
% hObject    handle to edit_loadfile_trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_loadfile_trim as text
%        str2double(get(hObject,'String')) returns contents of edit_loadfile_trim as a double

global etc_trace_obj;


etc_trace_obj.loafile.trim=str2double(get(hObject,'String'));




% --- Executes during object creation, after setting all properties.
function edit_loadfile_trim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_loadfile_trim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkbox_loadfile_hp.
function checkbox_loadfile_hp_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_loadfile_hp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_loadfile_hp

global etc_trace_obj;


etc_trace_obj.loadfile.flag_hp=get(hObject,'Value');



% --- Executes on button press in checkbox_loadfil_reference.
function checkbox_loadfil_reference_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_loadfil_reference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_loadfil_reference
global etc_trace_obj;


etc_trace_obj.loadfile.flag_reref=get(hObject,'Value');



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


