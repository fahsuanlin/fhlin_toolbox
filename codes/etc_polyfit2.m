function [output, output_all]=etc_polyfit2(img,order,varargin)

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

if(isempty(mask))
	if(~isempty(threshold))
 		valid_idx=find(img>threshold);
	else
		valid_idx=[1:prod(size(img))];
	end;
else
	valid_idx=find(mask);
end;

[xx,yy]=meshgrid(1:size(img,2),1:size(img,1));
x_all_idx=xx(1:end)';
y_all_idx=yy(1:end)';
x=[1:size(img,2)];
y=[1:size(img,1)];
rimg=img(1:end)';

%select valid idx
x_idx=x_all_idx(valid_idx);
y_idx=y_all_idx(valid_idx);
rimg=rimg(valid_idx);

if(max(size(order))==1)
    order_list=[0:order];
else
    order_list=order;
end;

%making regressors
col=1;
for i=1:length(order_list)
    for j=1:(length(order_list)+1-i)
        x_order=order_list(i);
        y_order=order_list(j);
        A(:,col)=(x_idx.^(x_order)).*(y_idx.^(y_order));
        A_all(:,col)=(x_all_idx.^(x_order)).*(y_all_idx.^(y_order));
        col=col+1;
    end;
end;

output=zeros(1,prod(size(img)));
coeffs=(pinv(A'*A)*A'*rimg);

fit=A*coeffs;
fit_all=A_all*coeffs;

output(valid_idx)=fit;
output=reshape(output,size(img));

output_all=reshape(fit_all,size(img));




