function varargout = etc_render_fsbrain_label_gui(varargin)
% ETC_RENDER_FSBRAIN_LABEL_GUI MATLAB code for etc_render_fsbrain_label_gui.fig
%      ETC_RENDER_FSBRAIN_LABEL_GUI, by itself, creates a new ETC_RENDER_FSBRAIN_LABEL_GUI or raises the existing
%      singleton*.
%
%      H = ETC_RENDER_FSBRAIN_LABEL_GUI returns the handle to a new ETC_RENDER_FSBRAIN_LABEL_GUI or the handle to
%      the existing singleton*.
%
%      ETC_RENDER_FSBRAIN_LABEL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ETC_RENDER_FSBRAIN_LABEL_GUI.M with the given input arguments.
%
%      ETC_RENDER_FSBRAIN_LABEL_GUI('Property','Value',...) creates a new ETC_RENDER_FSBRAIN_LABEL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before etc_render_fsbrain_label_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to etc_render_fsbrain_label_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help etc_render_fsbrain_label_gui

% Last Modified by GUIDE v2.5 18-Mar-2019 11:42:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @etc_render_fsbrain_label_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @etc_render_fsbrain_label_gui_OutputFcn, ...
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


% --- Executes just before etc_render_fsbrain_label_gui is made visible.
function etc_render_fsbrain_label_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to etc_render_fsbrain_label_gui (see VARARGIN)

% Choose default command line output for etc_render_fsbrain_label_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes etc_render_fsbrain_label_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global etc_render_fsbrain;
if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
    fprintf('annotated label loaded...\n');
    %set(handles.listbox_label,'value',4);
    set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
    set(handles.listbox_label,'min',0);
    set(handles.listbox_label,'max',max([2 length(etc_render_fsbrain.label_ctab.struct_names)]));
    set(handles.listbox_label,'value',[]);
    guidata(hObject, handles);
else
    set(handles.listbox_label,'string',{''});
    set(handles.listbox_label,'min',0);
    set(handles.listbox_label,'max',2);
    set(handles.listbox_label,'value',[]);
    guidata(hObject, handles);    
end;

set(hObject,'KeyPressFcn',@etc_render_fsbrain_kbhandle);




% --- Outputs from this function are returned to the command line.
function varargout = etc_render_fsbrain_label_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_label.
function listbox_label_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_label contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_label

