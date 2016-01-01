function inverse_render_handle(param)% inverse_smooth	smoothing surface values 
%
% inverse_render_handle(param)
%  	param:
%	'kb':		This is a keyboard event.
%	'bd':		This is a mouse bottom-down event.
%
% fhlin@feb. 26, 2004
%

global inverse_fig;
global inverse_fig_stc;

global inverse_dec_dipole;

global inverse_dfg_data;
global inverse_fg_data;

global inverse_stc_timeVec;
global inverse_stc_timeVec_idx;
global inverse_stc_timeVec_idx_handle
global inverse_stc_data;

global inverse_threshold;
global inverse_colorbar_handle;
global inverse_pointer_handle;

global inverse_smooth_step;

global inverse_subject;
global inverse_subjects_dir;
global inverse_hemi;
global inverse_surf;

cc=get(gcf,'currentchar');

switch lower(param)
case 'kb'
    switch(cc)
    case 'h'
        fprintf('inverse rendering information:\n\n');
        fprintf('a: archiving image (fmri_overlay.tif if no specified output file name)\n');
        fprintf('q: exit\n');
        fprintf('s: sharpen overlay \n');
        fprintf('+: increase threshold by 10%\n');
        fprintf('-: decrease threshold by 10%\n');
        fprintf('d: interactive threshold change\n');
        fprintf('c: switch on/off the colorbar\n');
        fprintf('\n\n fhlin@mar 6, 2004\n');
        
    case 'a'
        fprintf('archiving...\n');
        fn=sprintf('inverse_render.tif');
        fprintf('saving [%s]...\n',fn);
        print(fn,'-dtiff');
    case 'q'
        fprintf('\nterminating graph!\n');
        global inverse_fig;
        close(inverse_fig);
    case 'r'
        fprintf('\nredrawing...\n');
        
	redraw;
 	
    case 'c'
        if(inverse_colorbar_handle)
            fprintf('turning off colorbar\n');
			delete(inverse_colorbar_handle);
			inverse_colorbar_handle=[];
        else
            fprintf('turning on colorbar\n');
			inverse_colorbar_handle=inverse_colorbar(gca,inverse_threshold);
        end;
    
    case 'd'
    	global inverse_threshold;
    	
        fprintf('change threshold...\n');
        fprintf('current threshold = %s\n',mat2str(inverse_threshold));
        def={num2str(inverse_threshold)};
        answer=inputdlg('change threshold',sprintf('current threshold = %s',mat2str(inverse_threshold)),1,def);
        if(~isempty(answer))
            inverse_threshold=str2num(answer{1});
            fprintf('updated threshold = %s\n',mat2str(inverse_threshold));
	end;        
	redraw;
    
    otherwise
        %fprintf('pressed [%c]!\n',cc);
    end;
case 'bd'
	if(gcf==inverse_fig)
		if(~isempty(inverse_pointer_handle))
			if(ishandle(inverse_pointer_handle))
				delete(inverse_pointer_handle);
				inverse_pointer_handle=[];
			end;
		end;
		draw_pointer;
	
		if(~isempty(inverse_stc_data))
			draw_stc;
		end;
	elseif(gcf==inverse_fig_stc)
		if(~isempty(inverse_stc_timeVec_idx_handle))
			if(ishandle(inverse_pointer_handle))
				delete(inverse_pointer_handle);
			end;
			inverse_stc_timeVec_idx_handle=[];
		end;
		xx=get(gca,'currentpoint');
		xx=xx(1);
		
		if(isempty(inverse_stc_timeVec))
			inverse_stc_timeVec_idx=xx;
			fprintf('showing STC at time index [%d]\n',inverse_stc_max_idx);
		else
			[dummy,inverse_stc_timeVec_idx]=min(abs(inverse_stc_timeVec-xx));
			fprintf('showing STC at time [%2.2f] ms\n',inverse_stc_timeVec(inverse_stc_timeVec_idx));
		end;
		
		inverse_fg_data=zeros(size(inverse_fg_data));
		inverse_fg_data(inverse_dec_dipole)=inverse_stc_data(:,inverse_stc_timeVec_idx);
		inverse_dfg_data=inverse_stc_data(:,inverse_stc_timeVec_idx);
		
		if(~isempty(inverse_stc_data))
			draw_stc;
		end;
		
		redraw;
	end;
end;

return;




