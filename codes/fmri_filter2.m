function [avgdat]=fmri_filter2(data,mask)
%fmri_filter2	average the raw data by 2D mask
%
%[avgdat]=fmri_filter2(data,mask)
%
%data: the 3D raw data matrix
%mask: the 2D average mask. mask=ones(2,2) will do a 2*2 averaging.
%
%written by fhlin@aug. 24, 1999

total=sum(sum(mask,1),2);

buffer=zeros(size(data,1)+size(mask,1)-1,size(data,2)+size(mask,2)-1);
str=sprintf('averaging for size of : %s ...',mat2str(size(data)));
disp(str);

for i=1:size(data,3)
	buffer(:,:,i)=conv2(data(:,:,i),mask)./total;
end;

avgdat=buffer(size(mask,1):size(data,1)+size(mask,1)-1,size(mask,2):size(data,2)+size(mask,2)-1,:);
