function [output_mask,output]=sense_poly_sensitivity(input,order,varargin)
%
% sense_poly_sensitivity	estimating sensitivity maps using polynomal fitting
%
% [output]=sense_poly_sensitivity(input,order,[option1, option_value1,....])
%
% input: input images with complex values. it can be n-by-n-by-c for c channel arrays
% order: the order of the polynomial to be used
%
% output: estimated coil maps
%
% fhlin@aug. 24, 2004
%

threshold=[];
mask=[];

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    
    switch lower(option_name)
    case 'threshold'
        threshold=option;
    case 'mask'
    	mask=option;
    otherwise
        fprintf('unknown option [%s]...\n',option_name);
    end;
end;

output=zeros(size(input));
input_mag=abs(input);

for i=1:size(input,3)
	if(~isempty(threshold))
		fprintf('using threshold = [%2.2f]...\n',threshold);
		[output_mask(:,:,i),output(:,:,i)]=etc_polyfit2(input_mag(:,:,i),order,'threshold',threshold);
	elseif(~isempty(mask))
		%fprintf('using provided image mask...\n');
		[output_mask(:,:,i),output(:,:,i)]=etc_polyfit2(input_mag(:,:,i),order,'mask',mask);
	else
		[output_mask(:,:,i),output(:,:,i)]=etc_polyfit2(input_mag(:,:,i),order);
	end;
	
	%phase grafting
	output(:,:,i)=output(:,:,i).*(input(:,:,i)./abs(input(:,:,i)));
	output_mask(:,:,i)=output_mask(:,:,i).*(input(:,:,i)./abs(input(:,:,i)));
end;