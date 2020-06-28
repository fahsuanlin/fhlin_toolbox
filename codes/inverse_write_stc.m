function [varargout]=inverse_write_stc(stc,vertex_data,epoch_begin_latency, sample_period, stc_file,varargin)

% inverse_read_stc.m
%
% inverse_write_stc(stc,vertex_data,epoch_begin_latency, sample_period, stc_file)
%
% read stc matrix into matlab
%
% may 25, 2001
%

flag_append=0;

for i=1:length(varargin)/2
	option_name=varargin{i*2-1};
	option=varargin{i*2};
	switch lower(option_name)
	case 'flag_append'
		flag_append=option;
	otherwise
		fprintf('no [%s] option available!\nerror!\n',option_name);
		return;
	end;
end;

if(flag_append)
	if(~isempty(dir(stc_file)))
		[stc_orig]=inverse_read_stc(stc_file);
		stc=cat(2,stc_orig,stc);
	end;	
end;

if(isempty(stc_file))
	fprintf('No stc file name to write\n');
	stc=[];
	return;
end;

%%fprintf('writing STC...\n');

%%fprintf('epoch_begin_latency=%f\n',epoch_begin_latency);
%%fprintf('sample_period=%f\n',sample_period);
n_vertex=length(vertex_data);
%%fprintf('# of dipole=%d\n',n_vertex);
n_time=size(stc,2);
%%fprintf('# of time point=%d\n',n_time);


fp=fopen(stc_file,'w','ieee-be.l64');

% 
fwrite(fp,epoch_begin_latency,'float32');
fwrite(fp,sample_period,'float32');

n_vertex=length(vertex_data);
fwrite(fp,n_vertex,'int32');

%write vertex indices
fwrite(fp,vertex_data,'int32');

n_time=size(stc,2);
fwrite(fp,n_time,'int32');

%write STC data
fwrite(fp,stc,'float32');

fclose(fp);


%%disp('write_stc DONE!');

return;
