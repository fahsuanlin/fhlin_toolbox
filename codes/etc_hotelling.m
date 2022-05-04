function [T2,p,F]=etc_hotelling(data1,data2)
%
% etc_hotelling     multivariate hypothesis testing
%
% [T2,p,F]=etc_hotelling(data1,data2)
%
% data1: a n1*d matrix of n1 observations and d dimension
% data2: a n2*d matrix of n2 observations and d dimension
%
% T2: Hotelling's T^2
% p: p-value
% F: F-statistics
%
% fhlin@jul 17,2002

if(size(data1,2)~=size(data2,2))
    fprintf('non-equal dimension!\n');
    fprintf('error!\n');
    return;
end;

m1=mean(data1);
n1=size(data1,1);
cov1=cov(data1,1);


m2=mean(data2);
n2=size(data2,1);
cov2=cov(data2,1);


d=size(data1,2);

S=(cov1.*n1+cov2.*n2)./(n1+n2);

T2=(n1*n2)/(n1+n2-2)*(m1-m2)*inv(S)*(m1-m2)';

F=(n1+n2+d-1)/d/(n1+n2-2)*T2;
p=1-fcdf(F,d,n1+n2-d-1);

return;


