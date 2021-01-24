function inverse_render_bem_handle(param)

global inverse_threshold;
global inverse_colorbar_handle;
global inverse_pointer_handle;


cc=get(gcf,'currentchar');

switch lower(param)
case 'kb'
    switch(cc)
    case 'h'
        fprintf('inverse rendering information:\n\n');
        fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
        fprintf('q: exit fmri_overlay\n');
        fprintf('s: sharpen overlay \n');
        fprintf('+: increase threshold by 10%\n');
        fprintf('-: decrease threshold by 10%\n');
        fprintf('d: interactive threshold change\n');
        fprintf('c: switch on/off the colorbar\n');
        fprintf('\n\n fhlin@mar 6, 2004\n');
        
    case 'a'
        %         fprintf('archiving...\n');
        %         cmap=get(gcf,'colormap');
        %         h=get(gcf,'children');
        %         h=get(h(1),'children');
        %         im=get(h(2),'cdata');
        %         fn=sprintf('inverse_render.tif');
        %         fprintf('saving [%s]...\n',fn);
        %         imwrite(im,cmap,fn,'tiff');
    case 'f'
        global inverse_bem_all_channel_fig;
        global inverse_bem_Y;
        global inverse_bem_timeVec;
        
        if(size(inverse_bem_Y,2)>1)
		if(~isempty(inverse_bem_Y)) %we have meg data?
            if(isempty(inverse_bem_all_channel_fig))
                inverse_bem_all_channel_fig=figure;
            else
                figure(inverse_bem_all_channel_fig);
            end;
            if(~isempty(inverse_bem_timeVec))
                plotEF(inverse_bem_timeVec,inverse_bem_Y);
            else
                plotEF([1:size(inverse_bem_Y,2)],inverse_bem_Y);
            end;
        	end;
	end;
    case 'g'        
    	global inverse_bem_coil_offset;

	inverse_bem_coil_offset=mod(inverse_bem_coil_offset+1,3);
	switch inverse_bem_coil_offset
	case 0
		fprintf('Magnetometers...\n');
	case 1
		fprintf('Gradiometer 1...\n');
	case 2 
		fprintf('Gradiometer 2...\n');
	end;

        draw_topo;

    case 'v'        
    	global inverse_bem_sensor;
    	
    	if(strcmp(get(inverse_bem_sensor,'visible'),'on'))
	    	set(inverse_bem_sensor,'visible','off');
	else
		set(inverse_bem_sensor,'visible','on');
	end;
	    	
    case 's'
        
        global inverse_bem_face;
        global inverse_bem_vertex;
        global inverse_bem_name;
        global inverse_bem_idx;
        global inverse_bem_brain;
        
            delete(inverse_bem_brain);
        
        fprintf('changing from [%s] to ',inverse_bem_name{inverse_bem_idx});
        if(inverse_bem_idx~=length(inverse_bem_face))
            inverse_bem_idx=inverse_bem_idx+1;
        else
            inverse_bem_idx=1;
        end;
        fprintf('[%s]...\n',inverse_bem_name{inverse_bem_idx});
        
        ff=inverse_bem_face{inverse_bem_idx};
        vv=inverse_bem_vertex{inverse_bem_idx};
        
        inverse_bem_brain=patch('Faces',ff,...
            'Vertices',vv,...
            'EdgeColor','none',...
            'FaceColor',[1,.75,.65],...
            'SpecularStrength' ,0.5, 'AmbientStrength', 0.7,...
            'DiffuseStrength', 0.5, 'SpecularExponent', 10.0);
        
    case 'q'
        fprintf('\nterminating graph!\n');
        close(gcf);
    case 'c'
        global inverse_bem_selected_chan;
	try
		if(strcmp(get(inverse_bem_selected_chan,'visible'),'on'))
	        	set(inverse_bem_selected_chan,'visible','off');
		else
	        	set(inverse_bem_selected_chan,'visible','on');
		end;
	catch
        	inverse_bem_selected_chan=[];
	end;
    otherwise
        %fprintf('pressed [%c]!\n',cc);
    end;
