function inverse_render_sensor(data,varargin)
% inverse_render_sensor		render sensor data (over a 3D helmet model)
%
% inverse_render_sensor(data,[option, option_value,...])
% data: a 1D vector (306 element 1D vector)
% option:
%	'coils': 'grad1','grad2',or 'mag' for gradiometers and magnetometers rendering.
%
% fhlin@jan. 17, 2003
%

bad=[];

render_interval=[];

timeVec=[];

format='helmet';

view_angle=[];

coils='all';

threshold='maxmin';

flag_colorbar=0;

for i=1:ceil(length(varargin)./2)
	option=varargin{2*i-1};
	option_value=varargin{2*i};


	switch(lower(option))
	case {'bad_channel','bad','bad_chan'}
		bad=option_value;
	case 'coils'
		coils=option_value;
	case 'format'
		format=option_value;
	case 'timevec'
		timeVec=option_value;
	case 'render_interval'
		render_interval=option_value; 
	case 'threshold'
		threshold=option_value;
	case 'view_angle'
		view_angle=option_value;
	case 'flag_colorbar'
		flag_colorbar=option_value;
	end;
end;


if(~isempty(bad))
	good_channel=setdiff([1:306],bad);
else
	good_channel=[1:306];
end;

Y=zeros(306,size(data,2));
Y(good_channel,:)=data;

if(~isempty(render_interval))
	%covert render interval into indices
	if(~isempty(timeVec))
		render_interval=find(timeVec>min(render_interval)&timeVec<max(render_interval));
	end;
end;


switch lower(format)
case 'helmet'
	
	if(isempty(render_interval))
		render_interval=[1:size(Y,2)];
	end;

	if(isempty(coils))
		fprintf('no default coil setting! set coil into gradiometer1!\n');
		coils='grad1';
	end;


	switch(coils)
	case 'grad1'
		yy=mean(Y(1:3:end,render_interval),2);
		topohelmet(yy,'coils',coils,'maplimits',threshold);
		set(gca,'DataAspectRatio',[1 1 1]);
		if(~isempty(view_angle))
			view(view_angle);
		end;
	case 'mag'
		yy=mean(Y(3:3:end,render_interval),2);			
		topohelmet(yy,'coils',coils,'maplimits',threshold);
		set(gca,'DataAspectRatio',[1 1 1]);
		if(~isempty(view_angle))
			view(view_angle);
		end;
	case 'grad2'
		yy=mean(Y(2:3:end,render_interval),2);			
		topohelmet(yy,'coils',coils,'maplimits',threshold);
		set(gca,'DataAspectRatio',[1 1 1]);
		if(~isempty(view_angle))
			view(view_angle);
		end;
	case 'all'
		for i=1:3
			subplot(2,2,i);
			yy=mean(Y(i:3:end,render_interval),2);			
			topohelmet(yy,'coils',coils,'maplimits',threshold);
			switch i
			case 1	
				title('grad1');
			case 2	
				title('grad2');
			case 3	
				title('mag');
			end;
			set(gca,'DataAspectRatio',[1 1 1]);
			if(~isempty(view_angle))
				view(view_angle);
			end;
			if(flag_colorbar)
				colorbar;
			end;

		end;
	end;

end;
