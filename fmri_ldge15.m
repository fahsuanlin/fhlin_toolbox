function [data]=fmri_ldge15(file,varargin)
%fmri_ldge15	load GE 1.5 T raw data file
%
%[data]=fmri_ldge15(file,size,flag)
%
%data: 2D data of voxel
%file: the source file
%size: 2D size setting for x and y dimension (auto-detection enabled)
%flag: set flag=1, this routine will extract only the central part of the data (y dimension remained the same)
%
% written by fhlin@nov. 11, 1999

fp=fopen(file,'r','ieee-be');

[dummy,count]=fread(fp,inf,'uchar');	%check the length of file
fseek(fp,0,-1);

if(floor(count/128/128/2)==1)
	sz=[128,128];
elseif(floor(count/256/256/2)==1)
	sz=[256,256];
elseif(floor(count/512/512/2)==1)
	sz=[512,512];
end;	

if(nargin==2)
	sz=(varargin{1})
end;


skip=7904;
fseek(fp,skip,'bof');
[data,count]=fread(fp,sz,'uint16');

if(nargin==3)
	str=(varargin{2})
	if(str==1)
		data=data(:,size_x/4:size_x*3/4);
	end;
end;
data=data';

imagesc(data);
axis('equal');
minn=min(min(data));
maxx=max(max(data));
str=sprintf('min=%d max=%d',minn,maxx);
disp(str);

fclose(fp);