global etc_render_fsbrain;
try
    if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
        %contents = cellstr(get(hObject,'String'));
        contents=etc_render_fsbrain.label_ctab.struct_names;
        select_idx=get(hObject,'Value');
        
        
        etc_render_fsbrain.label_register(select_idx)=1-etc_render_fsbrain.label_register(select_idx);

        if( etc_render_fsbrain.label_register(select_idx))
            fprintf('label <<%s>> selected\n',contents{get(hObject,'Value')})
        else
            fprintf('label <<%s>> un-selected\n',contents{get(hObject,'Value')})
        end;
        
        set(hObject,'Value',find(etc_render_fsbrain.label_register));
        

        
        try
            for ss=1:length(etc_render_fsbrain.label_register)    
                etc_render_fsbrain.label_number=etc_render_fsbrain.label_ctab.table(ss,5);
                vidx=find((etc_render_fsbrain.label_value)==etc_render_fsbrain.label_number);
                if(etc_render_fsbrain.label_register(ss)==1)
                    if(etc_render_fsbrain.flag_show_cort_label)
                        %plot label
                        cc=etc_render_fsbrain.label_ctab.table(ss,1:3)./255;
                        etc_render_fsbrain.h.FaceVertexCData(vidx,:)=repmat(cc(:)',[length(vidx),1]);
                    end;
                    
                    if(etc_render_fsbrain.flag_show_cort_label_boundary)
                        set(etc_render_fsbrain.h_label_boundary{ss}(:),'visible','on');
                    else
                        set(etc_render_fsbrain.h_label_boundary{ss}(:),'visible','off');
                    end;

                    face_in_label_counter=sum(ismember(etc_render_fsbrain.faces,vidx-1),2);
                    face_in_label_idx=find(face_in_label_counter==3); %mesh triangulation indices for all three vertices included by a label
                    v1=etc_render_fsbrain.faces(face_in_label_idx,1);
                    v2=etc_render_fsbrain.faces(face_in_label_idx,2);
                    v3=etc_render_fsbrain.faces(face_in_label_idx,3);

                    P1=etc_render_fsbrain.orig_vertex_coords(v1+1,:);
                    P2=etc_render_fsbrain.orig_vertex_coords(v2+1,:);
                    P3=etc_render_fsbrain.orig_vertex_coords(v3+1,:);
                    area_within_label=.5*sum(sqrt(sum(cross(P2-P1,P3-P1).^2,2)));

                    fprintf('label area =%2.1f (mm^2)\n',area_within_label);

                    %overlay
                    if(~isempty(etc_render_fsbrain.ovs))
                        fprintf('[%s] overlay = %2.2f +/- %2.2f \n',etc_render_fsbrain.label_ctab.struct_names{ss}, mean(etc_render_fsbrain.ovs(vidx)),std(etc_render_fsbrain.ovs(vidx)));

                       
                        
                        %overlay center-of-mass
                        ww=etc_render_fsbrain.ovs(vidx);
                        vv=etc_render_fsbrain.vertex_coords(vidx,:);
                        com_surf=sum(vv.*repmat(ww,[1 3]),1)./sum(ww);
                        
                        ww=etc_render_fsbrain.ovs(vidx);
                        vv=etc_render_fsbrain.orig_vertex_coords(vidx,:);
                        com_orig_surf=sum(vv.*repmat(ww,[1 3]),1)./sum(ww);

                        click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*[com_orig_surf(:); 1];

                        com_surf_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*click_vertex_vox;
                        com_surf_tal=com_surf_tal(1:3)';
                        fprintf('center of mass coordinates: surface: %s; orig. surface: %s; MNI: %s\n',mat2str(com_surf, 2), mat2str(com_orig_surf, 2), mat2str(com_surf_tal, 2));

                    end;
                else
                    etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                    set(etc_render_fsbrain.h_label_boundary{ss}(:),'visible','off');
                end;


                %label_coords=etc_render_fsbrain.orig_vertex_coords(vidx,:);
                label_coords=etc_render_fsbrain.vertex_coords(vidx,:);
                
                
                %find electrode contacts closest to the selected label
                if(~isempty(etc_render_fsbrain.electrode))
                    
                    max_contact=0;
                    for e_idx=1:length(etc_render_fsbrain.electrode)
                            if(etc_render_fsbrain.electrode(e_idx).n_contact>max_contact)
                                max_contact=etc_render_fsbrain.electrode(e_idx).n_contact;
                            end;
                    end;
                    electrode_dist_min=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                    electrode_dist_avg=ones(length(etc_render_fsbrain.electrode),max_contact).*nan;
                    
                    for e_idx=1:length(etc_render_fsbrain.electrode)
                        for c_idx=1:etc_render_fsbrain.electrode(e_idx).n_contact
                            
                            surface_coord=etc_render_fsbrain.electrode(e_idx).coord(c_idx,:);
                            
                            tmp=label_coords-repmat(surface_coord(:)',[size(label_coords,1),1]);
                            tmp=sqrt(sum(tmp.^2,2));
                            
                            electrode_dist_min(e_idx,c_idx)=min(tmp);
                            electrode_dist_avg(e_idx,c_idx)=mean(tmp);
                        end;
                    end;
                    
                    [dummy,min_idx]=sort(electrode_dist_min(:));
                    fprintf('Top 3 closest contacts\n');
                    for ii=1:3 %show the nearest three contacts
                        [ee,cc]=ind2sub(size(electrode_dist_min),min_idx(ii));
                        fprintf('closest electrode contact:: [%s_%02d]: %2.2f (mm) (%1.1f %1.1f %1.1f)\n',etc_render_fsbrain.electrode(ee).name,cc,dummy(ii),etc_render_fsbrain.electrode(ee).coord(cc,1),etc_render_fsbrain.electrode(ee).coord(cc,2),etc_render_fsbrain.electrode(ee).coord(cc,3));
                    end;
                end;
            end;

            figure(etc_render_fsbrain.fig_label_gui);
            
        catch ME
        end;
    end;
catch ME
end;

% --- Executes during object creation, after setting all properties.
function listbox_label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on listbox_label and none of its controls.
function listbox_label_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox_label (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global etc_render_fsbrain;

eventdata.Key;
if(strcmp(eventdata.Key,'backspace')|strcmp(eventdata.Key,'delete'))
    contents = cellstr(get(hObject,'String'));
    select_idx=get(hObject,'Value');
    
    setlect_idx=sort(select_idx,'descend');
    
    if(~isempty(select_idx))
        try
            for l_idx=1:length(select_idx)
                
                label_number=etc_render_fsbrain.label_ctab.table(select_idx(l_idx),5);
                vidx=find((etc_render_fsbrain.label_value)==label_number);
                
                etc_render_fsbrain.h.FaceVertexCData(vidx,:)=etc_render_fsbrain.fvdata(vidx,:);
                
                etc_render_fsbrain.label_value(vidx)=0;
                
                etc_render_fsbrain.label_ctab.numEntries=etc_render_fsbrain.label_ctab.numEntries-1;
                
                set(etc_render_fsbrain.h_label_boundary{select_idx(l_idx)}(:),'visible','off');    
            end;

            etc_render_fsbrain.h_label_boundary(select_idx)=[];

            etc_render_fsbrain.label_ctab.table(select_idx,:)=[];
            etc_render_fsbrain.label_ctab.struct_names(select_idx)=[];
            etc_render_fsbrain.label_register(select_idx)=[];
            
            set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
            if(etc_render_fsbrain.label_ctab.numEntries>0)
                if(select_idx>1)
                    set(handles.listbox_label,'value',select_idx-1);
                    etc_render_fsbrain.label_select_idx=select_idx-1;
                else
                    set(handles.listbox_label,'value',select_idx);
                    etc_render_fsbrain.label_select_idx=select_idx;
                end;
            else
                set(handles.listbox_label,'value',[]);
            end;
            guidata(hObject, handles);
            
            figure(etc_render_fsbrain.fig_label_gui);
            
        catch ME
        end;
    end;
end;
