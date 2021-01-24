function [label,x,y,z,val,idx]=inverse_read_label(fn)

% inverse_read_label	read dipole labels
%
% [label,x,y,z,val,(idx)]=inverse_read_label(fn);
%
% fn: the file name of the output label. it must be xxxx-lh.label or xxxx-rh.label for MNE_SIMU to recognize appropriate hemisphere.
% label: a vector of dipole number (0-based).
% x: a vector of x-coordinate 
% y: a vector of y-coordinate
% z: a vector of z-coordinate
% val: a vector of values associated with each dipole
% idx: unique index for each dipole
% fhlin@jul 30, 2003

fprintf('reading [%s]...\n',fn);
fp=fopen(fn,'r');
header=fscanf(fp,'%s\n');
n_label=fscanf(fp,'%d\n');
fclose(fp);
[label,x,y,z,val]=textread(fn,'%d\t%f\t%f\t%f\t%f\n','headerlines',2);

return;
