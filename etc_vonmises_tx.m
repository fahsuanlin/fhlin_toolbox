function tx=etc_vonmises_tx(x,mu,k)
% transform an angle to another based on the assigned Von Mises distribution
%
% tx=etc_vonmises_tx(x,mu,k)
%
% x: input argument
% mu: mean
% k: a parameter tuning the "variance" of the normal distribution
%
% tx: transformed angle
%
% fhlin@june 4, 2007
%

tx=[];
y0=[-pi:0.01:pi]';
x0=etc_vonmises_cdf(y0,0,k); 

tx=angle(exp(sqrt(-1).*(griddatan(x0.*2.*pi-pi,y0,angle(exp(sqrt(-1).*(x(:)-mu(:)))),'nearest')+mu(:))));

tx=reshape(tx,size(x));

return;