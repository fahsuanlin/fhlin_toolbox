function inverse_render_stc(brain_patch_file,stc,stc_vertex,threshold,dec_dipole,varargin)
% inverse_ render_stc Render stc on the matlab patched brain
%
% inverse_render_stc(brain_patch_file,stc,stc_vertex,threshold,dec_dipole [, option, option_value,....])
%
% brain_patch_file: filename and path of the patched brain for matlab rendering
% stc: d*t 2D matrix for d dipoles and t timepoints
% stc_vertex: d-element 1D vector describing the vertex number of the STC. This must be the indices of undecimated dipole for the brain patch (0-based indices)
% threshold: 2-element 1D vector descibing the threshold to display and the value for full range color
% dec_dipole: 1D vector describing the decimated dipoles (0-based)
% 		This can be either 0-1 indicators of all undecimated dip from *.dec directly, or it can also be numeral indices (0-based) of all decimated dipole
%
% option:
%	avi_output_file: the file name for AVI output
% 	interpolation: either 'on' (default) or 'off', to detemine the decimated data to be interpolated linearly for rendering on patched brain surface, or the nearest vertices of brain patch to display data; 
% 	grid: either 'on' (default) or 'off' to show the grid
%	axis_label: either 'on' (default) or 'off' to show th axis
%	sample_time: either 'on' (default) or 'off' to display the tag for temporal sequences of the STC file
%	sample_time: a 1-d vector descibing the timing of each STC time point. It must have the same element as the number of columns in variable stc.
%	sample_unit: a string describing the unit of each sample time point (default: empty string)
%	view_angle: the 2-element vector describing the azimuth (element 1) and elevation (element 2) angle of the figure
%
%	fhlin@sep. 19, 2001


avi_output_file='';
quicktime_output_file='';
flag_interpolation=1;
flag_grid=1;	
flag_axis_label=0;
flag_sample_time=1;
sample_time=[1:size(stc,2)];
bg_weight=1;
sample_unit=[];
view_angle=[-90 0];
show_sample_time='on';

stc_threshold=[0.90, 0.99]; % render the most active 10% of dipoles and make the most active 1% dioples as maximals.

if(nargin>4)
	for i=1:length(varargin)/2
		option_name=varargin{(i-1)*2+1};	
		option_value=varargin{i*2};

		switch lower(option_name)
		case 'avi_output_file'
			avi_output_file=option_value;
        case 'quicktime_output_file'
			quicktime_output_file=option_value;
        case 'interpolation'
			if(strcmp(lower(option_value),'on'))
				flag_interpolation=1;
			else
				flag_interpolation=0;
			end;
		case 'sample_time'
			sample_time=option_value;
		case 'sample_unit'
			sample_unit=option_value;
		case 'grid'
			if(strcmp(lower(option_value),'on'))
				flag_grid=1;
			else
				flag_grid=0;
			end;
		case 'show_sample_time'
			if(strcmp(lower(option_value),'on'))
				flag_sample_time=1;
			else
				flag_sample_time=0;
			end;
		case 'axis_label'
			if(strcmp(lower(option_value),'on'))
				flag_axis_label=1;
			else
				flag_axis_label=0;
			end;
		case 'view_angle'
			view_angle=option_value; 
		case 'threshold'
			threshold=option_value;
        case 'bg_weight'
            bg_weight=option_value;
		otherwise
  		        fprintf('Unknown optional argument [%s]...\nexit!\n',option_name);
			return;
		end;
	end;
end;

%automatic thresholding
if(isempty(threshold))
	ff=sort(reshape(stc,[1,prod(size(stc))]));
  	threshold(1)=ff(floor(length(ff).*min(stc_threshold)));
   	threshold(2)=ff(floor(length(ff).*max(stc_threshold)));
    fprintf('automatic thesholding between [%2.2f] and [%2.2f]\n',min(threshold),max(threshold));
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualization of brain mesh using Matlab functions
%
% load the brain patch for visualization
fprintf('loading brain patch...\n');
load(brain_patch_file,'face','vertex','curv','orig2patch_idx','patch2orig_idx','triangle');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparation of AVI output file
%
if(~isempty(avi_output_file))
	avi_mov = avifile(avi_output_file);
    avi_mov.FPS=4;
    avi_mov.Compression='none';
    avi_mov.Quality=100;
else
	avi_mov=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparation of AVI output file
%
if(~isempty(quicktime_output_file))
    makeqtmovie('start',quicktime_output_file);
    makeqtmovie('framerate',4);
    quicktime_mov=1;
