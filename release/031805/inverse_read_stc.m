function [stc,varargout]=inverse_read_stc(stc_file,varargin)

% inverse_read_stc.m
%
% [stc, (vertex_data, epoch_begin_latency, sample_period)]=inverse_read_stc(stc_file)
%
% read stc matrix into matlab
%
% fhlin@may 25, 2001
%

if(isempty(stc_file))
	fprintf('No stc file name to read\n');
	stc=[];
	return;
end;

fprintf('reading STC...\n');

fp=fopen(stc_file,'r','ieee-be.l64');


% 
epoch_begin_latency=fread(fp,1,'float32');
sample_period=fread(fp,1,'float32');
n_vertex=fread(fp,1,'int32');

%read vertex indices
vertex_data=fread(fp,[n_vertex],'int32');

n_time=fread(fp,1,'int32');

fprintf('epoch_begin_latency=%f\n',epoch_begin_latency);
fprintf('sample_period=%f\n',sample_period);
fprintf('# of dipole=%d\n',n_vertex);
fprintf('# of time point=%d\n',n_time);

%read STC data
stc=fread(fp,[n_vertex,n_time],'float32');

fclose(fp);


timeVec=[0:size(stc,2)-1]*sample_period+epoch_begin_latency;

varargout{1}=vertex_data;
varargout{2}=epoch_begin_latency;
varargout{3}=sample_period;
varargout{4}=timeVec;

disp('read_stc DONE!');

return;
