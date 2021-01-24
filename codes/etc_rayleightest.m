function [R,p]=etc_rayleightest(data)
% etc_rayleightest      Rayleigh test for circular uniformity
%
% [R,p]=etc_rayleightest(data)
% data: n*2 matrix of n-observation with x- and y-components
% R: Rayleigh statistics; R=n*r; (r: mean distance from the origin)
% p: probability of type-1 error
%
% fhlin@jan. 20, 2003

n=size(data,1);

%normalizing data for unit circle
r=sqrt(sum(data.^2,2));
data=data./repmat(r,[1,2]);

theta=atan2(data(:,2),data(:,1));
X=mean(cos(theta));
Y=mean(sin(theta));
r=sqrt(X^2+Y^2);

R=n*r;

p=exp(sqrt(1+4*n+4*(n^2-R^2))-1-2*n);