function fmri_overlay_handle(param)
ud=get(gcf,'userdata');
cc=get(ud.fig_overlay,'currentchar');

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
	case 'r'
		fprintf('re-orienting...\n');
		ud.overlay=shiftdim(ud.overlay,1);
		ud.underlay=shiftdim(ud.underlay,1);
        redraw(ud);

    case 'l'
        fprintf('flipping left-right...')
        for i=1:size(ud.overlay,3)
            ud.overlay(:,:,i)=fliplr(ud.overlay(:,:,i));
            ud.underlay(:,:,i)=fliplr(ud.underlay(:,:,i));
        end;
        redraw(ud);
    case 't'
        fprintf('rotating 90...')
        for i=1:size(ud.overlay,3)
            overlay(:,:,i)=rot90(ud.overlay(:,:,i));
            underlay(:,:,i)=rot90(ud.underlay(:,:,i));
        end;
        ud.overlay=overlay;
        ud.underlay=underlay;
        redraw(ud);
    case 'u'
        fprintf('flipping up-down...')
        for i=1:size(ud.overlay,3)
            ud.overlay(:,:,i)=flipud(ud.overlay(:,:,i));
            ud.underlay(:,:,i)=flipud(ud.underlay(:,:,i));
        end;
        redraw(ud);
    case 'p'
        fprintf('projection plots...\n');
        fmri_overlay_handle('proj');
    case 's'
        fprintf('sharpening overlay...\n');
        overlay=ud.overlay;
        mx=max(max(max(overlay)));
        mn=min(min(min(overlay)));
        ud.overlay=fmri_scale((ud.overlay).^1.2,mx,mn);
        redraw(ud);
	otherwise
		fprintf('pressed [%c]!\n',cc);
	end;
case 'bd'
	pp=get(gca,'currentpoint');
	xx=round(pp(1,1));
	yy=round(pp(1,2));
	ud.flag=1;
	ud.xx=xx;
	ud.yy=yy;



	total_slice_x=size(ud.imgov,2)/ud.x;
	total_slice_y=size(ud.imgov,1)/ud.y;
		
	sx=ceil(xx/ud.x);
	sy=ceil(yy/ud.y);
		
	zz=(sy-1)*total_slice_x+sx;
	xx=xx-(sx-1)*ud.x;
	yy=yy-(sy-1)*ud.y;
	
	idx=[];
	if(zz>ud.z)
		fprintf('slice not existed in the original data!\n');
	else
		if(~isempty(ud.coords))
			idx=fmri_coord(ud.coords,ud.x,ud.y,ud.z,1,[xx,yy,zz]);
			select_value=ud.overlay_orig(yy,xx,zz);
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
	set(ud.fig_overlay,'userdata',ud);
    if(exist('ud.fig_profile'))
    	set(ud.fig_profile,'userdata',ud);
    end;
    if(exist('ud.fig_project'));
        set(ud.fig_project,'userdata',ud);
    end;
case 'proj'
    fprintf('inside proj!\n');
    if(ud.fig_project>0)
        figure(ud.fig_project);
    else
        ud.fig_project=figure;
    end;

    under=ud.underlay;
    over=ud.overlay;
    
    for i=1:ndims(under)
        under_proj{i}=squeeze(mean(under,i));
        over_proj{i}=squeeze(max(over,[],i));
        subplot(sprintf('22%d',i));
        fmri_overlay(under_proj{i},over_proj{i},ud.idxx,ud.threshold);
    end;
    
    set(ud.fig_overlay,'userdata',ud);
    
    if(exist('ud.fig_profile'))
    	set(ud.fig_profile,'userdata',ud);
    end;
    if(exist('ud.fig_project'));
        set(ud.fig_project,'userdata',ud);
    end;
    
end;

return;

function redraw(ud)
str=sprintf('fmri_overlay(ud.underlay,ud.overlay,ud.idxx,ud.threshold');
if(isempty(ud.varargin))
    str=strcat(str,');');
else
    for i=1:length(ud.varargin)./2
        str=strcat(str,sprintf(',''%s''',ud.varargin{i}));
        str=strcat(str,sprintf(',ud.varargin{%d}',i*2));
    end;
    str=strcat(str,');');
end;
eval(str);

return;


