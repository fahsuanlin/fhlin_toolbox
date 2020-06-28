function [data]=fmri_datamat_ptselect(image,coords,y,x,slice,datamat)
%fmri_ptselect	select ROI from mouse click after reading bshort or bfloat file
%
%[data]=fmri_datamat_ptselect(image,coords,y,x,slice,datamat)
%
%datamat: the datamat (t rows for t time points, v columns for v voxel)
%coords: 1D coordinate vector
%y: # of voxel in each column (image)
%x: # of voxel in each row (time point)
%slice: # of slice
%
%data: t*n matrix of n selected voxels; each of voxel has t time point signal from datamat
%
%written by fhlin@oct. 31. 1999


fmri_datamat_show(image,coords,y,x,slice);

[xx,yy]=etc_getpts_1(gcf);
xx=round(xx);
yy=round(yy);

clear idx;
clear cc;
sets=length(xx);
for i=1: sets
	cc=(xx(i)-1)*y+yy(i);
	idx(i)=find(coords==cc);
end;


figure;
data=zeros(size(datamat,1),sets);
data(:,i)=datamat(:,idx(i));
plot(datamat(:,idx(i)));



