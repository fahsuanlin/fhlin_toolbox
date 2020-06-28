function [b,y_recon,b_err,residual_s2,T,df,p_value]=fmri_regression(y,x);
%fmri_regression 	linear regression 
%
%[b,y_recon,b_err,residual_s2,T,df,p_value]=fmri_regression(y,x);
%
%	Based on the model: y=b*x+e, where e is normal i.i.d
%
%y: n*1 vector of observation
%x: n*p vector of indepedent variable
%
%b: estimated b (p*1)
%y_recon: the reconstructed y based on the linear model (n*1)
%b_err:estiamted covariance matrix of b (p*p)
%residual_s2: estimated variance of the residual (scalar)
%T: associated T value to of estimated parameters (1*p)
%df: degree of freedom (scalar)
%p_value: the p_value of each b to test if the estimated b is significant
%
% written by fhlin @ mar. 08, 2000


[m1,n1]=size(y);
[m2,n2]=size(y);

if(n1~=1)
	disp('y must be a n*1 vector!');
	return;
end;

if(m1~=m2)
	disp('x and y must have the same number of rows1');
	return;
end;



%parameter estimation
b=inv(x'*x)*x'*y;

n=size(x,1);

p=size(x,2);

y_hat=x*b;


%error evaluation
s=sum((y-y_hat).^2)./(n-p); 	%estimate of error variance
residual_s2=s;
	

b_err=s*inv(x'*x);		%estimate of b variance



%test the significance of b
T=b./diag(b_err);
df=n-p;


idx_plus=find(T>0);
idx_minus=find(T<0);

p=zeros(size(T));
if ~isempty(idx_plus)
   p_value(idx_plus)=2-2*tcdf(T(idx_plus),df);
end;
if ~isempty(idx_minus)
	p_value(idx_minus)=2*tcdf(T(idx_minus),df);
end;

y_recon=x*b;




