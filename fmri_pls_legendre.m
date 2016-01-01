function [y]=fmri_pls_legendre(order,x,varargin)
% fmri_pls_legendre	Using Legendre polynomial to construct orthonormal contrast vector
%
% [y]=fmri_pls_legendre(order,x,[bound])
%
% order: the order of the Legendre polynomial. Order from 0 to (order) will be created.
% x: 1-D vector of input point
% bound: 2-element vector representing the lower and upper bound of the interval for othogonality. 
%	 The default is between [-1 1];
%
% y: p by order+1  2D matrix. P is the length of the input X.
%
% fhlin@sep. 7, 2001
%

lower=-1;
upper=1;
if(nargin==3)
	lower=min(varargin{1});
	upper=max(varargin{1});
end;

%normalize input vector for new orthogonal interval
x=(2.*x-lower-upper)./(upper-lower);

y=zeros(order+1,length(x));
for i=0:order
	tmp=legendre(i,x);
	y(i+1,:)=tmp(1,:)./sqrt(1/(2*i+1));
end;

y=y./sqrt(length(x));
y=y';

return;
	
