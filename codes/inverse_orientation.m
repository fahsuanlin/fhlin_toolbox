function [dec_norm_avg,dec_angle_std]=inverse_orientation(file_search,file_dip,file_dec,varargin);
%
% inverse_orientation		get orientation files after searching the local cortical patches
%
% inverse_orientation(file_search,file_dip,file_dec,file_output,[option_name, option_value]);
%
% file_search: cell array of Dijkstra search results (in Matlab mat format);
% file_dip: DIP file associated with the dipole locations and orientations.
% file_dec: DEC file associated with the forward model
% file_output: the file name to be saved for local cortical patch orientations
%
% fhlin@may 27, 2003
%

%defaults.
flag_display=1;
file_output='';

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	optino_value=varargin{i*2};
	switch lower(option)
	case 'flag_display'
		flag_display=option_value;
	case 'flag_output'
		flag_output=option_value;
	otherwise
		fprintf('unknown option [%s]...\nerror!\n',option);
		return;
	end;
end;


min_DEC=[];
min_DIST=[];
for i=1:length(file_search)
	load(file_search{i});
	min_DEC=[min_DEC, min_dec];
	min_DIST=[min_DIST, min_dist];
end;


[dipole_info,dd]=inverse_read_dipdec(file_dip, file_dec);
dec{i}=find(dd);

for i=1:length(dec{1})
	fprintf('[%d|%d]...\r',i,length(dec{1}));
	
	idx=find(min_DEC==dec{1}(i));
	norm=dipole_info(4:6,idx);

	dec_norm_avg(:,i)=mean(norm,2);
	angle=acos(sum(norm.*repmat(mean(norm,2),[1,length(idx)]),1)./sqrt(sum(norm.^2,1))./sqrt(sum(mean(norm,2).^2,1)));
	dec_angle_std(i)=std(angle);
	dec_angle_deviate(i)=acos(sum(mean(norm,2).*dipole_info(4:6,dec{1}(i)),1)./sqrt(sum(mean(norm,2).^2,1))./sqrt(sum(dipole_info(4:6,dec{1}(i)).^2,1)));
	dec_count(i)=length(idx);
end;

if(flag_display)
	subplot(311);
	hist(dec_angle_std.*180/pi,100);
	title('distribution of std. dev. of cortical normal vectors within local cortical patch');
	xlabel('std. dev. (deg)');
	ylabel('# of dec. dipole');


	subplot(312);
	hist(dec_angle_deviate.*180/pi,100);
	title('distribution of angle difference between cortical patch average and dec. dipole');
	xlabel('deviation (deg)');
	ylabel('# of dec. dipole');

	subplot(313);
	hist(dec_count,100);
	title('distribution of # of dipoles in a cortical patch');
	xlabel('# of dipoles');
	ylabel('# of dec. dipole');
end;

if(~isempty(file_output))
	save(file_output,'min_DEC','dec','norm','dec_norm_avg','dec_angle_std','dec_count','dec_angle_deviate','min_DIST');
end;

return;
