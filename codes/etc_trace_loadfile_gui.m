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

switch lower(ext)
    case {'.eeg','.vmrk','.vhdr'}
        fprintf('reading EEG file [%s]....\n',fstem);
        
        headerFile=sprintf('%s/%s%s',path,fstem,'.vhdr');
        % first get the continuous data as a matlab array
        etc_trace_obj.data = double(bva_loadeeg(headerFile));
        
        % meta information such as samplingRate (fs), labels, etc
        [etc_trace_obj.fs etc_trace_obj.ch_names etc_trace_obj.meta] = bva_readheader(headerFile);
        
        %read maker file
        markerFile=sprintf('%s/%s%s',path,fstem,'.vmrk');
        etc_trace_obj.trigger=etc_read_vmrk(markerFile);
        
        flag_reref=etc_trace_obj.loadfile.flag_reref;
        %re-referencing
        if(flag_reref)
            fprintf('\tRe-referencing...\n');
            eeg_ref=mean(etc_trace_obj.data ,1);
            for ch_idx=1:size(etc_trace_obj.data,1)
                etc_trace_obj.data(ch_idx,:)=etc_trace_obj.data(ch_idx,:)-eeg_ref;
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
            for ch_idx=1:size(etc_trace_obj.data,1)
                etc_trace_obj.data(ch_idx,:) = filtfilt(a,b,etc_trace_obj.data(ch_idx,:));
            end;
        else
            fprintf('\tNo high-pass filtering...\n');
        end;
        
        
        time_trim=etc_trace_obj.loadfile.trim;
        %remove first few seconds (if needed....)
        if(~isempty(time_trim))
            time_trim_idx=round(time_trim*etc_trace_obj.fs);
            
            fprintf('\tData trimming [%1.1f] s data {(%d) samples}...\n',time_trim, time_trim_idx);
            etc_trace_obj.data=etc_trace_obj.data(:,time_trim_idx+1:end);
        else
            fprintf('\tNo data trimming...\n');
        end;
        
        hObject=findobj('tag','listbox_time_duration');
        contents = cellstr(get(hObject,'String'));
        ii=round(cellfun(@str2num,contents).*etc_trace_obj.fs);
        [dummy,vv]=min(abs(ii-size(etc_trace_obj.data,2)));
        round(str2num(contents{vv})*etc_trace_obj.fs);
        etc_trace_obj.time_duration_idx=round(str2num(contents{vv})*etc_trace_obj.fs);
        
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
