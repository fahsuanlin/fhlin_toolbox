function [data]=inverse_read_efwd(efwd_file)

% inverse_read_efwd
%
% read eforward matrix into matlab
%
% [data]=inverse_read_efwd(efwd_file)
%
% nov. 7, 2000
%
fprintf('reading forward solution...\n');

fp=fopen(efwd_file,'r','ieee-be.l64');

% dummy char
[ch]=fread(fp,1,'uchar');

% number of dipole
[n_dipole3]=fread(fp,1,'int32');
n_dipole=n_dipole3/3;


% number of electrode
[n_electrode]=fread(fp,1,'int32');

fprintf('foward solution: [%d] dipoles and [%d] electrode\n',n_dipole,n_electrode);

% read decimated dipole index
[dec_index]=fread(fp,[n_dipole],'int32');

% read forward solution data (bipolar mode)
[data,count]=fread(fp,[n_dipole*3*n_electrode],'float');

% reshape the data into a 3-D matrix
%data=reshape(data,[n_dipole,3,n_electrode]);
data=reshape(data,[n_electrode,3,n_dipole]);

fclose(fp);

disp('read_efwd DONE!');

return;
