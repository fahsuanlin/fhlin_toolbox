function c=inverse_crossproduct(a,b)
%  inverse_crossproduct     calculate the cross (outer) product between two
%  vectors in a 3D Cartesian coordiate system
%
%  c=inverse_crossproduct(a,b)
%
%  a: 3x1 input vector
%  b: 3x1 input vector
%  c: 3x1 output vector
%
%  fhlin@dec 5 2010
%

c=[];
a=a(:);
b=b(:);
A=[0 -a(3) a(2); a(3) 0 -a(1); -a(2) a(1) 0];
c=A*b;
return;