case 'bd'
    if(~isempty(inverse_pointer_handle))
        %delete(inverse_pointer_handle);
        inverse_pointer_handle=[];
    end;

    
	global inverse_bem_single_channel_fig;
	global inverse_bem_all_channel_fig;
    

	if(gcf==inverse_bem_all_channel_fig)
		draw_pointer;
	elseif(gcf==inverse_bem_single_channel_fig)
		global inverse_timecourse_x;

		inverse_timecourse_x=get(gca,'currentpoint');
		inverse_timecourse_x=inverse_timecourse_x(1);

		draw_timecourse;
		draw_topo;
	end;
case 'init'
	global inverse_bem_Y;
	global inverse_timecourse_x;

	if(~isempty(inverse_bem_Y))
		tmp=max(inverse_bem_Y,[],1);
		[dummy,inverse_timecourse_x]=max(tmp);
	else
		inverse_timecourse_x=1;
	end;

	draw_topo;
end;

return;

function draw_timecourse()
global inverse_bem_Y;
global inverse_bem_single_channel_fig;
global inverse_bem_timeVec;
global inverse_timecourse_x;
global inverse_bem_patch;
global inverse_bem_selected_sensor;

	
    if(~isempty(inverse_bem_Y)) %we have meg data?
        if(isempty(inverse_bem_single_channel_fig))
            inverse_bem_single_channel_fig=figure;
        else
            figure(inverse_bem_single_channel_fig);
        end;
	set(inverse_bem_single_channel_fig,'WindowButtonDownFcn','inverse_render_bem_handle(''bd'')');
	set(inverse_bem_single_channel_fig,'KeyPressFcn','inverse_render_bem_handle(''kb'')');


        if(~isempty(inverse_bem_timeVec))
            subplot(211); plot(inverse_bem_timeVec,inverse_bem_Y(inverse_bem_selected_sensor*3-2:inverse_bem_selected_sensor*3-1,:));
            xlabel('time (ms)'); ylabel('signal strength (T/cm)');
            title('gradiometer');
            subplot(212); plot(inverse_bem_timeVec,inverse_bem_Y(inverse_bem_selected_sensor*3,:),'r');
            xlabel('time (ms)'); ylabel('signal strength (T)');
            title('magnetometer');
	    ymin=min(get(gca,'ylim')); ymax=max(get(gca,'ylim'));
	    h=line([inverse_bem_timeVec(inverse_timecourse_x),inverse_bem_timeVec(inverse_timecourse_x)],[ymin,ymax]); set(h,'color',[1 1 1].*.7);
        else
            plot(inverse_bem_Y(inverse_bem_selected_sensor,:));
	    ymin=min(get(gca,'ylim')); ymax=max(get(gca,'ylim'));
	    h=line([inverse_timecourse_x,inverse_timecourse_x],[ymin,ymax]); set(h,'color',[1 1 1].*.7);
        end;
    end;
return;


