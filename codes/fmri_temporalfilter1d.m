function [avgdat]=fmri_temporalfilter1d(data,mask)
%fmri_temporalfilter1d	temporal average the raw data by 1D mask
%
%[avgdat]=fmri_temporalfilter1d(data,mask)
%
%data: the 3D raw data matrix
%mask: the 1D average mask. mask=[1,1] will do a 2 voxel averaging along time;
%
%written by fhlin@aug. 24, 1999

total=sum(mask);

buffer=zeros(size(data));
str=sprintf('temporal averaging for size of : %s ...',mat2str(size(data)));
disp(str);



for i=1:size(data,1)
	d=reshape(data(i,:,:),[size(data,2),size(data,3)])';
	d=filter([1,1],[1,0],d);
	buffer(i,:,:)=reshape(d',[1,size(data,2),size(data,3)]);
end;

buffer(:,:,1)=buffer(:,:,1).*2; % rescaling the first time point;

avgdat=buffer./total;
