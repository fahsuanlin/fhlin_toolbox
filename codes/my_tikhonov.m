function [x_lambda] = my_tikhonov(U,s,V,b,lambda,x_0) 

% Initialization. 
if (min(lambda)<0) 
  error('Illegal regularization parameter lambda') 
end 
%n = size(V,1); 
beta = U'*b; 
zeta = repmat(s,[1,size(b,2)]).*beta; 

 
omega = V'*x_0;
x_lambda = V*((zeta + lambda^2*omega)./(repmat(s,[1,size(b,2)]).^2 + lambda^2)); 

