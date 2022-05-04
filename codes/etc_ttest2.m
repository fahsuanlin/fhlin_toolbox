function [p,t]=etc_ttest2(x,y,varargin)

flag_2sided=0;

if(~isempty(varargin))
	flag_2sided=varargin{1};
end;

if(size(x,2)>1&size(y,2)==1)
    y=repmat(y,[1,size(x,2)]);
end;

if(size(y,2)>1&size(x,2)==1)
    x=repmat(x,[1,size(y,2)]);
end;

mean_x=mean(x,1);
mean_y=mean(y,1);
nx=size(x,1);
ny=size(y,1);
var_x=var(x,1);
var_y=var(y,1);
sp=sqrt(((nx-1).*var_x+(ny-1).*var_y)./(nx+ny-2));

t=zeros(1,size(x,2));
idx=find(sp>0);
if(~flag_2sided)
	t(idx)=(mean_x(idx)-mean_y(idx))./sp(idx)./sqrt(1/nx+1/ny);
else
    t(idx)=abs((mean_x(idx)-mean_y(idx)))./sp(idx)./sqrt(1/nx+1/ny);
end;
p=[];
if(~flag_2sided)
	p=1 - tcdf(t,nx+ny-2);
else
	p=2*tcdf(-t,nx+ny-2);
end;
return;
