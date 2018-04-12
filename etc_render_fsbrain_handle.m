function etc_render_fsbrain_handle(param,varargin)

global etc_render_fsbrain;

cc=[];

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
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('interactive rendering commands:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('g: open time course GUI \n');
                fprintf('k: open registration GUI\n');
                fprintf('l: open label GUI\n');
                fprintf('w: open coordinates GUI\n');
                fprintf('s: smooth overlay \n');
                fprintf('d: interactive threshold change\n');
                fprintf('c: switch on/off the colorbar\n');
                fprintf('u: show cluster labels from files\n');
                fprintf('q: exit\n');
                fprintf('\n\n fhlin@dec 25, 2014\n');
            case 'a'
                fprintf('archiving...\n');
                fn=sprintf('etc_render_fsbrain.tif');
                fprintf('saving [%s]...\n',fn);
                print(fn,'-dtiff');
            case 'q'
                fprintf('\nclosing all figures!\n');
                close(etc_render_fsbrain.fig_brain);
                close(etc_render_fsbrain.fig_stc);
                close(etc_render_fsbrain.fig_vol);
            case 'r'
                fprintf('\nredrawing...\n');
                redraw;
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
                                set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',10);
                            end;
                        end;
                        
                        mean_point=mean(etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.collect_vertex_boundary,:),1);
                        dist=sum((etc_render_fsbrain.vertex_coords_hemi-repmat(mean_point,[size(etc_render_fsbrain.vertex_coords_hemi,1),1])).^2,2);
                        [dummy,min_dist]=min(dist);
                        roi_idx=etc_patchflood(etc_render_fsbrain.faces_hemi+1,min_dist,etc_render_fsbrain.collect_vertex_boundary);
                        %ROI....
                        etc_render_fsbrain.roi_points=plot3(etc_render_fsbrain.vertex_coords_hemi(roi_idx,1),etc_render_fsbrain.vertex_coords_hemi(roi_idx,2), etc_render_fsbrain.vertex_coords_hemi(roi_idx,3),'.');
                        set(etc_render_fsbrain.roi_points,'color',[1 0 0].*1,'markersize',1);
                        etc_render_fsbrain.roi=roi_idx;
                        
                        %clear boundary points and vertices
                        delete(etc_render_fsbrain.collect_vertex_boundary_point(:));
                        etc_render_fsbrain.collect_vertex_boundary_point=[];
                        etc_render_fsbrain.collect_vertex_boundary=[];
                        
                        etc_render_fsbrain.collect_vertex=[];
                        delete(etc_render_fsbrain.collect_vertex_point(:));
                        etc_render_fsbrain.collect_vertex_point=[];
                        
                    end;
                else
                    etc_render_fsbrain.flag_collect_vertex=1;
                    fprintf('\start collecting vertices for ROI definition...\n');
                    etc_render_fsbrain.collect_vertex=[];
                end;
                
            case 'g'
                %fprintf('\nGUI...\n');
                if(isfield(etc_render_fsbrain,'fig_gui'))
                    etc_render_fsbrain.fig_gui=[];
                end;
                etc_render_fsbrain.fig_gui=etc_render_fsbrain_gui;
                set(etc_render_fsbrain.fig_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
            case 'k'
                %fprintf('\nregister points...\n');
                if(isfield(etc_render_fsbrain,'fig_register'))
                    etc_render_fsbrain.fig_register=[];
                end;
                etc_render_fsbrain.fig_register=etc_render_fsbrain_register;
                set(etc_render_fsbrain.fig_register,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_register,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_register,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
            case 't'
                fprintf('\ntemporal integration...\n');
                if(isempty(inverse_time_integration))
                    inverse_time_integration=1;
                end;
                
                def={num2str(inverse_time_integration)};
                if(isempty(inverse_stc_timeVec))
                    answer=inputdlg('temporal integration',sprintf('temporal integration interval= %s [samples]',num2str(inverse_time_integration)),1,def);
                else
                    answer=inputdlg('temporal integration',sprintf('temporal integration interval= %s [ms]',num2str(inverse_time_integration)),1,def);
                end;
                if(~isempty(answer))
                    inverse_time_integration=str2num(answer{1});
                    if(isempty(inverse_stc_timeVec))
                        fprintf('temporal integration = %s [samples]\n',mat2str(inverse_time_integration));
                    else
                        fprintf('temporal integration = %s [ms]\n',mat2str(inverse_time_integration));
                    end;
                    redraw;
                end;
            case 'w' %coordinate GUI
                %fprintf('\nCoordinate GUI...\n');
                if(isfield(etc_render_fsbrain,'fig_coord_gui'))
                    etc_render_fsbrain.fig_coord_gui=[];
                end;
                etc_render_fsbrain.fig_coord_gui=etc_render_fsbrain_coord_gui;
                set(etc_render_fsbrain.fig_coord_gui,'unit','pixel');
                pos=get(etc_render_fsbrain.fig_coord_gui,'pos');
                pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                set(etc_render_fsbrain.fig_coord_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
            case 'l' %annotation/labels GUI
                %fprintf('\nannotation/labels GUI...\n');
                global etc_render_fsbrain;
                
                if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                else
                    [filename, pathname, filterindex] = uigetfile({'*.annot','FreeSufer annotation (*.annot)';}, 'Pick a file', 'lh.aparc.a2009s.annot');
                    try
                        file_annot=sprintf('%s/%s',pathname,filename);
                        [etc_render_fsbrain.label_vertex etc_render_fsbrain.label_value etc_render_fsbrain.label_ctab] = read_annotation(file_annot);
                    catch ME
                    end;
                end;
                
                if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
                    if(isfield(etc_render_fsbrain,'fig_label_gui'))
                        etc_render_fsbrain.fig_label_gui=[];
                    end;
                    etc_render_fsbrain.fig_label_gui=etc_render_fsbrain_label_gui;
                    set(etc_render_fsbrain.fig_label_gui,'unit','pixel');
                    pos=get(etc_render_fsbrain.fig_label_gui,'pos');
                    pos_brain=get(etc_render_fsbrain.fig_brain,'pos');
                    set(etc_render_fsbrain.fig_label_gui,'pos',[pos_brain(1)+pos_brain(3), pos_brain(2), pos(3), pos(4)]);
                end;
                
            case 'c' %colorbar;
                figure(etc_render_fsbrain.fig_brain);
                if(isfield(etc_render_fsbrain,'h_colorbar_pos'))
                    if(isempty(etc_render_fsbrain.h_colorbar_pos))
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
                if(gcf==etc_render_fsbrain.fig_brain)
                    fprintf('change threshold...\n');
                    fprintf('current threshold = %s\n',mat2str(etc_render_fsbrain.overlay_threshold));
                    def={num2str(etc_render_fsbrain.overlay_threshold)};
                    answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(etc_render_fsbrain.overlay_threshold)),1,def);
                    if(~isempty(answer))
                        etc_render_fsbrain.overlay_threshold=str2num(answer{1});
                        fprintf('updated threshold = %s\n',mat2str(etc_render_fsbrain.overlay_threshold));
                        
                        if(ishandle(etc_render_fsbrain.fig_gui))
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_threshold_min'),'string',sprintf('%1.0f',min(etc_render_fsbrain.overlay_threshold)));
                            set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_threshold_max'),'string',sprintf('%1.0f',max(etc_render_fsbrain.overlay_threshold)));
                        end;
                        
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
                    end;
                    
                    if(ishandle(etc_render_fsbrain.fig_gui))
                        set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_smooth'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_smooth));
                    end;
                end;
                
            case 'p' %create a surface patch based on the clicked location and a specified radius
                
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
                        fprintf('updated ROI radius = %s\n',mat2str(etc_render_fsbrain.roi_radius));
                        
                        
                        [d]=inverse_search_dijk(etc_render_fsbrain.faces'+1,etc_render_fsbrain.click_vertex,'flag_base0',0);
                        [ds,ds_dip_idx]=sort(d);
                        dip_idx=find(ds<=etc_render_fsbrain.roi_radius);
                        inverse_roi_dip_idx=ds_dip_idx(dip_idx);
                        
                        fprintf('[%d] dipoles in this ROI (global variable ''inverse_roi_dip_idx'')\n',length(inverse_roi_dip_idx));
                        for j=1:length(inverse_roi_dip_idx)
                            plot3(etc_render_fsbrain.vertex_coords(inverse_roi_dip_idx(j),1),etc_render_fsbrain.vertex_coords(inverse_roi_dip_idx(j),2),etc_render_fsbrain.vertex_coords(inverse_roi_dip_idx(j),3),'.','Color',[0 1 0].*0.9,'markersize',1); hold on;
                        end;
                        etc_render_fsbrain.roi_label=inverse_roi_dip_idx;
                        
                    end;
                end;
            otherwise
                %fprintf('pressed [%c]!\n',cc);
        end;
    case 'bd'
        if(gcf==etc_render_fsbrain.fig_brain)
            draw_pointer;
            draw_stc;
            figure(etc_render_fsbrain.fig_brain);
        elseif(gcf==etc_render_fsbrain.fig_vol)
            xx=get(gca,'currentpoint');
            xx=xx(1,1:2);
            tmp=ceil(xx(1,1:2)./256);
            if(min(tmp(:))>=1&max(tmp(:))<=2)
                ind=sub2ind([2 2],tmp(1),tmp(2));
                
                
                vox=etc_render_fsbrain.click_vertex_vox;
                switch ind
                    case 1 %cor slice
                        v=[xx(1) xx(2) vox(3)];
                    case 2 %ax slice
                        v=[xx(2) vox(2) xx(1)-256];
                    case 3 %sag slice
                        v=[vox(1) xx(2)-256 xx(1)];
                    otherwise
                        v=[];
                end;
                if(~isempty(v))
                    surface_coord=etc_render_fsbrain.vol.tkrvox2ras*[v(:); 1];
                    surface_coord=surface_coord(1:3);
                    click_vertex_vox=v;
                    
                    vv=etc_render_fsbrain.orig_vertex_coords;
                    dist=sqrt(sum((vv-repmat([surface_coord(1),surface_coord(2),surface_coord(3)],[size(vv,1),1])).^2,2));
                    [min_dist,min_dist_idx]=min(dist);
                    surface_coord=etc_render_fsbrain.vertex_coords(min_dist_idx,:)';
                    
                    draw_pointer('pt',surface_coord,'min_dist_idx',min_dist_idx,'click_vertex_vox',click_vertex_vox);
                end;
            end;
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
            
            if(~iscell(etc_render_fsbrain.overlay_value))
                etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
            else
                for h_idx=1:length(etc_render_fsbrain.overlay_value)
                    etc_render_fsbrain.overlay_value{h_idx}=etc_render_fsbrain.overlay_stc_hemi{h_idx}(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
                end;
            end;
            
            if(~isempty(etc_render_fsbrain.overlay_stc))
                draw_stc;
            end;
            
            if(ishandle(etc_render_fsbrain.fig_gui))
                set(findobj(etc_render_fsbrain.fig_gui,'tag','slider_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                
                set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'value',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx));
                set(findobj(etc_render_fsbrain.fig_gui,'tag','edit_timeVec'),'string',sprintf('%1.0f',etc_render_fsbrain.overlay_stc_timeVec(etc_render_fsbrain.overlay_stc_timeVec_idx)));
            end;
            
            figure(etc_render_fsbrain.fig_brain);
            redraw;
            figure(etc_render_fsbrain.fig_stc);
            
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
    end;
else
end;

if(~isempty(etc_render_fsbrain.click_point))
    etc_render_fsbrain.click_point=[];
end;

etc_render_fsbrain.click_coord=pt;
etc_render_fsbrain.click_point=plot3(pt(1),pt(2),pt(3),'.');
fprintf('\nsurface coordinate of the selected point ={%s}\n',num2str(pt','%2.2f '));
set(etc_render_fsbrain.click_point,'color',[1 0 1],'markersize',10);

vv=etc_render_fsbrain.vertex_coords;
if(isempty(min_dist_idx))
    dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
    [min_dist,min_dist_idx]=min(dist);
end;
fprintf('the nearest vertex: IDX=[%d] {%2.2f %2.2f %2.2f} \n',min_dist_idx,vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3));
etc_render_fsbrain.click_coord_round=[vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3)];
etc_render_fsbrain.click_vertex=min_dist_idx;
etc_render_fsbrain.click_vertex_point=plot3(vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3),'.');
set(etc_render_fsbrain.click_vertex_point,'color',[0 1 1],'markersize',10);

if(isfield(etc_render_fsbrain,'flag_collect_vertex'))
    if(etc_render_fsbrain.flag_collect_vertex)
        etc_render_fsbrain.collect_vertex=cat(1,etc_render_fsbrain.collect_vertex,etc_render_fsbrain.click_vertex);
        
        if(isfield(etc_render_fsbrain,'collect_vertex_point'))
            etc_render_fsbrain.collect_vertex_point(end+1)=plot3(vv(etc_render_fsbrain.collect_vertex(end),1),vv(etc_render_fsbrain.collect_vertex(end),2),vv(etc_render_fsbrain.collect_vertex(end),3),'.');
        else
            etc_render_fsbrain.collect_vertex_point=plot3(vv(etc_render_fsbrain.collect_vertex(end),1),vv(etc_render_fsbrain.collect_vertex(end),2),vv(etc_render_fsbrain.collect_vertex(end),3),'.');
        end;
        set(etc_render_fsbrain.collect_vertex_point(end),'color',[0 1 1].*0.5,'markersize',10);
        
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
                set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',10);
            end;
        else
            etc_render_fsbrain.collect_vertex_boundary=etc_render_fsbrain.collect_vertex(end);
            etc_render_fsbrain.collect_vertex_boundary_point=plot3(vv(etc_render_fsbrain.collect_vertex_boundary(end),1),vv(etc_render_fsbrain.collect_vertex_boundary(end),2),vv(etc_render_fsbrain.collect_vertex_boundary(end),3),'.');
            set(etc_render_fsbrain.collect_vertex_boundary_point(end),'color',[0 1 1].*0.8,'markersize',10);
        end;
    end;
else
    etc_render_fsbrain.flag_collect_vertex=0;
end;

%show label
if(~isempty(etc_render_fsbrain.label_vertex)&&~isempty(etc_render_fsbrain.label_value)&&~isempty(etc_render_fsbrain.label_ctab))
    ctab_val=etc_render_fsbrain.label_ctab.table(:,5);
    ii=find(ctab_val==etc_render_fsbrain.label_value(min_dist_idx));
    fprintf('the nearest vertex is at label {%s}\n',etc_render_fsbrain.label_ctab.struct_names{ii});
    
    try
        if(~isempty(etc_render_fsbrain.fig_label_gui))
            handles=guidata(etc_render_fsbrain.fig_label_gui);
            set(handles.listbox_label,'value',ii);
        end;
    catch ME
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
    etc_render_fsbrain.click_vertex_vox_round=round(etc_render_fsbrain.vol_vox(min_dist_idx,:));
    %tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*([pt(:); 1]);
    %etc_render_fsbrain.click_vertex_vox=tmp(1:3)';
    if(isempty(click_vertex_vox))
        etc_render_fsbrain.click_vertex_vox=(etc_render_fsbrain.vol_vox(min_dist_idx,:));
    else
        etc_render_fsbrain.click_vertex_vox=click_vertex_vox;
    end;
    %etc_render_fsbrain.click_vertex_vox_round=round(tmp(1:3))';
    fprintf('clicked surface voxel = [%1.1f %1.1f %1.1f]\n',etc_render_fsbrain.click_vertex_vox(1),etc_render_fsbrain.click_vertex_vox(2),etc_render_fsbrain.click_vertex_vox(3));
    fprintf('the closest voxel to the clicked surface voxel = [%d %d %d]\n',etc_render_fsbrain.click_vertex_vox_round(1),etc_render_fsbrain.click_vertex_vox_round(2),etc_render_fsbrain.click_vertex_vox_round(3));
    if(~isempty(etc_render_fsbrain.talxfm))
        etc_render_fsbrain.click_vertex_point_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox 1].';
        etc_render_fsbrain.click_vertex_point_tal=etc_render_fsbrain.click_vertex_point_tal(1:3)';
        fprintf('clicked surface voxel MNI305 coordinate = (%1.0f %1.0f %1.0f)\n',etc_render_fsbrain.click_vertex_point_tal(1),etc_render_fsbrain.click_vertex_point_tal(2),etc_render_fsbrain.click_vertex_point_tal(3));
        etc_render_fsbrain.click_vertex_point_round_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol.vox2ras*[etc_render_fsbrain.click_vertex_vox_round 1].';
        etc_render_fsbrain.click_vertex_point_round_tal=etc_render_fsbrain.click_vertex_point_round_tal(1:3)';
        fprintf('the closest voxel to the clicked surface voxel MNI305 coordinate = (%1.0f %1.0f %1.0f)\n',etc_render_fsbrain.click_vertex_point_round_tal(1),etc_render_fsbrain.click_vertex_point_round_tal(2),etc_render_fsbrain.click_vertex_point_round_tal(3));
    end;
    clf;
    try
        img_cor=squeeze(etc_render_fsbrain.vol.vol(:,:,round(etc_render_fsbrain.click_vertex_vox(3))));
        img_sag=squeeze(etc_render_fsbrain.vol.vol(:,round(etc_render_fsbrain.click_vertex_vox(1)),:));
        img_ax=squeeze(etc_render_fsbrain.vol.vol(round(etc_render_fsbrain.click_vertex_vox(2)),:,:));
        etc_render_fsbrain.vol_img=[img_cor img_ax; img_sag, zeros(size(img_cor))];
        imagesc(etc_render_fsbrain.vol_img);
        etc_render_fsbrain.vol_img_h=gca;
        axis off image; colormap(gray);
        if(~isempty(xlim)) set(etc_render_fsbrain.vol_img_h,'xlim',xlim); end;
        if(~isempty(ylim)) set(etc_render_fsbrain.vol_img_h,'ylim',ylim); end;
        
        etc_render_fsbrain.vol_img_h_cor=text(etc_render_fsbrain.click_vertex_vox(1), etc_render_fsbrain.click_vertex_vox(2),'x'); set(etc_render_fsbrain.vol_img_h_cor,'color','m','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',12);
        etc_render_fsbrain.vol_img_h_ax=text(256+etc_render_fsbrain.click_vertex_vox(3), etc_render_fsbrain.click_vertex_vox(1),'x'); set(etc_render_fsbrain.vol_img_h_ax,'color','m','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',12);
        etc_render_fsbrain.vol_img_h_sag=text(etc_render_fsbrain.click_vertex_vox(3), 256+etc_render_fsbrain.click_vertex_vox(2),'x'); set(etc_render_fsbrain.vol_img_h_sag,'color','m','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',12);
        
        etc_render_fsbrain.vol_img_h_round_cor=text(etc_render_fsbrain.click_vertex_vox_round(1), etc_render_fsbrain.click_vertex_vox_round(2),'o'); set(etc_render_fsbrain.vol_img_h_round_cor,'color','c','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',12);
        etc_render_fsbrain.vol_img_h_round_ax=text(256+etc_render_fsbrain.click_vertex_vox_round(3), etc_render_fsbrain.click_vertex_vox_round(1),'o'); set(etc_render_fsbrain.vol_img_h_round_ax,'color','c','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',12);
        etc_render_fsbrain.vol_img_h_round_sag=text(etc_render_fsbrain.click_vertex_vox_round(3), 256+etc_render_fsbrain.click_vertex_vox_round(2),'o'); set(etc_render_fsbrain.vol_img_h_round_sag,'color','c','HorizontalAlignment','center','VerticalAlignment','middle','fontsize',12);
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
        fprintf('the nearest overlay vertex: location=[%d]::<%2.2f> (%2.2f %2.2f %2.2f) \n',min_overlay_dist_idx,etc_render_fsbrain.overlay_value(min_overlay_dist_idx),vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3));
    else
        if(min_overlay_dist_idx>length(etc_render_fsbrain.overlay_vertex{1}))
            offset=length(etc_render_fsbrain.overlay_vertex{1});
            hemi_idx=2;
        else
            offset=0;
            hemi_idx=1;
        end;
        fprintf('the nearest overlay vertex: hemi{%d} location=[%d]::<%2.2f> @ (%2.2f %2.2f %2.2f) \n',hemi_idx,min_overlay_dist_idx-offset,etc_render_fsbrain.overlay_value{hemi_idx}(min_overlay_dist_idx-offset),vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3));
    end;
    etc_render_fsbrain.click_overlay_vertex=min_overlay_dist_idx;
    etc_render_fsbrain.click_overlay_vertex_point=plot3(vv(min_overlay_dist_idx,1),vv(min_overlay_dist_idx,2),vv(min_overlay_dist_idx,3),'.');
    set(etc_render_fsbrain.click_overlay_vertex_point,'color',[0 1 0]);
