function [curv]=inverse_read_curv(curv_file)

% inverse_read_curv.m
%
% read curvature into matlab
%
% [curv]=inverse_read_curv(curv_file)
% curv: 1D curvature vector
%
%
% May. 18, 2001
%

fprintf('Reading curvature file...\n');

fp=fopen(curv_file,'r','ieee-be.l64');

n_vertex=fread3(fp);
n_face=fread3(fp);

curv=fread(fp,[n_vertex],'int16')./100.0;

fclose(fp);

return;

function [retval] = fread3(fid)

% [retval] = fd3(fid)
% read a 3 byte integer out of a file

b1 = fread(fid, 1, 'uchar');
b2 = fread(fid, 1, 'uchar');
b3 = fread(fid, 1, 'uchar');
retval = bitshift(b1, 16) + bitshift(b2,8) + b3 ;

return;
