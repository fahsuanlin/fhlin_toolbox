function [mask]=fmri_thresholdmask(data,threshold)
%fmri_thresholdmask	generate a 3D mask based on the given threshold on 2D/3D data
%
%data: either 2D or 3D. the raw image data
%threshold: the threshold to screen. set threshold to 0 will use 1/7 of the maximal of the data as threshold
%
%written by fhlin@aug. 28, 1999

mask=[];

if ndims(data)==2
	mask=zeros(size(data));
	if(threshold==0)
		threshold=max(max(data))/7;
	end;
	
	t=ones(y,x)*threshold;
	
	mask=(data>=t);
end;

if ndims(data)==3
	[y,x,timepoints]=size(data);
	mask=zeros(y,x);
	if(threshold==0)
		threshold=max(max(max(data)))/7;
	end;
	
	t=ones(y,x)*threshold;
	
	for i=1:timepoints
		if (i==1)
			mask=(reshape(data(:,:,i),[y,x])>=t);
		else
			mask=mask.*(reshape(data(:,:,i),[y,x])>=t);
		end;
	end;
end;
