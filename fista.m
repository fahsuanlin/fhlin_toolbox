function x1=fista(A,b,w,n,x0,L)
% find argmin{w*sum(abs(x1))+1/2*sum((A*x1-b).^2)}.
% w is the weighting of l1 norm.
% n is the iteration number.
% x0 is the initial guess of solution which is set to zero without initial guess. 
% L is the Lipschitz constant.

if nargin==4
    x0=zeros(size(A,2),1);
end
if nargin<=5
    L=eigs(A'*A,1)
end

y1=x0;
t1=1;

for i=1:n
z0=real(y1-A'*(A*y1-b)/L);
x1=sign(z0).*(max(abs(z0)-w/L,zeros(size(z0))));
t2=(1+sqrt(1+4*t1^2))/2;
y2=x1+(t1-1)/t2*(x1-x0);

y1=y2;
x0=x1;
t1=t2;

end

Energy=w*sum(abs(x1))+1/2*norm(A*x1-b).^2

end