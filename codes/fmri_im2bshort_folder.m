function [data]=fmri_im2bshort_folder(folder,in_prefix,out_prefix,slice,timepoint,varargin)
%fmri_im2bshort		convert IMs file at the specified folder to bshort files
%
%[data]=fmri_im2bshort_folder(folder,in_prefix,out_prefix,slice,timepoint,flag)
%
%data: 2D data of voxel
%folder: the folder with all IM files
%in_prefix: the input file name filter to do format conversion
%out_prefix: the output bshort file prefix
%slice: total number of slice
%timepoint: total number of timepoint
%flag: set flag=1, this routine will extract only the central part of the data (y dimension remained the same)
%
% written by fhlin@nov. 06, 1999

cd(folder);

flag=varargin{1}(1);

filter=sprintf('%s*.im',in_prefix);

d=dir(filter);

if(size(d,1)~=timepoint*slice)
	disp('timepoint/slice error!');
	str=sprintf('total im file: %d',size(d,1));
	disp(str);
	str=sprintf('timepoint: %d',timepoint);
	disp(str);
	str=sprintf('slice: %d',slice);
	disp(str);
	return;
end;

[size_y,size_x]=size(fmri_ldim(d(1).name));


for i=1:slice
	outfile=sprintf('%s_%s.bshort',out_prefix,num2str(i-1,'%03d'));
	str=sprintf('making [%s] ...',outfile);
	disp(str);
	
	clear buffer;
	if(flag~=1)
		buffer=zeros(size_y,size_x,timepoint);
	else
		disp('shrinking x dimension by 2');
		buffer=zeros(size_y,size_x/2,timepoint);
	end;
	for j=1:timepoint
		file=sprintf('%s_%d.im',in_prefix,(j-1)+(i-1)*timepoint);
		bb=fmri_ldim(file,flag);
		buffer(:,:,j)=bb;
	end;
	fmri_svbfile(buffer,outfile);
end;

disp('done!');