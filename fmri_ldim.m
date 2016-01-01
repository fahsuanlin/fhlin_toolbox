function [data]=fmri_ldim(imfile,varargin)
%fmri_ldim	load 2D IM format file (GE)
%
%[data]=fmri_ldim(imfile,flag)
%
%data: 2D data of voxel
%imfile: the source im file
%flag: set flag=1, this routine will extract only the central part of the data (y dimension remained the same)
%
% written by fhlin@nov. 06, 1999

fp=fopen(imfile,'r','ieee-be');

fseek(fp,44,'bof');
size_x=fread(fp,1,'uint16');

fseek(fp,46,'bof');
size_y=fread(fp,1,'uint16');


fseek(fp,80,'bof');
data=fread(fp,[size_x,size_y],'uint16');
data=data';
if(nargin==2)
	str=varargin{1};
	if(str==1)
		data=data(:,size_x/4+1:size_x*3/4);
	end;
end;

imagesc(data);
axis('equal');

fclose(fp);