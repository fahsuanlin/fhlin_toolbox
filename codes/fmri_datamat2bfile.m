function [mask_3d,mask_2d] = fmri_datamat2bfile(image,coords,y,x,slices,filename,varargin)
%fmri_datamat2bfile convert datamat into bfile
%      
%[mask_3d,mask_2d] = fmri_datamat2bfile(image,coords,y,x,slices,filename,select_idx)
%image: 2D datamat; each row is an image at one time point, each column is a time series of a voxel
%coords: 1D row vector associated with the datamat
%y: the number of y voxels associated with the datamat
%x: the number of x voxels associated with the datamat
%slices: the number of slices associated with the datamat
%filename: the output file name, if filename is empty, then no output file will be generated.
%	   the output file name must be either 'XXXX.bshort' or 'XXXX.bfloat'.
%select_idx: the row vector indicating which slices will be selected as output
%	   the default value is select_idx=[1:slices] % all slices will be chosen.
%
% written by fhlin@nov 09, 1999
	   
if nargin==6
	select_idx=[1:slices];
end;

if nargin==7
	select_idx=varargin{1};
end;

%transpose image in the case of vector input. %modified apr. 05, 2001
if(size(image,2)==1)
   image=image';
end;

for i=1:size(image,1)
	mask=zeros(y*x*slices,1);
	mask(coords) = image(i,:);

	mask_3d=reshape(mask,[y x slices]);
	fig=figure;
	disp_data=reshape(mask_3d,[y,x,1,slices]);
	disp_data=disp_data(:,:,:,select_idx);
	fmri_mont(disp_data);
	mask_2d=getimage(fig);
	close(fig);

	if(~isempty(filename))
		fn=sprintf('%s_%s.bshort',filename,num2str(i-1,'%03d'));
		fmri_svbfile(mask_3d,fn);
	end;
end;



