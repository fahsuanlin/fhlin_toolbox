function [output_mask,output]=pmri_poly_sensitivity_3d(input,order,varargin)
%
%	pmri_poly_sensitivity_3d	estimating sensitivity maps using polynomal fitting
%
%	[output_mask,output]=pmri_poly_sensitivity_3d(input,order,['mask', mask,....])
%
%	INPUT:
%	input: 3D input image [n_PE, n_PE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%	order: the order of polynomial fitting
%	mask: 3D input image mask [n_PE, n_PE].
%		n_PE: # of phase encoding
%		n_FE: # of frequency encoding
%		"0" indicates the correponding entries are included.
%		"1" indicates the correponding entries are excluded.
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	output_mask: 3D estimated coil map with a spatial mask [n_PE, n_PE].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%	output_mask: 3D estimated coil map without a spatial mask [n_PE, n_PE].
%		n_PE: # of phase encoding steps
%		n_FE: # of frequency encoding steps
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%	
%	fhlin@jul. 12, 2006
%

threshold=[];
mask=[];

flag_reim=0;
flag_maph=1;

flag_distance_weight=0;

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    
    switch lower(option_name)
    case 'threshold'
        threshold=option;
    case 'mask'
    	mask=option;
    case 'flag_maph'
    	flag_maph=option;
    case 'flag_reim'
    	flag_reim=option;
    case 'flag_distance_weight'
        flag_distance_weight=option;
    otherwise
        fprintf('unknown option [%s]...\n',option_name);
    end;
end;

if(ndims(input)==3)
    input=permute(input,[1 2 4 3]);
end;

output=zeros(size(input));
input_mag=abs(input);
%minn=min(input_mag(find(input_mag)));
%input_mag(find(input_mag<minn))=minn;
%input_mag=log(input_mag);

output_mask=zeros(size(input));
output=zeros(size(input));

if(flag_maph)
	for i=1:size(input,4)
		if(~isempty(threshold))
			fprintf('using threshold = [%2.2f]...\n',threshold);
			[output_mask(:,:,:,i),output(:,:,:,i)]=etc_polyfit2(input_mag(:,:,:,i),order,'threshold',threshold,'flag_distance_weight',flag_distance_weight);
		elseif(~isempty(mask))
			%fprintf('using provided image mask...\n');
    	    [output_mask(:,:,:,i),output(:,:,:,i)]=etc_polyfit2(input_mag(:,:,:,i),order,'mask',mask,'flag_distance_weight',flag_distance_weight);
		else
			[output_mask(:,:,:,i),output(:,:,:,i)]=etc_polyfit2(input_mag(:,:,:,i),order,'flag_distance_weight',flag_distance_weight);
		end;
	end;
	%output=exp(output);
	%output_mask=exp(output_mask);
	
	for i=1:size(input,4)
		%phase grafting
  		aa=angle(input(:,:,:,i));
		aa(find(mask<0.5))=0;
		output(:,:,:,i)=output(:,:,:,i).*exp(sqrt(-1).*aa);
		output_mask(:,:,:,i)=output_mask(:,:,:,i).*exp(sqrt(-1).*aa);
	end;
end;

if(flag_reim)
	input_real=real(input);	
	for i=1:size(input,4)
		if(~isempty(threshold))
			fprintf('using threshold = [%2.2f]...\n',threshold);
			[output_mask_real(:,:,:,i),output_real(:,:,:,i)]=etc_polyfit2(input_real(:,:,:,i),order,'threshold',threshold,'flag_distance_weight',flag_distance_weight);
		elseif(~isempty(mask))
			%fprintf('using provided image mask...\n');
			[output_mask_real(:,:,:,i),output_real(:,:,:,i)]=etc_polyfit2(input_real(:,:,:,i),order,'mask',mask,'flag_distance_weight',flag_distance_weight);
		else
			[output_mask_real(:,:,:,i),output_real(:,:,:,i)]=etc_polyfit2(input_real(:,:,:,i),order,'flag_distance_weight',flag_distance_weight);
		end;
	end;


	input_imag=imag(input);	
	for i=1:size(input,4)
		if(~isempty(threshold))
			fprintf('using threshold = [%2.2f]...\n',threshold);
			[output_mask_imag(:,:,:,i),output_imag(:,:,:,i)]=etc_polyfit2(input_imag(:,:,:,i),order,'threshold',threshold,'flag_distance_weight',flag_distance_weight);
		elseif(~isempty(mask))
			%fprintf('using provided image mask...\n');
			[output_mask_imag(:,:,:,i),output_imag(:,:,:,i)]=etc_polyfit2(input_imag(:,:,:,i),order,'mask',mask,'flag_distance_weight',flag_distance_weight);
		else
			[output_mask_imag(:,:,:,i),output_imag(:,:,:,i)]=etc_polyfit2(input_imag(:,:,:,i),order,'flag_distance_weight',flag_distance_weight);
		end;
	end;
	
	output=output_real+sqrt(-1).*output_imag;
	output_mask=output_mask_real+sqrt(-1).*output_mask_imag;
end;

output=squeeze(output);
output_mask=squeeze(output_mask);

return;

function [output, output_all]=etc_polyfit2(img,order,varargin)

threshold=[];
mask=[];
flag_distance_weight=0;

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    
    switch lower(option_name)
    case 'threshold'
        threshold=option;
    case 'mask'
    	mask=option;
    case 'flag_distance_weight'
        flag_distance_weight=option;
    otherwise
        fprintf('unknown option [%s]...\n',option_name);
    end;
end;

if(isempty(mask))
	if(~isempty(threshold))
 		valid_idx=find(img>threshold);
	else
		valid_idx=[1:prod(size(img))];
	end;
else
	valid_idx=find(mask);
end;

if(flag_distance_weight)
    [dummy,maxx_idx]=max(abs(img(:)));
    [max_row,max_col,max_sli]=ind2sub(size(img),maxx_idx);
    center_row=size(img,1)/2;
    center_col=size(img,2)/2;
    center_sli=size(img,3)/2;
    max_row=3*(max_row-center_row)+center_row;
    max_col=3*(max_col-center_col)+center_col;
    max_sli=3*(max_col-center_col)+center_col;
end;

[xx,yy,zz]=meshgrid(1:size(img,2),1:size(img,1),1:size(img,3));
if(flag_distance_weight)
    xx=((xx-max_col)-0.5);
    yy=((yy-max_row)-0.5);
    zz=((zz-max_sli)-0.5);
end;
x_all_idx=xx(1:end)';
y_all_idx=yy(1:end)';
z_all_idx=zz(1:end)';
x=[1:size(img,2)];
y=[1:size(img,1)];
z=[1:size(img,3)];
rimg=img(1:end)';

if(flag_distance_weight)
    max_R=((zz-max_sli-0.5).^2+(yy-max_col-0.5).^2+(xx-max_row-0.5).^2);
else
    max_R=ones(size(img));
end;

%select valid idx
x_idx=x_all_idx(valid_idx);
y_idx=y_all_idx(valid_idx);
z_idx=z_all_idx(valid_idx);
rimg=rimg(valid_idx);
maxr=max_R(valid_idx);

if(max(size(order))==1)
    order_list=[0:order];
else
    order_list=order;
end;

%making regressors
col=1;
for i=1:length(order_list)
    for j=1:(length(order_list)+1-i)
        for k=1:(length(order_list)+2-i-j)
            x_order=order_list(i);
            y_order=order_list(j);
            z_order=order_list(k);
%         dd=(x_idx.^(x_order)).*(y_idx.^(y_order));
%         if(length(find(isinf(dd)))>0)
%             idx=find(isinf(dd));
%             x_idx(idx)
%             y_idx(idx)
%             keyboard;
%         end;
            A(:,col)=(x_idx.^(x_order)).*(y_idx.^(y_order)).*(z_idx.^(z_order));
            A_all(:,col)=(x_all_idx.^(x_order)).*(y_all_idx.^(y_order)).*(z_all_idx.^(z_order));
            col=col+1;
        end;
    end;
end;

output=zeros(1,prod(size(img)));
coeffs=(pinv((A'.*repmat(maxr,[size(A,2),1]))*A)*(A'.*repmat(maxr,[size(A,2),1]))*rimg);
fit=A*coeffs;
fit_all=A_all*coeffs;

output(valid_idx)=fit;
output=reshape(output,size(img));

output_all=reshape(fit_all,size(img));




return;