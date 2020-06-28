function inverse_temporal_algin(varargin)
% inverse_temporal_algin	temporally re-aligning (regridding) data 
% 
% []=inverse_temporal_algin([option1, option_value1],...);
% option:
%	'RtimeVec': the new time vector for the data (in ms). By default the program will look for all STC files defined in the file filter and get the intersection
%	'file_filter': the string for filtering all STC files to be processed. (default: '*.stc')
%	'file_prefix': the file prefix for all processed STC file. (default: 'R');
%
% fhlin @sep. 29, 2005
%

RtimeVec=[]; % only change this to get new sample time stamps. If it is empty, it will be determined automatically from data.

file_filter='*.stc';
file_prefix='R';

for i=1:length(varargin)./2
	option=varargin{i*2-1};
	option_value=varargin{i*2};

	switch(lower(option))
	case 'rtimevec'
		RtimeVec=option_value;
	case 'file_filter'
		file_filter=option_value;
	case 'file_prefix'
		file_prefix=option_value;
	otherwise
		fprintf('unknown option [%s]...\n',option);
		fprintf('error!\n');
		return;
	end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p=dir(file_filter);
fprintf('diagnosis...\n');
for i=1:length(p)
	fprintf('reading [%s]...',p(i).name);
	[stc,v,latency,period,timeVec]=inverse_read_stc(p(i).name);

	fprintf('min: [%2.2f] ms; max: [%2.2f] ms; latency=%3.3f (ms); sample period=%3.3f (ms)',min(timeVec),max(timeVec),latency, period);

	t_min(i)=min(timeVec);
	t_max(i)=max(timeVec);
	sf(i)=1./period.*1e3;

	fprintf('\n');
end;

t_start=max(t_min);
t_end=min(t_max);
sf_max=max(sf);
if(isempty(RtimeVec))
	RtimeVec=[t_start:1e3./sf_max:t_end];
end;

fprintf('\n\nresampling from [%2.2f] (ms) to [%2.2f] (ms)...\n\n', min(RtimeVec),max(RtimeVec));

for i=1:length(p)
	fprintf('reading [%s]...',p(i).name);
	[stc,v,latency,period,timeVec]=inverse_read_stc(p(i).name);

	fprintf('regridding...');
	Rstc=zeros(size(stc,1),length(RtimeVec));
	for dipole_idx=1:size(stc,1)
		%fprintf('*');
		Rstc(dipole_idx,:)=griddatan(timeVec',stc(dipole_idx,:)',RtimeVec')';
	end;

	[dummy,fstem]=fileparts(p(i).name);
	fn=sprintf('%s_%s.stc',file_prefix,fstem);
	fprintf('writing [%s]...',fn);
	inverse_write_stc(Rstc,v,min(RtimeVec),1e3./sf_max,fn);

	fprintf('\n');
end;
