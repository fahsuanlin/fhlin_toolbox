function inverse_render_sensor_movie(Y_input,badchannel,varargin)

avi_output_file='';
quicktime_output_file='';

bad_channel=[];

view_angle={
[45,30],
[90,30],
[135,30],
[-45,30],
[-90,30],
[-135,30],
[0,30],
[180,30],
[0,90],
};

coils={
'grad1',
'grad2',
'mag',
};

sample_time='';
sample_unit='';

quicktime_output_file='inverse_sensor';
avi_output_file='';

threshold=[];

for i=1:length(varargin)/2
	option=varargin{2*i-1};
	option_value=varargin{2*i};
	switch lower(option)
	case 'sample_time'
		sample_time=option_value;
	case 'sample_unit'
		sample_unit=option_value;
	case 'view_angle'
		view_angle=option_value;
	case 'coils'
		coils=option_value;
	case 'avi_output_file'
		avi_output_file=option_value;
	case 'quicktime_output_file'
		quicktime_output_file=option_value;
	case 'threshold'
		threshold=option_value;
	otherwise
		fprintf('unknown option [%s]!\n',option);
		fprintf('error!\n');
		return;
	end;
end;
		

xx=sqrt(length(view_angle));
nn=ceil(xx);
mm=ceil(length(view_angle)/nn);



good_channel=setdiff([1:306],badchannel);
Y=zeros(306,size(Y_input,2));
Y(good_channel,:)=Y_input;





for j=1:length(coils)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% preparation of AVI output file
	%
	if(~isempty(avi_output_file))
		avi_mov = avifile(sprintf('%s_%s.avi',avi_output_file,coils{j}));
		avi_mov.FPS=4;
		avi_mov.Compression='none';
		avi_mov.Quality=100;
	else
		avi_mov=[];
	end;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% preparation of Quicktime output file
	%
	if(~isempty(quicktime_output_file))
		makeqtmovie('start',sprintf('%s_%s.qt',quicktime_output_file,coils{j}));
		makeqtmovie('framerate',16);
		quicktime_mov=1;
	else
		quicktime_mov=[];
	end;

	if(isempty(threshold))
		switch coils{j}
		case 'grad1'
			xx=sort(reshape(Y(1:3:end,:),[1,prod(size(Y))./3]));
		case 'grad2'
			xx=sort(reshape(Y(2:3:end,:),[1,prod(size(Y))./3]));
		case 'mag'
			xx=sort(reshape(Y(3:3:end,:),[1,prod(size(Y))./3]));
		end;
	
		threshold_now=[xx(ceil(length(xx).*0.95)),xx(ceil(length(xx).*0.99))];
	else
		threshold_now=threshold;
	end;


	for i=1:size(Y,2)
		fprintf('[%d/%d]...[%2.2f%%] completed!\n', i,size(Y,2),i./size(Y,2).*100.0);


		set(gcf,'DoubleBuffer','off');

		set(gca,'NextPlot','replace');
    	
		%render brain
		delete(gca);

%		fprintf('max=[%3.3f] min=[%3.3f] threshold=[%3.3f, %3.3f]\n',max(Y(:,i)),min(Y(:,i)),min(threshold),max(threshold));
	
		for v=1:length(view_angle)
			subplot(mm,nn,v);
			inverse_render_sensor(Y(:,i),'coils',coils{j});
			set(gca,'clim',threshold_now);
	    	%set view angle
			view(view_angle{v});
		end;

		set(gcf,'color',[0 0 0]);
		set(gcf,'visible','off');
		set(gca,'Visible','off');


		%control the display of axis label
		set(gca,'xticklabel',[]);
		set(gca,'yticklabel',[]);
		set(gca,'zticklabel',[]);
	
		pos=get(gca,'pos');
		hax=axes('pos',pos);
		set(hax,'visible','off');

		% show timing
		if(~isempty(sample_time))
			h=text(0,0.1,sprintf('%2.0f %s',sample_time(i),sample_unit));
			set(h,'color',[1 1 1]);
			set(h,'fontsize',12);
			set(h,'fontname','helvetica')
		end;


		% get frames into AVI file
		if(~isempty(avi_mov))
			set(gcf,'visible','on');
			F = getframe(gcf);
      		set(gcf,'visible','off');
			avi_mov = addframe(avi_mov,F);
		end;

		% get frames into Quicktime file
		if(~isempty(quicktime_mov))
			set(gcf,'visible','on');
			F = getframe(gcf);
			makeqtmovie('addfigure');
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
end;

