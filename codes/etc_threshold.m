function [output,th]=etc_threshold(data,threshold,varargin)
% etc_threshold 	threshold data 
%
% [output, th]=etc_threshold(data,threshold,[mode])
% data: multiple dimensional data to be thresholded
% threshold: threshold value to be applied
% mode : 'proportion' (default) or 'value'
%
% output: thresholded data
% th: the used threshold valeu
%
% fhlin@may 09, 2002

output=data;

mode='proportion';

if(nargin==3&strcmp(lower(varargin{1}),'value')==1)
	mode='value';
end;

data_1d=reshape(data,[1,prod(size(data))]);


switch mode
case 'proportion'
	data_1d_sort=sort(data_1d);
	th=data_1d_sort(round(length(data_1d_sort)*threshold));
	output(find(output>=th))=th;
case 'value'
	output(find(output>=max(threshold)))=max(threshold);
	output(find(output<=min(threshold)))=min(threshold);
	th=threshold;
end;

return;
		
