function fmri_overlay_handle(param)

global fmri_under_vol;
global fmri_over_vol;
global fmri_talxfm;
global fmri_xfm; %the transformation applied to this program only
global fmri_under;
global fmri_over;
global fmri_over_data;
global fmri_op;
global fmri_threshold;
global fmri_pointer;
global fmri_pointer_handle;
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_timeVec;
global fmri_fig_projection
global fmri_fig_overlay_coord_gui;
global fmri_datamat;
global fmri_beta;
global fmri_hdr;
global fmri_timeVec;
global fmri_coords;
global fmri_origin;
global fmri_origin_handle;
global fmri_vox;
global fmri_colormap;
global fmri_colorbar_handle;
global fmri_projection_slice;
global fmri_cluster_box_overlay;
global fmri_cluster_box_projection;
global fmri_cluster_box_orig_overlay;
global fmri_cluster_box_orig_projection;
global fmri_cluster_halfrange;
global fmri_timeVec_line;
global fmri_timeVec_x_idx;
global fmri_cluster_index;

ff=gcf;
cc=get(gcf,'currentchar');
%fmri_fig_overlay=gcf;

%fprintf('\nfmri_overlay_handle... gcf=[%d]; param=[%s]; currentchar=[%c]\n',ff,param,cc);

switch lower(param)
    case 'kb'
        switch(cc)
            case 'h'
                fprintf('fmri_overlay information:\n\n');
                fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
                fprintf('q: exit fmri_overlay\n');
                fprintf('o: reorienting 3D orthogonal slice \n');
                fprintf('l: flip images left-right \n');
                fprintf('u: flip images up-down \n');
                fprintf('t: rotate images 90-deg counterclockwise \n');
                fprintf('s: sharpen overlay \n');
                fprintf('p: projection plots \n');
                fprintf('v: orthogonal slice view in projection plots \n');
                fprintf('w: show MNI/Talairach coordinate GUI \n');
                fprintf('+: increase threshold by 10%\n');
                fprintf('-: decrease threshold by 10%\n');
                fprintf('d: interactive threshold change\n');
                fprintf('c: switch on/off the colorbar\n');
                fprintf('\n\n fhlin@jun 24, 2002\n');
            case 'a'
                fprintf('archiving...\n');
                f = getframe(gcf);
                colormap(f.colormap);
                cmap=get(gcf,'colormap');
                fn=sprintf('fmri_overlay.tif');
                fprintf('saving [%s]...\n',fn);
                imwrite(f.cdata,cmap,fn,'tiff');
            case 'q'
                fprintf('\nterminating graph!\n');
                close_all;
            case 'r'
                if(strcmp(get(gcf,'name'),'fmri_fig_overlay'))
                    fprintf('re-orienting...\n');
                    fmri_over=shiftdim(fmri_over,1);
                    fmri_under=shiftdim(fmri_under,1);
                    
                    if(~isempty(fmri_vox))
                        fmri_vox=[fmri_vox(end), fmri_vox(1), fmri_vox(2)];
                    end;
                    
                    if(~isempty(fmri_pointer))
                        fmri_pointer=[fmri_pointer(end), fmri_pointer(1), fmri_pointer(2)];
                    end;
                    
                    if(~isempty(fmri_origin))
                        fmri_origin=[fmri_origin(end), fmri_origin(1), fmri_origin(2)];
                    end;
                    
                    if(~isempty(fmri_over_data))
                        if(ndims(fmri_over_data)==4)
                            fmri_over_data=permute(fmri_over_data,[2 3 1 4]);
                        elseif(ndims(fmri_over_data)==3)
                            fmri_over_data=permute(fmri_over_data,[2 1 3]);
                        end;
                    end;
                    
                    T=[0 0 1 0;
                       1 0 0 0;
                       0 1 0 0;
                       0 0 0 1];
                    
                    fmri_xfm=T*fmri_xfm;
                    
                    redraw_all;
                end;
            case 'l'
                if(strcmp(get(gcf,'name'),'fmri_fig_overlay'))
                    fprintf('flipping left-right...\n')
                    
                    if(~isempty(fmri_pointer))
                        fmri_pointer=[size(fmri_under,2)+1-fmri_pointer(1),fmri_pointer(2),fmri_pointer(end)];
                    end;
                    
                    if(~isempty(fmri_origin))
                        fmri_origin=[size(fmri_under,2)+1-fmri_origin(1),fmri_origin(2),fmri_origin(end)];
                    end;
                    
                    
                    o=zeros(size(fmri_over,1),size(fmri_over,2),size(fmri_over,3));
                    for i=1:size(fmri_over,3)
                        o(:,:,i)=fliplr(fmri_over(:,:,i));
                    end;
                    fmri_over=o;
                    clear o;
                    
                    T=[-1 0 0 size(fmri_under,2)+1;
                        0 1 0 0;
                        0 0 1 0;
                        0 0 0 1];
                    
                    fmri_xfm=T*fmri_xfm;
                    
                    u=zeros(size(fmri_under,1),size(fmri_under,2),size(fmri_under,3));
                    for i=1:size(fmri_under,3)
                        u(:,:,i)=fliplr(fmri_under(:,:,i));
                    end;
                    fmri_under=u;
                    clear u;
                    
                    if(~isempty(fmri_over_data))
                        fmri_over_data=flipdim(fmri_over_data,2);
                    end;
                    
                    redraw_all;
                end;
            case 't'
                if(strcmp(get(gcf,'name'),'fmri_fig_overlay'))
                    fprintf('rotating 90...\n')
                    
                    if(~isempty(fmri_vox))
                        fmri_vox=[fmri_vox(2), fmri_vox(1), fmri_vox(3)];
                    end;
                    
                    if(~isempty(fmri_pointer))
                        fmri_pointer=[fmri_pointer(2),size(fmri_under,2)+1-fmri_pointer(1), fmri_pointer(end)];
                    end;
                    
                    if(~isempty(fmri_origin))
                        fmri_origin=[fmri_origin(2),size(fmri_under,2)+1-fmri_origin(1), fmri_origin(end)];
                    end;
                    
                    
                    o=zeros(size(fmri_over,2),size(fmri_over,1),size(fmri_over,3));
                    for i=1:size(fmri_over,3)
                        o(:,:,i)=rot90(fmri_over(:,:,i));
                    end;
                    fmri_over=o;
                    clear o;
                    
                    T=[0 1 0 0;
                      -1 0 0 size(fmri_under,2)+1;
                       0 0 1 0;
                       0 0 0 1];
                    
                    fmri_xfm=T*fmri_xfm;                    
                    
                    u=zeros(size(fmri_under,2),size(fmri_under,1),size(fmri_under,3));
                    for i=1:size(fmri_under,3)
                        u(:,:,i)=rot90(fmri_under(:,:,i));
                    end;
                    fmri_under=u;
                    clear u;
                    
                    if(ndims(fmri_over_data)==3)
                        u=zeros(size(fmri_over_data,2),size(fmri_over_data,1),size(fmri_over_data,3));
                        for t=1:size(fmri_over_data,3)
                            u(:,:,t)=rot90(fmri_over_data(:,:,t));
                        end;
                    elseif(ndims(fmri_over_data)==4)
                        u=zeros(size(fmri_over_data,2),size(fmri_over_data,1),size(fmri_over_data,3),size(fmri_over_data,4));
                        for t=1:size(fmri_over_data,4)
                            for i=1:size(fmri_over_data,3)
                                u(:,:,i,t)=rot90(fmri_over_data(:,:,i,t));
                            end;
                        end;
                    end;
                    fmri_over_data=u;
                    clear u;
                    
                    redraw_all;
                end;
            case 'u'
                if(strcmp(get(gcf,'name'),'fmri_fig_overlay'))
                    fprintf('flipping up-down...\n')
                    
                    if(~isempty(fmri_pointer))
                        fmri_pointer=[fmri_pointer(1),size(fmri_under,1)+1-fmri_pointer(2),fmri_pointer(end)];
                    end;
                    
                    if(~isempty(fmri_origin))
                        fmri_origin=[fmri_pointer(1),size(fmri_under,1)+1-fmri_origin(2),fmri_origin(end)];
                    end;
                    
                    
                    o=zeros(size(fmri_over,1),size(fmri_over,2),size(fmri_over,3));
                    for i=1:size(fmri_over,3)
                        o(:,:,i)=flipud(fmri_over(:,:,i));
                    end;
                    fmri_over=o;
                    clear o;
                    
                    T=[1 0 0 0;
                       0 -1 0 size(fmri_under,1)+1;
                       0 0 1 0;
                       0 0 0 1];
                    
                    fmri_xfm=T*fmri_xfm;
                    
                    u=zeros(size(fmri_under,1),size(fmri_under,2),size(fmri_under,3));
                    for i=1:size(fmri_under,3)
                        u(:,:,i)=flipud(fmri_under(:,:,i));
                    end;
                    fmri_under=u;
                    clear u;
                    
                    if(~isempty(fmri_over_data))
                        fmri_over_data=flipdim(fmri_over_data,1);
                    end;
                    
                    redraw_all;
                end;
            case 'p'
                fprintf('projection plots...\n');
                fmri_overlay_handle('proj');
                
            case 's'
                fprintf('sharpening overlay...\n');
                
                fmri_threshold=fmri_threshold.*1.1;
                
                redraw_all;
                
            case 'd'
                fprintf('change threshold...\n');
                fprintf('current threshold = %s\n',mat2str(fmri_threshold));
                def={num2str(fmri_threshold)};
                answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(fmri_threshold)),1,def);
                if(~isempty(answer))
                    fmri_threshold=str2num(answer{1});
                    fprintf('updated threshold = %s\n',mat2str(fmri_threshold));
                    redraw_all;
                end;
            case 'c'
                if(~isempty(fmri_colorbar_handle))
                    fprintf('turning off colorbar...\n');
                    delete(fmri_colorbar_handle)
                    fmri_colorbar_handle=[];
                else
                    
                    fprintf('turning on colorbar...\n');
                    draw_colorbar;
                    
                end;
            case 'k'
                if(~isempty(fmri_cluster_halfrange))
                    default_hr=sprintf('%d',fmri_cluster_halfrange);
                else
                    default_hr='3';
                end;
                answer=inputdlg('cluster half range ','clustering half range (pixel)',1,{default_hr});
                if(~isempty(answer))
                    hr=str2num(answer{1});
                    fmri_cluster_halfrange=hr;
                    fprintf('clustering from center [%s]...\n',num2str(fmri_pointer,'%3d '));
                    %[output_center,max_mean_data3d]=fmri_locuscenter(fmri_over,[fmri_pointer(2),fmri_pointer(1),fmri_pointer(3)],'half_range',hr);
                    output_center=[fmri_pointer(2) fmri_pointer(1) fmri_pointer(3)];
                else
                    output_center=[];
                end;
                
                draw_pointer;
                
                
                if(~isempty(output_center))
                    gcf_tmp=gcf;
                    if(~isempty(fmri_over_data))
                        [xx,yy,zz]=meshgrid(output_center(2)-fmri_cluster_halfrange:output_center(2)+fmri_cluster_halfrange,output_center(1)-fmri_cluster_halfrange:output_center(1)+fmri_cluster_halfrange,output_center(3)-fmri_cluster_halfrange:output_center(3)+fmri_cluster_halfrange);
                        fmri_cluster_index=sub2ind(size(fmri_over),yy(:),xx(:),zz(:));
                        
                        draw_timecourse();
                    end;
                    
                    if(~isempty(fmri_cluster_box_projection))
                        for i=1:length(fmri_cluster_box_projection)
                            if(ishandle(fmri_cluster_box_projection{i}))
                                delete(fmri_cluster_box_projection{i});
                            else
                                fmri_cluster_box_projection{i}=[];
                            end;
                        end;
                    end;
                    if(ishandle(fmri_fig_projection))
                        figure(fmri_fig_projection);
                        fmri_cluster_box_projection{1}=rectangle('position',[output_center(2)-hr,size(fmri_under,3)+1-output_center(3)-hr,2*hr,2*hr]);
                        set(fmri_cluster_box_projection{1},'linewidth',1);
                        set(fmri_cluster_box_projection{1},'edgecolor',[0 0 1]);
                        fmri_cluster_box_projection{2}=rectangle('position',[size(fmri_under,2)+output_center(1)-hr,size(fmri_under,3)+1-output_center(3)-hr,2*hr,2*hr]);
                        set(fmri_cluster_box_projection{2},'linewidth',1);
                        set(fmri_cluster_box_projection{2},'edgecolor',[0 0 1]);
                        fmri_cluster_box_projection{3}=rectangle('position',[output_center(2)-hr,size(fmri_under,3)+output_center(1)-hr,2*hr,2*hr]);
                        set(fmri_cluster_box_projection{3},'linewidth',1);
                        set(fmri_cluster_box_projection{3},'edgecolor',[0 0 1]);
                    else
                        fmri_fig_projection=[];
                    end;
                    
                    
                    if(~isempty(fmri_cluster_box_overlay))
                        for i=1:length(fmri_cluster_box_overlay)
                            if(ishandle(fmri_cluster_box_overlay{i}))
                                delete(fmri_cluster_box_overlay{i});
                            else
                                fmri_cluster_box_overlay{i}=[];
                            end;
                        end;
                    end;
                    
                    if(ishandle(fmri_fig_overlay))
                        figure(fmri_fig_overlay);
                        for i=1:(2*fmri_cluster_halfrange+1)
                            output=etc_coords_convert([output_center(2),output_center(1),output_center(3)-fmri_cluster_halfrange-1+i],[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
                            xx=output(1);
                            yy=output(2);
                            fmri_cluster_box_overlay{i}=rectangle('position',[xx-fmri_cluster_halfrange,yy-fmri_cluster_halfrange,2*fmri_cluster_halfrange,2*fmri_cluster_halfrange]);
                            set(fmri_cluster_box_overlay{i},'linewidth',1);
                            set(fmri_cluster_box_overlay{i},'edgecolor',[0 0 1]);
                        end;
                    else
                        fmri_fig_overlay=[];
                    end;
                    
                    figure(gcf_tmp);
                end;
            case 'w' %coordinate GUI
                fprintf('\nCoordinate GUI...\n');
                fmri_fig_overlay_coord_gui=fmri_overlay_coord_gui;
                set(fmri_fig_overlay_coord_gui,'unit','pixel');
                pos=get(fmri_fig_overlay_coord_gui,'pos');
                pos_brain=get(fmri_fig_overlay,'pos');
                set(fmri_fig_overlay_coord_gui,'pos',[pos_brain(1), pos_brain(2)-pos(4), pos(3), pos(4)]);
            case 'o'
                fprintf('overlay...\n');
                if(~isempty(fmri_fig_overlay))
                    if(ishandle(fmri_fig_overlay))
                        figure(fmri_fig_overlay);
                    else
                        fmri_fig_overlay=figure;
                    end;
                else
                    fmri_fig_overlay=figure;
                end;
                
                overlay_core(fmri_under,fmri_over,fmri_op,fmri_threshold,fmri_colormap);
                draw_pointer;
            case 'v'
                if(isempty(fmri_projection_slice))
                    fmri_projection_slice=0;
                end;
                
                fmri_projection_slice=~fmri_projection_slice;
                
                redraw_all;
        end;
        
    case 'bd'
        if(gcf==fmri_fig_overlay) %clicking on overlay figure
            pp=get(gca,'currentpoint');
            xx=round(pp(1,1));
            yy=round(pp(1,2));
            pos=get(gcf,'pos');
            fmri_pointer=etc_coords_convert([xx,yy],[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
            if(fmri_pointer(end)<1) fmri_pointer(end)=1; end;
           
            
            if(~isempty(fmri_datamat)|~isempty(fmri_beta)|~isempty(fmri_over_data))
                draw_timecourse;
            end;
            
            if(~isempty(fmri_fig_projection))
                if(ishandle(fmri_fig_projection))
                    if(fmri_projection_slice)
                        uu=[rot90(squeeze(fmri_under(fmri_pointer(2),:,:))),rot90(squeeze(fmri_under(:,fmri_pointer(1),:)));
                            squeeze(fmri_under(:,:,fmri_pointer(3))),zeros(size(fmri_under,1),size(fmri_under,1))].*0.8;
                        
                        oo=[rot90(squeeze(fmri_over(fmri_pointer(2),:,:))),rot90(squeeze(fmri_over(:,fmri_pointer(1),:)));
                            squeeze(fmri_over(:,:,fmri_pointer(3))),zeros(size(fmri_over,1),size(fmri_over,1))];
                        
                        figure(fmri_fig_projection);
                        overlay_core(uu,oo,fmri_op,fmri_threshold,fmri_colormap);
                    end;
                else
                    fmri_fig_projection=[];
                end;
            end;
            
            
            draw_pointer;
            
            idx=[];
            if(fmri_pointer(3)>size(fmri_under,3))
                fprintf('slice not existed in the original data!\n');
            else
                if(~isempty(fmri_vox)&~isempty(fmri_origin))
                    coords(1)=(fmri_pointer(1)-fmri_origin(1))*fmri_vox(1);
                    coords(2)=(fmri_origin(2)-fmri_pointer(2))*fmri_vox(2);
                    coords(3)=(fmri_pointer(3)-fmri_origin(3))*fmri_vox(3);
                    fprintf('selected matrix: %s, coordinate: %s\n',mat2str(fmri_pointer),mat2str(coords));
                else
                    fprintf('selected matrix: %s\t',mat2str(fmri_pointer));
                end;
                fprintf('selected overlay value = %4.4f\n',fmri_over(fmri_pointer(2),fmri_pointer(1),fmri_pointer(3)));
            end;
            fprintf('\n');
        elseif(gcf==fmri_fig_timeVec) %clicking on timeVec figure
            pp=get(gca,'currentpoint');
            xx=round(pp(1,1));
            yy=round(pp(1,2));
            
            ymax=max(get(gca,'ylim'));
            ymin=min(get(gca,'ylim'));
            
            try
                delete(fmri_timeVec_line);
            catch
                
            end;
            
            if(isempty(fmri_timeVec)) fmri_timeVec=[1:size(fmri_hdr,1)]; end;
            
            [dummy,fmri_timeVec_x_idx]=min(abs(fmri_timeVec-xx));
            
            fprintf('click at [%2.2f] --> time_idx =%d\n',fmri_timeVec(fmri_timeVec_x_idx),fmri_timeVec_x_idx);
            
            fmri_timeVec_line=line([fmri_timeVec(fmri_timeVec_x_idx),fmri_timeVec(fmri_timeVec_x_idx)],[ymax,ymin]); set(fmri_timeVec_line,'color',[1 1 1].*0.5);
            
            if(~isempty(fmri_over_data))
                if(ndims(fmri_over_data)==4)
                    fmri_over=fmri_over_data(:,:,:,fmri_timeVec_x_idx);
                elseif(ndims(fmri_over_data)==3)
                    fmri_over=fmri_over_data(:,:,fmri_timeVec_x_idx);
                end;
                
                redraw_all;
            end;
            
        elseif(gcf==fmri_fig_projection) %clicking on overlay figure
            if(isempty(fmri_pointer)) fmri_pointer=[round(size(fmri_under,2)/2),round(size(fmri_under,1)/2),round(size(fmri_under,3)/2)]; end;
            
            pp=get(gca,'currentpoint');
            xx=round(pp(1,1));
            yy=round(pp(1,2));
            
            if((xx>=1)&(xx<=size(fmri_under,2))&(yy>=1)&(yy<=size(fmri_under,3)))
                fmri_pointer(1)=xx;
                fmri_pointer(3)=size(fmri_under,3)+1-yy;
            end;
            
            a0=size(fmri_under,1)+size(fmri_under,2);
            if((xx>size(fmri_under,2))&(xx<a0)&(yy>=1)&(yy<=size(fmri_under,3)))
                fmri_pointer(2)=xx-size(fmri_under,2);
                fmri_pointer(3)=size(fmri_under,3)+1-yy;
            end;
            
            a1=size(fmri_under,3)+size(fmri_under,1);
            if((xx>=1)&(xx<=size(fmri_under,2))&(yy>size(fmri_under,3))&(yy<=a1))
                fmri_pointer(1)=xx;
                fmri_pointer(2)=yy-size(fmri_under,3);
            end;
            
            if(~isempty(fmri_fig_projection))
                if(ishandle(fmri_fig_projection))
                    if(fmri_projection_slice)
                        uu=[rot90(squeeze(fmri_under(fmri_pointer(2),:,:))),rot90(squeeze(fmri_under(:,fmri_pointer(1),:)));
                            squeeze(fmri_under(:,:,fmri_pointer(3))),zeros(size(fmri_under,1),size(fmri_under,1))].*0.8;
                        
                        oo=[rot90(squeeze(fmri_over(fmri_pointer(2),:,:))),rot90(squeeze(fmri_over(:,fmri_pointer(1),:)));
                            squeeze(fmri_over(:,:,fmri_pointer(3))),zeros(size(fmri_over,1),size(fmri_over,1))];
                        
                        figure(fmri_fig_projection);
                        overlay_core(uu,oo,fmri_op,fmri_threshold,fmri_colormap);
                    end;
                else
                    fmri_fig_projection=[];
                end;
            end;
            
            draw_pointer;

            if(fmri_pointer(3)>size(fmri_under,3))
                fprintf('slice not existed in the original data!\n');
            else
                if(~isempty(fmri_vox)&~isempty(fmri_origin))
                    coords(1)=(fmri_pointer(1)-fmri_origin(1))*fmri_vox(1);
                    coords(2)=(fmri_origin(2)-fmri_pointer(2))*fmri_vox(2);
                    coords(3)=(fmri_pointer(3)-fmri_origin(3))*fmri_vox(3);
                    fprintf('selected matrix: %s, coordinate: %s\n',mat2str(fmri_pointer),mat2str(coords));
                else
                    fprintf('selected matrix: %s\t',mat2str(fmri_pointer));
                end;
                fprintf('selected overlay value = %4.4f\n',fmri_over(fmri_pointer(2),fmri_pointer(1),fmri_pointer(3)));
            end;
            fprintf('\n');
            
            if(~isempty(fmri_datamat)|~isempty(fmri_beta)|~isempty(fmri_over_data))
                draw_timecourse;
            end;

        end;
    case 'proj'
        draw_projection;
        figure(fmri_fig_overlay);
    case 'draw_pointer'
        draw_pointer;
        draw_timecourse;
end;

%figure(ff);

return;


function close_all()
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection;
global fmri_pointer_handle;
global fmri_origin_handle;
global fmri_colorbar_handle;

if(~isempty(fmri_fig_profile))
    if(isvalid(fmri_fig_profile))
        close(fmri_fig_profile);
    end;
    fmri_fig_profile=[];
end;
if(~isempty(fmri_fig_overlay))
    if(isvalid(fmri_fig_overlay))
        close(fmri_fig_overlay);
    end;
    fmri_fig_overlay=[];
end;
if(~isempty(fmri_fig_projection))
    if(isvalid(fmri_fig_projection))
        close(fmri_fig_projection);
    end;
    fmri_fig_projection=[];
end;
if(~isempty(fmri_colorbar_handle))
    fmri_colorbar_handle=[];
end;
fmri_pointer_handle=[];
fmri_origin_handle=[];
return;


function redraw_all()
global fmri_under_vol;
global fmri_over_vol;
global fmri_talxfm;
global fmri_xfm;
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection;
global fmri_pointer_handle;
global fmri_under;
global fmri_over;
global fmri_op;
global fmri_threshold;
global fmri_colorbar_handle;
global fmri_colormap;
global fmri_hdr;
global fmri_datamat;
global fmri_beta;
global fmri_over_data;
global fmri_timeVec;

fmri_fig_overlay_xlim=[];
fmri_fig_overlay_ylim=[];
if(~isempty(fmri_fig_overlay))
    flag_overlay=1;
    tmp=get(fmri_fig_overlay,'child');
    tmp0=find(isgraphics(tmp,'axes'));
    fmri_fig_overlay_xlim=get(tmp(tmp0),'xlim');
    fmri_fig_overlay_ylim=get(tmp(tmp0),'ylim');
else
    flag_overlay=0;
end;

if(~isempty(fmri_fig_profile))
    flag_profile=1;
else
    flag_profile=0;
end;

if(~isempty(fmri_fig_projection))
    flag_projection=1;
else
    flag_projection=0;
end;

if(~isempty(fmri_pointer_handle))
    flag_pointer_handle=1;
else
    flag_pointer_handle=0;
end;

if(isempty(fmri_colorbar_handle))
    flag_colorbar_handle=0;
elseif(isvalid(fmri_colorbar_handle))
    flag_colorbar_handle=1;
else
    flag_colorbar_handle=0;
end;

close_all;

%figure(fmri_fig_overlay);
fmri_fig_overlay=figure;
fmri_overlay(fmri_under,fmri_over,fmri_op,fmri_threshold,'cmap',fmri_colormap,'datamat',fmri_datamat,'beta',fmri_beta,'hdr',fmri_hdr,'over_data',fmri_over_data,'timeVec',fmri_timeVec,'under_vol',fmri_under_vol,'over_vol',fmri_over_vol,'talxfm',fmri_talxfm,'xfm',fmri_xfm,'colorbar',flag_colorbar_handle);
tmp=get(fmri_fig_overlay,'child');
tmp0=find(isgraphics(tmp,'axes'));
if(~isempty(fmri_fig_overlay_xlim))
    set(tmp(tmp0),'xlim',fmri_fig_overlay_xlim);
end;
if(~isempty(fmri_fig_overlay_ylim))
    set(tmp(tmp0),'ylim',fmri_fig_overlay_ylim);
end;

if(flag_profile)
    draw_profile;
end;
if(flag_projection)
    draw_projection;
end;
if(flag_pointer_handle)
    draw_pointer;
end;

if((~isempty(fmri_colorbar_handle)))
    if(~isvalid(fmri_colorbar_handle))
        try
            delete(fmri_colorbar_handle)
            draw_colorbar;
        catch ME
        end;
    end;
end;

return;


function draw_pointer()
global fmri_under_vol;
global fmri_xfm;
global fmri_talxfm;
global fmri_pointer;
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection;
global fmri_pointer_handle;
global fmri_under;
global fmri_pointer_projection_line;
global fmri_cluster_halfrange;
global fmri_cluster_box_orig_overlay;
global fmri_cluster_box_orig_projection;

if(isempty(fmri_pointer)) return; end;

if(~isempty(fmri_pointer_handle))
    if(ishandle(fmri_pointer_handle))
        delete(fmri_pointer_handle);
    else
        fmri_pointer_handle=[];
    end;
end;

if(~isempty(fmri_fig_overlay))
    if(ishandle(fmri_fig_overlay))
        figure(fmri_fig_overlay);
        output=etc_coords_convert(fmri_pointer,[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
        fmri_pointer_handle=text(output(1),output(2),'+');
        set(fmri_pointer_handle,'verticalalignment','middle');
        set(fmri_pointer_handle,'horizontalalignment','center');
        set(fmri_pointer_handle,'color',[0 1 1]);
    else
        fmri_fig_overlay=[];
    end;
    
    if(~isempty(fmri_cluster_box_orig_overlay))
        for i=1:length(fmri_cluster_box_orig_overlay)
            if(ishandle(fmri_cluster_box_orig_overlay{i}))
                delete(fmri_cluster_box_orig_overlay{i});
            else
                fmri_cluster_box_orig_overlay{i}=[];
            end;
        end;
    end;
    
    if(~isempty(fmri_cluster_halfrange))
        for i=1:(2*fmri_cluster_halfrange+1)
            output=etc_coords_convert([fmri_pointer(1),fmri_pointer(2),fmri_pointer(3)-fmri_cluster_halfrange-1+i],[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
            xx=output(1);
            yy=output(2);
            fmri_cluster_box_orig_overlay{i}=rectangle('position',[xx-fmri_cluster_halfrange,yy-fmri_cluster_halfrange,2*fmri_cluster_halfrange,2*fmri_cluster_halfrange]);
            set(fmri_cluster_box_orig_overlay{i},'linewidth',1);
            set(fmri_cluster_box_orig_overlay{i},'edgecolor',[0 1 1]);
        end;
    end;
end;

if(~isempty(fmri_fig_projection))
    if(ishandle(fmri_fig_projection))
        figure(fmri_fig_projection);
        if(~isempty(fmri_pointer_projection_line))
            for i=1:length(fmri_pointer_projection_line)
                if(ishandle(fmri_pointer_projection_line{i}))
                    delete(fmri_pointer_projection_line{i});
                else
                    fmri_pointer_projection_line{i}=[];
                end;
            end;
        end;
        
        fmri_pointer_projection_line{1}=line([fmri_pointer(1),fmri_pointer(1)],[1,size(fmri_under,1)+size(fmri_under,3)]);
        set(fmri_pointer_projection_line{1},'color',[0 1 1]);
        fmri_pointer_projection_line{2}=line([1,size(fmri_under,1)+size(fmri_under,2)],size(fmri_under,3)+1-[fmri_pointer(3),fmri_pointer(3)]);
        set(fmri_pointer_projection_line{2},'color',[0 1 1]);
        fmri_pointer_projection_line{3}=line([1, size(fmri_under,2)],size(fmri_under,3)+[fmri_pointer(2),fmri_pointer(2)]);
        set(fmri_pointer_projection_line{3},'color',[0 1 1]);
        fmri_pointer_projection_line{4}=line(size(fmri_under,2)+[fmri_pointer(2),fmri_pointer(2)],[1, size(fmri_under,3)]);
        set(fmri_pointer_projection_line{4},'color',[0 1 1]);
    else
        fmri_fig_projection=[];
    end;
    
    
    
    if(~isempty(fmri_cluster_box_orig_projection))
        for i=1:length(fmri_cluster_box_orig_projection)
            if(ishandle(fmri_cluster_box_orig_projection{i}))
                delete(fmri_cluster_box_orig_projection{i});
            else
                fmri_cluster_box_orig_projection{i}=[];
            end;
        end;
    end;
    
    
    if(~isempty(fmri_cluster_halfrange))
        fmri_cluster_box_orig_projection{1}=rectangle('position',[fmri_pointer(1)-fmri_cluster_halfrange,size(fmri_under,3)+1-fmri_pointer(3)-fmri_cluster_halfrange,2*fmri_cluster_halfrange,2*fmri_cluster_halfrange]);
        set(fmri_cluster_box_orig_projection{1},'linewidth',1);
        set(fmri_cluster_box_orig_projection{1},'edgecolor',[0 1 1]);
        fmri_cluster_box_orig_projection{2}=rectangle('position',[size(fmri_under,2)+fmri_pointer(2)-fmri_cluster_halfrange,size(fmri_under,3)+1-fmri_pointer(3)-fmri_cluster_halfrange,2*fmri_cluster_halfrange,2*fmri_cluster_halfrange]);
        set(fmri_cluster_box_orig_projection{2},'linewidth',1);
        set(fmri_cluster_box_orig_projection{2},'edgecolor',[0 1 1]);
        fmri_cluster_box_orig_projection{3}=rectangle('position',[fmri_pointer(1)-fmri_cluster_halfrange,size(fmri_under,3)+fmri_pointer(2)-fmri_cluster_halfrange,2*fmri_cluster_halfrange,2*fmri_cluster_halfrange]);
        set(fmri_cluster_box_orig_projection{3},'linewidth',1);
        set(fmri_cluster_box_orig_projection{3},'edgecolor',[0 1 1]);
    end;
end;


if(~isempty(fmri_pointer))
    tmp=inv(fmri_xfm)*[fmri_pointer(:); 1];
    click_vertex_vox=tmp(1:3);
    fprintf('clicked voxel index = (%1.0f %1.0f %1.0f)\n',click_vertex_vox(1),click_vertex_vox(2),click_vertex_vox(3));
else
    click_vertex_vox=[];
end;

if(~isempty(fmri_talxfm)&&~isempty(fmri_pointer)&&~isempty(fmri_under_vol))
    click_vertex_point_mni=fmri_talxfm*fmri_under_vol.vox2ras*[click_vertex_vox(:)' 1].';
    click_vertex_point_mni=click_vertex_point_mni(1:3)';
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    fprintf('clicked voxel MNI305 coordinate = (%1.0f %1.0f %1.0f)\n',click_vertex_point_mni(1),click_vertex_point_mni(2),click_vertex_point_mni(3));
    T_mni2tal = [0.88 0 0 -0.8;0 0.97 0 -3.32; 0 0.05 0.88 -0.44;0 0 0 1];
    click_vertex_point_tal = T_mni2tal * [click_vertex_point_mni(:)' 1]';
    fprintf('clicked voxel Talairach coordinate = (%1.0f %1.0f %1.0f)\n',click_vertex_point_tal(1),click_vertex_point_tal(2),click_vertex_point_tal(3));
else
    click_vertex_point_mni=[];
    click_vertex_point_tal=[];
end;


if(~isempty(click_vertex_vox))
    h=findobj('tag','edit_vox_x');
    set(h,'String',num2str(click_vertex_vox(1),'%1.0f'));
    h=findobj('tag','edit_vox_y');
    set(h,'String',num2str(click_vertex_vox(2),'%1.0f'));
    h=findobj('tag','edit_vox_z');
    set(h,'String',num2str(click_vertex_vox(3),'%1.0f'));
else
    h=findobj('tag','edit_vox_x');
    set(h,'String','');
    h=findobj('tag','edit_vox_y');
    set(h,'String','');
    h=findobj('tag','edit_vox_z');
    set(h,'String','');   
end;


if(~isempty(click_vertex_point_mni))
    h=findobj('tag','edit_mni_x');
    set(h,'String',num2str(click_vertex_point_mni(1),'%1.0f'));
    h=findobj('tag','edit_mni_y');
    set(h,'String',num2str(click_vertex_point_mni(2),'%1.0f'));
    h=findobj('tag','edit_mni_z');
    set(h,'String',num2str(click_vertex_point_mni(3),'%1.0f'));
else
    h=findobj('tag','edit_mni_x');
    set(h,'String','');
    h=findobj('tag','edit_mni_y');
    set(h,'String','');
    h=findobj('tag','edit_mni_z');
    set(h,'String','');   
end;

if(~isempty(click_vertex_point_tal))
    h=findobj('tag','edit_tal_x');
    set(h,'String',num2str(click_vertex_point_tal(1),'%1.0f'));
    h=findobj('tag','edit_tal_y');
    set(h,'String',num2str(click_vertex_point_tal(2),'%1.0f'));
    h=findobj('tag','edit_tal_z');
    set(h,'String',num2str(click_vertex_point_tal(3),'%1.0f'));
else
    h=findobj('tag','edit_tal_x');
    set(h,'String','');
    h=findobj('tag','edit_tal_y');
    set(h,'String','');
    h=findobj('tag','edit_tal_z');
    set(h,'String','');
end;

return;

function draw_timecourse()
global fmri_fig_timeVec;
global fmri_fig_overlay;
global fmri_under_vol;
global fmri_over_vol;
global fmri_talxfm;
global fmri_xfm; %the transformation applied to this program only
global fmri_under;
global fmri_over;
global fmri_over_data;
global fmri_pointer;
global fmri_coords;
global fmri_timeVec;
global fmri_timeVec_line;
global fmri_timeVec_x_idx;
global fmri_cluster_index;

if(~isempty(fmri_fig_timeVec))
    if(isvalid(fmri_fig_timeVec))
        figure(fmri_fig_timeVec);
    else
        fmri_fig_timeVec=figure;
    end;
else
    fmri_fig_timeVec=figure;
end;
set(fmri_fig_timeVec,'name','fmri_fig_timeVec');
pos1=get(fmri_fig_timeVec,'pos');
pos=get(fmri_fig_overlay,'pos');
set(fmri_fig_timeVec,'pos',[pos(1)+pos(3),pos1(2),pos1(3),pos1(4)]);
set(fmri_fig_timeVec,'KeyPressFcn','fmri_overlay_handle(''kb'')');
set(fmri_fig_timeVec,'WindowButtonDownFcn','fmri_overlay_handle(''bd'')');

if(fmri_pointer(2)<=size(fmri_under,1)&fmri_pointer(1)<=size(fmri_under,2)&fmri_pointer(3)<=size(fmri_under,3))
    tmp=sub2ind(size(fmri_under),fmri_pointer(2),fmri_pointer(1),fmri_pointer(3));
    tmp=find(fmri_coords==tmp);
    
    if(isempty(fmri_timeVec))
        if(isempty(fmri_over_data))
            fmri_timeVec=[1:size(fmri_hdr,1)];
        else
            fmri_timeVec=[1:size(fmri_over_data,4)];
        end;
    end;
    
    if(~isempty(fmri_over_data))
        plot(fmri_timeVec,squeeze(fmri_over_data(fmri_pointer(2),fmri_pointer(1),fmri_pointer(3),:))); %hold on;
        
        ymax=max(get(gca,'ylim'));
        ymin=min(get(gca,'ylim'));
        
        try
            delete(fmri_timeVec_line);
        catch
            
        end;
        
        if(~isempty(fmri_timeVec_x_idx))
            fmri_timeVec_line=line([fmri_timeVec(fmri_timeVec_x_idx),fmri_timeVec(fmri_timeVec_x_idx)],[ymax,ymin]); set(fmri_timeVec_line,'color',[1 1 1].*0.5);
        end;
        
        if(~isempty(fmri_cluster_index))
            tmp=reshape(fmri_over_data,[prod(size(fmri_over)), size(fmri_over_data,ndims(fmri_over_data))]);
            fmri_roi_timecourse=squeeze(mean(tmp(fmri_cluster_index,:),1));
            hold on; 
            h=plot(fmri_timeVec,fmri_roi_timecourse); hold off;
            set(h,'color','b');
        end;
        
    else
        if(~isempty(tmp))
            if(~isempty(fmri_hdr))
                plot(fmri_timeVec,fmri_hdr*fmri_beta(1:size(fmri_hdr,2),tmp));
                
                ymax=max(get(gca,'ylim'));
                ymin=min(get(gca,'ylim'));
                
                try
                    delete(fmri_timeVec_line);
                catch
                    
                end;
                
                if(~isempty(fmri_timeVec_x_idx))
                    fmri_timeVec_line=line([fmri_timeVec(fmri_timeVec_x_idx),fmri_timeVec(fmri_timeVec_x_idx)],[ymax,ymin]); set(fmri_timeVec_line,'color',[1 1 1].*0.5);
                end;
            else
                fprintf('no <hdr> variable!\n');
            end;
        end;
    end;
end;
return;
                
function draw_colorbar()


global fmri_overlay_min;
global fmri_overlay_max;
global fmri_colorbar_handle

set(gca,'DataAspectRatioMode','auto');
set(gca,'PlotBoxAspectRatioMode','manual');
set(gca,'PlotBoxAspectRatio',[1 1 1]);
set(gca,'unit','normalized');
pos=get(gca,'pos');

fmri_colorbar_handle=colorbar('peer',gca);
set(fmri_colorbar_handle,'tag','colorbar');
set(fmri_colorbar_handle,'unit','normalized');
set(fmri_colorbar_handle,'pos',[pos(1)+pos(3),pos(2),pos(3)/8,pos(4)]);
set(fmri_colorbar_handle,'color',[0 0 0]);
set(fmri_colorbar_handle,'ycolor',[1,1,1]);
set(fmri_colorbar_handle,'ylim',[128,256]);
set(fmri_colorbar_handle,'ytickmode','manual');
set(fmri_colorbar_handle,'ytick',[130:13:255]);
set(fmri_colorbar_handle,'yaxislocation','right');
set(fmri_colorbar_handle,'yticklabelmode','manual');
s=num2str(reshape([fmri_overlay_min:(fmri_overlay_max-fmri_overlay_min)/9:fmri_overlay_max],[10,1]),'%1.3f');
set(fmri_colorbar_handle,'yticklabel',s);

pos_a=get(gca,'pos');
pos_b=get(fmri_colorbar_handle,'pos');
pos_b(1)=pos_a(1)+pos_a(3);
set(fmri_colorbar_handle,'pos',pos_b);
hh=rectangle('pos',[pos_b(1),pos_b(2),pos_b(3)/2,pos_b(4)]);


return;

function draw_projection()
global fmri_fig_overlay;
global fmri_fig_projection;
global fmri_under;
global fmri_over;
global fmri_op;
global fmri_threshold;
global fmri_pointer;
global fmri_projection_slice;
global fmri_colormap;

fprintf('creating projection...\n');
if(~isempty(fmri_fig_projection))
    if(isvalid(fmri_fig_projection))
        figure(fmri_fig_projection);
    end;
else
    fmri_fig_projection=figure;
end;

if(isvalid(fmri_fig_overlay))
    pos=get(fmri_fig_overlay,'pos');
    pos1=get(fmri_fig_projection,'pos');
    set(fmri_fig_projection,'pos',[pos(1)-pos(3),pos1(2),pos1(3),pos1(4)]);
end;


if(isempty(fmri_pointer)) fmri_pointer=[round(size(fmri_under,2)/2),round(size(fmri_under,1)/2),round(size(fmri_under,3)/2)]; end;

if(fmri_projection_slice)
    uu=[rot90(squeeze(fmri_under(fmri_pointer(2),:,:))),rot90(squeeze(fmri_under(:,fmri_pointer(1),:)));
        squeeze(fmri_under(:,:,fmri_pointer(3))),zeros(size(fmri_under,1),size(fmri_under,1))].*0.8;
    
    oo=[rot90(squeeze(fmri_over(fmri_pointer(2),:,:))),rot90(squeeze(fmri_over(:,fmri_pointer(1),:)));
        squeeze(fmri_over(:,:,fmri_pointer(3))),zeros(size(fmri_over,1),size(fmri_over,1))];
    
else
    uu=[rot90(squeeze(mean(fmri_under,1))),rot90(squeeze(mean(fmri_under,2)));
        squeeze(mean(fmri_under,3)),zeros(size(fmri_under,1),size(fmri_under,1))].*0.8;
    
    oo=[rot90(squeeze(max(fmri_over,[],1))),rot90(squeeze(max(fmri_over,[],2)));
        squeeze(max(fmri_over,[],3)),zeros(size(fmri_over,1),size(fmri_over,1))];
end;

overlay_core(uu,oo,fmri_op,fmri_threshold,fmri_colormap);

if(~isempty(fmri_pointer))
    draw_pointer;
end;

set(fmri_fig_projection,'KeyPressFcn','fmri_overlay_handle(''kb'')');
set(fmri_fig_projection,'name','fmri_fig_projection');
set(fmri_fig_projection,'WindowButtonDownFcn','fmri_overlay_handle(''bd'')');

return;



function overlay_core(img,overlay,idxx,threshold,fmri_colormap,varargin)
if(nargin < 4)
    fprintf('insufficient input arguments!\n');
    fprintf('error!\n');
    eval('help fmri_overlay');
    return;
end

img0=img;
overlay0=overlay;

status=1;
img_depth=128;				%default: 128 gray level underlay
overlay_depth=128;		    %default: 128 color level overlay
colorbar_flag=1;			%default: with color fmri_colorbar_handle

overlay_orig=overlay;

init=1;
datamat_flag=0;
coords=[];
datamat=[];
TR=[];
flag_archive=0;

beta=[];
contrast=[];
fout='';

flag_normalize_under=1;

if(length(varargin)>0)
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        switch lower(option)
            case 'datamat'
                datamat=option_value;
                datamat_flag=1;
            case 'coords'
                coords=option_value;
                fmri_coords=option_value;
            case 'tr'
                TR=option_value;
            case 'beta'
                beta=option_value;
            case 'contrast'
                contrast=option_value;
            case 'flag_normalize_under'
                flag_normalize_under=option_value;
            case 'fout'
                fout=option_value;
            case 'archive'
                flag_archive=option_value;
            case 'colorbar'
                colorbar_flag=option_value;
            case 'init'
                flag_init=option_value;
            case 'ud'
                ud=option_value;
                flag_init=ud.init;
                colorbar_flag=ud.colorbar;
                fout=ud.fout;
                %             beta=ud.beta;
                datamat=ud.datamat;
                coords=ud.coords;
                img=ud.underlay;
                overlay=ud.overlay;
                idxx=ud.idxx;
                threshold=ud.threshold;
                init=ud.init;
                %             TR=ud.TR:
            otherwise
                fprintf('unknown option [%s]\n',option);
                return;
        end;
    end;
end;



%make img a 2D image
if(length(size(img))==3)
    [y,x,z]=size(img);
    [dummy,img]=fmri_mont(reshape(img,[y,x,z]),[],'null');
end;


if(length(size(img))==2)
    [y,x]=size(img);
    z=1;
    [dummy,img]=fmri_mont(reshape(img,[y,x,z]),[],'null');
end;


%make overlay a 2D image
if(length(size(overlay))==3)
    [y,x,z]=size(overlay);
    [dummy,overlay]=fmri_mont(reshape(overlay,[y,x,1,z]),[],'null');
end;


%get information about padded area
extra_y_start=0;
extra_y_end=0;
extra_x_start=0;
extra_x_end=0;
if(length(size(overlay))>2)
    extra_slice=prod(size(overlay))./(y*x)-z;
    if(extra_slice>0)
        extra_y_start=size(overlay,1)-y+1;
        extra_y_end=size(overlay,1);
        extra_x_start=size(overlay,2)-extra_slice*x+1;
        extra_x_end=size(overlay,2);
    end;
end;

nImgRows  = size(img,1);
nImgCols  = size(img,2);
nImgDepth = size(img,3);

nOvRows  = size(overlay,1);
nOvCols  = size(overlay,2);
nOvDepth = size(overlay,3);

if(nImgDepth ~= 1 & nImgDepth ~= nOvDepth)
    msg = sprintf('Overlay (%d) and Underlay (%d) depths differ\n',...
        nImgDepth,nOvDepth);
    disp(msg);
end


img=reshape(img,[nImgRows*nImgCols*nImgDepth,1]);
img_min = min(img);
img_max = max(img);
if(flag_normalize_under)
    img = (img_depth-1) .* (img - img_min)/ (img_max - img_min) + 1; %normalize img between 1 and img_depth
end;

% make overlay and image of the same size %
oo=overlay;
overlay = reshape(imresize(overlay(:,:),[nImgRows nImgCols]),[nImgRows*nImgCols,1]);


% get indices of extra padded area
mx=max(overlay);
if(extra_y_start>0 & extra_x_start>0)
    oo(extra_y_start:extra_y_end,extra_x_start:extra_x_end)=mx+1;
end;
oo = reshape(imresize(oo(:,:),[nImgRows nImgCols]),[nImgRows*nImgCols,1]);
orig_index=find(oo<=mx);
extra_index=find(oo==mx+1);
overlay=overlay(orig_index);
img=img(orig_index);

omin=min(overlay);
omax=max(overlay);

if(idxx=='>')
    fmri_overlay_min=threshold(1);
    if(length(threshold)==1);
        limit=max(max(overlay));
    else
        limit=threshold(2);
    end;
    fmri_overlay_max=limit;
    mode=1;
    if(fmri_overlay_min>omax)
        %disp('minimal threshold exceeds the overlay maximum!');
        %s=sprintf('max of overlay = %f', omax);
        %disp(s);
        status=0;
        %return;
    end;
elseif(idxx=='<')
    fmri_overlay_max=threshold(1);
    if(length(threshold)==1)
        limit=min(min(overlay));
    else
        limit=threshold(2);
    end;
    fmri_overlay_min=limit;
    mode=2;
    if(fmri_overlay_max<omin)
        %disp('maximal threshold below the overlay minimum!');
        %s=sprintf('min of overlay = %f', omin);
        %disp(s);
        status=0;
        %return;
    end;
elseif(idxx=='~')
    fmri_overlay_max=threshold(2);
    fmri_overlay_min=threshold(1);
    mode=3;
    if(fmri_overlay_max>omax|fmri_overlay_min<omin)
        %disp('threshold range exceeds the overlay!');
        %s=sprintf('max of overlay = %f', omax);
        %disp(s);
        %s=sprintf('min of overlay = %f', omin);
        %disp(s);
        status=0;
        %return;
    end;
elseif(idxx=='=')
    fmri_overlay_max=threshold(1);
    fmri_overlay_min=threshold(1);
    mode=4;
    if(fmri_overlay_max>omax|fmri_overlay_min<omin)
        disp('threshold range exceeds the overlay!');
        s=sprintf('max of overlay = %f', omax);
        disp(s);
        s=sprintf('min of overlay = %f', omin);
        disp(s);
        status=0;
        %return;
    end;
else
    disp('invalid display mode!');
    return;
end;

% Construct the Colormap %
cmap(1:img_depth,:) =gray(img_depth);

% thresholding %
switch mode
    case 1,
        overlay(find(overlay>fmri_overlay_max))=fmri_overlay_max;
        
        idx_scale=find(overlay>=(fmri_overlay_min+eps));
        idx_replace=find(overlay<fmri_overlay_min);
        
        overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - fmri_overlay_min)/ (fmri_overlay_max-fmri_overlay_min) + (img_depth+1);
        
        flag_normalize_under=0;
        if(flag_normalize_under)
            overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth-1,0);
        else
            overlay(idx_replace)=img(idx_replace);
        end;
        
        overlay_map=fmri_colormap;
        
        cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
        
    case 2,
        overlay(find(overlay<fmri_overlay_min))=fmri_overlay_min;
        
        idx_scale=find(overlay<=fmri_overlay_max);
        idx_replace=find(overlay>(fmri_overlay_max-eps));
        [fmri_overlay_max,index]=max(overlay(idx_scale));
        
        overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - fmri_overlay_min)/ (fmri_overlay_max-fmri_overlay_min) + (img_depth+1);
        
        overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
        
        overlay_map=fmri_colormap;
        
        cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
    case 3,
        idx_scale=find((overlay<=fmri_overlay_max)&(overlay>=fmri_overlay_min));
        idx_replace=find((overlay>fmri_overlay_max)|(overlay<fmri_overlay_min));
        
        overlay(find(overlay<fmri_overlay_min))=fmri_overlay_min;
        overlay(find(overlay>fmri_overlay_max))=fmri_overlay_max;
        
        [fmri_overlay_max,index]=max(overlay(idx_scale));
        [fmri_overlay_min,index]=min(overlay(idx_scale));
        
        overlay(idx_scale)=  (overlay_depth-1) * (overlay(idx_scale) - fmri_overlay_min)/ (fmri_overlay_max-fmri_overlay_min) + (img_depth+1);
        
        overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
        
        overlay_map=fmri_colormap;
        
        cmap(img_depth+1:img_depth+overlay_depth,:) = overlay_map(1:overlay_depth,:);
    case 4,
        
        idx_scale=find((overlay==fmri_overlay_max));
        idx_replace=find((overlay~=fmri_overlay_max));
        
        overlay(idx_scale)=  overlay_depth  + img_depth;
        
        overlay(idx_replace)=fmri_scale(img(idx_replace),img_depth,1);
        
        cmap(img_depth+1:img_depth+overlay_depth,:) = repmat([1 1 0],[overlay_depth,1]); %yellow as index
        
        colorbar_flag=0;
end;
oo=zeros(nImgRows*nImgCols,1);
oo(orig_index)=overlay;
oo(extra_index)=1;


%% Compress the range of the overlays %%
imgov(:,:) = reshape(oo,[nImgRows nImgCols]);


%set extra padded area to black
if(extra_y_start>0 & extra_x_start>0)
    imgov(extra_y_start:extra_y_end,extra_x_start:extra_x_end)=1;
end;

% set bk to black
m=imgov(2,2);
idx=find(imgov==m);
imgov(idx)=min(min(imgov));

%paste the overlay and underlay
h=fmri_mont(imgov);

%apply the palette
colormap(cmap);

%setup figure
set(gca,'color',[1,1,1]);
set(gcf,'color',[0,0,0]);
if(colorbar_flag)
    set(gca,'DataAspectRatioMode','auto');
    set(gca,'PlotBoxAspectRatioMode','manual');
    set(gca,'PlotBoxAspectRatio',[1 1 1]);
    set(gca,'unit','normalized');
    pos=get(gca,'pos');
    
    fmri_colorbar_handle=colorbar('peer',gca);
    set(fmri_colorbar_handle,'tag','colorbar');
    set(fmri_colorbar_handle,'unit','normalized');
    set(fmri_colorbar_handle,'pos',[pos(1)+pos(3),pos(2),pos(3)/8,pos(4)]);
    set(fmri_colorbar_handle,'color',[0 0 0]);
    set(fmri_colorbar_handle,'ycolor',[1,1,1]);
    set(fmri_colorbar_handle,'ylim',[128,256]);
    set(fmri_colorbar_handle,'ytickmode','manual');
    set(fmri_colorbar_handle,'ytick',[130:13:255]);
    set(fmri_colorbar_handle,'yaxislocation','right');
    set(fmri_colorbar_handle,'yticklabelmode','manual');
    s=num2str(reshape([fmri_overlay_min:(fmri_overlay_max-fmri_overlay_min)/9:fmri_overlay_max],[10,1]),'%1.2f');
    set(fmri_colorbar_handle,'yticklabel',s);
    
    pos_a=get(gca,'pos');
    pos_b=get(fmri_colorbar_handle,'pos');
    pos_b(1)=pos_a(1)+pos_a(3);
    set(fmri_colorbar_handle,'pos',pos_b);
    hh=rectangle('pos',[pos_b(1),pos_b(2),pos_b(3)/2,pos_b(4)]);
else
    fmri_colorbar_handle=[];
end;
datamat_select_idx=[];
varargout{1}=gca;



if(flag_archive)
    if(~isempty(fout))
        fprintf('saving [%s]...\n',fout);
        imwrite(imgov,cmap,fout,'tiff');
    else
        fprintf('saving [fmri_overlay.tiff]...\n');
        imwrite(imgov,cmap,'fmri_overlay.tiff','tiff');
    end;
end;

return;