else
    etc_render_fsbrain.click_overlay_vertex=[];
    etc_render_fsbrain.click_overlay_vertex_point=[];
end;
%fprintf('by the end of draw pointer: [%d]\n', ishandle(etc_render_fsbrain.h));


return;


function draw_stc()
global etc_render_fsbrain;

if(~isempty(etc_render_fsbrain.fig_stc))
    if(~isvalid(etc_render_fsbrain.fig_stc))
        delete(etc_render_fsbrain.fig_stc);
        etc_render_fsbrain.fig_stc=[];
    end;
end;

if(~isempty(etc_render_fsbrain.click_overlay_vertex)&~isempty(etc_render_fsbrain.overlay_stc))
    if(isempty(etc_render_fsbrain.fig_stc))
        etc_render_fsbrain.fig_stc=figure;
        pos=get(etc_render_fsbrain.fig_brain,'pos');
        set(etc_render_fsbrain.fig_stc,'pos',[pos(1)-pos(3), pos(2), pos(3), pos(4)]);
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
        if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
            delete(etc_render_fsbrain.handle_fig_stc_timecourse)
            delete(etc_render_fsbrain.handle_fig_stc_aux_timecourse);
        end;
        
        etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
        
        h_xline=line([1 size(etc_render_fsbrain.overlay_stc,2)],[0 0]); hold on;
        set(h_xline,'linewidth',2,'color',[1 1 1].*0.5);
        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
            h=plot(squeeze(etc_render_fsbrain.overlay_aux_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
            cc=get(gca,'ColorOrder');
            for ii=1:length(h)
                set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
            end;
            etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
        end;
        h=plot(etc_render_fsbrain.overlay_stc(etc_render_fsbrain.click_overlay_vertex,:));
        set(h,'linewidth',2,'color','r'); hold off;
        
        if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
            etc_render_fsbrain.handle_fig_stc_timecourse=h;
        else
            etc_render_fsbrain.handle_fig_stc_timecourse(end+1)=h;
        end;
    else
        if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
            delete(etc_render_fsbrain.handle_fig_stc_timecourse);
            delete(etc_render_fsbrain.handle_fig_stc_aux_timecourse);
        end;
        h_xline=line([min(etc_render_fsbrain.overlay_stc_timeVec) max(etc_render_fsbrain.overlay_stc_timeVec)],[0 0]); hold on;
        set(h_xline,'linewidth',2,'color',[1 1 1].*0.5);
        if(~isempty(etc_render_fsbrain.overlay_aux_stc))
            h=plot(etc_render_fsbrain.overlay_stc_timeVec,squeeze(etc_render_fsbrain.overlay_aux_stc(etc_render_fsbrain.click_overlay_vertex,:,:)));
            cc=get(gca,'ColorOrder');
            for ii=1:length(h)
                set(h(ii),'linewidth',1,'color',cc(rem(ii,8),:));
            end;
            etc_render_fsbrain.handle_fig_stc_aux_timecourse=h;
        end;
        h=plot(etc_render_fsbrain.overlay_stc_timeVec,etc_render_fsbrain.overlay_stc(etc_render_fsbrain.click_overlay_vertex,:));
        set(h,'linewidth',2,'color','r'); hold off;
        
        if(~etc_render_fsbrain.flag_hold_fig_stc_timecourse)
            etc_render_fsbrain.handle_fig_stc_timecourse=h;
        else
            etc_render_fsbrain.handle_fig_stc_timecourse(end+1)=h;
        end;
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
return;

function redraw()

global etc_render_fsbrain;

figure(etc_render_fsbrain.fig_brain);
[etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2)]=view;

%set axes
axes(etc_render_fsbrain.brain_axis);

xlim=get(gca,'xlim');
ylim=get(gca,'ylim');
zlim=get(gca,'zlim');

etc_render_fsbrain.lim=[xlim(:)' ylim(:)' zlim(:)'];

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

if(etc_render_fsbrain.overlay_flag_render)
    %2: curvature and overlay color
    if(~isempty(etc_render_fsbrain.overlay_value))
        if(~iscell(etc_render_fsbrain.overlay_value))
            ov=zeros(size(etc_render_fsbrain.vertex_coords,1),1);
            ov(etc_render_fsbrain.overlay_vertex+1)=etc_render_fsbrain.overlay_value;
            
            if(~isempty(etc_render_fsbrain.overlay_smooth))
                ovs=inverse_smooth('','vertex',etc_render_fsbrain.vertex_coords','face',etc_render_fsbrain.faces','value',ov,'step',etc_render_fsbrain.overlay_smooth,'flag_fixval',0,'exc_vertex',etc_render_fsbrain.overlay_exclude);
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
                    ovs=cat(1,ovs,inverse_smooth('','vertex',etc_render_fsbrain.vertex_coords_hemi{h_idx}','face',etc_render_fsbrain.faces_hemi{h_idx}','value',ov,'step',etc_render_fsbrain.overlay_smooth,'flag_fixval',0,'exc_vertex',etc_render_fsbrain.overlay_exclude{h_idx}));
                else
                    ovs=cat(1,ovs,ov);
                end;
                if(~isempty(find(etc_render_fsbrain.overlay_value{h_idx}>0))) etc_render_fsbrain.overlay_value_flag_pos=1; end;
                if(~isempty(find(etc_render_fsbrain.overlay_value{h_idx}<0))) etc_render_fsbrain.overlay_value_flag_neg=1; end;
            end;
        end;
        
        if(isempty(etc_render_fsbrain.overlay_threshold))
            tmp=sort(ovs(:));
            etc_render_fsbrain.overlay_threshold=[tmp(round(length(tmp)*0.5)) tmp(round(length(tmp)*0.9))];
        end;
        c_idx=find(ovs(:)>=min(etc_render_fsbrain.overlay_threshold));
        
        etc_render_fsbrain.fvdata(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap,ovs(c_idx),max(etc_render_fsbrain.overlay_threshold),min(etc_render_fsbrain.overlay_threshold));
        
        c_idx=find(ovs(:)<=-min(etc_render_fsbrain.overlay_threshold));
        
        etc_render_fsbrain.fvdata(c_idx,:)=inverse_get_color(etc_render_fsbrain.overlay_cmap_neg,ovs(c_idx),-max(etc_render_fsbrain.overlay_threshold),-min(etc_render_fsbrain.overlay_threshold));
        
    end;
end;

h=patch('Faces',etc_render_fsbrain.faces+1,'Vertices',etc_render_fsbrain.vertex_coords,'FaceVertexCData',etc_render_fsbrain.fvdata,'facealpha',etc_render_fsbrain.alpha,'CDataMapping','direct','facecolor','interp','edgecolor','none');
material dull;

etc_render_fsbrain.h=h;

axis off vis3d equal;
axis(etc_render_fsbrain.lim);

if(~isempty(etc_render_fsbrain.overlay_threshold))
    set(gca,'climmode','manual','clim',etc_render_fsbrain.overlay_threshold);
end;
set(gcf,'color',etc_render_fsbrain.bg_color);


view(etc_render_fsbrain.view_angle(1), etc_render_fsbrain.view_angle(2));


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
        sr=0.005;
        xx=[]; yy=[]; zz=[];
        for idx=1:size(etc_render_fsbrain.aux_point_coords,1)
            xx=cat(1,xx,sx.*sr+etc_render_fsbrain.aux_point_coords(idx,1));
            yy=cat(1,yy,sy.*sr+etc_render_fsbrain.aux_point_coords(idx,2));
            zz=cat(1,zz,sz.*sr+etc_render_fsbrain.aux_point_coords(idx,3));
            if(~isempty(etc_render_fsbrain.aux_point_name))
                etc_render_fsbrain.aux_point_name_h(idx)=text(etc_render_fsbrain.aux_point_coords(idx,1),etc_render_fsbrain.aux_point_coords(idx,2),etc_render_fsbrain.aux_point_coords(idx,3),etc_render_fsbrain.aux_point_name{idx}); hold on;
            end;
        end;
        etc_render_fsbrain.aux_point_coords_h(1)=surf(xx,yy,zz);
        set(etc_render_fsbrain.aux_point_coords_h(1),'facecolor','r','edgecolor','none');
    end;
end;


if(isfield(etc_render_fsbrain,'aux2_point_coords'))
    if(~isempty(etc_render_fsbrain.aux2_point_coords_h))
        delete(etc_render_fsbrain.aux2_point_coords_h(:));
        etc_render_fsbrain.aux2_point_coords_h=[];
    end;
    
    if(~isempty(etc_render_fsbrain.aux2_point_name_h))
        delete(etc_render_fsbrain.aux2_point_name_h(:));
        etc_render_fsbrain.aux2_point_name_h=[];
    end;
    
    if(~isempty(etc_render_fsbrain.aux2_point_coords))
        
        xx=[]; yy=[]; zz=[];
        for idx=1:size(etc_render_fsbrain.aux2_point_coords,1)
            xx=cat(1,xx,etc_render_fsbrain.aux2_point_coords(idx,1));
            yy=cat(1,yy,etc_render_fsbrain.aux2_point_coords(idx,2));
            zz=cat(1,zz,etc_render_fsbrain.aux2_point_coords(idx,3));
            if(~isempty(etc_render_fsbrain.aux2_point_name))
                etc_render_fsbrain.aux2_point_name_h(idx)=text(etc_render_fsbrain.aux2_point_coords(idx,1),etc_render_fsbrain.aux2_point_coords(idx,2),etc_render_fsbrain.aux2_point_coords(idx,3),etc_render_fsbrain.aux2_point_name{idx}); hold on;
            end;
        end;
        etc_render_fsbrain.aux2_point_coords_h=plot3(xx,yy,zz,'r.');
        set(etc_render_fsbrain.aux2_point_coords_h,'color',[1 0 0].*0.5);
    end;
end;

return;