function draw_pointer()

global inverse_pointer_handle;
global inverse_dec_dipole;
global inverse_vertex;
global inverse_dec_dipole_range;
global inverse_min_dist_dec_dipole;


pt=select3d(gca);
if(isempty(pt))
	return;
end;

if(~isempty(inverse_pointer_handle))
	inverse_pointer_handle=[];
end;

inverse_pointer_handle=plot3(pt(1),pt(2),pt(3),'.');
fprintf('\nselected [x,y,z]=(%s)\n',num2str(pt','%2.2f '));
set(inverse_pointer_handle,'color',[0 0 1]);

vv=inverse_vertex(inverse_dec_dipole,:);
dist=sqrt(sum((vv-repmat([pt(1),pt(2),pt(3)],[size(vv,1),1])).^2,2));
[min_dist,min_dist_idx]=min(dist);
fprintf('nearest decimated diople: IDX=[%d] (%2.2f %2.2f %2.2f) \n',min_dist_idx,vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3));
h=plot3(vv(min_dist_idx,1),vv(min_dist_idx,2),vv(min_dist_idx,3),'.');
set(h,'color',[1 0 0]);

inverse_min_dist_dec_dipole=min_dist_idx;

return;


function draw_stc()
	global inverse_stc_data;
	global inverse_stc_timeVec;
	global inverse_stc_timeVec_idx;
	global inverse_stc_timeVec_idx_handle
	global inverse_fig_stc;
	global inverse_min_dist_dec_dipole;

	if(isempty(inverse_fig_stc))
		inverse_fig_stc=figure;
	else
		figure(inverse_fig_stc);
	end;
	
	set(inverse_fig_stc,'WindowButtonDownFcn','inverse_render_handle(''bd'')');
	set(inverse_fig_stc,'KeyPressFcn','inverse_render_handle(''kb'')');

	
	if(isempty(inverse_stc_timeVec))
		h=plot(inverse_stc_data(inverse_min_dist_dec_dipole,:));
		if(~isempty(inverse_stc_timeVec_idx))
			yy=get(gca,'ylim');
			inverse_stc_timeVec_idx_handle=line([inverse_stc_timeVec_idx, inverse_stc_timeVec_idx],[yy(1), yy(2)]);
			set(inverse_stc_timeVec_idx_handle,'color',[0.4 0.4 0.4]);
		end;
		xlabel('sample');
		axis tight;
	else
		h=plot(inverse_stc_timeVec,inverse_stc_data(inverse_min_dist_dec_dipole,:));
		if(~isempty(inverse_stc_timeVec_idx))
			yy=get(gca,'ylim');
			inverse_stc_timeVec_idx_handle=line([inverse_stc_timeVec(inverse_stc_timeVec_idx), inverse_stc_timeVec(inverse_stc_timeVec_idx)],[yy(1), yy(2)]);
			set(inverse_stc_timeVec_idx_handle,'color',[0.4 0.4 0.4]);
		end;
		xlabel('time (ms)');
		axis tight;
	end;

return;

function redraw()

	global inverse_fig;
 	global inverse_vertex;
 	global inverse_face;
 	global inverse_curv;
 	global inverse_fg_data;
 	global inverse_dfg_data;
 	global inverse_threshold;
 	global inverse_dec_dipole;
 	global inverse_subject;
 	global inverse_subjects_dir;
 	global inverse_hemi;
 	global inverse_surf;
 	global inverse_smooth_step;
 	global inverse_stc_timeVec;
 	global inverse_stc_data;
 	
	
	figure(inverse_fig);
 	vw=get(gca,'view');
 	close(inverse_fig);
 		
	figure(inverse_fig); 	
 	inverse_render_brain_new('vertex',inverse_vertex,...
 				'face',inverse_face,....
 				'curv',inverse_curv,...
 				'threshold',inverse_threshold,...
 				'fg_data',inverse_fg_data,...
 				'dfg_data',inverse_dfg_data,...
 				'dec_dipole',inverse_dec_dipole,...
 				'smooth',inverse_smooth_step,...
 				'stc_data',inverse_stc_data,...
 				'timeVec',inverse_stc_timeVec,...
 				'subject',inverse_subject,...
 				'subjects_dir',inverse_subjects_dir,...
 				'hemi',inverse_hemi,...
 				'surf',inverse_surf);
	view(vw(1),vw(2));
return;


