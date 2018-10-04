function [output,kernel]=fmri_smooth(data,fwhm,varargin)
% fmri_smooth	3D smoothing of data
%
% [output,kernel]=fmri_smooth(data,fwhm,[option1, option1_value, ....]);
%
% options:
% 'vox': a 1-by-3 vectror about image voxel size in mm
% 'kernel': a n-d matrix of the same size of input "data". This describes
% the smoothing kernel to be applied.
% 
 
output=[];
kernel=[];
vox=[];

for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	switch(lower(option))
		case 'kernel'
			kernel=option_value;
		case 'vox'
			vox=option_value;
		otherwise
			fprintf('unknown option [%s]!\nerror!\n',option);
			return;
	end;
end;

if(isempty(kernel))
	kernel=zeros(size(data));
	
	if(isempty(vox))
		vox=ones([1 ndims(data)]);
	end;

	[xx,yy,zz]=meshgrid([1:size(data,2)]-round(size(data,2)/2)-1,[1:size(data,1)]-round(size(data,1)/2)-1,[1:size(data,3)]-round(size(data,3)/2)-1);

	xc=size(data,1)-round(size(data,1)/2)-1;
	yc=size(data,2)-round(size(data,2)/2)-1;
	zc=size(data,3)-round(size(data,3)/2)-1;

	xx=xx.*vox(1);
	yy=yy.*vox(2);
	zz=zz.*vox(3);
	dist=sqrt(xx.^2+yy.^2+zz.^2);
	
	sig=fwhm./2.355;

	kernel=exp(-(dist.^2./sig^2));
	kernel=fftshift(fftn(fftshift(kernel)));
	kernel=kernel./sum(kernel(xc,yc,zc));
	%.*prod(size(data));
end;

output=real(ifftn(fftn(data).*fftshift(kernel)));

return;
