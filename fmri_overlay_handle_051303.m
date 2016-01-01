function fmri_overlay_handle(param)

global fmri_under;
global fmri_over;
global fmri_op;
global fmri_threshold;
global fmri_pointer;
global fmri_pointer_handle;
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection
global fmri_datamat;
global fmri_coords;
global fmri_orig;
global fmri_orig_handle;
global fmri_vox;
global fmri_colorbar_handle;

cc=get(gcf,'currentchar');

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
        fprintf('+: increase threshold by 10%\n');
        fprintf('-: decrease threshold by 10%\n');
        fprintf('d: interactive threshold change\n');
        fprintf('c: switch on/off the colorbar\n');
        fprintf('\n\n fhlin@jun 24, 2002\n');
        
    case 'a'
        fprintf('archiving...\n');
        cmap=get(gcf,'colormap');
        h=get(gcf,'children');
        h=get(h(1),'children');
        im=get(h(2),'cdata');
        fn=sprintf('fmri_overlay.tif');
        fprintf('saving [%s]...\n',fn);
        imwrite(im,cmap,fn,'tiff');
    case 'q'
        fprintf('\nterminating graph!\n');
        
        close_all;
        
    case 'r'
        fprintf('re-orienting...\n');
        fmri_over=shiftdim(fmri_over,1);
        fmri_under=shiftdim(fmri_under,1);
        
        if(~isempty(fmri_vox))
            fmri_vox=[fmri_vox(end), fmri_vox(1), fmri_vox(2)];
        end;
        
        if(~isempty(fmri_pointer))
			fmri_pointer=[fmri_pointer(end), fmri_pointer(1), fmri_pointer(2)];
        end;

        if(~isempty(fmri_orig))
            fmri_orig=[fmri_orig(end), fmri_orig(1), fmri_orig(2)];
        end;

        redraw_all;
    case 'l'
        fprintf('flipping left-right...\n')

        if(~isempty(fmri_pointer))
			fmri_pointer=[size(fmri_under,2)+1-fmri_pointer(1),fmri_pointer(2),fmri_pointer(end)];
        end;

        if(~isempty(fmri_orig))
            fmri_orig=[size(fmri_under,2)+1-fmri_orig(1),fmri_orig(2),fmri_orig(end)];
        end;


		o=zeros(size(fmri_over,2),size(fmri_over,1),size(fmri_over,3));
		for i=1:size(fmri_over,3)
			o(:,:,i)=fliplr(fmri_over(:,:,i));
		end;
		fmri_over=o;
		clear o;

		u=zeros(size(fmri_under,2),size(fmri_under,1),size(fmri_under,3));
		for i=1:size(fmri_under,3)
			u(:,:,i)=fliplr(fmri_under(:,:,i));
		end;
		fmri_under=u;
		clear u;

        redraw_all;
        
    case 't'
        fprintf('rotating 90...\n')

        if(~isempty(fmri_vox))
            fmri_vox=[fmri_vox(2), fmri_vox(1), fmri_vox(3)];
        end;
        
        if(~isempty(fmri_pointer))
			fmri_pointer=[fmri_pointer(2),size(fmri_under,2)+1-fmri_pointer(1), fmri_pointer(end)];
        end;

        if(~isempty(fmri_orig))
            fmri_orig=[fmri_orig(2),size(fmri_under,2)+1-fmri_orig(1), fmri_orig(end)];
        end;


		o=zeros(size(fmri_over,2),size(fmri_over,1),size(fmri_over,3));
		for i=1:size(fmri_over,3)
			o(:,:,i)=rot90(fmri_over(:,:,i));
		end;
		fmri_over=o;
		clear o;

		u=zeros(size(fmri_under,2),size(fmri_under,1),size(fmri_under,3));
		for i=1:size(fmri_under,3)
			u(:,:,i)=rot90(fmri_under(:,:,i));
		end;
		fmri_under=u;
		clear u;

        redraw_all;

    case 'u'
        fprintf('flipping up-down...\n')
        
      
        if(~isempty(fmri_pointer))
			fmri_pointer=[fmri_pointer(1),size(fmri_under,1)+1-fmri_pointer(2),fmri_pointer(end)];
        end;

        if(~isempty(fmri_orig))
            fmri_orig=[fmri_pointer(1),size(fmri_under,1)+1-fmri_orig(2),fmri_orig(end)];
        end;


		o=zeros(size(fmri_over,2),size(fmri_over,1),size(fmri_over,3));
		for i=1:size(fmri_over,3)
			o(:,:,i)=flipud(fmri_over(:,:,i));
		end;
		fmri_over=o;
		clear o;

		u=zeros(size(fmri_under,2),size(fmri_under,1),size(fmri_under,3));
		for i=1:size(fmri_under,3)
			u(:,:,i)=flipud(fmri_under(:,:,i));
		end;
		fmri_under=u;
		clear u;

        redraw_all;
        
    case 'p'
        fprintf('projection plots...\n');
        fmri_overlay_handle('proj');

    case 's'
        fprintf('sharpening overlay...\n');
        overlay=fmri_over;
        mx=max(max(max(overlay)));
        mn=min(min(min(overlay)));
        fmri_over=fmri_scale((fmri_over).^1.1,mx,mn);

        redraw_all;
        
    case '+'
        fprintf('increasing threshold...\n');
        fprintf('current threshold = %s\n',mat2str(fmri_threshold));
        fmri_threshold=fmri_threshold.*1.1;
        fprintf('updated threshold = %s\n',mat2str(fmri_threshold));

        redraw_all;
    case '-'
        fprintf('decreasing threshold...\n');
        fprintf('current threshold = %s\n',mat2str(fmri_threshold));
      	fmri_threshold=fmri_threshold.*0.9;
        fprintf('updated threshold = %s\n',mat2str(fmri_threshold));
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
    otherwise
        %fprintf('pressed [%c]!\n',cc);
    end;
