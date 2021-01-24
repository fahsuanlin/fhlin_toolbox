function [data_3d,data_2d]=inverse_read_fwd(fwd_file,varargin)

% inverse_read_fwd.m
%
% inverse_read_fwd(fwd_file,nperdip)
%
% read forward matrix into matlab
%
% nov. 7, 2000
%

nperdip=3;
if(nargin>1)
	nperdip=varargin{1};
end;

if(isempty(fwd_file))
	fprintf('No input file for this forward solution\n');
	data_3d=[];
	data_2d=[];
	return;
end;

fprintf('reading forward solution...\n');

if(length(findstr(fwd_file,'fwd'))>0)
	fprintf('.fwd format\m');
	fp=fopen(fwd_file,'r','ieee-be.l64');

	% dummy char
	[ch]=fread(fp,1,'uchar');

	% number of dipole
	[n_dipole3]=fread(fp,1,'int32');
	n_dipole=n_dipole3/3;


	% number of sensors
	[n_sensor]=fread(fp,1,'int32');

	fprintf('foward solution: [%d] dipoles and [%d] sensors\n',n_dipole,n_sensor);

	% read decimated dipole index
	[dec_index]=fread(fp,[n_dipole],'int32');


	if(nargin==1)
		nperdip=3;
	else
		nperdip=varargin{1};
	end;

	% read forward solution data
	[data,count]=fread(fp,[n_dipole*nperdip*n_sensor],'float');

	% reshape the data into a 2-D matrix
	data_2d=reshape(data,[n_sensor,nperdip*n_dipole]);

	% reshape the data into a 3-D matrix
	data_3d=reshape(data,[n_sensor,nperdip,n_dipole]);
else
	fprintf('matlab mat format.\n');
	load(fwd_file);
	fprintf('[%d] directional component per dipole.\n',nperdip);
	data_2d=MEG_fwd';
	data_3d=reshape(data_2d,[size(data_2d,1)/nperdip,nperdip,size(data_2d,2)]);
end;

fclose(fp);

disp('Read Forward solution DONE!');

return;
