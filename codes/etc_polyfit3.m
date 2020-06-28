function [output, output_all]=etc_polyfit3(img,order,varargin)

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

