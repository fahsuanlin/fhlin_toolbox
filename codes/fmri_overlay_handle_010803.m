function fmri_overlay_handle(param)
ud=get(gca,'userdata');
%cc=get(ud.fig_overlay,'currentchar');
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
        cmap=get(ud.fig_overlay,'colormap');
        h=get(ud.fig_overlay,'children');
        h=get(h(1),'children');
        im=get(h(2),'cdata');
        if(isempty(ud.fout));
            fn=sprintf('fmri_overlay.tif');
        else
            fn=ud.fout;
        end;
        fprintf('saving [%s]...\n',fn);
        imwrite(im,cmap,fn,'tiff');
    case 'q'
        fprintf('\nterminating graph!\n');
        
        if(ud.fig_profile>0)
            close(ud.fig_profile);
        end;
        if(ud.fig_overlay>0)
            close(ud.fig_overlay);
        end;
        if(ud.fig_project>0);
            close(ud.fig_project);
        end;
    case 'r'
        fprintf('re-orienting...\n');
        ud.overlay=shiftdim(ud.overlay,1);
        ud.underlay=shiftdim(ud.underlay,1);
        
        set(gca,'userdata',ud);
        redraw;
        
    case 'l'
        fprintf('flipping left-right...\n')
        for i=1:size(ud.overlay,3)
            ud.overlay(:,:,i)=fliplr(ud.overlay(:,:,i));
            ud.underlay(:,:,i)=fliplr(ud.underlay(:,:,i));
        end;
        
        set(gca,'userdata',ud);
        redraw;
        
    case 't'
        fprintf('rotating 90...\n')
        for i=1:size(ud.overlay,3)
            overlay(:,:,i)=rot90(ud.overlay(:,:,i));
            underlay(:,:,i)=rot90(ud.underlay(:,:,i));
        end;
        ud=setfield(ud,'overlay',overlay);
        ud=setfield(ud,'underlay',underlay);
        set(gca,'userdata',ud);
        redraw;
    case 'u'
        fprintf('flipping up-down...\n')
        for i=1:size(ud.overlay,3)
            ud.overlay(:,:,i)=flipud(ud.overlay(:,:,i));
            ud.underlay(:,:,i)=flipud(ud.underlay(:,:,i));
        end;
        set(gca,'userdata',ud);
        redraw;
    case 'p'
        fprintf('projection plots...\n');
        fmri_overlay_handle('proj');
    case 's'
        fprintf('sharpening overlay...\n');
        overlay=ud.overlay;
        mx=max(max(max(overlay)));
        mn=min(min(min(overlay)));
        ud.overlay=fmri_scale((ud.overlay).^1.2,mx,mn);
        
        set(gca,'userdata',ud);
        redraw;
        
    case '+'
        fprintf('increasing threshold...\n');
        fprintf('current threshold = %s\n',mat2str(ud.threshold));
        ud.threshold=ud.threshold.*1.1;
        broadcast(ud,'threshold',ud.threshold);
        fprintf('updated threshold = %s\n',mat2str(ud.threshold));
        redraw_all(ud);
    case '-'
        fprintf('decreasing threshold...\n');
        fprintf('current threshold = %s\n',mat2str(ud.threshold));
        ud.threshold=ud.threshold.*0.9;
        broadcast(ud,'threshold',ud.threshold);
        fprintf('updated threshold = %s\n',mat2str(ud.threshold));
        redraw_all(ud);
    case 'd'
        fprintf('change threshold...\n');
        fprintf('current threshold = %s\n',mat2str(ud.threshold));
        def={num2str(ud.threshold)};
        answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(ud.threshold)),1,def);
        if(~isempty(answer))
            ud.threshold=str2num(answer{1});
            broadcast(ud,'threshold',ud.threshold);
            fprintf('updated threshold = %s\n',mat2str(ud.threshold));
            redraw_all(ud);
        end;
    case 'c'
        if(ud.colorbar)
            fprintf('turning off colorbar\n');
            ud.colorbar=0;
            redraw(ud);
        else
            fprintf('turning on colorbar\n');
            ud.colorbar=1;
            redraw(ud);
        end;
    otherwise
        %fprintf('pressed [%c]!\n',cc);
    end;