case 'bd'
    fprintf('buttom down...\n');
    if(gcf==fmri_fig_overlay) %clicking on overlay figure
        pp=get(gca,'currentpoint');
        xx=round(pp(1,1));
        yy=round(pp(1,2));
        
        fmri_pointer=etc_coords_convert([xx,yy],[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
        
        draw_pointer;
        
        idx=[];
        if(fmri_pointer(3)>size(fmri_under,3))
            fprintf('slice not existed in the original data!\n');
        else
            if(~isempty(fmri_vox))
                fprintf('selected matrix: %s, coordinate: %s\n',mat2str(fmri_pointer),mat2str(fmri_pointer.*fmri_vox));
            else
                fprintf('selected matrix: %s\n',mat2str(fmri_pointer));
            end;
            fprintf('selected overlay value = %4.4f\n',fmri_over(fmri_pointer(2),fmri_pointer(1),fmri_pointer(3)));
        end;
        
        %         if((~isempty(idx))&(~isempty(ud.datamat)))
        %             if(ud.fig_profile>0)
        %                 figure(ud.fig_profile);
        %             else
        %                 ud.fig_profile=figure;
        %                 pos=get(ud.fig_overlay,'position');
        %                 posnew=[pos(1),pos(2)-200,pos(3),200];
        %                 set(ud.fig_profile,'position',posnew);
        % 				broadcast(ud,'fig_profile',ud.fig_profile);
        %             end;
        %             
        %             %get the selected index (in datamat)	
        %             ud.select_pixel=ud.select_pixel+1;
        %             ud.datamat_select_idx(ud.select_pixel)=idx;
        %             ud.datamat_select_idx_value(ud.select_pixel)=select_value;
        %             
        %             if(~isempty(ud.datamat))
        %                 %draw the temporal profile
        %                 xx=[1:size(ud.datamat,1)];
        %                 if(~isempty(ud.TR))
        %                     xx=xx.*(ud.TR);
        %                 end;
        %                 figure(ud.fig_profile);
        %                 xlim=get(get(ud.fig_profile,'children'),'xlim');
        %                 if(~isempty(ud.datamat'))
        %                     if(ndims(ud.datamat)==2)
        %                         plot(xx,ud.datamat(:,idx));
        %                     else
        %                         plot(xx,ud.datamat(:,idx,1),'b',xx,ud.datamat(:,idx,2),'r');
        %                     end;
        %                 end;
        %                 
        %                 if(~isempty(xlim)) set(get(ud.fig_profile,'children'),'xlim',xlim); end;
        %                 
        %                 if(isempty(ud.TR))
        %                     xlabel('scan');
        %                 else
        %                     xlabel('sec');
        %                 end;
        %                 title('time course');
        %             end;
        %         end;
        
        fprintf('\n');
    end;
    
case 'proj'
    fprintf('creating projection...\n');
    
    %     if(strcmp(ud.window_id,'overlay'))
    %         if(ud.fig_project>0)
    %             figure(ud.fig_project);
    %             return;
    %         end;
    %         
    %         ud.fig_project=figure;
    %         
    %         under=ud.underlay;
    %         over=ud.overlay;
    %         
    %         figure(ud.fig_project);
    %         for i=1:ndims(under)
    %             under_proj{i}=squeeze(mean(under,i));
    %             over_proj{i}=squeeze(max(over,[],i));
    %             ud.proj_axis(i)=subplot(sprintf('22%d',i));
    %             ud.colorbar=0;    
    %         end;
    %         
    %         %set window_overlay data
    %         figure(ud.fig_overlay);
    %         set(ud.fig_overlay,'userdata',ud);
    %         set(gca,'userdata',ud);
    %         
    %         %set window_project data
    %         figure(ud.fig_project);
    %         for i=1:ndims(under)
    %             ud.window_id='proj';
    %             ud.overlay=over_proj{i};
    %             ud.underlay=under_proj{i};
    %             ud.colorbar=0;
    %             set(ud.proj_axis(i),'userdata',ud);
    %             
    %             axis(ud.proj_axis(i));
    %             redraw;
    %         end;
    %         
    %     else
    %         fprintf('not overlay window; no projection!\n');
    %     end;
end;

return;


function close_all()
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection;
global fmri_pointer_handle;
global fmri_orig_handle;
global fmri_colorbar_handle;

if(~isempty(fmri_fig_profile))
    close(fmri_fig_profile);
    fmri_fig_profile=[];
end;
if(~isempty(fmri_fig_overlay))
    close(fmri_fig_overlay);
    fmri_fig_overlay=[];
end;
if(~isempty(fmri_fig_projection))
    close(fmri_fig_projection);
    fmri_fig_projection=[];
end;
if(~isempty(fmri_colorbar_handle))
    fmri_colorbar_handle=[];
end;
fmri_pointer_handle=[];
fmri_orig_handle=[];
return;


function redraw_all()
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection;
global fmri_pointer_handle;
global fmri_under;
global fmri_over;
global fmri_op;
global fmri_threshold;
global fmri_colorbar_handle;

if(~isempty(fmri_fig_overlay))
    flag_overlay=1;
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

if(~isempty(fmri_colorbar_handle))
    flag_colorbar_handle=1;
else
    flag_colorbar_handle=0;
end;

close_all;    
fmri_overlay(fmri_under,fmri_over,fmri_op,fmri_threshold);

if(flag_profile)
    draw_profile;
end;
if(flag_projection)
    draw_projection;
end;
if(flag_pointer_handle)
    draw_pointer;
end;

if(flag_colorbar_handle)
    draw_colorbar;
end;

return;     


function draw_pointer()
global fmri_pointer;
global fmri_fig_overlay;
global fmri_fig_profile;
global fmri_fig_projection;
global fmri_pointer_handle;
global fmri_under;

if(~isempty(fmri_pointer_handle))
    delete(fmri_pointer_handle);
    fmri_pointer_handle=[];
end;

if(~isempty(fmri_fig_overlay))
    figure(fmri_fig_overlay);
    output=etc_coords_convert(fmri_pointer,[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
    fmri_pointer_handle=text(output(1),output(2),'+');
    set(fmri_pointer_handle,'verticalalignment','middle');
    set(fmri_pointer_handle,'horizontalalignment','center');
    set(fmri_pointer_handle,'color',[0 1 1]);
    
end;

if(~isempty(fmri_fig_projection))
    figure(fmri_fig_projection);
    output=etc_coords_convert(fmri_pointer,[size(fmri_under,2),size(fmri_under,1),size(fmri_under,3)],'flag_display',0);
    
    fprintf('under construction...\n');
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



