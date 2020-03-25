function etc_render_fsbrain_handle(param,varargin)

global etc_render_fsbrain;

cc=[];
surface_coord=[];
min_dist_idx=[];
click_vertex_vox=[];

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'c0'
            cc='c0';
        case 'cc'
            cc=option;
        case 'surface_coord'
            surface_coord=option;
        case 'min_dist_idx'
            min_dist_idx=option;
        case 'click_vertex_vox'
            click_vertex_vox=option;
    end;
end;

if(isempty(cc))
    cc=get(gcf,'currentchar');
end;

switch lower(param)
    case 'draw_pointer'
        draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
    case 'redraw'
        redraw;
    case 'draw_stc'
        draw_stc;
    case 'update_overlay_vol'
        update_overlay_vol;
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('p: open subject/volume/surface GUI\n');
                fprintf('g: open visualization option GUI \n');
                fprintf('k: open registration GUI\n');
                fprintf('e: open electrode GUI\n');
                fprintf('b: open sensor location GUI\n');
                fprintf('v: open trace viewer GUI\n');
                fprintf('f: load overlay (w/stc) file\n');
                fprintf('l: open label GUI\n');
                fprintf('w: open coordinates GUI\n');
                fprintf('s: smooth overlay \n');
                fprintf('o: create ROI\n');
                fprintf('d: interactive threshold change\n');
                fprintf('c: switch on/off the colorbar\n');
                fprintf('u: show cluster labels from files\n');
                fprintf('m: create a region of specified extension\n');
                fprintf('q: exit\n');
                fprintf('\n\n fhlin@dec 25, 2014\n');
            case 'a'
                fprintf('archiving...\n');
                fn=sprintf('etc_render_fsbrain.tif');
                fprintf('saving [%s]...\n',fn);
                print(fn,'-dtiff');
            case 'q'
                fprintf('\nclosing all figures!\n');
                etc_render_fsbrain_handle('del');
            case 'r'
                fprintf('\nredrawing...\n');
                redraw;
            case 'p'
                %fprintf('\nSUBJECT...\n');
                if(isfield(etc_render_fsbrain,'fig_subject'))
                    etc_render_fsbrain.fig_subject=[];
                end;
                etc_render_fsbrain.fig_subject=etc_render_fsbrain_subject;
                set(etc_render_fsbrain.fig_subject,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_subject,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_subject,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_subject,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                
                set(etc_render_fsbrain.fig_subject,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');

            case 'f'
                fprintf('\nload overlay...\n');
                [filename, pathname, filterindex] = uigetfile({'*.stc','STC file (space x time)';'*.w','w file (space x 1)'}, 'Pick an overlay file');
                if(filename~=0) %not 'cancel'
                    if(findstr(filename,'.stc')) %stc file
                        [stc,vv,d0,d1,timeVec]=inverse_read_stc(sprintf('%s/%s',pathname,filename));
                        if(findstr(filename,'-lh'))
                            hemi='lh';
                        else
                            hemi='rh';
                        end;
                        etc_render_fsbrain.overlay_stc=stc;
                        etc_render_fsbrain.overlay_vertex=vv;
                        etc_render_fsbrain.overlay_stc_timeVec=timeVec;
                        etc_render_fsbrain.stc_hemi=hemi;
                        etc_render_fsbrain.overlay_stc_timeVec_unit='ms';
                        set(findobj('tag','text_timeVec_unit'),etc_render_fsbrain.overlay_stc_timeVec_unit);
                        
                        [tmp,etc_render_fsbrain.overlay_stc_timeVec_idx]=max(sum(etc_render_fsbrain.overlay_stc.^2,1));
                        etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                        etc_render_fsbrain.overlay_stc_hemi=etc_render_fsbrain.overlay_stc;
                        
                        etc_render_fsbrain.overlay_flag_render=1;
                    elseif(findstr(filename,'.w')) %w file
                        [ww,vv]=inverse_read_wfile(sprintf('%s/%s',pathname,filename));
                        if(findstr(filename,'-lh'))
                            hemi='lh';
                        else
                            hemi='rh';
                        end;
                        etc_render_fsbrain.overlay_value=ww;
                        etc_render_fsbrain.overlay_vertex=vv;
                        etc_render_fsbrain.stc_hemi=hemi;
                        
                        etc_render_fsbrain.overlay_flag_render=1;
                        
                    end;
                    etc_render_fsbrain.overlay_Ds=[];
                    redraw;
                end;
            case 'o' %draw ROI....
                if(isfield(etc_render_fsbrain,'flag_collect_vertex'))
                    etc_render_fsbrain.flag_collect_vertex=~etc_render_fsbrain.flag_collect_vertex;
                    if(etc_render_fsbrain.flag_collect_vertex)
                        fprintf('start collecting vertices for ROI definition...\n');
                        etc_render_fsbrain.collect_vertex=[];
                    else
                        fprintf('stop collecting vertices for ROI definition...\n');
                        etc_render_fsbrain.flag_collect_vertex=0;
                        %etc_render_fsbrain.collect_vertex=[];
                        
                        if(length(etc_render_fsbrain.collect_vertex)>1)
                            %complete a closed ROI...
                            
                            %dijkstra search finds vertices on the shortest path between
                            %the last two selected vertices
                            D=dijkstra(etc_render_fsbrain.dijk_A,etc_render_fsbrain.collect_vertex(end));
                            paths=etc_distance2path(etc_render_fsbrain.collect_vertex(1),D,etc_render_fsbrain.faces_hemi+1);
                            paths=flipud(paths);
                            
                            %connect vertices by traversing the shortest path
                            for p_idx=2:length(paths)
                                etc_render_fsbrain.collect_vertex_boundary=cat(1,etc_render_fsbrain.collect_vertex_boundary,paths(p_idx));
                                etc_render_fsbrain.collect_vertex_boundary_point(end+1)=plot3(etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary(end),1),etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary(end),2),etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
                                set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',1);
                            end;
                        end;
                        
                        try
                            mean_point=mean(etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary,:),1);
                            dist=sum((etc_render_fsbrain.vertex_coords_hemi-repmat(mean_point,[size(etc_render_fsbrain.vertex_coords_hemi,1),1])).^2,2);
                            [dummy,min_dist]=min(dist);
                            roi_idx=etc_patchflood(etc_render_fsbrain.faces_hemi+1,min_dist,etc_render_fsbrain.collect_vertex_boundary);
                            
                            %ROI....
                            etc_render_fsbrain.label_idx=roi_idx;
                            etc_render_fsbrain.label_h=plot3(etc_render_fsbrain.vertex_coords_hemi(roi_idx,1),etc_render_fsbrain.vertex_coords_hemi(roi_idx,2), etc_render_fsbrain.vertex_coords_hemi(roi_idx,3),'r.');
                            
                            %save the label?
                            %[file, path] = uiputfile({'*.label'});
                            %[file, path] = uigetfile({'*.label','FreeSufer label'}, 'Pick a file');
                            filter = {'*.label'};
                            [file, path] = uiputfile(filter);
                            if isequal(file,0) || isequal(path,0)
                                etc_render_fsbrain.label_idx=[];
                                delete(etc_render_fsbrain.label_h);
                            else
                                fn=fullfile(path,file);
                                disp(['User selected ',fullfile(path,file),...
                                    ' and then clicked Save.'])
                                inverse_write_label(etc_render_fsbrain.label_idx(:)-1,zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),ones(size(etc_render_fsbrain.label_idx(:))),fn);
                                fprintf('ROI saved [%s].\n',fn);
                            end
                            
                            %clear boundary points and vertices
                            delete(etc_render_fsbrain.collect_vertex_boundary_point(:));
                            etc_render_fsbrain.collect_vertex_boundary_point=[];
                            etc_render_fsbrain.collect_vertex_boundary=[];
                            
                            etc_render_fsbrain.collect_vertex=[];
                            delete(etc_render_fsbrain.collect_vertex_point(:));
                            etc_render_fsbrain.collect_vertex_point=[];
                        catch ME
                        end;
                        
                    end;
                else
                    etc_render_fsbrain.flag_collect_vertex=1;
                    fprintf('start collecting vertices for ROI definition...\n');
                    etc_render_fsbrain.collect_vertex=[];
                end;
                
                if(isfield(etc_render_fsbrain,'roi'))
                    delete(etc_render_fsbrain.roi_points(:));
                    etc_render_fsbrain.roi=[];
                end;
                
            case 'g'
                %fprintf('\nGUI...\n');
                if(isfield(etc_render_fsbrain,'fig_gui'))
                    etc_render_fsbrain.fig_gui=[];
                end;
                etc_render_fsbrain.fig_gui=etc_render_fsbrain_gui;
                set(etc_render_fsbrain.fig_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');

            case 'k'
                %fprintf('\nregister points...\n');
                if(isfield(etc_render_fsbrain,'fig_register'))
                    etc_render_fsbrain.fig_register=[];
                end;
                etc_render_fsbrain.fig_register=etc_render_fsbrain_register;
                set(etc_render_fsbrain.fig_register,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_register,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_register,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_register,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_register,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');

            case 'e'
                %fprintf('\nelectrodes...\n');
                if(isfield(etc_render_fsbrain,'fig_electrode_gui'))
                    etc_render_fsbrain.fig_electrode_gui=[];
                end;
                etc_render_fsbrain.fig_electrode_gui=etc_render_fsbrain_electrode_gui;
                set(etc_render_fsbrain.fig_electrode_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_electrode_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_electrode_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_electrode_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_electrode_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
             case 'b'
                %fprintf('\nsensors...\n');
                if(isfield(etc_render_fsbrain,'fig_sensor_gui'))
                    etc_render_fsbrain.fig_sensor_gui=[];
                end;
                etc_render_fsbrain.fig_sensor_gui=etc_render_fsbrain_sensors;
                set(etc_render_fsbrain.fig_sensor_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_sensor_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_sensor_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_sensor_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_sensor_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
            case 'v'
                fprintf('showing trace GUI...\n');
                if(~isempty(etc_render_fsbrain.overlay_stc))
                    %etc_trace(etc_render_fsbrian.overlay_stc,'fs',fs,'trigger',trigger_all,'ch_names',label,'aux_data',{data_nobcg});
                    aux_data={};
                    if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                        for vv_idx=1:size(etc_render_fsbrain.overlay_aux_stc,3)
                            aux_data{vv_idx}=etc_render_fsbrain.overlay_aux_stc(:,:,vv_idx);
                        end;
                    end;
                    
                    if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                        fs=1./mean(diff(etc_render_fsbrain.overlay_stc_timeVec));
                        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                            switch lower(etc_render_fsbrain.overlay_stc_timeVec_unit)
                                case 'ms'
                                    fs=fs.*1e3;
                            end;
                        end;
                    else
                        fs=1e3; %default sampling rate; 1000 Hz
                    end;
                   

                    time_begin=0;
                    if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                        time_begin=etc_render_fsbrain.overlay_stc_timeVec(1);
                        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                            switch lower(etc_render_fsbrain.overlay_stc_timeVec_unit)
                                case 'ms'
                                    time_begin=time_begin/1e3;
                            end;
                        end;
                    end;
                    etc_trace(etc_render_fsbrain.overlay_stc,'fs',fs,'ch_names',etc_render_fsbrain.aux_point_name,'aux_data',aux_data,'time_begin',time_begin);
                    
                    global etc_trace_obj;
                    if(isvalid(etc_trace_obj.fig_trace))
                        etc_trace_handle('bd','time_idx',etc_render_fsbrain.overlay_stc_timeVec_idx);
                    end;
                    
                    global etc_trace_obj;
                    
                    if(~isempty(etc_trace_obj))
                        try
                            etc_trace_obj.topo.vertex=etc_render_fsbrain.vertex_coords;
                            etc_trace_obj.topo.face=etc_render_fsbrain.faces;
                            
                            Index=find(contains(etc_render_fsbrain.aux_point_name,etc_trace_obj.ch_names));
                            if(length(Index)<=length(etc_trace_obj.ch_names)) %all electrodes were found on topology
                                for ii=1:length(etc_trace_obj.ch_names)
                                    for idx=1:length(etc_render_fsbrain.aux_point_name)
                                        if(strcmp(etc_render_fsbrain.aux_point_name{idx},etc_trace_obj.ch_names{ii}))
                                            Index(ii)=idx;
                                            electrode_data_idx(idx)=ii;
                                        end;
                                    end;
                                end;
                                
                                for jj=1:size(etc_render_fsbrain.aux_point_coords,1)
                                    dd=etc_trace_obj.topo.vertex-repmat(etc_render_fsbrain.aux_point_coords(jj,:),[size(etc_trace_obj.topo.vertex,1) 1]);
                                    dd=sum(dd.^2,2);
                                    [dummy, electrode_idx(jj)]=min(dd);
                                end;
                                
                                etc_trace_obj.topo.ch_names=etc_render_fsbrain.aux_point_name(Index);
                                etc_trace_obj.topo.electrode_idx=electrode_idx;
                                etc_trace_obj.topo.electrode_data_idx=electrode_data_idx;
                            end;
                        catch ME
                        end;
                    end;
                end;
            case 't'
%                 fprintf('\ntemporal integration...\n');
%                 if(isempty(inverse_time_integration))
%                     inverse_time_integration=1;
%                 end;
%                 
%                 def={num2str(inverse_time_integration)};
%                 if(isempty(inverse_stc_timeVec))
%                     answer=inputdlg('temporal integration',sprintf('temporal integration interval= %s [samples]',num2str(inverse_time_integration)),1,def);
%                 else
%                     answer=inputdlg('temporal integration',sprintf('temporal integration interval= %s [ms]',num2str(inverse_time_integration)),1,def);
%                 end;
%                 if(~isempty(answer))
%                     inverse_time_integration=str2num(answer{1});
%                     if(isempty(inverse_stc_timeVec))
%                         fprintf('temporal integration = %s [samples]\n',mat2str(inverse_time_integration));
%                     else
%                         fprintf('temporal integration = %s [ms]\n',mat2str(inverse_time_integration));
%                     end;
%                     redraw;
%                 end;
            case 'w' %coordinate GUI
                %fprintf('\nCoordinate GUI...\n');
                if(isfield(etc_render_fsbrain,'fig_coord_gui'))
                    etc_render_fsbrain.fig_coord_gui=[];
                end;
                etc_render_fsbrain.fig_coord_gui=etc_render_fsbrain_coord_gui;
                set(etc_render_fsbrain.fig_coord_gui,'HandleVisibility','on')
                set(etc_render_fsbrain.fig_coord_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_coord_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_coord_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);

                set(etc_render_fsbrain.fig_coord_gui,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
            case 'l' %annotation/labels GUI
                %fprintf('\nannotation/labels GUI...\n');
                global etc_render_fsbrain;
                
                %[filename, pathname, filterindex] = uigetfile({'*.annot','FreeSufer annotation';'*.label','FreeSufer label'}, 'Pick a file', 'lh.aparc.a2009s.annot');
                %[filename, pathname, filterindex] = uigetfile({'*.annot','FreeSufer annotation'; '*.mgz','FreeSufer annotation';'*.label','FreeSufer label';  }, 'Pick a file', 'lh.aparc.a2009s.annot');
                [filename, pathname, filterindex] = uigetfile(fullfile(pwd,'*.mgz;*.mgh;*.annot;*.label'),'select an annotation/label file');
                try
                    [dummy,fstem,ext]=fileparts(filename);
                    switch lower(ext)
                        case '.label'
                            file_label=sprintf('%s/%s',pathname,filename);
                            [ii,d0,d1,d2, vv] = inverse_read_label(file_label);
                            
                            if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                                etc_render_fsbrain.label_vertex(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
                                etc_render_fsbrain.label_value(ii+1)=etc_render_fsbrain.label_ctab.numEntries+1;
                                etc_render_fsbrain.label_ctab.numEntries=etc_render_fsbrain.label_ctab.numEntries+1;
                                etc_render_fsbrain.label_ctab.struct_names{end+1}=filename;
                                etc_render_fsbrain.label_ctab.table(end+1,:)=[220          60         120          0        etc_render_fsbrain.label_ctab.numEntries];
                            else
                                etc_render_fsbrain.label_vertex=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
                                etc_render_fsbrain.label_vertex(ii+1)=1;
                                etc_render_fsbrain.label_value=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
                                etc_render_fsbrain.label_value(ii+1)=1;
                                s.numEntries=1;
                                s.orig_tab='';
                                s.struct_names={filename};
                                s.table=[220          60         120          0        1];
                                etc_render_fsbrain.label_ctab=s;
                            end;
                        case '.mgz'
                            file_annot=sprintf('%s/%s',pathname,filename);
                            etc_render_fsbrain.overlay_vol_mask=MRIread(file_annot);
                            
                            [dummy,fstem]=fileparts(filename);
                            
                            file_lut='/Applications/freesurfer/FreeSurferColorLUT.txt';
                            
                            [etc_render_fsbrain.lut.number,etc_render_fsbrain.lut.name,etc_render_fsbrain.lut.r,etc_render_fsbrain.lut.g,etc_render_fsbrain.lut.b,f]=textread(file_lut,'%d%s%d%d%d%d','commentstyle','shell');
                            obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                            set(obj,'enable','on');
                            set(obj,'string',etc_render_fsbrain.lut.name);
                            set(obj,'value',1);
                            set(obj,'min',0);
                            set(obj,'max',length(etc_render_fsbrain.lut.name));
                            
                            obj=findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_overlay_aux_vol');
                            set(obj,'enable','on');
                                                        
                            draw_pointer();
                        case '.mgh'
                            file_annot=sprintf('%s/%s',pathname,filename);
                            etc_render_fsbrain.overlay_vol_mask=MRIread(file_annot);
                            
                            [dummy,fstem]=fileparts(filename);
                            
                            file_lut='/Applications/freesurfer/FreeSurferColorLUT.txt';
                            
                            [etc_render_fsbrain.lut.number,etc_render_fsbrain.lut.name,etc_render_fsbrain.lut.r,etc_render_fsbrain.lut.g,etc_render_fsbrain.lut.b,f]=textread(file_lut,'%d%s%d%d%d%d','commentstyle','shell');
                            obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                            set(obj,'enable','on');
                            set(obj,'string',etc_render_fsbrain.lut.name);
                            set(obj,'value',1);
                            set(obj,'min',0);
                            set(obj,'max',length(etc_render_fsbrain.lut.name));
                            
                            obj=findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_overlay_aux_vol');
                            set(obj,'enable','on');
                            
                            draw_pointer();
                        case '.annot'
                            file_annot=sprintf('%s/%s',pathname,filename);
                            [etc_render_fsbrain.label_vertex etc_render_fsbrain.label_value etc_render_fsbrain.label_ctab] = read_annotation(file_annot);                    
                        otherwise
                    end;
                catch ME
                end;
                
                %if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value))
                     if(isfield(etc_render_fsbrain,'fig_label_gui'))
                        if(~isempty(etc_render_fsbrain.fig_label_gui))
                            if(isvalid(etc_render_fsbrain.fig_label_gui))
                                %etc_render_fsbrain.fig_label_gui=[];
                                handles=guidata(etc_render_fsbrain.fig_label_gui);
                                set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
                                set(handles.listbox_label,'value',1);
                                set(handles.listbox_label,'min',0);
                                set(handles.listbox_label,'max',length(etc_render_fsbrain.label_ctab.struct_names));
                    
                                etc_render_fsbrain.fcvdata_orig=etc_render_fsbrain.h.FaceVertexCData;
                                etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                                
                                figure(etc_render_fsbrain.fig_label_gui);
                            else
                                etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                                set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                                pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                                set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                                
                                handles=guidata(etc_render_fsbrain.fig_label_gui);
                                set(handles.listbox_label,'string',{etc_render_fsbrain.label_ctab.struct_names{:}});
                                set(handles.listbox_label,'value',1);
                                set(handles.listbox_label,'min',0);
                                set(handles.listbox_label,'max',length(etc_render_fsbrain.label_ctab.struct_names));
                    
                                %etc_render_fsbrain.fcvdata_orig=etc_render_fsbrain.h.FaceVertexCData;
                                etc_render_fsbrain.label_register=zeros(1,length(etc_render_fsbrain.label_ctab.struct_names));
                            end;
                        else
                            etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                            set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                            pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                            pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                            set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                        end;
                    else
                        etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                        set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                        pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                        pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                        set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                    end;
                end;
                
            case 'c' %colorbar;
                figure(etc_render_fsbrain.fig_brain);
                if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
                    if(isempty(etc_render_fsbrain.h_colorbar_pos))
                        if(etc_render_fsbrain.overlay_value_flag_pos|etc_render_fsbrain.overlay_value_flag_neg)
                            etc_render_fsbrain.brain_axis_pos=get(etc_render_fsbrain.brain_axis,'pos');
                            set(etc_render_fsbrain.brain_axis,'pos',[etc_render_fsbrain.brain_axis_pos(1) 0.2 etc_render_fsbrain.brain_axis_pos(3) 0.8]);
                            etc_render_fsbrain.h_colorbar=subplot('position',[etc_render_fsbrain.brain_axis_pos(1) 0.0 etc_render_fsbrain.brain_axis_pos(3) 0.2]);
                            
                            cmap=[etc_render_fsbrain.overlay_cmap; etc_render_fsbrain.overlay_cmap_neg];
                            hold on;
                            
                            if(etc_render_fsbrain.overlay_value_flag_pos)
                                etc_render_fsbrain.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                                image([1:size(etc_render_fsbrain.overlay_cmap,1)]); axis off; colormap(cmap);
                                h=text(-3,1,sprintf('%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                                h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                            else
                                etc_render_fsbrain.h_colorbar_pos=[];
                            end;
                            if(etc_render_fsbrain.overlay_value_flag_neg)
                                etc_render_fsbrain.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                                image([size(etc_render_fsbrain.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                                h=text(-3,1,sprintf('-%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                                h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                            else
                                etc_render_fsbrain.h_colorbar_neg=[];
                            end;
                        end;
                        
                        if(ishandle(etc_render_fsbrain.fig_gui))
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_show_colorbar'),'value',1);
                        end;
                    else
                        delete(etc_render_fsbrain.h_colorbar_pos);
                        etc_render_fsbrain.h_colorbar_pos=[];
                        delete(etc_render_fsbrain.h_colorbar_neg);
                        etc_render_fsbrain.h_colorbar_neg=[];
                        set(etc_render_fsbrain.brain_axis,'pos',etc_render_fsbrain.brain_axis_pos);
                        
                        if(ishandle(etc_render_fsbrain.fig_gui))
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','checkbox_show_colorbar'),'value',0);
                        end;
                    end;
                else
                    if(etc_render_fsbrain.overlay_value_flag_pos|etc_render_fsbrain.overlay_value_flag_neg)
                        etc_render_fsbrain.brain_axis=gca;
                        etc_render_fsbrain.brain_axis_pos=get(gca,'pos');
                        set(etc_render_fsbrain.brain_axis,'pos',[etc_render_fsbrain.brain_axis_pos(1) 0.2 etc_render_fsbrain.brain_axis_pos(3) 0.8]);
                        etc_render_fsbrain.h_colorbar=subplot('position',[etc_render_fsbrain.brain_axis_pos(1) 0.0 etc_render_fsbrain.brain_axis_pos(3) 0.2]);
                        
                        cmap=[etc_render_fsbrain.overlay_cmap; etc_render_fsbrain.overlay_cmap_neg];
                        
                        if(etc_render_fsbrain.overlay_value_flag_pos)
                            etc_render_fsbrain.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                            image([1:size(etc_render_fsbrain.overlay_cmap,1)]); axis off; colormap(cmap);
                            h=text(-3,1,sprintf('%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                            h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                        else
                            etc_render_fsbrain.h_colorbar_pos=[];
                        end;
                        
                        if(etc_render_fsbrain.overlay_value_flag_neg)
                            etc_render_fsbrain.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                            image([size(etc_render_fsbrain.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                            h=text(-3,1,sprintf('-%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                            h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                        else
                            etc_render_fsbrain.h_colorbar_neg=[];
                        end;
                    end;
                end;
            case 'c0' %enforce showing colorbar
                figure(etc_render_fsbrain.fig_brain);
                
                etc_render_fsbrain.brain_axis_pos=get(etc_render_fsbrain.brain_axis,'pos');
                set(etc_render_fsbrain.brain_axis,'pos',[etc_render_fsbrain.brain_axis_pos(1) 0.2 etc_render_fsbrain.brain_axis_pos(3) 0.8]);
                etc_render_fsbrain.h_colorbar=subplot('position',[etc_render_fsbrain.brain_axis_pos(1) 0.0 etc_render_fsbrain.brain_axis_pos(3) 0.2]);
                
                cmap=[etc_render_fsbrain.overlay_cmap; etc_render_fsbrain.overlay_cmap_neg];
                hold on;
                
                if(etc_render_fsbrain.overlay_value_flag_pos)
                    etc_render_fsbrain.h_colorbar_pos=subplot('position',[0.4 0.05 0.2 0.02]);
                    image([1:size(etc_render_fsbrain.overlay_cmap,1)]); axis off; colormap(cmap);
                    h=text(-3,1,sprintf('%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                    h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                else
                    etc_render_fsbrain.h_colorbar_pos=[];
                end;
                if(etc_render_fsbrain.overlay_value_flag_neg)
                    etc_render_fsbrain.h_colorbar_neg=subplot('position',[0.4 0.10 0.2 0.02]);
                    image([size(etc_render_fsbrain.overlay_cmap,1)+1:size(cmap,1)]); axis off; colormap(cmap);
                    h=text(-3,1,sprintf('-%1.3f',min(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','right','color',[1 1 1]-etc_render_fsbrain.bg_color);
                    h=text(size(etc_render_fsbrain.overlay_cmap,1)+3,1,sprintf('-%1.3f',max(etc_render_fsbrain.overlay_threshold))); set(h,'fontname','helvetica','fontsize',14,'fontweight','bold','horizon','left','color',[1 1 1]-etc_render_fsbrain.bg_color);
                else
                    etc_render_fsbrain.h_colorbar_neg=[];
                end;
                
            case 'y' %cluster
                
                
            case 'u' %show cluster labeling from files
                if(isfield(etc_render_fsbrain,'h_cluster'))
                    if(isempty(etc_render_fsbrain.h_cluster))
                        l_idx_offset=0;
                        for f_idx=1:length(etc_render_fsbrain.cluster_file)
                            fprintf('\nlabeling clusters from file [%s]...\n',etc_render_fsbrain.cluster_file{f_idx});
                            [x1 x2 x3 x4 x5 x6 x7 x8 x9 x10] = textread(etc_render_fsbrain.cluster_file{f_idx},'%d%f%d%f%f%f%f%f%d%s','commentstyle','shell');
                            axes(etc_render_fsbrain.brain_axis);
                            
                            for l_idx=1:length(x3)
                                ss=sprintf('%d',l_idx+l_idx_offset);
                                etc_render_fsbrain.h_cluster(l_idx+l_idx_offset)=text(etc_render_fsbrain.vertex_coords(x3(l_idx)+1,1).*1.1,etc_render_fsbrain.vertex_coords(x3(l_idx)+1,2).*1.1, etc_render_fsbrain.vertex_coords(x3(l_idx)+1,3).*1.1,ss);
                                set(etc_render_fsbrain.h_cluster(l_idx+l_idx_offset),'color','k','fontname','helvetica','fontsize',18,'fontweight','bold','HorizontalAlignment','center');
                                fprintf('cluster [%03d]: value=%2.2f area=%1.0f (mm^2) x=%2.2f (mm) y=%2.2f (mm) z=%2.2f (mm)  <<%s>>\n',l_idx+l_idx_offset,x2(l_idx),x4(l_idx),x5(l_idx),x6(l_idx),x7(l_idx),x10{l_idx});
                            end;
                            l_idx_offset=l_idx_offset+l_idx;
                        end;
                    else
                        delete(etc_render_fsbrain.h_cluster);
                        etc_render_fsbrain.h_cluster=[];
                    end;
                else
                    l_idx_offset=0;
                    for f_idx=1:length(etc_render_fsbrain.cluster_file)
                        fprintf('\nlabeling clusters from file [%s]...\n',etc_render_fsbrain.cluster_file{f_idx});
                        [x1 x2 x3 x4 x5 x6 x7 x8 x9 x10] = textread(etc_render_fsbrain.cluster_file{f_idx},'%d%f%d%f%f%f%f%f%d%s','commentstyle','shell');
                        axes(etc_render_fsbrain.brain_axis);
                        
                        for l_idx=1:length(x3)
                            ss=sprintf('%d',l_idx+l_idx_offset);
                            etc_render_fsbrain.h_cluster(l_idx+l_idx_offset)=text(etc_render_fsbrain.vertex_coords(x3(l_idx)+1,1).*1.1,etc_render_fsbrain.vertex_coords(x3(l_idx)+1,2).*1.1, etc_render_fsbrain.vertex_coords(x3(l_idx)+1,3).*1.1,ss);
                            set(etc_render_fsbrain.h_cluster(l_idx+l_idx_offset),'color','k','fontname','helvetica','fontsize',18,'fontweight','bold','HorizontalAlignment','center');
                            fprintf('cluster [%03d]: value=%2.2f area=%1.0f (mm^2) x=%2.2f (mm) y=%2.2f (mm) z=%2.2f (mm)  <<%s>>\n',l_idx+l_idx_offset,x2(l_idx),x4(l_idx),x5(l_idx),x6(l_idx),x7(l_idx),x10{l_idx});
                        end;
                        l_idx_offset=l_idx_offset+l_idx;
                    end;
                end;
            case 'd' %change overlay threshold or time course limits
                if((gcf==etc_render_fsbrain.fig_brain)|(gcf==etc_render_fsbrain.fig_vol))
                    fprintf('change threshold...\n');
                    fprintf('current threshold = %s\n',mat2str(etc_render_fsbrain.overlay_threshold));
                    def={num2str(etc_render_fsbrain.overlay_threshold(:)')};
                    answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.overlay_threshold)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_threshold=str2num(answer{1});
                        fprintf('updated threshold = %s\n',mat2str(etc_render_fsbrain.overlay_threshold));
                        
                        if(ishandle(etc_render_fsbrain.fig_gui))
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_threshold_min'),'string',sprintf('%1.0f',min(etc_render_fsbrain.overlay_threshold)));
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_threshold_max'),'string',sprintf('%1.0f',max(etc_render_fsbrain.overlay_threshold)));
                        end;
                        draw_pointer;
                        redraw;
                    end;
                elseif(gcf==etc_render_fsbrain.fig_stc)
                    fprintf('change time course limits...\n');
                    if(isempty(etc_render_fsbrain.overlay_stc_lim))
                        etc_render_fsbrain.overlay_stc_lim=get(gca,'ylim');
                    end;
                    fprintf('current limits = %s\n',mat2str(etc_render_fsbrain.overlay_stc_lim));
                    def={num2str(etc_render_fsbrain.overlay_stc_lim)};
                    answer=inputdlg('change limits',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.overlay_stc_lim)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_stc_lim=str2num(answer{1});
                        fprintf('updated time course limits = %s\n',mat2str(etc_render_fsbrain.overlay_stc_lim));
                        
                        draw_stc;
                    end;
                end;
            case 's' %change overlay smoothing steps
                if(gcf==etc_render_fsbrain.fig_brain)
                    fprintf('change smoothing steps...\n');
                    fprintf('current smoothing steps = %s\n',mat2str(etc_render_fsbrain.overlay_smooth));
                    def={num2str(etc_render_fsbrain.overlay_smooth)};
                    answer=inputdlg('change smoothing steps',sprintf('current smoothing steps = %s',mat2str(etc_render_fsbrain.overlay_smooth)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_smooth=str2num(answer{1});
                        fprintf('updated smoothing steps = %s\n',mat2str(etc_render_fsbrain.overlay_smooth));
                        
                        redraw;
                    end
                    
                    if(ishandle(etc_render_fsbrain.fig_gui))
                        set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_smooth'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_smooth));
                    end;
                end;
                
            case 'm' %create a surface patch based on the clicked location and a specified radius
                
                if(isempty(etc_render_fsbrain.click_vertex))
                    fprintf('no selected point! try to click the figure to select one point before creating ROI.\n');
                else
                    fprintf('creating ROI...\n');
                    if(isempty(etc_render_fsbrain.roi_radius)) etc_render_fsbrain.roi_radius=5; end;
                    fprintf('current ROI radius = %s\n',mat2str(etc_render_fsbrain.roi_radius));
                    def={mat2str(etc_render_fsbrain.roi_radius)};
                    answer=inputdlg('ROI radius (mm)',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.roi_radius)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.roi_radius=str2num(answer{1});
                        fprintf('ROI radius = %s\n',mat2str(etc_render_fsbrain.roi_radius));
                        
                        if(~isfield(etc_render_fsbrain,'dijk_A'))
                            connection=etc_render_fsbrain.faces_hemi'+1;
                            d1=[connection(1,:);connection(2,:);ones(1,size(connection,2))]';
                            d2=[connection(2,:);connection(1,:);ones(1,size(connection,2))]';
                            d3=[connection(1,:);connection(3,:);ones(1,size(connection,2))]';
                            d4=[connection(3,:);connection(1,:);ones(1,size(connection,2))]';
                            d5=[connection(2,:);connection(3,:);ones(1,size(connection,2))]';
                            d6=[connection(3,:);connection(2,:);ones(1,size(connection,2))]';
                            dd=[d1;d2;d3;d4;d5;d6];
                            dd=unique(dd,'rows');
                            etc_render_fsbrain.dijk_A=spones(spconvert(dd));
                        end;
                        
                        D=dijkstra(etc_render_fsbrain.dijk_A,etc_render_fsbrain.click_vertex);
                        roi_idx=find(D<=etc_render_fsbrain.roi_radius);
                        etc_render_fsbrain.label_idx=roi_idx;
                        etc_render_fsbrain.label_h=plot3(etc_render_fsbrain.vertex_coords_hemi(roi_idx,1),etc_render_fsbrain.vertex_coords_hemi(roi_idx,2), etc_render_fsbrain.vertex_coords_hemi(roi_idx,3),'r.');
                        
                        %save the label?
                        [file, path] = uiputfile({'*.label'});
                        if isequal(file,0) || isequal(path,0)
                            etc_render_fsbrain.label_idx=[];
                            delete(etc_render_fsbrain.label_h);
                        else
                            fn=fullfile(path,file);
                            disp(['User selected ',fullfile(path,file),...
                                ' and then clicked Save.'])
                            inverse_write_label(etc_render_fsbrain.label_idx(:)-1,zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),zeros(size(etc_render_fsbrain.label_idx(:))),ones(size(etc_render_fsbrain.label_idx(:))),fn);
                            fprintf('ROI saved [%s].\n',fn);
                        end
                        
                    end;
                end;
            otherwise
                %fprintf('pressed [%c]!\n',cc);
        end;
    case 'del'
        try
            delete(etc_render_fsbrain.fig_subject);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_subject'))
                close(etc_render_fsbrain.fig_subject,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_register);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_register'))
                close(etc_render_fsbrain.fig_register,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_stc);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_stc'))
                close(etc_render_fsbrain.fig_stc,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_coord_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_coord_gui'))
                close(etc_render_fsbrain.fig_coord_gui,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_label_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_label_gui'))
                close(etc_render_fsbrain.fig_label_gui,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_electrode_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_electrode_gui'))
                close(etc_render_fsbrain.fig_electrode_gui,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_gui);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_gui'))
                close(etc_render_fsbrain.fig_gui,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_vol);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_vol'))
                close(etc_render_fsbrain.fig_vol,'force');
            else
                close(gcf,'force');
            end;
        end;
        
        try
            delete(etc_render_fsbrain.fig_brain);
        catch ME
            if(isfield(etc_render_fsbrain,'fig_brain'))
                close(etc_render_fsbrain.fig_brain,'force');
            else
                close(gcf,'force');
            end;
        end;
    case 'bd'
        if(gcf==etc_render_fsbrain.fig_brain)
            
            %add exploration toolbar
            [vv date] = version;
            DateNumber = datenum(date);
            if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
                addToolbarExplorationButtons(etc_render_fsbrain.fig_vol);
            end;
            
            etc_render_fsbrain.flag_overlay_stc_surf=1;
            etc_render_fsbrain.flag_overlay_stc_vol=0;
            
           
            update_overlay_vol;
            draw_pointer;
            
            if(isfield(etc_render_fsbrain,'overlay_stc_timeVec_idx'))
                if(~isempty(etc_render_fsbrain.overlay_stc_timeVec))
                    if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                        draw_stc;
                        
                        global etc_trace_obj;
                        if(~isempty(etc_trace_obj))
                            if(isvalid(etc_trace_obj.fig_trace))
                                try
                                    etc_trace_obj.trace_selected_idx=etc_render_fsbrain.click_overlay_vertex;
                                    etc_trace_handle('redraw');
                                catch ME
                                end;
                            end;
                        end;
                    end;
                end;
            end;
            %redraw;
            figure(etc_render_fsbrain.fig_brain);
        elseif(gcf==etc_render_fsbrain.fig_vol)
            
            %add exploration toolbar
            [vv date] = version;
            DateNumber = datenum(date);
            if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
                addToolbarExplorationButtons(etc_render_fsbrain.fig_vol);
            end;
            
            etc_render_fsbrain.flag_overlay_stc_surf=0;
            etc_render_fsbrain.flag_overlay_stc_vol=1;
            
            update_overlay_vol;
            xx=get(gca,'currentpoint');
            xx=xx(1,1:2);
            
            [z1,x1,y1]=size(etc_render_fsbrain.vol.vol);
            mm=max([z1 y1 x1]);
            
            tmp=ceil([xx(1)./mm, xx(2)./mm]);
            
            if(min(tmp(:))>=1&max(tmp(:))<=2)
                ind=sub2ind([2 2],tmp(1),tmp(2));
                                
                vox=etc_render_fsbrain.click_vertex_vox;
                switch ind
                    case 1 %cor slice
                        v=[xx(1)-etc_render_fsbrain.img_cor_padx xx(2)-etc_render_fsbrain.img_cor_pady vox(3)];
                    case 2 %ax slice
                        %v=[xx(2)-etc_render_fsbrain.img_ax_pady vox(2) xx(1)-etc_render_fsbrain.img_ax_padx-mm];
                        v=[xx(1)-etc_render_fsbrain.img_ax_padx-mm vox(2) mm-xx(2)+etc_render_fsbrain.img_ax_pady];
                    case 3 %sag slice
                        v=[vox(1) xx(2)-etc_render_fsbrain.img_sag_pady-mm xx(1)-etc_render_fsbrain.img_sag_padx];
                    otherwise
                        v=[];
                end;
                if(~isempty(v))
                    %surface_coord=etc_render_fsbrain.vol.vox2ras*[v(:); 1];
                    
                    %convert the volume CRS coordinates to surface (x,y,z)
                    surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[v(:); 1];
                    
                    %convert the surface coordinate corresponding to
                    %current volume to to the surface coordinate
                    %corresponding to "ORIG' volume
                    surface_coord=inv(etc_render_fsbrain.vol_reg)*surface_coord;
                    
                    surface_coord=surface_coord(1:3);
                    click_vertex_vox=v;
                    
                    vv=etc_render_fsbrain.orig_vertex_coords;
                    dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                    [min_dist,min_dist_idx]=min(dist);
                    %surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
                    
                    %surface_coord=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:)';
                    
                    %draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
                    surface_coord_now=etc_render_fsbrain.vertex_coords(min_dist_idx,:);
                    draw_pointer('pt',surface_coord_now,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);    
                    
                    if((~isempty(etc_render_fsbrain.vol_A))&&(~isempty(etc_render_fsbrain.overlay_vol_stc)))
                        loc_lh=cat(1,etc_render_fsbrain.vol_A(1).loc,etc_render_fsbrain.vol_A(1).wb_loc.*1e3);
                        loc_rh=cat(1,etc_render_fsbrain.vol_A(2).loc,etc_render_fsbrain.vol_A(2).wb_loc.*1e3);
                        loc=cat(1,loc_lh,loc_rh);
                        dist=sqrt(sum((loc-repmat(surface_coord(:)',[size(loc,1),1])).^2,2));
                        [dummy,loc_min_idx]=min(dist);
                        
                        
                        etc_render_fsbrain.click_overlay_vertex=loc_min_idx;
                        
                        %figure(10);
                        %plot(etc_render_fsbrain.overlay_vol_stc(loc_min_idx,:));
                        etc_render_fsbrain.overlay_vol_stc_1d=etc_render_fsbrain.overlay_vol_stc(loc_min_idx,:);
                        
                        if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                            for vv_idx=1:size(etc_render_fsbrain.overlay_aux_vol_stc,3);
                                etc_render_fsbrain.overlay_aux_vol_stc_1d=etc_render_fsbrain.overlay_aux_vol_stc(loc_min_idx,:,vv_idx);
                            end;
                        end;
                        
                        %etc_render_fsbrain.overlay_stc=etc_render_fsbrain.overlay_vol_stc;
                        %etc_render_fsbrain.click_overlay_vertex=loc_min_idx;
                        
                        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                            draw_stc;
                        end;
                    elseif(~isempty(etc_render_fsbrain.overlay_vol))
                        rv=round(v);
                        tmp=etc_render_fsbrain.overlay_vol.vol(rv(1),rv(2),rv(3),:);
                        etc_render_fsbrain.overlay_vol_stc_1d=tmp(:);
                        
                        for vv_idx=1:length(etc_render_fsbrain.overlay_aux_vol);
                            tmp=etc_render_fsbrain.overlay_aux_vol(vv_idx).vol(rv(1),rv(2),rv(3),:);
                            etc_render_fsbrain.overlay_vol_stc_1d(:,vv_idx)=tmp(:);
                        end;
                        
                        if(length(etc_render_fsbrain.overlay_stc_timeVec)>1)
                            draw_stc;
                        end;
                    end;

                end;
            end;
            figure(etc_render_fsbrain.fig_vol);
            
        elseif(gcf==etc_render_fsbrain.fig_stc)
           xx=get(gca,'currentpoint');
            xx=xx(1);
            if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
                etc_render_fsbrain.overlay_stc_timeVec_idx=round(xx);
                fprintf('showing STC at time index [%d] (sample)\n',etc_render_fsbrain.overlay_stc_timeVec_idx);
            else
                [dummy,etc_render_fsbrain.overlay_stc_timeVec_idx]=min(abs(etc_render_fsbrain.overlay_stc_timeVec-xx));
                if(isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
                    unt='sample';
                else
                    unt=etc_render_fsbrain.overlay_stc_timeVec_unit;
                end;
                fprintf('showing STC at time [%2.2f] %s\n',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx),unt);
            end;
            
            %update the overlay values at current time point
            update_overlay_vol;

            if(~iscell(etc_render_fsbrain.overlay_value))
                etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
            else
                for h_idx=1:length(etc_render_fsbrain.overlay_value)
                    etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                end;
            end;
            
            if(~isempty(etc_render_fsbrain.overlay_stc))
                draw_stc;
            end
           
            if(ishandle(etc_render_fsbrain.fig_gui))
                set(findobj(etc_render_fsbrain.fig_gui,'tag','slider_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                
                set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
            end;
            
            figure(etc_render_fsbrain.fig_brain);
           
            draw_pointer('pt',etc_render_fsbrain.click_coord,'min_dist_idx',etc_render_fsbrain.click_vertex,'click_vertex_vox',etc_render_fsbrain.click_vertex_vox);
            redraw;
            figure(etc_render_fsbrain.fig_stc);
            
        end;
        
        global etc_trace_obj;
        if(~isempty(etc_trace_obj))
            if(isvalid(etc_trace_obj.fig_trace))
                etc_trace_handle('bd','time_idx',etc_render_fsbrain.overlay_stc_timeVec_idx);
            end;
        end;
end;

return;


function draw_pointer(varargin)
pt=[];
min_dist_idx=[];
click_vertex_vox=[];
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch option
        case 'pt'
            pt=option_value;
        case 'min_dist_idx'
            min_dist_idx=option_value;
        case 'click_vertex_vox'
            click_vertex_vox=option_value;
    end;
end;

global etc_render_fsbrain;
%fprintf('at the beginning of draw pointer: [%d]\n', ishandle(etc_render_fsbrain.h));

try
    
    ax=get(etc_render_fsbrain.fig_brain,'child');
    set(etc_render_fsbrain.fig_brain,'CurrentAxes',etc_render_fsbrain.brain_axis);

    if(~isempty(etc_render_fsbrain.click_point))
        if(ishandle(etc_render_fsbrain.click_point))
            delete(etc_render_fsbrain.click_point);
            %        fprintf('1: [%d]\n',ishandle(etc_render_fsbrain.h));
            etc_render_fsbrain.click_point=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.click_vertex_point))
        if(ishandle(etc_render_fsbrain.click_vertex_point))
            delete(etc_render_fsbrain.click_vertex_point);
            %        fprintf('3: [%d]\n',ishandle(etc_render_fsbrain.h));
            etc_render_fsbrain.click_vertex_point=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.click_overlay_vertex_point))
        if(ishandle(etc_render_fsbrain.click_overlay_vertex_point))
            delete(etc_render_fsbrain.click_overlay_vertex_point);
            %        fprintf('5: [%d]\n',ishandle(etc_render_fsbrain.h));
            etc_render_fsbrain.click_overlay_vertex_point=[];
        end;
    end;
    
    
    if(isvalid(etc_render_fsbrain.fig_brain))
        figure(etc_render_fsbrain.fig_brain);
    end;
    
    if(ishandle(etc_render_fsbrain.h)&isempty(pt))
        pt=inverse_select3d(etc_render_fsbrain.h);
        if(isempty(pt))
            return;
        end
    else
    end;
    
    if(~isempty(etc_render_fsbrain.click_point))
        etc_render_fsbrain.click_point=[];
    end;
    
    etc_render_fsbrain.click_coord=pt;
    if(etc_render_fsbrain.show_brain_surface_location_flag)
        etc_render_fsbrain.click_point=plot3(pt(1),pt(2),pt(3),'.');
        fprintf('\nsurface coordinate of the clicked point {x, y, z} = {%s}\n',num2str(pt(:)','%2.2f '));
        %set(etc_render_fsbrain.click_point,'color',[1 0 1],'markersize',28);
        set(etc_render_fsbrain.click_point,'color',etc_render_fsbrain.click_point_color,'markersize',etc_render_fsbrain.click_point_size);
    end;
    
    vv=etc_render_fsbrain.vertex_coords;
    if(isempty(min_dist_idx))
        dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
        [min_dist,min_dist_idx]=min(dist);
    end;
    if(isempty(etc_render_fsbrain.ovs))
        fprintf('the nearest vertex on the surface: IDX=[%d] {x, y, z} = {%2.2f %2.2f %2.2f} \n',min_dist_idx,vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3));
    else
        fprintf('the nearest vertex on the surface: IDX=[%d] {x, y, z} = {%2.2f %2.2f %2.2f} <<%2.2f>> \n',min_dist_idx,vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3),etc_render_fsbrain.ovs(min_dist_idx));
    end;
    etc_render_fsbrain.click_coord_round=[vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3)];
    etc_render_fsbrain.click_vertex=min_dist_idx;
    if(etc_render_fsbrain.show_nearest_brain_surface_location_flag)
        etc_render_fsbrain.click_vertex_point=plot3(vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3),'.');
        %set(etc_render_fsbrain.click_vertex_point,'color',[0 1 1],'markersize',24);
        set(etc_render_fsbrain.click_vertex_point,'color',etc_render_fsbrain.click_vertex_point_color,'markersize',etc_render_fsbrain.click_vertex_point_size);
    end;
    
    if(isfield(etc_render_fsbrain,'flag_collect_vertex'))
        if(etc_render_fsbrain.flag_collect_vertex)
            etc_render_fsbrain.collect_vertex=cat(1,etc_render_fsbrain.collect_vertex,etc_render_fsbrain.click_vertex);
            
            if(isfield(etc_render_fsbrain,'collect_vertex_point'))
                etc_render_fsbrain.collect_vertex_point(end+1)=plot3(vv(etc_render_fsbrain.collect_vertex(end),1),vv(etc_render_fsbrain.collect_vertex(end),2),vv(etc_render_fsbrain.collect_vertex(end),3),'.');
            else
                etc_render_fsbrain.collect_vertex_point=plot3(vv(etc_render_fsbrain.collect_vertex(end),1),vv(etc_render_fsbrain.collect_vertex(end),2),vv(etc_render_fsbrain.collect_vertex(end),3),'.');
            end;
            set(etc_render_fsbrain.collect_vertex_point(end),'color',[0 1 1].*0.5,'markersize',1);
            
            fprintf('collected vertices: %s\n',mat2str(etc_render_fsbrain.collect_vertex));
            
            if(length(etc_render_fsbrain.collect_vertex)>1) %connecting selected vertices
                
                %dijkstra search preparation
                if(~isfield(etc_render_fsbrain,'dijk_A'))
                    connection=etc_render_fsbrain.faces_hemi'+1;
                    d1=[connection(1,:);connection(2,:);ones(1,size(connection,2))]';
                    d2=[connection(2,:);connection(1,:);ones(1,size(connection,2))]';
                    d3=[connection(1,:);connection(3,:);ones(1,size(connection,2))]';
                    d4=[connection(3,:);connection(1,:);ones(1,size(connection,2))]';
                    d5=[connection(2,:);connection(3,:);ones(1,size(connection,2))]';
                    d6=[connection(3,:);connection(2,:);ones(1,size(connection,2))]';
                    dd=[d1;d2;d3;d4;d5;d6];
                    dd=unique(dd,'rows');
                    etc_render_fsbrain.dijk_A=spones(spconvert(dd));
                end;
                
                %dijkstra search finds vertices on the shortest path between
                %the last two selected vertices
                D=dijkstra(etc_render_fsbrain.dijk_A,etc_render_fsbrain.collect_vertex(end-1));
                paths=etc_distance2path(etc_render_fsbrain.collect_vertex(end),D,etc_render_fsbrain.faces_hemi+1);
                paths=flipud(paths);
                
                %connect vertices by traversing the shortest path
                for p_idx=2:length(paths)
                    etc_render_fsbrain.collect_vertex_boundary=cat(1,etc_render_fsbrain.collect_vertex_boundary,paths(p_idx));
                    etc_render_fsbrain.collect_vertex_boundary_point(end+1)=plot3(vv(etc_render_fsbrain.collect_vertex_boundary(end),1),vv(etc_render_fsbrain.collect_vertex_boundary(end),2),vv(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
                    set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',1);
                end;
            else
                etc_render_fsbrain.collect_vertex_boundary=etc_render_fsbrain.collect_vertex(end);
                etc_render_fsbrain.collect_vertex_boundary_point=plot3(vv(etc_render_fsbrain.collect_vertex_boundary(end),1),vv(etc_render_fsbrain.collect_vertex_boundary(end),2),vv(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
                set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',1);
            end;
        end;
    else
        etc_render_fsbrain.flag_collect_vertex=0;
    end;
    
    %show label
    if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
        ctab_val=etc_render_fsbrain.label_ctab.table(:,5);
        ii=find(ctab_val==etc_render_fsbrain.label_value(min_dist_idx));
        if(~isempty(ii))
            fprintf('the nearest vertex is at label {%s}\n',etc_render_fsbrain.label_ctab.struct_names{ii});
            try
                if(~isempty(etc_render_fsbrain.fig_label_gui))
                    handles=guidata(etc_render_fsbrain.fig_label_gui);
                    set(handles.listbox_label,'value',ii);
                end;
            catch ME
            end;
        end;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %volume image rendering
    if(~isempty(etc_render_fsbrain.fig_vol))
        if(~isvalid(etc_render_fsbrain.fig_vol))
            delete(etc_render_fsbrain.fig_vol);
            etc_render_fsbrain.fig_vol=[];
            
            etc_render_fsbrain.fig_vol=figure;
            pos=get(etc_render_fsbrain.fig_brain,'pos');
            set(etc_render_fsbrain.fig_vol,'pos',[pos(1)-pos(3), pos(2), pos(3), pos(4)]);
            
            xlim=[];
            ylim=[];
        else
            try
                xlim=get(etc_render_fsbrain.vol_img_h,'xlim');
                ylim=get(etc_render_fsbrain.vol_img_h,'ylim');
                CATCH ME
            end;
        end;
    else
        if(~isempty(etc_render_fsbrain.vol_vox))
            etc_render_fsbrain.fig_vol=figure;
            pos=get(etc_render_fsbrain.fig_brain,'pos');
            set(etc_render_fsbrain.fig_vol,'pos',[pos(1)-pos(3), pos(2), pos(3), pos(4)]);
            
            xlim=[];
            ylim=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.vol_vox))
        figure(etc_render_fsbrain.fig_vol);
        
        set(etc_render_fsbrain.fig_vol,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
        set(etc_render_fsbrain.fig_vol,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
        set(etc_render_fsbrain.fig_vol,'invert','off','color','k');
    end;
    
    if(~isempty(etc_render_fsbrain.vol_vox))
        %coordinate transformation
        
        
        %the volume index click_vertex_vox is in CRS!
        if(isempty(click_vertex_vox))
            etc_render_fsbrain.click_vertex_vox=(etc_render_fsbrain.vol_vox(min_dist_idx,:));
            etc_render_fsbrain.click_vertex_vox_round=round(etc_render_fsbrain.vol_vox(min_dist_idx,:));
        else
            %fprintf('------[%s]-----\n',mat2str(round(etc_render_fsbrain.click_vertex_vox)));
            etc_render_fsbrain.click_vertex_vox=click_vertex_vox;
            etc_render_fsbrain.click_vertex_vox_round=round(click_vertex_vox);
        end;
        fprintf('voxel for the clicked surface point [C, R, S] = [%1.1f %1.1f %1.1f]\n',etc_render_fsbrain.click_vertex_vox(1),etc_render_fsbrain.click_vertex_vox(2),etc_render_fsbrain.click_vertex_vox(3));
        fprintf('the rounded voxel for the clicked surface point [C, R, S] = [%d %d %d]\n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3));
        if(~isempty(etc_render_fsbrain.overlay_vol))
            if(ndims(etc_render_fsbrain.overlay_vol.vol)==3)
                fprintf('value at the rounded voxel for the clicked surface point [%d %d %d] = [%1.1f] \n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3),etc_render_fsbrain.overlay_vol.vol(etc_render_fsbrain.click_vertex_vox_round(2), etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.click_vertex_vox_round(3)));
            elseif(ndims(etc_render_fsbrain.overlay_vol.vol)==4)
                fprintf('value at the rounded voxel for the clicked surface point [%d %d %d] = [%1.1f] \n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3),etc_render_fsbrain.overlay_vol.vol(etc_render_fsbrain.click_vertex_vox_round(2), etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.click_vertex_vox_round(3),etc_render_fsbrain.overlay_stc_timeVec_idx));
            end;
        end;
        if(~isempty(etc_render_fsbrain.talxfm))
            etc_render_fsbrain.click_vertex_point_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox 1].';
            etc_render_fsbrain.click_vertex_point_tal=etc_render_fsbrain.click_vertex_point_tal(1:3)';
            fprintf('MNI305 coordinate for the clicked point (x, y, z) = (%1.0f %1.0f %1.0f)\n',etc_render_fsbrain.click_vertex_point_tal(1),etc_render_fsbrain.click_vertex_point_tal(2),etc_render_fsbrain.click_vertex_point_tal(3));
            etc_render_fsbrain.click_vertex_point_round_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox_round 1].';
            etc_render_fsbrain.click_vertex_point_round_tal=etc_render_fsbrain.click_vertex_point_round_tal(1:3)';
            fprintf('MNI305 coordinate for the surface location closest to the clicked point (x, y, ,z) = (%1.0f %1.0f %1.0f)\n',etc_render_fsbrain.click_vertex_point_round_tal(1),etc_render_fsbrain.click_vertex_point_round_tal(2),etc_render_fsbrain.click_vertex_point_round_tal(3));
        end;
        try
            [zz,xx,yy]=size(etc_render_fsbrain.vol.vol);
            mm=max([zz yy xx]);
            
            if(etc_render_fsbrain.electrode_update_contact_view_flag)
                img_cor=squeeze(etc_render_fsbrain.vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
                img_sag=squeeze(etc_render_fsbrain.vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
                img_ax=rot90(squeeze(etc_render_fsbrain.vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:)));
                
                if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    mask_img_cor=squeeze(etc_render_fsbrain.overlay_vol_mask.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
                    mask_img_sag=squeeze(etc_render_fsbrain.overlay_vol_mask.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
                    mask_img_ax=rot90(squeeze(etc_render_fsbrain.overlay_vol_mask.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:)));
                else
                    mask_img_cor=[];
                    mask_img_sag=[];
                    mask_img_ax=[];
                end;
                
                if(~isempty(etc_render_fsbrain.overlay_vol))
                    if(ndims(etc_render_fsbrain.overlay_vol.vol)==4)
                        img_cor_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3)),etc_render_fsbrain.overlay_stc_timeVec_idx));
                        img_sag_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:,etc_render_fsbrain.overlay_stc_timeVec_idx));
                        img_ax_overlay=rot90(squeeze(etc_render_fsbrain.overlay_vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:,etc_render_fsbrain.overlay_stc_timeVec_idx)));
                    elseif(ndims(etc_render_fsbrain.overlay_vol.vol)==3)
                        img_cor_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
                        img_sag_overlay=squeeze(etc_render_fsbrain.overlay_vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
                        img_ax_overlay=rot90(squeeze(etc_render_fsbrain.overlay_vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:)));
                    end;
                    
                    
                    
                    %truncate positive value overlay
                    if(etc_render_fsbrain.flag_overlay_truncate_pos)
                        idx=find(img_cor_overlay(:)>0);
                        img_cor_overlay(idx)=0;
                        idx=find(img_sag_overlay(:)>0);
                        img_sag_overlay(idx)=0;
                        idx=find(img_ax_overlay(:)>0);
                        img_ax_overlay(idx)=0;
                    end;
                    
                    %truncate negative value overlay
                    if(etc_render_fsbrain.flag_overlay_truncate_neg)
                        idx=find(img_cor_overlay(:)<0);
                        img_cor_overlay(idx)=0;
                        idx=find(img_sag_overlay(:)<0);
                        img_sag_overlay(idx)=0;
                        idx=find(img_ax_overlay(:)<0);
                        img_ax_overlay(idx)=0;
                    end;
                    
                else
                    img_cor_overlay=[];
                    img_ax_overlay=[];
                    img_sag_overlay=[];
                end;
                
                %[zz,xx,yy]=size(etc_render_fsbrain.vol.vol);
                %mm=max([zz yy xx]);
                if(zz<mm)
                    n1=floor((mm-zz)/2);
                    n2=mm-zz-n1;
                    img_cor=cat(1,zeros(n1,size(img_cor,2)),img_cor,zeros(n2,size(img_cor,2)));
                    img_sag=cat(1,zeros(n1,size(img_sag,2)),img_sag,zeros(n2,size(img_sag,2)));
                    
                    if(~isempty(img_cor_overlay))
                        img_cor_overlay=cat(1,zeros(n1,size(img_cor_overlay,2)),img_cor_overlay,zeros(n2,size(img_cor_overlay,2)));
                    end;
                    if(~isempty(img_sag_overlay))
                        img_sag_overlay=cat(1,zeros(n1,size(img_sag_overlay,2)),img_sag_overlay,zeros(n2,size(img_sag_overlay,2)));
                    end;
                    
                    if(~isempty(mask_img_cor))
                        mask_img_cor=cat(1,zeros(n1,size(mask_img_cor,2)),mask_img_cor,zeros(n2,size(mask_img_cor,2)));
                    end;
                    if(~isempty(mask_img_sag))
                        mask_img_sag=cat(1,zeros(n1,size(mask_img_sag,2)),mask_img_sag,zeros(n2,size(mask_img_sag,2)));
                    end;                        
                    
                    etc_render_fsbrain.img_cor_pady=n1;
                    etc_render_fsbrain.img_sag_pady=n1;
                else
                    etc_render_fsbrain.img_cor_pady=0;
                    etc_render_fsbrain.img_sag_pady=0;
                end;
                
                if(yy<mm)
                    n1=floor((mm-yy)/2);
                    n2=mm-yy-n1;
                    img_sag=cat(2,zeros(size(img_sag,1),n1),img_sag,zeros(size(img_sag,1),n2));
                    img_ax=cat(1,zeros(n1,size(img_ax,2)),img_ax,zeros(n2,size(img_ax,2)));
                    
                    if(~isempty(img_sag_overlay))
                        img_sag_overlay=cat(2,zeros(size(img_sag_overlay,1),n1),img_sag_overlay,zeros(size(img_sag_overlay,1),n2));
                    end;
                    if(~isempty(img_ax_overlay))
                        img_ax_overlay=cat(1,zeros(n1,size(img_ax_overlay,2)),img_ax_overlay,zeros(n2,size(img_ax_overlay,2)));
                    end;
                    
                    if(~isempty(mask_img_sag))
                        mask_img_sag=cat(2,zeros(size(mask_img_sag,1),n1),mask_img_sag,zeros(size(mask_img_sag,1),n2));
                    end;
                    if(~isempty(mask_img_ax))
                        mask_img_ax=cat(1,zeros(n1,size(mask_img_ax,2)),mask_img_ax,zeros(n2,size(mask_img_ax,2)));
                    end;
                                     
                    etc_render_fsbrain.img_sag_padx=n1;
                    etc_render_fsbrain.img_ax_pady=n1;
                else
                    etc_render_fsbrain.img_sag_padx=0;
                    etc_render_fsbrain.img_ax_pady=0;
                end;
                
                if(xx<mm)
                    n1=floor((mm-xx)/2);
                    n2=mm-xx-n1;
                    img_cor=cat(2,zeros(size(img_cor,1),n1),img_cor,zeros(size(img_cor,1),n2));
                    img_ax=cat(2,zeros(size(img_ax,1),n1),img_ax,zeros(size(img_ax,1),n2));
                    
                    if(~isempty(img_cor_overlay))
                        img_cor_overlay=cat(2,zeros(size(img_cor_overlay,1),n1),img_cor_overlay,zeros(size(img_cor_overlay,1),n2));
                    end;
                    if(~isempty(img_ax_overlay))
                        img_ax_overlay=cat(2,zeros(size(img_ax_overlay,1),n1),img_ax_overlay,zeros(size(img_ax_overlay,1),n2));
                    end;
                    
                    if(~isempty(mask_img_cor))
                        mask_img_cor=cat(2,zeros(size(mask_img_cor,1),n1),mask_img_cor,zeros(size(mask_img_cor,1),n2));
                    end;
                    if(~isempty(mask_img_ax))
                        mask_img_ax=cat(2,zeros(size(mask_img_ax,1),n1),mask_img_ax,zeros(size(mask_img_ax,1),n2));
                    end;
                    
                    etc_render_fsbrain.img_cor_padx=n1;
                    etc_render_fsbrain.img_ax_padx=n1;
                else
                    etc_render_fsbrain.img_cor_padx=0;
                    etc_render_fsbrain.img_ax_padx=0;
                end;
                
                etc_render_fsbrain.vol_img=[img_cor img_ax; img_sag, zeros(size(img_cor))];
                if(~isempty(etc_render_fsbrain.overlay_vol))
                    etc_render_fsbrain.overlay_vol_img=[img_cor_overlay img_ax_overlay; img_sag_overlay, zeros(size(img_cor_overlay))];
                else
                    etc_render_fsbrain.overlay_vol_img=[];
                end;
 
                if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    etc_render_fsbrain.overlay_vol_mask_img=[mask_img_cor mask_img_ax; mask_img_sag, zeros(size(mask_img_cor))];
                else
                    etc_render_fsbrain.overlay_vol_mask_img=[];
                end;
                
                if(~isempty(etc_render_fsbrain.overlay_vol))
                    etc_render_fsbrain.overlay_vol_img_c=zeros(size(etc_render_fsbrain.vol_img,1)*size(etc_render_fsbrain.vol_img,2),3);
                    
                    c_idx=[1:prod(size(etc_render_fsbrain.vol_img))];
                    mmax=max(etc_render_fsbrain.vol_img(:));
                    mmin=min(etc_render_fsbrain.vol_img(:));
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),etc_render_fsbrain.vol_img(c_idx),mmax,mmin);
                    
                    c_idx=find(etc_render_fsbrain.overlay_vol_img(:)>=min(etc_render_fsbrain.overlay_threshold));
                    
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,etc_render_fsbrain.overlay_vol_img(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                    
                    c_idx=find(etc_render_fsbrain.overlay_vol_img(:)<=-min(etc_render_fsbrain.overlay_threshold));
                    
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-etc_render_fsbrain.overlay_vol_img(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
                else
                    etc_render_fsbrain.overlay_vol_img_c=zeros(size(etc_render_fsbrain.vol_img,1)*size(etc_render_fsbrain.vol_img,2),3);
                    
                    c_idx=[1:prod(size(etc_render_fsbrain.vol_img))];
                    mmax=max(etc_render_fsbrain.vol_img(:));
                    mmin=min(etc_render_fsbrain.vol_img(:));
                    etc_render_fsbrain.overlay_vol_img_c(c_idx,:)=inverse_get_color(gray(128),etc_render_fsbrain.vol_img(c_idx),mmax,mmin);
                end;
                
                etc_render_fsbrain.overlay_vol_img_c=reshape(etc_render_fsbrain.overlay_vol_img_c,[ size(etc_render_fsbrain.vol_img,1), size(etc_render_fsbrain.vol_img,2),3]);
                
                clf;
                image(etc_render_fsbrain.overlay_vol_img_c); hold on;
                
                
                %create aseg mask....
                if(~isempty(etc_render_fsbrain.overlay_vol_mask))
                    if(etc_render_fsbrain.overlay_flag_vol_mask)
                        
                        obj=findobj(etc_render_fsbrain.fig_gui,'tag','listbox_overlay_vol_mask');
                        idx=get(obj,'value');
                        
                        for ii=1:length(idx)
                            mask=zeros(size(etc_render_fsbrain.overlay_vol_mask_img));
                            mask_idx=find(etc_render_fsbrain.overlay_vol_mask_img==etc_render_fsbrain.lut.number(idx(ii)));
                            mask(mask_idx)=1;
                            if(ii==1)
                                mask_c=cat(3,mask.*etc_render_fsbrain.lut.r(idx(ii))./255,mask.*etc_render_fsbrain.lut.g(idx(ii))./255,mask.*etc_render_fsbrain.lut.b(idx(ii))./255);
                                mask_all=mask;
                            else
                                mask_c=mask_c+cat(3,mask.*etc_render_fsbrain.lut.r(idx(ii))./255,mask.*etc_render_fsbrain.lut.g(idx(ii))./255,mask.*etc_render_fsbrain.lut.b(idx(ii))./255);
                                mask_all=mask_all+mask;                                
                            end;
                        end;
                        h=image(mask_c); hold on;
                        set(h,'alphadata',etc_render_fsbrain.overlay_vol_mask_alpha.*mask_all);
                    end;
                end;
                set(gca,'pos',[0 0 1 1]);
                etc_render_fsbrain.vol_img_h=gca;
                axis off image;
                if(~isempty(xlim)) set(etc_render_fsbrain.vol_img_h,'xlim',xlim); end;
                if(~isempty(ylim)) set(etc_render_fsbrain.vol_img_h,'ylim',ylim); end;
            end;
            
            %showing locations of other electrode contacts
            try
                delete(etc_render_fsbrain.aux2_point_mri_ax_h(:));
                delete(etc_render_fsbrain.aux2_point_mri_cor_h(:));
                delete(etc_render_fsbrain.aux2_point_mri_sag_h(:));
            catch ME
            end;



            if(etc_render_fsbrain.show_brain_surface_location_flag)
                try
                    delete(etc_render_fsbrain.vol_img_h_cor);
                    delete(etc_render_fsbrain.vol_img_h_ax);
                    delete(etc_render_fsbrain.vol_img_h_sag);
                catch ME
                end;
                etc_render_fsbrain.vol_img_h_cor=plot(etc_render_fsbrain.img_cor_padx+etc_render_fsbrain.click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+etc_render_fsbrain.click_vertex_vox(2),'.');
                set(etc_render_fsbrain.vol_img_h_cor,'color',etc_render_fsbrain.click_point_color,'MarkerSize',etc_render_fsbrain.click_point_size,'AlignVertexCenters','on');
                etc_render_fsbrain.vol_img_h_ax=plot(mm+etc_render_fsbrain.img_ax_padx+etc_render_fsbrain.click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+etc_render_fsbrain.click_vertex_vox(3)),'.');
                set(etc_render_fsbrain.vol_img_h_ax,'color',etc_render_fsbrain.click_point_color,'MarkerSize',etc_render_fsbrain.click_point_size,'AlignVertexCenters','on');
                etc_render_fsbrain.vol_img_h_sag=plot(etc_render_fsbrain.img_sag_padx+etc_render_fsbrain.click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+etc_render_fsbrain.click_vertex_vox(2),'.');
                set(etc_render_fsbrain.vol_img_h_sag,'color',etc_render_fsbrain.click_point_color,'MarkerSize',etc_render_fsbrain.click_point_size,'AlignVertexCenters','on');
            end;
            
            
            
            if(etc_render_fsbrain.show_nearest_brain_surface_location_flag)
                try
                    delete(etc_render_fsbrain.vol_img_h_round_cor);
                    delete(etc_render_fsbrain.vol_img_h_round_ax);
                    delete(etc_render_fsbrain.vol_img_h_round_sag);
                catch ME
                end;
                etc_render_fsbrain.vol_img_h_round_cor=plot(etc_render_fsbrain.img_cor_padx+etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.img_cor_pady+etc_render_fsbrain.click_vertex_vox_round(2),'.');
                set(etc_render_fsbrain.vol_img_h_round_cor,'color',etc_render_fsbrain.click_vertex_point_color,'MarkerSize',etc_render_fsbrain.click_vertex_point_size);               
                etc_render_fsbrain.vol_img_h_round_ax=plot(mm+etc_render_fsbrain.img_ax_padx+etc_render_fsbrain.click_vertex_vox_round(1), mm-(etc_render_fsbrain.img_ax_pady+etc_render_fsbrain.click_vertex_vox_round(3)),'.');
                set(etc_render_fsbrain.vol_img_h_round_ax,'color',etc_render_fsbrain.click_vertex_point_color,'MarkerSize',etc_render_fsbrain.click_vertex_point_size);
                etc_render_fsbrain.vol_img_h_round_sag=plot(etc_render_fsbrain.img_sag_padx+etc_render_fsbrain.click_vertex_vox_round(3), mm+etc_render_fsbrain.img_sag_pady+etc_render_fsbrain.click_vertex_vox_round(2),'.');
                set(etc_render_fsbrain.vol_img_h_round_sag,'color',etc_render_fsbrain.click_vertex_point_color,'MarkerSize',etc_render_fsbrain.click_vertex_point_size);
            end;

            if(etc_render_fsbrain.show_all_contacts_mri_flag)
                count=1;
                
                %highlight the selected contact
                selected_electrode_idx=[];
                selected_contact_idx=[];
                if(isfield(etc_render_fsbrain,'electrode'))
                    idx=0;
                    for ii=1:etc_render_fsbrain.electrode_idx-1
                        idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                    end;
                    for contact_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
                        selected_electrode_idx(end+1)=idx+contact_idx;
                    end;
                    
                    
                    idx=0;
                    for ii=1:etc_render_fsbrain.electrode_idx-1
                        idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                    end;
                    selected_contact_idx=idx+etc_render_fsbrain.electrode_contact_idx;
                end;


                for v_idx=1:size(etc_render_fsbrain.aux2_point_coords,1)
                    surface_coord=etc_render_fsbrain.aux2_point_coords(v_idx,:);
                    
                    
                    if(strcmp(etc_render_fsbrain.surf,'orig'))
                        
                    else
                        if(v_idx==1)
                            fprintf('surface <%s> not "orig". Electrode contacts locations are mapped from this surface back to the "orig" volume.\n',etc_render_fsbrain.surf);
                        end;
                        %tmp=etc_render_fsbrain.aux2_point_coords(count,:);
                        
                        vv=etc_render_fsbrain.vertex_coords;
                        dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                        [min_dist,min_dist_idx]=min(dist);
                        surface_coord=etc_render_fsbrain.orig_vertex_coords(min_dist_idx,:);
                    end;
                    
                    v=inv(etc_render_fsbrain.vol.tkrvox2ras)*[surface_coord(:); 1];
                    click_vertex_vox=round(v(1:3))';
                    
                    point_size=1e3;
                    
                    D=2; %a constant controlling the visibility of contacts
                    alpha=exp(-(abs(click_vertex_vox(3)-round(etc_render_fsbrain.click_vertex_vox(3))))/D);
                    if(alpha>0.2)
                        etc_render_fsbrain.aux2_point_mri_cor_h(count)=scatter(etc_render_fsbrain.img_cor_padx+click_vertex_vox(1), etc_render_fsbrain.img_cor_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                        %set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
                        if(~isempty(intersect(selected_contact_idx,v_idx))&&etc_render_fsbrain.selected_contact_flag)
                            set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_contact_color);

                        else
                            if(~isempty(intersect(selected_electrode_idx,v_idx))&&etc_render_fsbrain.selected_electrode_flag)
                                set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_electrode_color);
                            else
                                set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                            end;
                        end;

                        set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                        set(etc_render_fsbrain.aux2_point_mri_cor_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                        count=count+1;
                    end;
                    
                    alpha=exp(-(abs(click_vertex_vox(2)-round(etc_render_fsbrain.click_vertex_vox(2))))/D);
                    if(alpha>0.2)
                        etc_render_fsbrain.aux2_point_mri_ax_h(count)=scatter(mm+etc_render_fsbrain.img_ax_padx+click_vertex_vox(1), mm-(etc_render_fsbrain.img_ax_pady+click_vertex_vox(3)),point_size,[0.8500 0.3250 0.0980],'.');
                        %set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
                        if(~isempty(intersect(selected_contact_idx,v_idx))&&etc_render_fsbrain.selected_contact_flag)
                            set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_contact_color);

                        else
                            if(~isempty(intersect(selected_electrode_idx,v_idx))&&etc_render_fsbrain.selected_electrode_flag)
                                set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_electrode_color);
                            else
                                set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                            end;
                        end;
                        set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                        set(etc_render_fsbrain.aux2_point_mri_ax_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                        count=count+1;
                    end;
                    
                    alpha=exp(-(abs(click_vertex_vox(1)-round(etc_render_fsbrain.click_vertex_vox(1))))/D);
                    if(alpha>0.2)
                        etc_render_fsbrain.aux2_point_mri_sag_h(count)=scatter(etc_render_fsbrain.img_sag_padx+click_vertex_vox(3), mm+etc_render_fsbrain.img_sag_pady+click_vertex_vox(2),point_size,[0.8500 0.3250 0.0980],'.');
                        %set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',[0.8500 0.3250 0.0980]);
                        if(~isempty(intersect(selected_contact_idx,v_idx))&&etc_render_fsbrain.selected_contact_flag)
                            set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_contact_color);

                        else
                            if(~isempty(intersect(selected_electrode_idx,v_idx))&&etc_render_fsbrain.selected_electrode_flag)
                                set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.selected_electrode_color);
                            else
                                set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeColor',etc_render_fsbrain.aux2_point_color);
                            end;
                        end;
                        set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'MarkerEdgeAlpha',alpha); %transparency does not work for such a large marker.....
                        set(etc_render_fsbrain.aux2_point_mri_sag_h(count),'ButtonDownFcn',@(~,~)disp('patch'),'PickableParts','all');
                        count=count+1;
                    end;
                end;
            end;            
        catch ME
        end;
        
        
        %update coordinates at coordinate GUI
        h=findobj('tag','edit_surf_x');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(1),'%1.1f'));
        h=findobj('tag','edit_surf_y');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(2),'%1.1f'));
        h=findobj('tag','edit_surf_z');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(3),'%1.1f'));
        
        h=findobj('tag','edit_surf_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(1),'%1.1f'));
        h=findobj('tag','edit_surf_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(2),'%1.1f'));
        h=findobj('tag','edit_surf_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(3),'%1.1f'));
        
        h=findobj('tag','edit_vox_x');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(1),'%1.0f'));
        h=findobj('tag','edit_vox_y');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(2),'%1.0f'));
        h=findobj('tag','edit_vox_z');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox(3),'%1.0f'));
        
        h=findobj('tag','edit_vox_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(1),'%1.0f'));
        h=findobj('tag','edit_vox_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(2),'%1.0f'));
        h=findobj('tag','edit_vox_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_vox_round(3),'%1.0f'));
        
        
        h=findobj('tag','edit_mni_x');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(1),'%1.0f'));
        h=findobj('tag','edit_mni_y');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(2),'%1.0f'));
        h=findobj('tag','edit_mni_z');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_tal(3),'%1.0f'));
        
        h=findobj('tag','edit_mni_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(1),'%1.0f'));
        h=findobj('tag','edit_mni_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(2),'%1.0f'));
        h=findobj('tag','edit_mni_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_vertex_point_round_tal(3),'%1.0f'));
        
        %volume image rendering
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        %update coordinates at coordinate GUI
        h=findobj('tag','edit_surf_x');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(1),'%1.1f'));
        h=findobj('tag','edit_surf_y');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(2),'%1.1f'));
        h=findobj('tag','edit_surf_z');
        set(h,'String',num2str(etc_render_fsbrain.click_coord(3),'%1.1f'));
        
        h=findobj('tag','edit_surf_x_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(1),'%1.1f'));
        h=findobj('tag','edit_surf_y_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(2),'%1.1f'));
        h=findobj('tag','edit_surf_z_round');
        set(h,'String',num2str(etc_render_fsbrain.click_coord_round(3),'%1.1f'));
        
        etc_render_fsbrain.click_vertex_vox_round=[];
        etc_render_fsbrain.click_vertex_vox=[];
        etc_render_fsbrain.click_vertex_point_tal_round=[];
        etc_render_fsbrain.click_vertex_point_tal=[];
    end;
    
    
    %overlay
    if(~isempty(etc_render_fsbrain.overlay_vertex))
        try
            figure(etc_render_fsbrain.fig_brain);
            
            if(~iscell(etc_render_fsbrain.overlay_vertex))
                vv=etc_render_fsbrain.vertex_coords;
                vv=vv(etc_render_fsbrain.overlay_vertex+1,:);
            else
                vv=[];
                for h_idx=1:length(etc_render_fsbrain.overlay_vertex)
                    tmp=etc_render_fsbrain.vertex_coords_hemi{h_idx}(etc_render_fsbrain.overlay_vertex{h_idx}+1,:);
                    %tmp(:,1)=tmp(:,1)+(-1).^(h_idx).*50;
                    vv=cat(1,vv,tmp);
                end;
            end;
            dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
            [min_overlay_dist,min_overlay_dist_idx]=min(dist);
            if(~iscell(etc_render_fsbrain.overlay_vertex))
                fprintf('the nearest overlay surface vertex: location=[%d]::<<%2.2f>> @ (%2.2f %2.2f %2.2f) \n',min_overlay_dist_idx,etc_render_fsbrain.overlay_value(min_overlay_dist_idx),vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3));
            else
                if(min_overlay_dist_idx>length(etc_render_fsbrain.overlay_vertex{1}))
                    offset=length(etc_render_fsbrain.overlay_vertex{1});
                    hemi_idx=2;
                else
                    offset=0;
                    hemi_idx=1;
                end;
                fprintf('the nearest overlay vertex: hemi{%d} location=[%d]::<<%2.2f>> @ (%2.2f %2.2f %2.2f) \n',hemi_idx,min_overlay_dist_idx-offset,etc_render_fsbrain.overlay_value{hemi_idx}(min_overlay_dist_idx-offset),vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3));
            end;
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                etc_render_fsbrain.click_overlay_vertex=min_overlay_dist_idx;
            end;
            %etc_render_fsbrain.click_overlay_vertex_point=plot3(vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3),'.');
            %set(etc_render_fsbrain.click_overlay_vertex_point,'color',[0 1 0]);
        catch ME
        end;
    else
        etc_render_fsbrain.click_overlay_vertex=[];
        etc_render_fsbrain.click_overlay_vertex_point=[];
    end;
    
catch ME;
end;
return;


function draw_stc()
global etc_render_fsbrain;

% if(~isempty(etc_render_fsbrain.overlay_value))
%     fprintf('clicked overlay value = [%2.2f].\n',etc_render_fsbrain.overlay_value(etc_render_fsbrain.click_overlay_vertex));
%     if(isfield(etc_render_fsbrain,'label_idx'))
%         if(~isempty(etc_render_fsbrain.label_idx))
%             [dummy,itx_idx]=intersect(etc_render_fsbrain.overlay_vertex+1, etc_render_fsbrain.label_idx);
%             data=etc_render_fsbrain.overlay_value(itx_idx);
%             fprintf('overlay value in the selected ROI = %2.2f +/- %2.2f. (max = %2.2f; min = %2.2f)\n',mean(data),std(data),max(data),min(data));
%         end;
%     end;
% end;
            
if(~isempty(etc_render_fsbrain.overlay_stc))
    if(~isempty(etc_render_fsbrain.fig_stc))
        if(~isvalid(etc_render_fsbrain.fig_stc))
            delete(etc_render_fsbrain.fig_stc);
            etc_render_fsbrain.fig_stc=[];
        end;
    end;
    
    if(~isempty(etc_render_fsbrain.click_overlay_vertex)&~isempty(etc_render_fsbrain.overlay_stc))
        if(isempty(etc_render_fsbrain.fig_stc))
            etc_render_fsbrain.fig_stc=figure;
            pos=get(etc_render_fsbrain.fig_brain,'outerpos');
            set(etc_render_fsbrain.fig_stc,'outerpos',[pos(1), pos(2)-pos(4), pos(3), pos(4)]);
        else
            figure(etc_render_fsbrain.fig_stc);
        end;
        
        set(etc_render_fsbrain.fig_stc,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
        set(etc_render_fsbrain.fig_stc,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
        
        
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_idx_line))
            if(ishandle(etc_render_fsbrain.overlay_stc_timeVec_idx_line))
                delete(etc_render_fsbrain.overlay_stc_timeVec_idx_line);
            end;
            etc_render_fsbrain.overlay_stc_timeVec_idx_line=[];
        end;
        
        if(isempty(etc_render_fsbrain.overlay_stc_timeVec))
            try
                delete(etc_render_fsbrain.handle_fig_stc_timecourse)
                delete(etc_render_fsbrain.handle_fig_stc_aux_timecourse);
                delete(etc_render_fsbrain.handle_fig_stc_roi_timecourse)
                delete(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse);
            catch ME
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
                h_xline=line([1 size(etc_render_fsbrain.overlay_stc,2)],[0 0]); hold on;
            elseif(etc_render_fsbrain.flag_overlay_stc_vol)
                etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_vol_stc,2)]
                h_xline=line([1 size(etc_render_fsbrain.overlay_vol_stc,2)],[0 0]); hold on;
            end;
            
            set(h_xline,'linewidth',2,'color',[1 1 1].*0.5);
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                    hold on; h=plot(squeeze(etc_render_fsbrain.overlay_aux_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            if(etc_render_fsbrain.flag_overlay_stc_vol)
                if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                    hold on; h=plot(squeeze(etc_render_fsbrain.overlay_aux_vol_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                hold on; h=plot(etc_render_fsbrain.overlay_stc(etc_render_fsbrain.click_overlay_vertex,:));
            elseif(etc_render_fsbrain.flag_overlay_stc_vol)
                hold on; h=plot(etc_render_fsbrain.overlay_vol_stc_1d);
            end;
            
            set(h,'linewidth',2,'color','r'); hold off;
            
            if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
                etc_render_fsbrain.handle_fig_stc_timecourse=h;
            else
                etc_render_fsbrain.handle_fig_stc_timecourse(end+1)=h;
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(isfield(etc_render_fsbrain,'label_idx'))
                    if(~isempty(etc_render_fsbrain.label_idx))
                        [dummy,itx_idx]=intersect(etc_render_fsbrain.overlay_vertex+1, etc_render_fsbrain.label_idx);
                        data=etc_render_fsbrain.overlay_stc(itx_idx,:);
                        hold on; etc_render_fsbrain.handle_fig_stc_roi_timecourse=plot(mean(data,1));
                        set(etc_render_fsbrain.handle_fig_stc_roi_timecourse,'linewidth',2,'color','r','linestyle',':'); hold off;
                        
                        
                        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                            data=etc_render_fsbrain.overlay_aux_stc(itx_idx,:,:);
                            hold on; etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse=plot(squeeze(mean(data,1)));
                            cc=get(gca,'ColorOrder');
                            for ii=1:length(h)
                                set(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse(ii),'linewidth',1,'color',cc(rem(ii,8),:),'linestyle',':');
                            end;
                        end;
                    end;
                end;
            end;
            hold off;
        else
            try
                delete(etc_render_fsbrain.handle_fig_stc_timecourse);
                delete(etc_render_fsbrain.handle_fig_stc_aux_timecourse);
                delete(etc_render_fsbrain.handle_fig_stc_roi_timecourse);
                delete(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse);
            catch ME
            end;
            
            h_xline=line([min(etc_render_fsbrain.overlay_stc_timeVec) max(etc_render_fsbrain.overlay_stc_timeVec)],[0 0]); hold on;
            
            set(h_xline,'linewidth',2,'color',[1 1 1].*0.5);
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                    hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,squeeze(etc_render_fsbrain.overlay_aux_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            if(etc_render_fsbrain.flag_overlay_stc_vol)
                if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
                    hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,squeeze(etc_render_fsbrain.overlay_aux_vol_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
                    cc=get(gca,'ColorOrder');
                    for ii=1:length(h)
                        set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
                    end;
                    etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
                end;
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,etc_render_fsbrain.overlay_stc(etc_render_fsbrain.click_overlay_vertex,:));
            elseif(etc_render_fsbrain.flag_overlay_stc_vol)
                hold on; h=plot(etc_render_fsbrain.overlay_stc_timeVec,etc_render_fsbrain.overlay_vol_stc_1d);
            end;
            set(h,'linewidth',2,'color','r'); hold off;
            
            if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
                etc_render_fsbrain.handle_fig_stc_timecourse=h;
            else
                etc_render_fsbrain.handle_fig_stc_timecourse(end+1)=h;
            end;
            
            if(etc_render_fsbrain.flag_overlay_stc_surf)
                if(isfield(etc_render_fsbrain,'label_idx'))
                    if(~isempty(etc_render_fsbrain.label_idx))
                        [dummy,itx_idx]=intersect(etc_render_fsbrain.overlay_vertex+1, etc_render_fsbrain.label_idx);
                        data=etc_render_fsbrain.overlay_stc(itx_idx,:);
                        hold on; etc_render_fsbrain.handle_fig_stc_roi_timecourse=plot(etc_render_fsbrain.overlay_stc_timeVec,mean(data,1));
                        set(etc_render_fsbrain.handle_fig_stc_roi_timecourse,'linewidth',2,'color','r','linestyle',':'); hold off;
                        
                        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
                            data=etc_render_fsbrain.overlay_aux_stc(itx_idx,:,:);
                            hold on; etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse=plot(etc_render_fsbrain.overlay_stc_timeVec, squeeze(mean(data,1)));
                            cc=get(gca,'ColorOrder');
                            for ii=1:length(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse)
                                set(etc_render_fsbrain.handle_fig_stc_aux_roi_timecourse(ii),'linewidth',1,'color',cc(rem(ii,8),:),'linestyle',':');
                            end;
                        end;
                    end;
                end;
            end;
            
            hold off;
            
        end;
        if(~isempty(etc_render_fsbrain.overlay_stc_lim))
            set(gca,'ylim',etc_render_fsbrain.overlay_stc_lim);
        end;
        
        if(~isempty(etc_render_fsbrain.overlay_stc_timeVec_idx))
            yy=get(gca,'ylim');
            etc_render_fsbrain.overlay_stc_timeVec_idx_line=line([etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx), etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)],[yy(1), yy(2)]);
            set(etc_render_fsbrain.overlay_stc_timeVec_idx_line,'color',[0.4 0.4 0.4]);
        end;
        
        if(isempty(etc_render_fsbrain.overlay_stc_timeVec_unit))
            etc_render_fsbrain.overlay_stc_timeVec_unit='sample';
        end;
        
        
        h=xlabel(sprintf('time [%s]',etc_render_fsbrain.overlay_stc_timeVec_unit)); set(h,'fontname','helvetica','fontsize',12);
        
        axis tight; set(gca,'fontname','helvetica','fontsize',12);
        set(gcf,'color','w')
    end;
end;
return;

function redraw()

global etc_render_fsbrain;

if(~isvalid(etc_render_fsbrain.fig_brain))
    etc_render_fsbrain.fig_brain=figure;
else
    figure(etc_render_fsbrain.fig_brain);
end;


%set axes
if(~isvalid(etc_render_fsbrain.brain_axis))
    etc_render_fsbrain.brain_axis=gca;
else
    axes(etc_render_fsbrain.brain_axis);

    xlim=get(gca,'xlim');
    ylim=get(gca,'ylim');   
    zlim=get(gca,'zlim');

    etc_render_fsbrain.lim=[xlim(:)' ylim(:)' zlim(:)'];
end;
[etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2)]=view;

%delete brain patch object
if(ishandle(etc_render_fsbrain.h))
    delete(etc_render_fsbrain.h);
end;

%0: solid color
etc_render_fsbrain.fvdata=repmat(etc_render_fsbrain.default_solid_color,[size(etc_render_fsbrain.vertex_coords,1),1]);

%1: curvature color
if(~isempty(etc_render_fsbrain.curv))
    etc_render_fsbrain.fvdata=ones(size(etc_render_fsbrain.fvdata));
    idx=find(etc_render_fsbrain.curv>0);
    etc_render_fsbrain.fvdata(idx,:)=repmat(etc_render_fsbrain.curv_pos_color,[length(idx),1]);
    idx=find(etc_render_fsbrain.curv<0);
    etc_render_fsbrain.fvdata(idx,:)=repmat(etc_render_fsbrain.curv_neg_color,[length(idx),1]);
end;

ovs=[];
if(etc_render_fsbrain.overlay_flag_render)
    %2: curvature and overlay color
    if(~isempty(etc_render_fsbrain.overlay_value))
        if(~iscell(etc_render_fsbrain.overlay_value))
            ov=zeros(size(etc_render_fsbrain.vertex_coords,1),1);
            ov(etc_render_fsbrain.overlay_vertex+1)=etc_render_fsbrain.overlay_value;
            
            if(~isempty(etc_render_fsbrain.overlay_smooth))
                [ovs,dd0,dd1,etc_render_fsbrain.overlay_Ds]=inverse_smooth('','vertex',etc_render_fsbrain.vertex_coords','face',etc_render_fsbrain.faces','value_idx',etc_render_fsbrain.overlay_vertex+1,'value',ov,'step',etc_render_fsbrain.overlay_smooth,'flag_fixval',etc_render_fsbrain.overlay_fixval_flag,'exc_vertex',etc_render_fsbrain.overlay_exclude,'inc_vertex',etc_render_fsbrain.overlay_include,'flag_regrid',etc_render_fsbrain.overlay_regrid_flag,'flag_regrid_zero',etc_render_fsbrain.overlay_regrid_zero_flag,'Ds',etc_render_fsbrain.overlay_Ds,'n_ratio',length(ov)/length(etc_render_fsbrain.overlay_value));
            else
                ovs=ov;
            end;
            
            if(~isempty(find(etc_render_fsbrain.overlay_value>0))) etc_render_fsbrain.overlay_value_flag_pos=1; end;
            if(~isempty(find(etc_render_fsbrain.overlay_value<0))) etc_render_fsbrain.overlay_value_flag_neg=1; end;
        else
            ovs=[];
            for h_idx=1:length(etc_render_fsbrain.overlay_value)
                ov=zeros(size(etc_render_fsbrain.vertex_coords_hemi{h_idx},1),1);
                ov(etc_render_fsbrain.overlay_vertex{h_idx}+1)=etc_render_fsbrain.overlay_value{h_idx};
                
                if(~isempty(etc_render_fsbrain.overlay_smooth))
                    [tmp,dd0,dd1,etc_render_fsbrain.overlay_Ds]=inverse_smooth('','vertex',etc_render_fsbrain.vertex_coords_hemi{h_idx}','face',etc_render_fsbrain.faces_hemi{h_idx}','value_idx',etc_render_fsbrain.overlay_vertex+1,'value',ov,'step',etc_render_fsbrain.overlay_smooth,'flag_fixval',etc_render_fsbrain.overlay_fixval_flag,'exc_vertex',etc_render_fsbrain.overlay_exclude{h_idx},'inc_vertex',etc_render_fsbrain.overlay_include{h_idx},'flag_regrid',etc_render_fsbrain.overlay_regrid_flag,'flag_regrid_zero',etc_render_fsbrain.overlay_regrid_zero_flag,'Ds',etc_render_fsbrain.overlay_Ds,'n_ratio',length(ov)/length(etc_render_fsbrain.overlay_value))
                    ovs=cat(1,ovs,tmp);
                else
                    ovs=cat(1,ovs,ov);
                end;
                if(~isempty(find(etc_render_fsbrain.overlay_value{h_idx}>0))) etc_render_fsbrain.overlay_value_flag_pos=1; end;
                if(~isempty(find(etc_render_fsbrain.overlay_value{h_idx}<0))) etc_render_fsbrain.overlay_value_flag_neg=1; end;
            end;
        end;
        
        if(isempty(etc_render_fsbrain.overlay_threshold))
            tmp=sort(ovs(:));
            fprintf('automatic threshold at 50%% [%1.1e] and 90%% [%1.1e] of the current overlay...\n',tmp(round(length(tmp)*0.5)), tmp(round(length(tmp)*0.9)));
            etc_render_fsbrain.overlay_threshold=[tmp(round(length(tmp)*0.5)) tmp(round(length(tmp)*0.9))];
        end;

        %truncate positive value overlay
        if(etc_render_fsbrain.flag_overlay_truncate_pos)
            idx=find(ovs(:)>0);
            ovs(idx)=0;
        end;
        
        %truncate negative value overlay
        if(etc_render_fsbrain.flag_overlay_truncate_neg)
            idx=find(ovs(:)<0);
            ovs(idx)=0;
        end;

        c_idx=find(ovs(:)>=min(etc_render_fsbrain.overlay_threshold));
        
        etc_render_fsbrain.fvdata(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,ovs(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
        
        c_idx=find(ovs(:)<=-min(etc_render_fsbrain.overlay_threshold));
        
        etc_render_fsbrain.fvdata(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,-ovs(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
    end;
end;

etc_render_fsbrain.ovs=ovs;

h=patch('Faces',etc_render_fsbrain.faces+1,'Vertices',etc_render_fsbrain.vertex_coords,'FaceVertexCData',etc_render_fsbrain.fvdata,'facealpha',etc_render_fsbrain.alpha,'CDataMapping','direct','facecolor','interp','edgecolor','none');
material dull;

etc_render_fsbrain.h=h;

axis off vis3d equal;
axis(etc_render_fsbrain.lim);

if(~isempty(etc_render_fsbrain.overlay_threshold))
        h=findobj('tag','edit_threshold_min');
        set(h,'String',num2str(min(etc_render_fsbrain.overlay_threshold),'%1.1f'));
        h=findobj('tag','edit_threshold_max');
        set(h,'String',num2str(max(etc_render_fsbrain.overlay_threshold),'%1.1f'));
end;


if(~isempty(etc_render_fsbrain.overlay_threshold))
    if(length(etc_render_fsbrain.overlay_threshold)==2)
        if(etc_render_fsbrain.overlay_threshold(1)<etc_render_fsbrain.overlay_threshold(2))
            set(gca,'climmode','manual','clim',etc_render_fsbrain.overlay_threshold);
        end;
    end;
end;
set(gcf,'color',etc_render_fsbrain.bg_color);


view(etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2));

% %add exploration toolbar
% [vv date] = version;
% DateNumber = datenum(date);
% if(DateNumber>737426) %after January 1, 2019; Matlab verion 2019 and later
%     addToolbarExplorationButtons(etc_render_fsbrain.fig_brain);
% end;


try
    if(isfield(etc_render_fsbrain,'aux_point_coords'))
        if(~isempty(etc_render_fsbrain.aux_point_coords_h))
            delete(etc_render_fsbrain.aux_point_coords_h(:));
            etc_render_fsbrain.aux_point_coords_h=[];
        end;
        
        if(~isempty(etc_render_fsbrain.aux_point_name_h))
            delete(etc_render_fsbrain.aux_point_name_h(:));
            etc_render_fsbrain.aux_point_name_h=[];
        end;
        
        if(~isempty(etc_render_fsbrain.aux_point_coords))
            [sx,sy,sz] = sphere(8);
            %sr=0.005;
            sr=etc_render_fsbrain.aux_point_size;
            xx=[]; yy=[]; zz=[];
            for idx=1:size(etc_render_fsbrain.aux_point_coords,1)
                if(strcmp(etc_render_fsbrain.aux_point_name{idx},'.'))
                    xx=cat(1,xx,sx.*sr./3+etc_render_fsbrain.aux_point_coords(idx,1));
                    yy=cat(1,yy,sy.*sr./3+etc_render_fsbrain.aux_point_coords(idx,2));
                    zz=cat(1,zz,sz.*sr./3+etc_render_fsbrain.aux_point_coords(idx,3));
                else
                    xx=cat(1,xx,sx.*sr+etc_render_fsbrain.aux_point_coords(idx,1));
                    yy=cat(1,yy,sy.*sr+etc_render_fsbrain.aux_point_coords(idx,2));
                    zz=cat(1,zz,sz.*sr+etc_render_fsbrain.aux_point_coords(idx,3));
                end;
                if(~isfield(etc_render_fsbrain,'aux_point_label_flag'))
                    etc_render_fsbrain.aux_point_label_flag=1;
                end;
                if(etc_render_fsbrain.aux_point_label_flag)
                    if(~isempty(etc_render_fsbrain.aux_point_name))
                        if(strcmp(etc_render_fsbrain.aux_point_name{idx},'.'))
                            etc_render_fsbrain.aux_point_name_h(idx)=text(etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3),''); hold on;
                        else
                            etc_render_fsbrain.aux_point_name_h(idx)=text(etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3),etc_render_fsbrain.aux_point_name{idx}); hold on;
                        end;
                    end;
                end;
            end;
            etc_render_fsbrain.aux_point_coords_h(1)=surf(xx,yy,zz);
            %set(etc_render_fsbrain.aux_point_coords_h(1),'facecolor','r','edgecolor','none');
            set(etc_render_fsbrain.aux_point_coords_h(1),'facecolor',etc_render_fsbrain.aux_point_color,'edgecolor','none');
        end;
    end;
    
    
    if(isfield(etc_render_fsbrain,'aux2_point_coords'))
        if(~isempty(etc_render_fsbrain.aux2_point_coords_h))
            delete(etc_render_fsbrain.aux2_point_coords_h(:));
            etc_render_fsbrain.aux2_point_coords_h=[];
        end;
        
        if(~isempty(etc_render_fsbrain.selected_electrode_coords_h))
            delete(etc_render_fsbrain.selected_electrode_coords_h(:));
            etc_render_fsbrain.selected_electrode_coords_h=[];
        end;
        if(~isempty(etc_render_fsbrain.selected_contact_coords_h))
            delete(etc_render_fsbrain.selected_contact_coords_h(:));
            etc_render_fsbrain.selected_contact_coords_h=[];
        end;        
        
        if(~isempty(etc_render_fsbrain.aux2_point_name_h))
            delete(etc_render_fsbrain.aux2_point_name_h(:));
            etc_render_fsbrain.aux2_point_name_h=[];
        end;

        if(~isempty(etc_render_fsbrain.aux2_point_coords))
            if(etc_render_fsbrain.show_all_contacts_brain_surface_flag)
                xx=[]; yy=[]; zz=[];
                for idx=1:size(etc_render_fsbrain.aux2_point_coords,1)
                    xx=cat(1,xx,etc_render_fsbrain.aux2_point_coords(idx,1));
                    yy=cat(1,yy,etc_render_fsbrain.aux2_point_coords(idx,2));
                    zz=cat(1,zz,etc_render_fsbrain.aux2_point_coords(idx,3));
                    if(~isempty(etc_render_fsbrain.aux2_point_name))
                        if(etc_render_fsbrain.show_contact_names_flag)
                            etc_render_fsbrain.aux2_point_name_h(idx)=text(etc_render_fsbrain.aux2_point_coords(idx,1),etc_render_fsbrain.aux2_point_coords(idx,2),etc_render_fsbrain.aux2_point_coords(idx,3),etc_render_fsbrain.aux2_point_name{idx}); hold on;
                        end;
                    end;
                end;
                etc_render_fsbrain.aux2_point_coords_h=plot3(xx,yy,zz,'.');
                %set(etc_render_fsbrain.aux2_point_coords_h,'color',[1 0 0].*0.5,'markersize',16);
                set(etc_render_fsbrain.aux2_point_coords_h,'color',etc_render_fsbrain.aux2_point_color,'markersize',etc_render_fsbrain.aux2_point_size);
                
                
                %highlight the selected contact
                if(isfield(etc_render_fsbrain,'electrode'))
                    try
                        idx=0;
                        for ii=1:etc_render_fsbrain.electrode_idx-1
                            idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                        end;
                        for contact_idx=1:etc_render_fsbrain.electrode(etc_render_fsbrain.electrode_idx).n_contact
                            xx=etc_render_fsbrain.aux2_point_coords(idx+contact_idx,1);
                            yy=etc_render_fsbrain.aux2_point_coords(idx+contact_idx,2);
                            zz=etc_render_fsbrain.aux2_point_coords(idx+contact_idx,3);
                            
                            if(etc_render_fsbrain.selected_electrode_flag)
                                etc_render_fsbrain.selected_electrode_coords_h(contact_idx)=plot3(xx,yy,zz,'.');
                                set(etc_render_fsbrain.selected_electrode_coords_h(contact_idx),'color',etc_render_fsbrain.selected_electrode_color,'markersize',etc_render_fsbrain.selected_electrode_size);
                            end;
                        end;
                    catch ME
                    end;
                    
                    
                    try
                        idx=0;
                        for ii=1:etc_render_fsbrain.electrode_idx-1
                            idx=idx+etc_render_fsbrain.electrode(ii).n_contact;
                        end;
                        idx=idx+etc_render_fsbrain.electrode_contact_idx;
                        xx=etc_render_fsbrain.aux2_point_coords(idx,1);
                        yy=etc_render_fsbrain.aux2_point_coords(idx,2);
                        zz=etc_render_fsbrain.aux2_point_coords(idx,3);
                        
                        if(etc_render_fsbrain.selected_contact_flag)
                            etc_render_fsbrain.selected_contact_coords_h=plot3(xx,yy,zz,'.');
                            set(etc_render_fsbrain.selected_contact_coords_h,'color',etc_render_fsbrain.selected_contact_color,'markersize',etc_render_fsbrain.selected_contact_size);
                            %                    set(etc_render_fsbrain.aux2_point_coords_h(3),'color',etc_render_fsbrain.aux2_point_color,'markersize',etc_render_fsbrain.aux2_point_size);
                        end;
                    catch ME
                    end;
                end;
            end;
        end;
        
        
    end;
    
catch ME
end;

return;

function update_overlay_vol()

global etc_render_fsbrain;

try
    time_idx=etc_render_fsbrain.overlay_stc_timeVec_idx;
    
    %initialize
    loc_vol=[];
    for hemi_idx=1:2
        
        %n_dip(hemi_idx)=size(etc_render_fsbrain.vol_A(hemi_idx).A,2);
        n_dip(hemi_idx)=(size(etc_render_fsbrain.vol_A(hemi_idx).loc,1)+size(etc_render_fsbrain.vol_A(hemi_idx).wb_loc,1)).*3;
        n_source(hemi_idx)=n_dip(hemi_idx)/3;
        
        switch hemi_idx
            case 1
                offset=0;
            case 2
                offset=n_source(1);
        end;
        
        %get source estimates at cortical and sub-cortical locations
        X_hemi_cort=etc_render_fsbrain.overlay_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),time_idx);
        X_hemi_subcort=etc_render_fsbrain.overlay_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),time_idx);
        
        
        %smooth source estimates at cortical locations
        ov=zeros(size(etc_render_fsbrain.vol_A(hemi_idx).vertex_coords,1),1);
        ov(etc_render_fsbrain.vol_A(hemi_idx).v_idx+1)=X_hemi_cort;
        
        flag_overlay_D_init=1;
        if(isfield(etc_render_fsbrain,'overlay_D'))
            if(length(etc_render_fsbrain.overlay_D)==2)
                if(~isempty(etc_render_fsbrain.overlay_D{hemi_idx}))
                    flag_overlay_D_init=0;
                end;
            end;
        end;
        if(flag_overlay_D_init) etc_render_fsbrain.overlay_D{hemi_idx}=[];end;
        
        
        [ovs,dd0,dd1,overlay_Ds,etc_render_fsbrain.overlay_D{hemi_idx}]=inverse_smooth('','vertex',etc_render_fsbrain.vol_A(hemi_idx).vertex_coords','face',etc_render_fsbrain.vol_A(hemi_idx).faces','value',ov,'value_idx',etc_render_fsbrain.vol_A(hemi_idx).v_idx+1,'step',etc_render_fsbrain.overlay_smooth,'n_ratio',length(ov)/size(X_hemi_cort,1),'flag_display',0,'flag_regrid',0,'flag_fixval',0,'D',etc_render_fsbrain.overlay_D{hemi_idx});
        
        %assemble smoothed source at cortical locations and sources at sub-cortical locations
        X_wb{hemi_idx}=cat(1,ovs(:),X_hemi_subcort(:));
        
        flag_cal_loc_vol_idx=1;
        if(isfield(etc_render_fsbrain,'loc_vol_idx'))
            if(length(etc_render_fsbrain.loc_vol_idx)==2)
                if(~isempty(etc_render_fsbrain.loc_vol_idx{hemi_idx}))
                    flag_cal_loc_vol_idx=0;
                end;
            end;
        end;
        
        
        if(flag_cal_loc_vol_idx==1)
            etc_render_fsbrain.loc_vol_idx{hemi_idx}=[];
            %get coordinates from surface to volume
            loc=cat(1,etc_render_fsbrain.vol_A(hemi_idx).vertex_coords./1e3,etc_render_fsbrain.vol_A(hemi_idx).wb_loc);
            loc_surf=[loc.*1e3 ones(size(loc,1),1)]';
            tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
            loc_vol{hemi_idx}=round(tmp(1:3,:))';
            etc_render_fsbrain.loc_vol{hemi_idx}=round(tmp(1:3,:))';
            etc_render_fsbrain.loc_vol_idx{hemi_idx}=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol{hemi_idx}(:,2),loc_vol{hemi_idx}(:,1),loc_vol{hemi_idx}(:,3));
        end;
        
        
    end;
    
    
    tmp=zeros(size(etc_render_fsbrain.vol.vol));
    
    for hemi_idx=1:2
        tmp(etc_render_fsbrain.loc_vol_idx{hemi_idx})=X_wb{hemi_idx};
    end;
    
    etc_render_fsbrain.overlay_vol.vol=tmp;
    
catch ME
end;
return;