case 'bd'
    if(strcmp(ud.window_id,'overlay'))
        pp=get(gca,'currentpoint');
        xx=round(pp(1,1));
        yy=round(pp(1,2));
        ud.flag=1;
        ud.xx=xx;
        ud.yy=yy;
        
        
        
        ud.pointer=etc_coords_convert([yy,xx],[ud.x,ud.y,ud.z],'flag_display',0);
        
        
        %         ud.window_id='overlay';
        %         set(ud.fig_overlay,'userdata',ud);
        %         set(gca,'userdata',ud);
        
        
        broadcast(ud,'pointer',ud.pointer);
        redraw_all(ud);
        
        idx=[];
        if(ud.pointer(3)>ud.z)
            fprintf('slice not existed in the original data!\n');
        else
            if(~isempty(ud.coords))
                idx=fmri_coord(ud.coords,ud.x,ud.y,ud.z,1,ud.pointer);
                select_value=ud.overlay_orig(ud.pointer(2),ud.pointer(1),ud.pointer(3));
                fprintf('selected value=[%3.3f]\n\n',select_value);
            else
                fprintf('no ''coords'' parameter. skip pointer. \n');
            end;
        end;
      
        if((~isempty(idx))&(~isempty(ud.datamat)))
            if(ud.fig_profile>0)
                figure(ud.fig_profile);
            else
                ud.fig_profile=figure;
                pos=get(ud.fig_overlay,'position');
                posnew=[pos(1),pos(2)-200,pos(3),200];
                set(ud.fig_profile,'position',posnew);
				broadcast(ud,'fig_profile',ud.fig_profile);
            end;
            
            %get the selected index (in datamat)	
            ud.select_pixel=ud.select_pixel+1;
            ud.datamat_select_idx(ud.select_pixel)=idx;
            ud.datamat_select_idx_value(ud.select_pixel)=select_value;
            
            if(~isempty(ud.datamat))
                %draw the temporal profile
                xx=[1:size(ud.datamat,1)];
                if(~isempty(ud.TR))
                    xx=xx.*(ud.TR);
                end;
                figure(ud.fig_profile);
                xlim=get(get(ud.fig_profile,'children'),'xlim');
                if(~isempty(ud.datamat'))
                    if(ndims(ud.datamat)==2)
                        plot(xx,ud.datamat(:,idx));
                    else
                        plot(xx,ud.datamat(:,idx,1),'b',xx,ud.datamat(:,idx,2),'r');
                    end;
                end;
                
                if(~isempty(xlim)) set(get(ud.fig_profile,'children'),'xlim',xlim); end;
                
                if(isempty(ud.TR))
                    xlabel('scan');
                else
                    xlabel('sec');
                end;
                title('time course');
            end;
        end;
        
        
    end;
    
case 'proj'
    if(strcmp(ud.window_id,'overlay'))
        if(ud.fig_project>0)
            figure(ud.fig_project);
            return;
        end;
        
        ud.fig_project=figure;
        
        under=ud.underlay;
        over=ud.overlay;
        
        figure(ud.fig_project);
        for i=1:ndims(under)
            under_proj{i}=squeeze(mean(under,i));
            over_proj{i}=squeeze(max(over,[],i));
            ud.proj_axis(i)=subplot(sprintf('22%d',i));
            ud.colorbar=0;    
        end;
        
        %set window_overlay data
        figure(ud.fig_overlay);
        set(ud.fig_overlay,'userdata',ud);
        set(gca,'userdata',ud);
        
        %set window_project data
        figure(ud.fig_project);
        for i=1:ndims(under)
            ud.window_id='proj';
            ud.overlay=over_proj{i};
            ud.underlay=under_proj{i};
            ud.colorbar=0;
            set(ud.proj_axis(i),'userdata',ud);
            
            axis(ud.proj_axis(i));
            redraw;
        end;
        
    else
        fprintf('not overlay window; no projection!\n');
    end;
end;

return;

function redraw(varargin)
if(nargin==1)
    ud=varargin{1};
    ud.init=0;
    
    ud_now=get(gca,'userdata');
    if(~isempty(ud_now.pointer_mark))
        delete(ud_now.pointer_mark);
        ud_now=setfield(ud_now,'pointer_mark',[]);
        set(gca,'userdata',ud_now);
    end;
    ud.pointer_mark=[];
    
    
    fmri_overlay(ud.underlay,ud.overlay,ud.idxx,ud.threshold,'ud',ud);
    set(gca,'userdata',ud);
    draw_pointer(ud)
else
    
    ud_now=get(gca,'userdata');
    ud_now.init=0;
    if(~isempty(ud_now.pointer_mark))
        delete(ud_now.pointer_mark);
        ud_now=setfield(ud_now,'pointer_mark',[]);
    end;
    
    
    fmri_overlay(ud_now.underlay,ud_now.overlay,ud_now.idxx,ud_now.threshold,'ud',ud_now);
    draw_pointer(ud_now);
    
    set(gca,'userdata',ud_now);
    
end;


return;     


function redraw_all(ud)
if((ud.fig_overlay >0)&(ishandle(ud.fig_overlay)))
    figure(ud.fig_overlay);
    redraw;
else
    ud.fig_overlay=0;
    set(gca,'userdata',ud);
end;

if((ud.fig_project>0)&(ishandle(ud.fig_project))&(prod(ishandle(ud.proj_axis))>0))
    figure(ud.fig_project);
    for i=1:3
        axes(ud.proj_axis(i));
        redraw;
    end;
else
    ud.proj_axis=[];
    ud.fig_project=0;
    set(gca,'userdata',ud);
end;
if(ud.fig_profile>0)
    figure(ud.fig_profile);
    redraw;
end;
return;

function broadcast(ud,ud_name,ud_value)
if((ud.fig_overlay >0)&ishandle(ud.fig_overlay))
    figure(ud.fig_overlay);
    userdata=get(gca,'userdata');
    userdata=setfield(userdata,ud_name,ud_value)
    set(gca,'userdata',userdata);
else
    ud.fig_overlay=0;

    set(gca,'userdata',ud);
end;

if((ud.fig_project>0)&(ishandle(ud.fig_project)))
    figure(ud.fig_project);
    
    if(prod(ishandle(ud.proj_axis)))
        for i=1:3
            axes(ud.proj_axis(i));
            userdata=get(gca,'userdata');
            userdata=setfield(userdata,ud_name,ud_value);
            set(gca,'userdata',userdata);
            
        end;
    else
        ud.proj_axis=[];
    end;
else
    ud.fig_project=0;
    ud.proj_axis=[];
    
    set(gca,'userdata',ud);
end;

if((ud.fig_profile>0)&(ishandle(ud.fig_profile)))
    figure(ud.fig_profile);
    userdata=get(gca,'userdata');
    userdata=setfield(userdata,ud_name,ud_value);
    set(gca,'userdata',userdata);
else
    ud.fig_profile=0;
    
    set(gca,'userdata',ud);
end;


function draw_pointer(ud)
if(~isempty(ud.pointer))
    if(strcmp(ud.window_id,'overlay'))
        figure(ud.fig_overlay);
        output=etc_coords_convert(ud.pointer,[ud.x,ud.y,ud.z]);
        h=text(output(2),output(1),'+');
        set(h,'verticalalignment','middle');
        set(h,'horizontalalignment','center');
        set(h,'color',[0 1 1]);
        
        ud=setfield(ud,'pointer_mark',h);
        set(gca,'userdata',ud);
        fprintf('%s\n',ud.window_id);
    end;
    
    if(strcmp(ud.window_id,'proj'))
        figure(ud.fig_project)
        i=find(ud.proj_axis==gca)
        
        axes(ud.proj_axis(i));
        cc=ud.pointer;
        
        if(i==1|i==2)
            h=text(cc(2),cc(1),'+');
        else
            h=text(cc(1),cc(2),'+');
        end;
        set(h,'verticalalignment','middle');
        set(h,'horizontalalignment','center');
        set(h,'color',[0 1 1]);
        
        
        ud=setfield(ud,'pointer_mark',h);
        set(gca,'userdata',ud);
        fprintf('%s\n',ud.window_id);
        
    end;
end;
return;



