function varargout = etc_render_fsbrain_electrode_gui(varargin)
% ETC_RENDER_FSBRAIN_ELECTRODE_GUI MATLAB code for etc_render_fsbrain_electrode_gui.fig
%      ETC_RENDER_FSBRAIN_ELECTRODE_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_ELECTRODE_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_ELECTRODE_GUI returns the handle to a new ETC_RENDER_FSBRAIN_ELECTRODE_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_ELECTRODE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_ELECTRODE_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_ELECTRODE_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_ELECTRODE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_electrode_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_electrode_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_electrode_gui
% Last Modified by GUIDE v2.5 02-Apr-2020 01:34:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_electrode_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_electrode_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_electrode_gui is made visible.
function etc_render_fsbrain_electrode_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_electrode_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_electrode_gui
handles.output = hObject;

% **************** ADD THIS SECTION ******************
% Check if scribeOverlay is a field and that it contains an annotation pane
if isfield(handles,'scribeOverlay') && isa(handles.scribeOverlay(1),'matlab.graphics.shape.internal.AnnotationPane')
    delete(handles.scribeOverlay);
    handles = rmfield(handles, 'scribeOverlay');
end
% **********************  END ************************

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_electrode_gui wait for user response (see UIRESUME)
% uiwait(handles.fig_electrode_gui);
global etc_render_fsbrain;

set(handles.slider_alpha,'value',get(etc_render_fsbrain.h,'facealpha'));
set(handles.checkbox_nearest_brain_surface,'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);
set(handles.checkbox_show_contact_names,'value',etc_render_fsbrain.show_contact_names_flag);
set(handles.checkbox_mri_view,'value',etc_render_fsbrain.show_all_contacts_mri_flag);
set(handles.edit_mri_view_depth,'string',sprintf('%1.1f',etc_render_fsbrain.show_all_contacts_mri_depth));
set(handles.checkbox_brain_surface,'value',etc_render_fsbrain.show_all_contacts_brain_surface_flag);

if(~isempty(etc_render_fsbrain.electrode))
    fprintf('electrodes specified...\n');
    str={};
    for e_idx=1:length(etc_render_fsbrain.electrode)
        str{e_idx}=etc_render_fsbrain.electrode(e_idx).name;
    end;
    set(handles.listbox_electrode,'string',str);
    guidata(hObject, handles);
    
    %set default electrode and contact to the first one
    etc_render_fsbrain.electrode_idx=1;
    etc_render_fsbrain.electrode_contact_idx=1;
    
    %update the electrode contact list box
    hObject=findobj('tag','listbox_contact');
    str={};
    for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
        str{c_idx}=sprintf('%d',c_idx);
    end;
    set(handles.listbox_contact,'string',str);
    guidata(hObject, handles);
    
    %initialize contact coordinates
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        flag_init=1;
        if(isfield(etc_render_fsbrain.electrode(e_idx),'coord'))
            if(~isempty(etc_render_fsbrain.electrode(e_idx).coord))
                flag_init=0;
            end;
        end;
        
        if(flag_init)
            for c_idx=1:etc_render_fsbrain.electrode(e).n_contact
                etc_render_fsbrain.electrode(e_idx).coord(c_idx,1)=0;
                etc_render_fsbrain.electrode(e_idx).coord(c_idx,2)=etc_render_fsbrain.electrode(e_idx).spacing.*(c_idx-1).*1;
                etc_render_fsbrain.electrode(e_idx).coord(c_idx,3)=etc_render_fsbrain.electrode(e_idx).spacing.*(e_idx-1).*1;

                etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                etc_render_fsbrain.aux2_point_name{count}=sprintf('%s_%d',etc_render_fsbrain.electrode(e_idx).name, c_idx);;
                count=count+1;
            end;            
        else
            for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                
                if(strcmp(etc_render_fsbrain.surf,'orig'))
                    
                else
                    fprintf('surface <%s> not "orig". Electrode contacts locations are updated to the nearest location of this surface.\n',etc_render_fsbrain.surf);
                    
                    tmp=etc_render_fsbrain.aux2_point_coords(count,:);
                    
                    vv=etc_render_fsbrain.orig_vertex_coords;
                    dist=sqrt(sum((vv-repmat([tmp(1),tmp(2),tmp(3)],[size(vv,1),1])).^2,2));
                    [min_dist,min_dist_idx]=min(dist);
                    if(~isnan(min_dist))
                        etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
                    end;
                end;
                
                
                count=count+1;
            end;
        end;
    end;
    
    
    
    %initialize contact mask
    etc_render_fsbrain.electrode_mask=zeros(length(etc_render_fsbrain.electrode),size(etc_render_fsbrain.aux2_point_coords,1));
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            etc_render_fsbrain.electrode_mask(e_idx,count)=1;
            count=count+1;
        end;
    end;
    
    
%     %update coordinates for electrode contacts
%     count=1;
%     for e_idx=1:length(etc_render_fsbrain.electrode)
%         for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
%             etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
%             count=count+1;
%         end;
%     end;
    
    
    %uncheck electrod contact locking
    set(handles.checkbox_electrode_contact_lock,'value',0);
    etc_render_fsbrain.electrode_contact_lock_flag=0;
    guidata(hObject, handles);
    
    %uncheck contact view update option
    %set(handles.checkbox_update_contact_view,'value',0);
    %etc_render_fsbrain.electrode_update_contact_view_flag=0;
    if(etc_render_fsbrain.electrode_update_contact_view_flag)
        set(handles.checkbox_update_contact_view,'value',1);
    else
        set(handles.checkbox_update_contact_view,'value',0);
    end;
    guidata(hObject, handles);

    count=0;
    for e_idx=1:etc_render_fsbrain.electrode_idx-1
        count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
    end;
    count=count+etc_render_fsbrain.electrode_contact_idx;
    
    surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

    etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
    
    try
%         vv=etc_render_fsbrain.orig_vertex_coords;
%         dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
%         [min_dist,min_dist_idx]=min(dist);
%         surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
%         etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
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
            %    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
            v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
            click_vertex_vox=round(v(1:3))';
        catch ME
        end;
        
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'click_vertex_vox',click_vertex_vox);
    catch ME
    end;
                
    etc_render_fsbrain_handle('redraw');

else
    set(handles.listbox_electrode,'string',{});
    guidata(hObject, handles);
end;

%uncheck electrod contact locking
set(handles.checkbox_electrode_contact_lock,'value',0);
etc_render_fsbrain.electrode_contact_lock_flag=0;
guidata(hObject, handles);


if(isempty(etc_render_fsbrain.electrode))
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            if(strcmp(c{i}.Tag,'button_electrode_add')|strcmp(c{i}.Tag,'button_electrode_load'))
                c{i}.Enable='on';
            else
                c{i}.Enable='off';
            end;
        end;
    end;
