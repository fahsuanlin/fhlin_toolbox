function [y]=fmri_pls_polynomial(order,x,varargin)
% fmri_pls_polynomial	Using polynomial to construct orthonormal contrast vector
%
% [y]=fmri_pls_polynomial(order,x,['inv'])
%
% order: the order of the polynomial. Order from 0 to (order) will be created.
% x: 1-D vector of input point
% 'inv': specify both positive and negative power of polynomial bases are generated. i.e. x.^(order) and x.^(-order).
% y: p by order+1  2D matrix. P is the length of the input X.
%    y is orthonormalized to have the same span as the polynomial vectors suggested by input x.
%
% fhlin@sep. 15, 2001
%

x=reshape(x,[prod(size(x)),1]);

flag_inv=0;

if(nargin==3&strcmp(lower(varargin{1}),'inv')==1)
	flag_inv=1;
end;

y=[];
for i=0:order
	if(i==0)
		y=[y,x.^i];
	else
		if(flag_inv)
			y=[y,x.^i,x.^(-i)];
		else
			y=[y,x.^i];
		end;
	end;
end;



return;
	