function draw_topo()
	global inverse_bem_all_channel_fig;
	global inverse_bem_sensor;
	global inverse_bem_Y;
	global inverse_timecourse_x;
	global inverse_bem_sensor_V;
	global inverse_bem_sensor_F;
	global inverse_bem_coil_offset;
	global inverse_bem_patch;
	global inverse_bem_selected_sensor;

	figure(inverse_bem_all_channel_fig);
		
	%delete(inverse_bem_sensor);
	inverse_timecourse_x=round(inverse_timecourse_x);

	if(isempty(inverse_bem_Y))
		inverse_bem_sensor=patch('Faces',inverse_bem_sensor_F',...
			'Vertices',inverse_bem_sensor_V(:,1:3).*.95,...
			'EdgeColor','none',...
			'FaceColor',[1 1 1].*0.3,...
			'SpecularStrength' ,0.1, 'AmbientStrength', 1.2,...
			'DiffuseStrength', 1);
	else
		inverse_bem_sensor=patch('Faces',inverse_bem_sensor_F',...
			'Vertices',inverse_bem_sensor_V(:,1:3).*.95,...
			'EdgeColor','none',...
			'FaceVertexCData',inverse_bem_Y(1+inverse_bem_coil_offset:3:end,inverse_timecourse_x),...
			'SpecularStrength' ,0.1, 'AmbientStrength', 1.2,...
			'DiffuseStrength', 1);
	end;
			

	%prepare coil patch
	vc=[];
	fc=[];
	radius=6;
	seg=16;
	for r=1:seg
 		vc(r,1)=radius.*cos(2*pi/seg*r);
		vc(r,2)=radius.*sin(2*pi/seg*r);
		vc(r,3)=0.0;
	end;
	fc(1,:)=[1:seg];
	vc(:,4)=1;

    
	%plot individual coil patch
	for p=1:size(inverse_bem_sensor_V,1)
		phi=atan(sqrt(inverse_bem_sensor_V(p,1)^2+inverse_bem_sensor_V(p,2)^2)/inverse_bem_sensor_V(p,3));
		the=atan2(inverse_bem_sensor_V(p,1),inverse_bem_sensor_V(p,2));
    
		t_x=[1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
		t_z=[cos(the) sin(the) 0;-sin(the) cos(the) 0;0 0 1];
    
		T(4,:)=[0 0 0 1];
		T(1:3,4)=inverse_bem_sensor_V(p,1:3)';
		T(1:3,1:3)=t_z*t_x;
    

		tvc=vc*T';

		inverse_bem_patch{p}=patch('Faces',fc,...
			'Vertices',tvc(:,1:3),...
			'EdgeColor',[1 1 1].*0.7,...
			'FaceColor',[0 0 1],...
			'SpecularStrength' ,0.1, 'AmbientStrength', 1.2,...
			'DiffuseStrength', 1);
	end;


	if(~isempty(inverse_bem_selected_sensor))
		set(inverse_bem_patch{inverse_bem_selected_sensor},'facecolor',[1 0 0]);
	end;

	axis off image;

    set(inverse_bem_all_channel_fig,'WindowButtonDownFcn','inverse_render_bem_handle(''bd'')');
    set(inverse_bem_all_channel_fig,'KeyPressFcn','inverse_render_bem_handle(''kb'')');

return;



function draw_pointer()

global inverse_bem_patch;
global inverse_bem_chanlabels;
global inverse_bem_Y;
global inverse_bem_timeVec;
global inverse_timecourse_x;
global inverse_bem_single_channel_fig;
global inverse_bem_all_channel_fig;
global inverse_bem_selected_chan;
global inverse_bem_selected_sensor;


pt=[];
for p=1:length(inverse_bem_patch)
    pt=select3d(inverse_bem_patch{p});
    if(~isempty(pt))
        break;
    end;
end;

if(~isempty(pt)) %click on some channel?
	if(~isempty(inverse_bem_selected_sensor))
		set(inverse_bem_patch{inverse_bem_selected_sensor},'facecolor',[0 0 1]);
	end;
	inverse_bem_selected_sensor=p;
	set(inverse_bem_patch{p},'facecolor',[1 0 0]);
    
    fprintf('channel [%d|%d|%d] ...',(p-1)*3+1,(p-1)*3+2,(p-1)*3+3);
    %inverse_bem_selected_chan=[];
    %delete(inverse_bem_selected_chan);
    %inverse_bem_selected_chan=[];
    tmpstrr='';
    
    for k=1:3
    nstr = num2str(inverse_bem_chanlabels((p-1)*3+k));
        if length(nstr) == 1
            tmpstr = strcat('MEG000',nstr);
        elseif length(nstr) == 2
            tmpstr = strcat('MEG00',nstr);
        elseif length(nstr) == 3
            tmpstr = strcat('MEG0',nstr);
        else
            tmpstr = strcat('MEG',nstr);
        end
        fprintf('[%s] ',tmpstr);
        tmpstrr=strcat(tmpstrr,sprintf('[%s] ',tmpstr));
        %tmpstrr='';
    end;
	
    try
	delete(inverse_bem_selected_chan);
    catch
	inverse_bem_selected_chan=[];
    end;
    inverse_bem_selected_chan=text(pt(1),pt(2),pt(3),tmpstrr);
    set(inverse_bem_selected_chan,'color',[1 1 1].*0.7,'fontsize',12,'fontname','helvetica');
    fprintf('\n');
    
    if(size(inverse_bem_Y,2)>1)
	    draw_timecourse;
    end;
end;


return;

function redraw()

return;