else
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            c{i}.Enable='on';
        end;
        
        if(strcmp(c{i}.Tag,'pushbutton_rotate_c'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_rotate_cc'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_move_right'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_move_left'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_move_up'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_move_down'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_move_more'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_move_less'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'button_optimize'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'button_optimize_sel'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'button_evaluate_cost'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'checkbox_electrode_contact_lock'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'edit_move'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'edit_rotate'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
        if(strcmp(c{i}.Tag,'pushbutton_goto'))
            if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                c{i}.Enable='off';
            end;
        end;
    end;
end;

% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_electrode_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_electrode.
function listbox_electrode_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_electrode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_electrode
global etc_render_fsbrain

etc_render_fsbrain.electrode_idx=get(hObject,'Value');

hObject=findobj('tag','listbox_contact');
for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
    str{c_idx}=sprintf('%d',c_idx);
end;
set(handles.listbox_contact,'string',str);

etc_render_fsbrain.electrode_contact_idx=1;
hObject=findobj('tag','listbox_contact');
set(hObject,'Value',1);

guidata(hObject, handles);

%uncheck electrod contact locking
set(handles.checkbox_electrode_contact_lock,'value',0);
etc_render_fsbrain.electrode_contact_lock_flag=0;
guidata(hObject, handles);

count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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
    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
    click_vertex_vox=round(v(1:3))';
catch ME
end;


etc_render_fsbrain.electrode_contact_coord_now=surface_orig_coord;

try
    vv=etc_render_fsbrain.orig_vertex_coords;
    dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
    [min_dist,min_dist_idx]=min(dist);
    %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
    if(etc_render_fsbrain.electrode_update_contact_view_flag)
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    end;
catch ME
end;
etc_render_fsbrain_handle('redraw');



% --- Executes during object creation, after setting all properties.
function listbox_electrode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_electrode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_electrode_add.
function button_electrode_add_Callback(hObject, eventdata, handles)
% hObject    handle to button_electrode_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;


if(~strcmp(etc_render_fsbrain.surf,'orig'))
    fprintf('surface <%s> not "orig". Skip!\n',etc_render_fsbrain.surf);
    return;
end;
           
etc_render_fsbrain.electrode_add_gui_ok=0;
etc_render_fsbrain.electrode_modify_flag=0;
etc_render_fsbrain.electrode_add_gui_h=etc_render_fsbrain_electrode_add_gui;
uiwait(etc_render_fsbrain.electrode_add_gui_h);
delete(etc_render_fsbrain.electrode_add_gui_h);

if(etc_render_fsbrain.electrode_add_gui_ok)
    %the first electrode
    if(~isfield(etc_render_fsbrain,'electrode')) 
        etc_render_fsbrain.electrode=[]; 
    end; 
    
    %enable all uicontrols
    c=struct2cell(handles);
    for i=1:length(c)
        if(strcmp(c{i}.Type,'uicontrol'))
            c{i}.Enable='on';
        end;
            if(strcmp(c{i}.Tag,'pushbutton_rotate_c'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_rotate_cc'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_right'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_left'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;        
            if(strcmp(c{i}.Tag,'pushbutton_move_up'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_down'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;    
            if(strcmp(c{i}.Tag,'pushbutton_move_more'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_less'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'button_optimize'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'button_optimize_sel'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'button_evaluate_cost'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'checkbox_electrode_contact_lock'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'edit_move'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'edit_rotate'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_goto'))
                if(isempty(etc_render_fsbrain.vol))
                    c{i}.Enable='off';
                end;
            end;
    end;
    
    %uncheck contact view update option
    %set(handles.checkbox_update_contact_view,'value',0);
    %etc_render_fsbrain.electrode_update_contact_view_flag=0;
    if(etc_render_fsbrain.electrode_update_contact_view_flag)
        set(handles.checkbox_update_contact_view,'value',1);
    else
        set(handles.checkbox_update_contact_view,'value',0);
    end;
    %guidata(hObject, handles);
    
    etc_render_fsbrain.electrode(end+1).name=etc_render_fsbrain.new_electrode.name;
    etc_render_fsbrain.electrode(end).spacing=etc_render_fsbrain.new_electrode.spacing;
    etc_render_fsbrain.electrode(end).n_contact=etc_render_fsbrain.new_electrode.n_contact;
    
    %the first electrode
    if(length(etc_render_fsbrain.electrode)==1)
        etc_render_fsbrain.electrode_idx=1;
        etc_render_fsbrain.electrode_contact_idx=1;
        etc_render_fsbrain.electrode_update_contact_view_flag=0;
    end;
    
    %initialize new electrode and update its contact coordinates
    e_idx=length(etc_render_fsbrain.electrode);
    count=size(etc_render_fsbrain.aux2_point_coords,1)+1;
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        %etc_render_fsbrain.electrode(e_idx).coord(c_idx,1)=0;
        %etc_render_fsbrain.electrode(e_idx).coord(c_idx,2)=etc_render_fsbrain.electrode(e_idx).spacing.*(c_idx-1).*1;
        %etc_render_fsbrain.electrode(e_idx).coord(c_idx,3)=etc_render_fsbrain.electrode(e_idx).spacing.*(e_idx-1).*1;
        tmp(1)=0;
        tmp(2)=etc_render_fsbrain.electrode(e_idx).spacing.*(c_idx-1).*1;
        tmp(3)=etc_render_fsbrain.electrode(e_idx).spacing.*(e_idx-1).*1;
        %etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=tmp(:)';
        etc_render_fsbrain.aux2_point_coords(count,:)=tmp(:);
        etc_render_fsbrain.aux2_point_name{count}=sprintf('%s_%d',etc_render_fsbrain.electrode(e_idx).name, c_idx);;
        
        
%         if(strcmp(etc_render_fsbrain.surf,'orig'))
%             
%         else
%             fprintf('surface <%s> not "orig". Electrode contacts locations are updated to the nearest location of this surface.\n',etc_render_fsbrain.surf);
%             
%             tmp=etc_render_fsbrain.aux2_point_coords(count,:);
%             
%             vv=etc_render_fsbrain.orig_vertex_coords;
%             dist=sqrt(sum((vv-repmat([tmp(1),tmp(2),tmp(3)],[size(vv,1),1])).^2,2));
%             [min_dist,min_dist_idx]=min(dist);
%             etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
%             %etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
%         end;
        
        
        count=count+1;
    end;
            
    
    %update contact mask
    etc_render_fsbrain.electrode_mask=zeros(length(etc_render_fsbrain.electrode),size(etc_render_fsbrain.aux2_point_coords,1));
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            etc_render_fsbrain.electrode_mask(e_idx,count)=1;
            count=count+1;
        end;
    end;    
    
%     %update coordinates for electrode contacts
%     count=1;
%     for e_idx=1:length(etc_render_fsbrain.electrode)
%         for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
%             etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
%             count=count+1;
%         end;
%     end;
    
    %update electrode list in the GUI
    %etc_render_fsbrain.electrode_idx=length(etc_render_fsbrain.electrode);
    str={};
    for e_idx=1:length(etc_render_fsbrain.electrode)
        str{e_idx}=etc_render_fsbrain.electrode(e_idx).name;
    end;
    set(handles.listbox_electrode,'string',str);
    set(handles.listbox_electrode,'value',etc_render_fsbrain.electrode_idx);
   
    %update contact list in the GUI
    %etc_render_fsbrain.electrode_contact_idx=1;
    str={};
    for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
        str{c_idx}=sprintf('%d',c_idx);
    end;
    set(handles.listbox_contact,'string',str);
    set(handles.listbox_contact,'value',etc_render_fsbrain.electrode_contact_idx);
    guidata(hObject, handles);
    
    etc_render_fsbrain_handle('redraw');

end;
    
    
% --- Executes on button press in button_electrode_del.
function button_electrode_del_Callback(hObject, eventdata, handles)
% hObject    handle to button_electrode_del (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;


etc_render_fsbrain.electrode_idx=get(handles.listbox_electrode,'Value');

answer = questdlg(sprintf('delete electrode [%s]?',etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).name), ...
    'delete electrode', ...
    'yes','no','no');
% Handle response
switch answer
    case 'yes'
        
        %update electrode by ignoring the one to be deleted
        count=1;
        for e_idx=1:length(etc_render_fsbrain.electrode)
            if(e_idx~=etc_render_fsbrain.electrode_idx)
                electrode_buffer(count)=etc_render_fsbrain.electrode(e_idx);
                count=count+1;
            end;
        end;
        
        
        if(~exist('electrode_buffer'))
            %no more electrode
            etc_render_fsbrain.electrode=[];
            
            %update electrode list in the GUI
            etc_render_fsbrain.electrode_idx=[];
            str={};
            set(handles.listbox_electrode,'string',str);
            %set(handles.listbox_electrode,'value',1);
            
            
            %update contact list in the GUI
            etc_render_fsbrain.electrode_contact_idx=[];
            str={};
            set(handles.listbox_contact,'string',str);
            %set(handles.listbox_contact,'value',1);
            guidata(hObject, handles);
            
            etc_render_fsbrain.electrode=[];
            etc_render_fsbrain.aux2_point_coords=[];
            etc_render_fsbrain.aux2_point_name={};
            
            etc_render_fsbrain.electrode_mask=[];
            
            %update figure;
            %if(etc_render_fsbrain.electrode_update_contact_view_flag)
            %    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
            %end;
            
            etc_render_fsbrain_handle('redraw');
            
            %disable all uicontrol except '+' and 'l'
            if(isempty(etc_render_fsbrain.electrode))
                c=struct2cell(handles);
                for i=1:length(c)
                    if(strcmp(c{i}.Type,'uicontrol'))
                        if(strcmp(c{i}.Tag,'button_electrode_add')|strcmp(c{i}.Tag,'button_electrode_load'))
                            c{i}.Enable='on';
                        else
                            c{i}.Enable='off';
                        end;
                    end;
                end;
            end;
        else
            etc_render_fsbrain.electrode=electrode_buffer;
            
            %update electrode list in the GUI
            etc_render_fsbrain.electrode_idx=1;
            str={};
            for e_idx=1:length(etc_render_fsbrain.electrode)
                str{e_idx}=etc_render_fsbrain.electrode(e_idx).name;
            end;
            set(handles.listbox_electrode,'string',str);
            set(handles.listbox_electrode,'value',etc_render_fsbrain.electrode_idx);
            
            %update contact list in the GUI
            etc_render_fsbrain.electrode_contact_idx=1;
            str={};
            for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
                str{c_idx}=sprintf('%d',c_idx);
            end;
            set(handles.listbox_contact,'string',str);
            set(handles.listbox_contact,'value',etc_render_fsbrain.electrode_contact_idx);
            guidata(hObject, handles);
            
            
            
            %initialize new electrode and update its contact coordinates
            count=1;
            etc_render_fsbrain.aux2_point_coords=[];
            for e_idx=1:length(etc_render_fsbrain.electrode)
                for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                    %etc_render_fsbrain.electrode(e_idx).coord(c_idx,1)=0;
                    %etc_render_fsbrain.electrode(e_idx).coord(c_idx,2)=etc_render_fsbrain.electrode(e_idx).spacing.*(c_idx-1).*1;
                    %etc_render_fsbrain.electrode(e_idx).coord(c_idx,3)=etc_render_fsbrain.electrode(e_idx).spacing.*(e_idx-1).*1;
                    
                    etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                    etc_render_fsbrain.aux2_point_name{count}=sprintf('%s_%d',etc_render_fsbrain.electrode(e_idx).name, c_idx);;
                    count=count+1;
                end;
            end;
            
            %update contact mask
            etc_render_fsbrain.electrode_mask=zeros(length(etc_render_fsbrain.electrode),size(etc_render_fsbrain.aux2_point_coords,1));
            count=1;
            for e_idx=1:length(etc_render_fsbrain.electrode)
                for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                    etc_render_fsbrain.electrode_mask(e_idx,count)=1;
                    count=count+1;
                end;
            end;
            
            %         %update coordinates for electrode contacts
            %         count=1;
            %         for e_idx=1:length(etc_render_fsbrain.electrode)
            %             for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            %                 etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
            %                 count=count+1;
            %             end;
            %         end;
            
            
            
            %find current contact
            count=0;
            for e_idx=1:etc_render_fsbrain.electrode_idx-1
                count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
            end;
            count=count+etc_render_fsbrain.electrode_contact_idx;
            
            surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
            v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
            click_vertex_vox=round(v(1:3))';
            
            etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
            
            vv=etc_render_fsbrain.orig_vertex_coords;
            dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
            [min_dist,min_dist_idx]=min(dist);
            %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
            
            %update figure;
            if(etc_render_fsbrain.electrode_update_contact_view_flag)
                etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
            end;
            
            etc_render_fsbrain_handle('redraw');
        end;
    case 'no'
end




% --- Executes on button press in pushbutton_rotate_cc.
function pushbutton_rotate_cc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_cc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);

theta=(etc_render_fsbrain.register_rotate_angle).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix

if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=(R*etc_render_fsbrain.aux_point_coords.').';
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    tmp=etc_render_fsbrain.aux2_point_coords.';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp-repmat(etc_render_fsbrain.electrode_contact_coord_now.',[1 size(tmp,2)]);
    end;
    tmp=(R*(mask.'.*tmp)).';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp+repmat(etc_render_fsbrain.electrode_contact_coord_now,[size(tmp,1),1]);
    end;
    
    etc_render_fsbrain.aux2_point_coords(find(mask(:)>eps))=tmp(find(mask(:)>eps));
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_rotate_c.
function pushbutton_rotate_c_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_rotate_c (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);


theta=-(etc_render_fsbrain.register_rotate_angle).*pi/180;
R=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix

if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=(R*etc_render_fsbrain.aux_point_coords.').';
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    tmp=etc_render_fsbrain.aux2_point_coords.';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp-repmat(etc_render_fsbrain.electrode_contact_coord_now.',[1 size(tmp,2)]);
    end;
    tmp=(R*(mask.'.*tmp)).';
    if(etc_render_fsbrain.electrode_contact_lock_flag)
        tmp=tmp+repmat(etc_render_fsbrain.electrode_contact_coord_now,[size(tmp,1),1]);
    end;
    
    etc_render_fsbrain.aux2_point_coords(find(mask(:)>eps))=tmp(find(mask(:)>eps));
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;
etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_move_up.
function pushbutton_move_up_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');

% --- Executes on button press in pushbutton_move_left.
function pushbutton_move_left_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(rr.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_move_right.
function pushbutton_move_right_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(rr.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(rr.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_move_down.
function pushbutton_move_down_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
figure(etc_render_fsbrain.fig_brain);
[az,el]=view;
[x,y,z] = sph2cart((az-90)*pi/180,el*pi/180,1);
[xr,yr,zr] = sph2cart((az)*pi/180,0,1);
oo=[x,y,z]'; %outward screen unit vector
rr=[xr,yr,zr]'; %right screen unit vector
uu = cross(oo,rr); %up screen unit vector

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');


function edit_rotate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotate as text
%        str2double(get(hObject,'String')) returns contents of edit_rotate as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
etc_render_fsbrain.register_rotate_angle=mm;

% --- Executes during object creation, after setting all properties.
function edit_rotate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global etc_render_fsbrain;
etc_render_fsbrain.register_rotate_angle=3; %default: 3 degrees
set(hObject,'value',etc_render_fsbrain.register_rotate_angle);
set(hObject,'string',sprintf('%1.0f',etc_render_fsbrain.register_rotate_angle));


function edit_move_Callback(hObject, eventdata, handles)
% hObject    handle to edit_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_move as text
%        str2double(get(hObject,'String')) returns contents of edit_move as a double
global etc_render_fsbrain
mm=str2double(get(hObject,'string'));
etc_render_fsbrain.register_translate_dist=mm./1e3;

% --- Executes during object creation, after setting all properties.
function edit_move_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

global etc_render_fsbrain;
etc_render_fsbrain.register_translate_dist=1e-3; %default: 1 mm
set(hObject,'value',etc_render_fsbrain.register_translate_dist);
set(hObject,'string',sprintf('%1.0f',etc_render_fsbrain.register_translate_dist.*1e3));


% --- Executes on selection change in listbox_contact.
function listbox_contact_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_contact contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_contact
global etc_render_fsbrain

tmp=get(hObject,'Value');
if(tmp~=etc_render_fsbrain.electrode_contact_idx)
    etc_render_fsbrain.electrode_contact_idx=tmp;
    
    %uncheck electrod contact locking
    set(handles.checkbox_electrode_contact_lock,'value',0);
    etc_render_fsbrain.electrode_contact_lock_flag=0;
end;
guidata(hObject, handles);

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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
%    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
    click_vertex_vox=round(v(1:3))';
catch ME
end;

etc_render_fsbrain.electrode_contact_coord_now=surface_orig_coord;
                    
try
    vv=etc_render_fsbrain.orig_vertex_coords;
    dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
    [min_dist,min_dist_idx]=min(dist);
    %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

    %update figure;
%    if(etc_render_fsbrain.electrode_update_contact_view_flag)
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',[],'click_vertex_vox',click_vertex_vox);
%    end;
catch ME
end;
etc_render_fsbrain_handle('redraw');


   
    
    

% --- Executes during object creation, after setting all properties.
function listbox_contact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_contact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_electrode_contact_lock.
function checkbox_electrode_contact_lock_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_electrode_contact_lock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_electrode_contact_lock
global etc_render_fsbrain

etc_render_fsbrain.electrode_contact_lock_flag=get(hObject,'Value');


% --- Executes on button press in pushbutton_move_more.
function pushbutton_move_more_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_more (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global etc_render_fsbrain
v1=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,:);
v2=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(end,:);
vv=v1-v2;
uu=vv.'./norm(vv);

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');




% --- Executes on button press in pushbutton_move_less.
function pushbutton_move_less_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_move_less (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain
v1=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,:);
v2=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(end,:);
vv=v2-v1;
uu=vv.'./norm(vv);

dist=-1.*etc_render_fsbrain.register_translate_dist.*1e3;
if(~isempty(etc_render_fsbrain.aux_point_coords))
    etc_render_fsbrain.aux_point_coords=etc_render_fsbrain.aux_point_coords+repmat(uu.'.*dist,[size(etc_render_fsbrain.aux_point_coords,1),1]);
end;
if(~isempty(etc_render_fsbrain.aux2_point_coords))
    mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
    etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat(uu.'.*dist,[size(etc_render_fsbrain.aux2_point_coords,1),1]);
end;

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');

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
h=findobj('tag','edit_alpha');
set(h,'string',sprintf('%1.1f',get(etc_render_fsbrain.h,'facealpha')));



% --- Executes during object creation, after setting all properties.
function slider_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_goto.
function pushbutton_goto_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_goto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain


%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord0=etc_render_fsbrain.aux2_point_coords(count,:); %current surface coord
surface_coord=etc_render_fsbrain.click_coord'; %clicked surface coord


mask=repmat(etc_render_fsbrain.electrode_mask(etc_render_fsbrain.electrode_idx,:),[3 1])';
etc_render_fsbrain.aux2_point_coords=etc_render_fsbrain.aux2_point_coords+mask.*repmat((surface_coord(:)'-surface_coord0(:)'),[size(etc_render_fsbrain.aux2_point_coords,1),1]);

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
%vv=etc_render_fsbrain.orig_vertex_coords;
%dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
%[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
surface_coord=etc_render_fsbrain.click_coord; %clicked surface coord


%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',[],'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

% surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
% v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
% click_vertex_vox=round(v(1:3))';
% 
% etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
%                     
% vv=etc_render_fsbrain.orig_vertex_coords;
% dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
% [min_dist,min_dist_idx]=min(dist);
% surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
% 
% %update figure;
% etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);


if(~isempty(etc_render_fsbrain.vol))
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            
            surface_coord=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
            click_vertex_vox_now=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
            click_vertex_vox_now=round(click_vertex_vox_now(1:3))';
            
            if(e_idx==1&&c_idx==1)
                fprintf('name\tC\tR\tS\t\t');
                if(~isempty(etc_render_fsbrain.talxfm))
                    fprintf('MNI_x(mm)\tMNI_y(mm)\tMNI_z(mm)\t\t');
                    fprintf('TAL_x(mm)\tTAL_y(mm)\tTAL_z(mm)\t\t');
                end;
                fprintf('\n');
            end;
            fprintf('%s_%d\t%1.0f\t%1.0f\t%1.0f\t\t',etc_render_fsbrain.electrode(e_idx).name,c_idx,click_vertex_vox_now(1), click_vertex_vox_now(2), click_vertex_vox_now(3));
            if(~isempty(etc_render_fsbrain.talxfm))
                click_vertex_point_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*[click_vertex_vox_now 1].';
                fprintf('%1.0f\t%1.0f\t%1.0f\t\t',click_vertex_point_tal(1), click_vertex_point_tal(2), click_vertex_point_tal(3));

                
M2T.rotn  = [      1         0         0         0;
                   0    0.9988    0.0500         0;
                   0   -0.0500    0.9988         0;
                   0         0         0    1.0000 ];
 
M2T.upZ   = [ 0.9900         0         0         0;
                   0    0.9700         0         0;
                   0         0    0.9200         0;
                   0         0         0    1.0000 ];
M2T.downZ = [ 0.9900         0         0         0;
                   0    0.9700         0         0;
                   0         0    0.8400         0;
                   0         0         0    1.0000 ];
               
                if(click_vertex_point_tal(3)<0)
                    click_vertex_point_true_tal=(M2T.rotn * M2T.downZ) * click_vertex_point_tal(:);
                else
                    click_vertex_point_true_tal=(M2T.rotn * M2T.upZ) * click_vertex_point_tal(:);
                end;
                fprintf('%1.0f\t%1.0f\t%1.0f\t\t',click_vertex_point_true_tal(1), click_vertex_point_true_tal(2), click_vertex_point_true_tal(3));
 
            end;
            fprintf('\n');
        end;
    end;
end;

% --- Executes on button press in checkbox_update_contact_view.
function checkbox_update_contact_view_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_update_contact_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_update_contact_view
    %uncheck contact view update option
    
global etc_render_fsbrain

etc_render_fsbrain.electrode_update_contact_view_flag=get(hObject,'Value');

    
    


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain

tstr=datestr(datetime('now'),'mmddyy_HHMMss');
fn=sprintf('electrode_%s.txt',tstr);
fprintf('saving [%s]...',fn);
fp=fopen(fn,'w');

for e_idx=1:length(etc_render_fsbrain.electrode)
    
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        
        surface_coord=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
        click_vertex_vox_now=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
        click_vertex_vox_now=round(click_vertex_vox_now(1:3))';
        
        if(e_idx==1&&c_idx==1)
            fprintf(fp,'name\tC\tR\tS\t\t');
            if(~isempty(etc_render_fsbrain.talxfm))
                fprintf(fp,'MNI_x(mm)\tMNI_y(mm)\tMNI_z(mm)\t\t');
                fprintf(fp,'TAL_x(mm)\tTAL_y(mm)\tTAL_z(mm)\t\t');
            end;
            fprintf(fp,'\n');
        end;
        fprintf(fp,'%s_%d\t%1.0f\t%1.0f\t%1.0f\t\t',etc_render_fsbrain.electrode(e_idx).name,c_idx,click_vertex_vox_now(1), click_vertex_vox_now(2), click_vertex_vox_now(3));
        if(~isempty(etc_render_fsbrain.talxfm))
            click_vertex_point_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*[click_vertex_vox_now 1].';
            fprintf(fp,'%1.0f\t%1.0f\t%1.0f\t\t',click_vertex_point_tal(1), click_vertex_point_tal(2), click_vertex_point_tal(3));
            
            M2T.rotn  = [      1         0         0         0;
                0    0.9988    0.0500         0;
                0   -0.0500    0.9988         0;
                0         0         0    1.0000 ];
            
            M2T.upZ   = [ 0.9900         0         0         0;
                0    0.9700         0         0;
                0         0    0.9200         0;
                0         0         0    1.0000 ];
            M2T.downZ = [ 0.9900         0         0         0;
                0    0.9700         0         0;
                0         0    0.8400         0;
                0         0         0    1.0000 ];
            
            if(click_vertex_point_tal(3)<0)
                click_vertex_point_true_tal=(M2T.rotn * M2T.downZ) * click_vertex_point_tal(:);
            else
                click_vertex_point_true_tal=(M2T.rotn * M2T.upZ) * click_vertex_point_tal(:);
            end;
            fprintf(fp,'%1.0f\t%1.0f\t%1.0f\t\t',click_vertex_point_true_tal(1), click_vertex_point_true_tal(2), click_vertex_point_true_tal(3));
            
            
        end;
        fprintf(fp,'\n');
    end;
    
end;
fclose(fp);
fprintf('done!\n');

fn=sprintf('electrode_%s.mat',tstr);
fprintf('saving [%s]...',fn);
electrode=etc_render_fsbrain.electrode;
save(fn,'electrode');

fprintf('done!\n');

% --- Executes on button press in checkbox_nearest_brain_surface.
function checkbox_nearest_brain_surface_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_nearest_brain_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_nearest_brain_surface


global etc_render_fsbrain

etc_render_fsbrain.show_nearest_brain_surface_location_flag=get(hObject,'Value');

set(findobj('Tag','checkbox_nearest_brain_surface'),'value',etc_render_fsbrain.show_nearest_brain_surface_location_flag);

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord,'min_dist_idx',[],'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
    end;
end;

% --- Executes on button press in checkbox_show_contact_names.
function checkbox_show_contact_names_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_show_contact_names (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_show_contact_names
global etc_render_fsbrain

etc_render_fsbrain.show_contact_names_flag=get(hObject,'Value');

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in button_electrode_modify.
function button_electrode_modify_Callback(hObject, eventdata, handles)
% hObject    handle to button_electrode_modify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;

if(~strcmp(etc_render_fsbrain.surf,'orig'))
    fprintf('surface <%s> not "orig". Skip!\n',etc_render_fsbrain.surf);
    return;
end;

etc_render_fsbrain.electrode_add_gui_ok=0;

%specifiy that the electrode is to be modified.
etc_render_fsbrain.electrode_modify_flag=1;

etc_render_fsbrain.electrode_add_gui_h=etc_render_fsbrain_electrode_add_gui;
uiwait(etc_render_fsbrain.electrode_add_gui_h);
delete(etc_render_fsbrain.electrode_add_gui_h);

if(etc_render_fsbrain.electrode_add_gui_ok)

    %update
    etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).name=etc_render_fsbrain.new_electrode.name;
    
    %check if contact spacing is different
    if(abs(etc_render_fsbrain.new_electrode.spacing-etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing)>eps)
        fprintf('as the contact spacing changes from [%1.0f] to [%1.0f], all contact coordintes are reset.\n',etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing, etc_render_fsbrain.new_electrode.spacing);
        %update contact spacing
        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing=etc_render_fsbrain.new_electrode.spacing;

        %update contact coordinates
        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord=[];
        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact=etc_render_fsbrain.new_electrode.n_contact;
        for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
            etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,1)=0;
            etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,2)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing.*(c_idx-1).*1;
            etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,3)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing.*(etc_render_fsbrain.electrode_idx-1).*1;
        end;
    else
        if(abs(etc_render_fsbrain.new_electrode.n_contact-etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact)>eps)
            fprintf('# of contact changes.\n');
            
            if(etc_render_fsbrain.new_electrode.n_contact<etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact)
                fprintf('reduce the number of contact from [%d] to [%d]. remove the last [%d] contact(s)\n',etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact, etc_render_fsbrain.new_electrode.n_contact, etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact-etc_render_fsbrain.new_electrode.n_contact);
                etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(etc_render_fsbrain.new_electrode.n_contact+1:end,:)=[];                
            end;
            if(etc_render_fsbrain.new_electrode.n_contact>etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact)
                fprintf('increase the number of contact from [%d] to [%d].\n',etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact, etc_render_fsbrain.new_electrode.n_contact);               
                if(etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact==1)
                    for c_idx=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact+1:etc_render_fsbrain.new_electrode.n_contact
                        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,1)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,1);
                        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,2)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,2);
                        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,3)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,3)+etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).spacing.*(c_idx-etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact);
                    end;
                else
                    p1=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(1,:);
                    p2=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(end,:);
                    v=(p2-p1)./(etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact-1);
                        
                    for c_idx=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact+1:etc_render_fsbrain.new_electrode.n_contact
                        etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx,:)=etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).coord(c_idx-1,:)+v;
                    end;
                end;
            end;
            etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact=etc_render_fsbrain.new_electrode.n_contact;
        end;
    end;
    
    
    %update electrode contact coordinates
    etc_render_fsbrain.aux2_point_coords=[];
    etc_render_fsbrain.aux2_point_name={};
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            
            etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
            etc_render_fsbrain.aux2_point_name{count}=sprintf('%s_%d',etc_render_fsbrain.electrode(e_idx).name, c_idx);;
            count=count+1;
        end;
    end;
    
    %update contact mask
    etc_render_fsbrain.electrode_mask=zeros(length(etc_render_fsbrain.electrode),size(etc_render_fsbrain.aux2_point_coords,1));
    count=1;
    for e_idx=1:length(etc_render_fsbrain.electrode)
        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
            etc_render_fsbrain.electrode_mask(e_idx,count)=1;
            count=count+1;
        end;
    end;    

    %update electrode list in the GUI
    str={};
    for e_idx=1:length(etc_render_fsbrain.electrode)
        str{e_idx}=etc_render_fsbrain.electrode(e_idx).name;
    end;
    set(handles.listbox_electrode,'string',str);
    set(handles.listbox_electrode,'value',etc_render_fsbrain.electrode_idx);
   
    %update contact list in the GUI
    str={};
    for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
        str{c_idx}=sprintf('%d',c_idx);
    end;
    set(handles.listbox_contact,'string',str);
    set(handles.listbox_contact,'value',etc_render_fsbrain.electrode_contact_idx);
    guidata(hObject, handles);
    
    %update figure;
    %if(etc_render_fsbrain.electrode_update_contact_view_flag)
    %    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',[],'click_vertex_vox',click_vertex_vox);
    %end;
    
    etc_render_fsbrain_handle('redraw');
end;


% --- Executes on button press in button_electrode_load.
function button_electrode_load_Callback(hObject, eventdata, handles)
% hObject    handle to button_electrode_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;

[filename, pathname, filterindex] = uigetfile({'*.mat'}, 'Pick the Matlab mat file with saved "electrode"');

if(filename~=0)
    
    tmp=load(sprintf('%s/%s',pathname,filename));
    if(isfield(tmp,'electrode'))
        etc_render_fsbrain.electrode=tmp.electrode;
        
        etc_render_fsbrain.electrode_idx=1;
        etc_render_fsbrain.electrode_contact_idx=1;
        
        %update electrode contact coordinates
        etc_render_fsbrain.aux2_point_coords=[];
        etc_render_fsbrain.aux2_point_name={};
        count=1;
        for e_idx=1:length(etc_render_fsbrain.electrode)
            for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                
                etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                
                if(strcmp(etc_render_fsbrain.surf,'orig')|strcmp(etc_render_fsbrain.surf,'smoothwm')|strcmp(etc_render_fsbrain.surf,'pial'))
                    
                else
                    fprintf('surface <%s> not "orig"/"smoothwm"/"pial". Electrode contacts locations are updated to the nearest location of this surface.\n',etc_render_fsbrain.surf);
                    
                    tmp=etc_render_fsbrain.aux2_point_coords(count,:);
                    
                    vv=etc_render_fsbrain.orig_vertex_coords;
                    dist=sqrt(sum((vv-repmat([tmp(1),tmp(2),tmp(3)],[size(vv,1),1])).^2,2));
                    [min_dist,min_dist_idx]=min(dist);
                    if(~isnan(min_dist))
                        etc_render_fsbrain.aux2_point_coords(count,:)=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
                    end;    
                end;
                
                etc_render_fsbrain.aux2_point_name{count}=sprintf('%s_%d',etc_render_fsbrain.electrode(e_idx).name, c_idx);;
                count=count+1;
            end;
        end;
        
        %update contact mask
        etc_render_fsbrain.electrode_mask=zeros(length(etc_render_fsbrain.electrode),size(etc_render_fsbrain.aux2_point_coords,1));
        count=1;
        for e_idx=1:length(etc_render_fsbrain.electrode)
            for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                etc_render_fsbrain.electrode_mask(e_idx,count)=1;
                count=count+1;
            end;
        end;
        
        %update electrode list in the GUI
        str={};
        for e_idx=1:length(etc_render_fsbrain.electrode)
            str{e_idx}=etc_render_fsbrain.electrode(e_idx).name;
        end;
        set(handles.listbox_electrode,'string',str);
        set(handles.listbox_electrode,'value',etc_render_fsbrain.electrode_idx);
        
        %update contact list in the GUI
        str={};
        for c_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
            str{c_idx}=sprintf('%d',c_idx);
        end;
        set(handles.listbox_contact,'string',str);
        set(handles.listbox_contact,'value',etc_render_fsbrain.electrode_contact_idx);
        guidata(hObject, handles);
        
        %update figure;
        %if(etc_render_fsbrain.electrode_update_contact_view_flag)
        %    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',[],'click_vertex_vox',click_vertex_vox);
        %end;
        
        %enable all uicontrols
        c=struct2cell(handles);
        for i=1:length(c)
            if(strcmp(c{i}.Type,'uicontrol'))
                c{i}.Enable='on';
            end;
            
            if(strcmp(c{i}.Tag,'pushbutton_rotate_c'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_rotate_cc'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_right'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_left'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;        
            if(strcmp(c{i}.Tag,'pushbutton_move_up'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_down'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;    
            if(strcmp(c{i}.Tag,'pushbutton_move_more'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_move_less'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'button_optimize'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'button_optimize_sel'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'button_evaluate_cost'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
            if(strcmp(c{i}.Tag,'pushbutton_goto'))
                if(isempty(etc_render_fsbrain.vol)|~strcmp(etc_render_fsbrain.surf,'orig'))
                    c{i}.Enable='off';
                end;
            end;
        end;
        
        %uncheck contact view update option
        %set(handles.checkbox_update_contact_view,'value',0);
        %etc_render_fsbrain.electrode_update_contact_view_flag=0;
        if(etc_render_fsbrain.electrode_update_contact_view_flag)
            set(handles.checkbox_update_contact_view,'value',1);
        else
            set(handles.checkbox_update_contact_view,'value',0);
        end;
        %guidata(hObject, handles);
        
        
        
        if(~isempty(etc_render_fsbrain.aux2_point_coords))
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','pushbutton_aux2_point_color'),'BackgroundColor',etc_render_fsbrain.aux2_point_color);
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','edit_aux2_point_size'),'string',sprintf('%d',etc_render_fsbrain.aux2_point_size));
            v1=etc_render_fsbrain.show_all_contacts_mri_flag;
            v2=etc_render_fsbrain.show_all_contacts_brain_surface_flag;
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','checkbox_electrode_contacts'),'value',v1|v2);
            
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','checkbox_selected_contact'),'value',etc_render_fsbrain.selected_contact_flag);
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','pushbutton_selected_contact_color'),'BackgroundColor',etc_render_fsbrain.selected_contact_color);
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','edit_selected_contact_size'),'string',sprintf('%d',etc_render_fsbrain.selected_contact_size));
            
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','checkbox_selected_electrode'),'value',etc_render_fsbrain.selected_electrode_flag);
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','pushbutton_selected_electrode_color'),'BackgroundColor',etc_render_fsbrain.selected_electrode_color);
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','edit_selected_electrode_size'),'string',sprintf('%d',etc_render_fsbrain.selected_electrode_size));
 
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','pushbutton_aux2_point_color'),'enable','on');
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','edit_aux2_point_size'),'enable','off');
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','checkbox_electrode_contacts'),'enable','on');
            
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','checkbox_selected_contact'),'enable','on');
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','pushbutton_selected_contact_color'),'enable','on');
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','edit_selected_contact_size'),'enable','on');
            
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','checkbox_selected_electrode'),'enable','on');
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','pushbutton_selected_electrode_color'),'enable','on');
            set(findobj(etc_render_fsbrain.fig_gui,'Tag','edit_selected_electrode_size'),'enable','on');
        end;
        
        count=1;
        surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);
        
        etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
        
        try
%                     vv=etc_render_fsbrain.orig_vertex_coords;
%                     dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
%                     [min_dist,min_dist_idx]=min(dist);
%                     surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
%                     etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
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
                %    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
                v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
                click_vertex_vox=round(v(1:3))';
            catch ME
            end;

            etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'click_vertex_vox',click_vertex_vox);
        catch ME
        end;
        
        
        etc_render_fsbrain_handle('redraw');
    else
        fprintf('no variable "electrode" defined in the Matlab file [%s]!\nerror!\n',filename);
        return;
    end;
    
end;


% --- Executes on button press in checkbox_mri_view.
function checkbox_mri_view_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mri_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mri_view
global etc_render_fsbrain

etc_render_fsbrain.show_all_contacts_mri_flag=get(hObject,'Value');

v1=get(findobj(etc_render_fsbrain.fig_electrode_gui,'Tag','checkbox_mri_view'),'Value');
v2=get(findobj(etc_render_fsbrain.fig_electrode_gui,'Tag','checkbox_brain_surface'),'Value');
set(findobj('Tag','checkbox_electrode_contacts'),'Value',v1|v2);

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        surface_coord=etc_render_fsbrain.click_coord'; %clicked surface coord
        
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


        min_dist_idx=[];
        click_vertex_vox=[];
        if(isfield(etc_render_fsbrain,'vol'))
            if(~isempty(etc_render_fsbrain.vol))
                v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
                click_vertex_vox=round(v(1:3))';

                etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
                vv=etc_render_fsbrain.orig_vertex_coords;
                dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                [min_dist,min_dist_idx]=min(dist);
                %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

               %update figure;
               %if(etc_render_fsbrain.electrode_update_contact_view_flag)
               %end;
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord);
        
        etc_render_fsbrain_handle('redraw');
    end;
end;


% --- Executes on button press in button_optimize.
function button_optimize_Callback(hObject, eventdata, handles)
% hObject    handle to button_optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global etc_render_fsbrain;

az0=0; %degree;
el0=0; %degree
rotate_angle0=0; %degree
translate_dist0=0; % mm
translate_dist1=0; % mm

%parameters in the objective function
mri=etc_render_fsbrain.vol.vol;
tkrvox2ras=etc_render_fsbrain.vol.tkrvox2ras;

fprintf('optimizing electrode contact locations...\n');

%optimize each electrode separately
for e_idx=1:length(etc_render_fsbrain.electrode)
%for e_idx=1:1 
    fprintf('\toptimizing electrode [%s]...\n',etc_render_fsbrain.electrode(e_idx).name);

    mask_idx=find(etc_render_fsbrain.electrode_mask(e_idx,:)>eps);

    tmp=etc_render_fsbrain.aux2_point_coords(mask_idx,:).';

    mmin=min(tmp,[],2);
    mmax=max(tmp,[],2);
    
    %initialize optimizer
    init(1)=az0;
    init(2)=el0;
    init(3)=rotate_angle0;
    init(4)=translate_dist0;
    init(5)=translate_dist1;
    init(6:8)=mean(tmp,2);
    
   
    opt_options = optimset('Display','off','MaxIter',1e4,'tolX',1e-4, 'tolFun',1e-4);
    
    [cost_init, tmp_init]=etc_render_fsbrain_electrode_cost(init,tmp,mri,tkrvox2ras,'flag_display',1);
    
    f = @(x)etc_render_fsbrain_electrode_cost(x,tmp,mri,tkrvox2ras);
    %[param_opt, fval, exitflag] = fminsearch(@etc_render_fsbrain_electrode_cost, init, opt_options, tmp, mri, tkrvox2ras);
    %[param_opt, fval, exitflag] = fminsearch(f, init, opt_options);
    %[param_opt,fval] = fminunc(f,init,options);
    LB=[-90 -180 -5 -2 -2 mmin(1)-10 mmin(2)-10 mmin(3)-10];
    UB=[90 180 5 2 2 mmax(1)+10 mmax(2)+10 mmax(3)+10];
    
    [param_opt,fval] = patternsearch(f,init,[],[],[],[],LB,UB,[],opt_options);
    
    [cost_opt, tmp_opt]=etc_render_fsbrain_electrode_cost(param_opt,tmp,mri,tkrvox2ras,'flag_display',1);
    
    %fprintf('cost [%1.2f] --> [%1.2f]\n',cost_init,cost_opt);

    etc_render_fsbrain.aux2_point_coords(mask_idx,:)=tmp_opt';
end;
fprintf('optimization done!\n');

%end of optimization; update electrode contact information.....

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

                
v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in button_evaluate_cost.
function button_evaluate_cost_Callback(hObject, eventdata, handles)
% hObject    handle to button_evaluate_cost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
global etc_render_fsbrain;

%parameters in the objective function
mri=etc_render_fsbrain.vol.vol;
tkrvox2ras=etc_render_fsbrain.vol.tkrvox2ras;


for e_idx=etc_render_fsbrain.electrode_idx:etc_render_fsbrain.electrode_idx
    mask_idx=find(etc_render_fsbrain.electrode_mask(e_idx,:)>eps);
    
    tmp=etc_render_fsbrain.aux2_point_coords(mask_idx,:).';
    
    mmin=min(tmp,[],2);
    mmax=max(tmp,[],2);
    
    %initialize optimizer
    init(1)=0;
    init(2)=0;
    init(3)=0;
    init(4)=0;
    init(5)=0;
    init(6:8)=[0 0 0];

    [cost]=etc_render_fsbrain_electrode_cost(init,tmp,mri,tkrvox2ras,'flag_display',2);
    
    fprintf('electrode [%s] current cost [%1.2f]\n',etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).name,cost);
    
end;
return


% --- Executes on button press in button_optimize_sel.
function button_optimize_sel_Callback(hObject, eventdata, handles)
% hObject    handle to button_optimize_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

az0=0; %degree;
el0=0; %degree
rotate_angle0=0; %degree
translate_dist0=0; % mm
translate_dist1=0; % mm

%parameters in the objective function
mri=etc_render_fsbrain.vol.vol;
tkrvox2ras=etc_render_fsbrain.vol.tkrvox2ras;

fprintf('optimizing electrode contact locations...\n');

%optimize each electrode separately
for e_idx=etc_render_fsbrain.electrode_idx:etc_render_fsbrain.electrode_idx
    fprintf('\toptimizing electrode [%s]...\n',etc_render_fsbrain.electrode(e_idx).name);

    mask_idx=find(etc_render_fsbrain.electrode_mask(e_idx,:)>eps);

    tmp=etc_render_fsbrain.aux2_point_coords(mask_idx,:).';

    mmin=min(tmp,[],2);
    mmax=max(tmp,[],2);
    
    %initialize optimizer
    init(1)=az0;
    init(2)=el0;
    init(3)=rotate_angle0;
    init(4)=translate_dist0;
    init(5)=translate_dist1;
    init(6:8)=mean(tmp,2);
    
   
    opt_options = optimset('Display','off','MaxIter',1e4,'tolX',1e-6, 'tolFun',1e-6);
    
    [cost_init, tmp_init]=etc_render_fsbrain_electrode_cost(init,tmp,mri,tkrvox2ras,'flag_display',1);
    
    f = @(x)etc_render_fsbrain_electrode_cost(x,tmp,mri,tkrvox2ras);
    %[param_opt, fval, exitflag] = fminsearch(@etc_render_fsbrain_electrode_cost, init, opt_options, tmp, mri, tkrvox2ras);
    %[param_opt, fval, exitflag] = fminsearch(f, init, opt_options);
    %[param_opt,fval] = fminunc(f,init,options);
    LB=[-90 -180 -5 -2 -2 mmin(1)-10 mmin(2)-10 mmin(3)-10];
    UB=[90 180 5 2 2 mmax(1)+10 mmax(2)+10 mmax(3)+10];
    
    [param_opt,fval] = patternsearch(f,init,[],[],[],[],LB,UB,[],opt_options);
    
    [cost_opt, tmp_opt]=etc_render_fsbrain_electrode_cost(param_opt,tmp,mri,tkrvox2ras,'flag_display',1);
    
    %fprintf('cost [%1.2f] --> [%1.2f]\n',cost_init,cost_opt);

    etc_render_fsbrain.aux2_point_coords(mask_idx,:)=tmp_opt';
end;
fprintf('optimization done!\n');

%end of optimization; update electrode contact information.....

%update coordinates for electrode contacts
count=1;
for e_idx=1:length(etc_render_fsbrain.electrode)
    for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
        etc_render_fsbrain.electrode(e_idx).coord(c_idx,:)=etc_render_fsbrain.aux2_point_coords(count,:);
        count=count+1;
    end;
end;

%find current contact
count=0;
for e_idx=1:etc_render_fsbrain.electrode_idx-1
    count=count+etc_render_fsbrain.electrode(e_idx).n_contact;
end;
count=count+etc_render_fsbrain.electrode_contact_idx;

surface_coord=etc_render_fsbrain.aux2_point_coords(count,:);

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

v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
click_vertex_vox=round(v(1:3))';

etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
vv=etc_render_fsbrain.vertex_coords;
dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
%surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

%update figure;
if(etc_render_fsbrain.electrode_update_contact_view_flag)
    etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
end;

etc_render_fsbrain_handle('redraw');


% --- Executes on button press in checkbox_brain_surface.
function checkbox_brain_surface_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_brain_surface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_brain_surface
global etc_render_fsbrain

etc_render_fsbrain.show_all_contacts_brain_surface_flag=get(hObject,'Value');

v1=get(findobj(etc_render_fsbrain.fig_electrode_gui,'Tag','checkbox_mri_view'),'Value');
v2=get(findobj(etc_render_fsbrain.fig_electrode_gui,'Tag','checkbox_brain_surface'),'Value');
set(findobj('Tag','checkbox_electrode_contacts'),'Value',v1|v2);

if(isfield(etc_render_fsbrain,'click_coord'))
    if(~isempty(etc_render_fsbrain.click_coord))
        surface_coord=etc_render_fsbrain.click_coord'; %clicked surface coord
        
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


        min_dist_idx=[];
        click_vertex_vox=[];
        if(isfield(etc_render_fsbrain,'vol'))
            if(~isempty(etc_render_fsbrain.vol))
                v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_orig_coord(:); 1];
                click_vertex_vox=round(v(1:3))';

                etc_render_fsbrain.electrode_contact_coord_now=surface_coord;
                    
                vv=etc_render_fsbrain.orig_vertex_coords;
                dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                [min_dist,min_dist_idx]=min(dist);
                %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';

               %update figure;
               %if(etc_render_fsbrain.electrode_update_contact_view_flag)
               %end;
            end;
        end;
        etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
        %etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord);
        
        etc_render_fsbrain_handle('redraw');
    end;
end;


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

etc_render_fsbrain.electrode=[];

%update electrode contact coordinates
etc_render_fsbrain.aux2_point_coords=[];
etc_render_fsbrain.aux2_point_name={};


set(handles.listbox_electrode,'string',{});
set(handles.listbox_contact,'string',{});



c=struct2cell(handles);
for i=1:length(c)
    if(strcmp(c{i}.Type,'uicontrol'))
        c{i}.Enable='on';
    end;
    
    if(strcmp(c{i}.Tag,'pushbutton_rotate_c'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_rotate_cc'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_move_right'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_move_left'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_move_up'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_move_down'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_move_more'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'pushbutton_move_less'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'edit_move'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'edit_rotate'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'button_optimize'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'button_optimize_sel'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'button_evaluate_cost'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
    if(strcmp(c{i}.Tag,'checkbox_electrode_contact_lock'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;    
    if(strcmp(c{i}.Tag,'pushbutton_goto'))
        %if(isempty(etc_render_fsbrain.vol))
            c{i}.Enable='off';
        %end;
    end;
end;

%uncheck contact view update option
set(handles.checkbox_update_contact_view,'value',0);
etc_render_fsbrain.electrode_update_contact_view_flag=0;


etc_render_fsbrain_handle('draw_pointer','surface_coord',[],'click_vertex_vox',[]);

etc_render_fsbrain_handle('redraw');
return;
        
        
        
  



function edit_mri_view_depth_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mri_view_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mri_view_depth as text
%        str2double(get(hObject,'String')) returns contents of edit_mri_view_depth as a double
        
global etc_render_fsbrain;

etc_render_fsbrain.show_all_contacts_mri_depth=str2double(get(hObject,'String'));

etc_render_fsbrain_handle('draw_pointer','surface_coord',etc_render_fsbrain.click_coord','min_dist_idx',[],'click_vertex_vox',[]);
%etc_render_fsbrain_handle('draw_pointer','surface_coord',surface_coord);
        

% --- Executes during object creation, after setting all properties.
function edit_mri_view_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mri_view_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
