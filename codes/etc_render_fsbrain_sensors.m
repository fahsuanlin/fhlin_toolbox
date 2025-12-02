function varargout = etc_render_fsbrain_sensors(varargin)
% ETC_RENDER_FSBRAIN_SENSORS MATLAB code for etc_render_fsbrain_sensors.fig
%      ETC_RENDER_FSBRAIN_SENSORS, by itself, creates a new ETC_RENDER_FSBRAIN_SENSORS or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_SENSORS returns the handle to a new ETC_RENDER_FSBRAIN_SENSORS or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_SENSORS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_SENSORS.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_SENSORS('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_SENSORS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_sensors_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_sensors_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_sensors

% Last Modified by GUIDE v2.5 01-Dec-2025 13:19:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @etc_render_fsbrain_sensors_OpeningFcn, ...
    'gui_OutputFcn',  @etc_render_fsbrain_sensors_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    warning off;
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before etc_render_fsbrain_sensors is made visible.
function etc_render_fsbrain_sensors_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_sensors (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_sensors
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_sensors wait for user response (see UIRESUME)
% uiwait(handles.fig_electrode_gui);
global etc_render_fsbrain;

set(handles.slider_alpha,'value',get(etc_render_fsbrain.h,'facealpha'));
set(handles.checkbox_nearest_brain_surface,'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);
set(handles.checkbox_show_sensor_names,'value',etc_render_fsbrain.aux_point_label_flag);

if(~isempty(etc_render_fsbrain.aux_point_coords))
    fprintf('sensor specified...\n');
    for e_idx=1:size(etc_render_fsbrain.aux_point_coords,1)
        str{e_idx}=etc_render_fsbrain.aux_point_name{e_idx};
    end;
    set(handles.listbox_sensor,'String',str);
    guidata(hObject, handles);
    
    %set default sensor to the first one
    etc_render_fsbrain.aux_point_idx=1;
    
    
else
    set(handles.listbox_sensor,'string',{});
    guidata(hObject, handles);
end;


if(isempty(etc_render_fsbrain.aux_point_coords))
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            if(strcmp(c{i}.Tag,'button_sensor_add')|strcmp(c{i}.Tag,'button_sensor_load'))
                c{i}.Enable='on';
            else
                c{i}.Enable='off';
            end;
        end;
    end;
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_sensors_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_sensor.
function listbox_sensor_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_sensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_sensor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_sensor
global etc_render_fsbrain

etc_render_fsbrain.aux_point_idx=get(hObject,'Value');
tmp=cellstr(get(hObject,'String'));
fprintf('sensor [%s] selected.\n',tmp{etc_render_fsbrain.aux_point_idx});


surface_coord=etc_render_fsbrain.aux_point_coords(etc_render_fsbrain.aux_point_idx,:);

%etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'click_vertex_vox',click_vertex_vox);
try
    if(strcmp(etc_render_fsbrain.surf,'orig'))
        surface_orig_coord=surface_coord;
    else
        %fprintf('surface <%s> not "orig". Electrode contacts locations are updated to the nearest location of this surface.\n',etc_render_fsbrain.surf);
        
        tmp=surface_coord;
        
        vv=etc_render_fsbrain.vertex_coords;
        dist=sqrt(sum((vv-repmat([tmp(1),tmp(2),tmp(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
        surface_orig_coord=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:);
    end;
    
    try
        if(~isempty(etc_render_fsbrain.vol))
            v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
            click_vertex_vox=round(v(1:3))';
        else
            click_vertex_vox=[];
        end;
    catch ME
    end;
    
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'click_vertex_vox',click_vertex_vox);
catch ME
end;

guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function listbox_sensor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_sensor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_sensor_add.
function button_sensor_add_Callback(hObject, eventdata, handles)
% hObject    handle to button_sensor_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

etc_render_fsbrain.sensor_add_gui_ok=0;
etc_render_fsbrain.sensor_modify_flag=0;
etc_render_fsbrain.sensor_add_gui_h=etc_render_fsbrain_sensor_add_gui;
uiwait(etc_render_fsbrain.sensor_add_gui_h);
delete(etc_render_fsbrain.sensor_add_gui_h);

if(etc_render_fsbrain.sensor_add_gui_ok)
    %the first electrode
    if(~isfield(etc_render_fsbrain,'aux_point_coords'))
        etc_render_fsbrain.aux_point_coords=[];
        delete(etc_render_fsbrain.aux_point_coords_h);
        etc_render_fsbrain.aux_point_coords_h=[];
        etc_render_fsbrain.aux_point_name={};
        delete(etc_render_fsbrain.aux_point_name_h);
        etc_render_fsbrain.aux_point_name_h=[];
        etc_render_fsbrain.aux_point_color=[0 0 0.5];
        etc_render_fsbrain.aux_point_size=50;
        etc_render_fsbrain.aux_point_label_flag=1;
    end;
    
    %enable all uicontrols
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            c{i}.Enable='on';
        end;
    end;
    
    etc_render_fsbrain.aux_point_name{end+1}=etc_render_fsbrain.new_sensor.name;
    etc_render_fsbrain.aux_point_coords(end+1,:)=etc_render_fsbrain.click_coord(:).';


    %the first electrode
    if(length(etc_render_fsbrain.aux_point_name)==1)
        etc_render_fsbrain.aux_point_idx=1;
    end;
    
    
    %update electrode list in the GUI
    str={};
    for e_idx=1:length(etc_render_fsbrain.aux_point_name)
        str{e_idx}=etc_render_fsbrain.aux_point_name{e_idx};
    end;
    set(handles.listbox_sensor,'string',str);
    set(handles.listbox_sensor,'value',etc_render_fsbrain.aux_point_idx);
    
    etc_render_fsbrain_handle('redraw');

    guidata(hObject, handles);
end;


% --- Executes on button press in button_sensor_del.
function button_sensor_del_Callback(hObject, eventdata, handles)
% hObject    handle to button_sensor_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;


etc_render_fsbrain.aux_point_idx=get(handles.listbox_sensor,'Value');

answer = questdlg(sprintf('delete sensor [%s]?',etc_render_fsbrain.aux_point_name{etc_render_fsbrain.aux_point_idx}), ...
    'delete sensor', ...
    'yes','no','no');
% Handle response
switch answer
    case 'yes'
        
        %update electrode by ignoring the one to be deleted
        count=1;
        for e_idx=1:length(etc_render_fsbrain.aux_point_name)
            if(e_idx~=etc_render_fsbrain.aux_point_idx)
                aux_point_coords_buffer(count,:)=etc_render_fsbrain.aux_point_coords(e_idx,:);
                aux_point_name_buffer{count}=etc_render_fsbrain.aux_point_name{e_idx};
                count=count+1;
            end;
        end;
        
        
        if(~exist('aux_point_coords_buffer'))
            %no more sensor
            etc_render_fsbrain.aux_point_coords=[];
            delete(etc_render_fsbrain.aux_point_coords_h);
            etc_render_fsbrain.aux_point_coords_h=[];
            etc_render_fsbrain.aux_point_name={};
            delete(etc_render_fsbrain.aux_point_name_h);
            etc_render_fsbrain.aux_point_name_h=[];
            etc_render_fsbrain.aux_point_color=[1 0 0];
            etc_render_fsbrain.aux_point_size=0.005;
            etc_render_fsbrain.aux_point_label_flag=1;
            
            %update electrode list in the GUI
            etc_render_fsbrain.aux_point_idx=[];
            str={};
            set(handles.listbox_sensor,'string',str);
            guidata(hObject, handles);

            etc_render_fsbrain_handle('redraw');
            
            %disable all uicontrol except '+'
            if(isempty(etc_render_fsbrain.aux_point_name))
                c=struct2cell(handles);
                for i=1:length(c)
                    if(strcmp(c{i}.Type,'uicontrol'))
                        if(strcmp(c{i}.Tag,'button_sensor_add')|strcmp(c{i}.Tag,'button_sensor_load'))
                            c{i}.Enable='on';
                        else
                            c{i}.Enable='off';
                        end;
                    end;
                end;
            end;
        else
            etc_render_fsbrain.aux_point_coords=aux_point_coords_buffer;
            etc_render_fsbrain.aux_point_name=aux_point_name_buffer;
            
            %update sensor list in the GUI
            etc_render_fsbrain.aux_point_idx=1;
            str={};
            for e_idx=1:length(etc_render_fsbrain.aux_point_name)
                str{e_idx}=etc_render_fsbrain.aux_point_name{e_idx};
            end;
            set(handles.listbox_sensor,'string',str);
            set(handles.listbox_sensor,'value',etc_render_fsbrain.aux_point_idx);
            guidata(hObject, handles);
            
            
            etc_render_fsbrain_handle('redraw');
        end;
    case 'no'
end




% --- Executes on slider movement.
function slider_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to slider_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global etc_render_fsbrain;

set(etc_render_fsbrain.h,'facealpha',get(hObject,'Value'));
etc_render_fsbrain.alpha=get(hObject,'Value');
guidata(hObject, handles);

h=findobj('tag','slider_alpha');
set(h,'value',get(hObject,'Value'));

% --- Executes during object creation, after setting all properties.
function slider_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


% vv=etc_render_fsbrain.vertex_coords;
% 
% for idx=1:length(etc_render_fsbrain.aux_point_name)
%     dist=sqrt(sum((vv-repmat([etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3)],[size(vv,1),1])).^2,2));
%     [min_dist,min_dist_idx]=min(dist);
%     verts_electrode_idx(idx)=min_dist_idx;
% end;


sensor.name=etc_render_fsbrain.aux_point_name;
sensor.coords=etc_render_fsbrain.aux_point_coords;
    
assignin('base','sensor',sensor);
fprintf('variables "sensor" exported\n');



% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain

% vv=etc_render_fsbrain.vertex_coords;
% 
% for idx=1:length(etc_render_fsbrain.aux_point_name)
%     dist=sqrt(sum((vv-repmat([etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3)],[size(vv,1),1])).^2,2));
%     [min_dist,min_dist_idx]=min(dist);
%     verts_electrode_idx(idx)=min_dist_idx;
% end;

sensor.name=etc_render_fsbrain.aux_point_name;
sensor.coords=etc_render_fsbrain.aux_point_coords;


vertex=etc_render_fsbrain.vertex_coords;
face=etc_render_fsbrain.faces+1; %1-based faces!!

electrode_idx=knnsearch(etc_render_fsbrain.vertex_coords,sensor.coords);
electrode_name=sensor.name;

assignin('base','sensor',sensor);
[filename, pathname] = uiputfile('sensor.mat', 'Save sensor as');
if(filename)
    if(exist(filename))
        save(filename,'-append','sensor','electrode_idx','electrode_name','vertex','face');
    else
        save(filename,'sensor','electrode_idx','electrode_name','vertex','face');
    end;
    fprintf('variable "sensor" exported and saved in [%s]\n',filename);
end;

% --- Executes on button press in checkbox_nearest_brain_surface.
function checkbox_nearest_brain_surface_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_nearest_brain_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_nearest_brain_surface


global etc_render_fsbrain

etc_render_fsbrain.show_nearest_brain_surface_location_flag=get(hObject,'Value');

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    end;
end;

% --- Executes on button press in checkbox_show_sensor_names.
function checkbox_show_sensor_names_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_sensor_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_sensor_names
global etc_render_fsbrain

etc_render_fsbrain.aux_point_label_flag=get(hObject,'Value');

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in button_sensor_load.
function button_sensor_load_Callback(hObject, eventdata, handles)
% hObject    handle to button_sensor_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;
v = evalin('base', 'whos');
fn={v.name};
[indx,tf] = listdlg('PromptString','Select a variable...',...
    'SelectionMode','single',...
    'ListString',fn);
if(indx)
    var=fn{indx};
    evalin('base',sprintf('global etc_render_fsbrain; if(isfield(%s,''coords'')&&isfield(%s,''name'')) etc_render_fsbrain.tmp=1; else etc_render_fsbrain.tmp=0; end;',var,var));
    if(etc_render_fsbrain.tmp)
        %evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.aux_point_name=%s;',var));
        evalin('base',sprintf('etc_render_fsbrain.aux_point_name=%s.name; etc_render_fsbrain.aux_point_coords=%s.coords;',var,var));
        
        etc_render_fsbrain.aux_point_idx=1;
        str={};
        for e_idx=1:length(etc_render_fsbrain.aux_point_name)
            str{e_idx}=etc_render_fsbrain.aux_point_name{e_idx};
            %etc_render_fsbrain.aux_point_coords(e_idx,:)=[0 0 0];
        end;
        set(handles.listbox_sensor,'string',str);
        set(handles.listbox_sensor,'value',etc_render_fsbrain.aux_point_idx);
        guidata(hObject, handles);
        
        %enable all uicontrols
        c=struct2cell(handles);
        for i=1:length(c)
            if(strcmp(c{i}.Type,'uicontrol'))
                c{i}.Enable='on';
            end;
        end;
        
        etc_render_fsbrain_handle('redraw');
    else
        fprintf('A variable with fields ''coords'' and ''name'' must be provided!\n');
    end;
end;


% --- Executes on button press in button_mark.
function button_mark_Callback(hObject, eventdata, handles)
% hObject    handle to button_mark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

etc_render_fsbrain.aux_point_idx=get(handles.listbox_sensor,'Value');
etc_render_fsbrain.aux_point_coords(etc_render_fsbrain.aux_point_idx,:)=etc_render_fsbrain.click_coord(:)';

vv=etc_render_fsbrain.vertex_coords;

dist=sqrt(sum((vv-repmat([etc_render_fsbrain.click_coord(1),etc_render_fsbrain.click_coord(2),etc_render_fsbrain.click_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
etc_render_fsbrain.click_vertex=min_dist_idx;


etc_render_fsbrain_handle('redraw');


% --- Executes on button press in button_name.
function button_name_Callback(hObject, eventdata, handles)
% hObject    handle to button_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;


prompt = {'name:'};
dlgtitle = 'name';
dims = [1 35];
definput = {etc_render_fsbrain.aux_point_name{etc_render_fsbrain.aux_point_idx}};
answer = inputdlg(prompt,dlgtitle,dims,definput)


if(~isempty(answer))
    etc_render_fsbrain.aux_point_name{etc_render_fsbrain.aux_point_idx}=answer{1}

    str={};
    for e_idx=1:length(etc_render_fsbrain.aux_point_name)
        str{e_idx}=etc_render_fsbrain.aux_point_name{e_idx};
    end;
    set(handles.listbox_sensor,'string',str);
    set(handles.listbox_sensor,'value',etc_render_fsbrain.aux_point_idx);

end;

etc_render_fsbrain_handle('redraw');

% --- Executes on button press in button_snap.
function button_snap_Callback(hObject, eventdata, handles)
% hObject    handle to button_snap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain

if(get(hObject,'Value'))
    fprintf('snapped....\n');

    [a,b]=knnsearch(etc_render_fsbrain.vertex_coords,etc_render_fsbrain.aux_point_coords);
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.vertex_coords(a,:);
%         evalin('base',sprintf('global etc_render_fsbrain; if(isfield(%s,''coords'')&&isfield(%s,''name'')) etc_render_fsbrain.tmp=1; else etc_render_fsbrain.tmp=0; end;',var,var));
%     if(etc_render_fsbrain.tmp)
%         %evalin('base',sprintf('global etc_render_fsbrain; etc_render_fsbrain.aux_point_name=%s;',var));
%         evalin('base',sprintf('etc_render_fsbrain.aux_point_name=%s.name; etc_render_fsbrain.aux_point_coords=%s.coords;',var,var));
%         
%         etc_render_fsbrain.aux_point_idx=1;
%         str={};
%         for e_idx=1:length(etc_render_fsbrain.aux_point_name)
%             str{e_idx}=etc_render_fsbrain.aux_point_name{e_idx};
%             %etc_render_fsbrain.aux_point_coords(e_idx,:)=[0 0 0];
%         end;
%         set(handles.listbox_sensor,'string',str);
%         set(handles.listbox_sensor,'value',etc_render_fsbrain.aux_point_idx);
%         guidata(hObject, handles);
%         
%         %enable all uicontrols
%         c=struct2cell(handles);
%         for i=1:length(c)
%             if(strcmp(c{i}.Type,'uicontrol'))
%                 c{i}.Enable='on';
%             end;
%         end;
%         
%         etc_render_fsbrain_handle('redraw');
%     else
%         fprintf('A variable with fields ''coords'' and ''name'' must be provided!\n');
%     end;


end;

etc_render_fsbrain_handle('redraw');