else
	quicktime_mov=[];
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checking the decimated dipole indices
%
if((min(dec_dipole)==0)&(max(dec_dipole)==1))
	fprintf('Decimated dipole indices are indicators of original dipoles!\n');
	dec_dipole=find(dec_dipole)-1;
else
	fprintf('Decimated dipole indices are indices of original dipoles!\n');
	if(min(dec_dipole)==0)
		fprintf('0-based indices!\n');
    else	
		fprintf('not sure if this is 0-based indices...proceed as given!\n');
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check stc and decimate dipole size
%
[dummy,idxa,idxb]=intersect(stc_vertex,dec_dipole);
ss=zeros(length(dec_dipole),size(stc,2));
ss(idxb,:)=stc;
stc=ss;



for i=1:size(stc,2)
	fprintf('[%d/%d]...[%2.2f%%] completed!\n', i,size(stc,2),i./size(stc,2).*100.0);

    fg_data=stc(:,i);

%	set(gcf,'DoubleBuffer','on');
	set(gcf,'DoubleBuffer','off');

	if(flag_grid)
		set(gca,'NextPlot','replace');
	else
		set(gca,'NextPlot','replace');
		set(gca,'Visible','off');
	end;

	set(gca,'NextPlot','replace');

    	
	%render brain
	delete(gca);


    fprintf('max=[%3.3f] min=[%3.3f] threshold=[%3.3f, %3.3f]\n',max(fg_data),min(fg_data),min(threshold),max(threshold));

    inverse_render_brain(vertex,face,...
        'fg_data',fg_data,...
        'fg_v',stc_vertex,...
        'threshold',threshold,...
        'bg_data',curv,...
        'bg_weight',bg_weight,...
        'dec_dipole',dec_dipole,...
        'threshold',threshold,...
        'triangle',triangle);

    % set view angle
	view(view_angle);



	set(gcf,'visible','off');

	if(~flag_grid)
		set(gca,'Visible','off');
	end;

	%control the display of axis label
	if(~flag_axis_label)
		set(gca,'xticklabel',[]);
		set(gca,'yticklabel',[]);
		set(gca,'zticklabel',[]);
	end;		
		

	pos=get(gca,'pos');

	hax=axes('pos',pos);
	set(hax,'visible','off');

	% show timing
	if(flag_sample_time)
        %h=title(sprintf('%2.0f %s',sample_time(i),sample_unit));
		h=text(0,0.1,sprintf('%2.0f %s',sample_time(i),sample_unit));
		set(h,'color',[1 1 1]);
		set(h,'fontsize',12);
		set(h,'fontname','helvetica')
	end;


%	pos=get(gca,'pos');
%	hcolor=axes('pos',pos);
%	set(hcolor,'visible','off');
%	cmap=hot(128);
%	cmap=cmap(49:128,:);
%	colormap(hcolor,cmap);
%	bar=colorbar(hcolor);
%	set(bar,'tag','colorbar');
%	set(bar,'unit','normalized');
%    set(bar,'pos',[0 0 1 0.1]);
%    set(bar,'color',[0 0 0]);
%    set(bar,'ycolor',[1,1,1]);
%	 set(bar,'xcolor',[1,1,1]);
%    set(bar,'xlim',threshold);
%    set(bar,'xtickmode','manual');
%    set(bar,'xtick',[threshold(1):diff(threshold)./6:threshold(2)]);
%    s=num2str(reshape([threshold(1):diff(threshold)/6:threshold(2)],[7,1]),'%1.3f');
%    set(bar,'xticklabel',s);

	% get frames into AVI file
	if(~isempty(avi_mov))
       	set(gcf,'visible','on');
		F = getframe(gcf);
      	set(gcf,'visible','off');
		avi_mov = addframe(avi_mov,F);

		file_image_output=sprintf('inverse_render_%s_%03d.tif',date,i);
		print('-dtiff',file_image_output);
	end;

   	% get frames into Quicktime file
	if(~isempty(quicktime_mov))
       	set(gcf,'visible','on');
		F = getframe(gcf);
        makeqtmovie('addfigure');

%		file_image_output=sprintf('inverse_render_%s_%03d.tif',date,i);
%		print('-dtiff',file_image_output);
    end;

	close(gcf);
end;


if(~isempty(avi_mov))
    fprintf('closing AVI file [%s]...\n',avi_output_file);
	avi_mov = close(avi_mov);
end;

if(~isempty(quicktime_mov))
    fprintf('closing QuickTime file [%s]...\n',quicktime_output_file);
    makeqtmovie('finish');
end;

return;
