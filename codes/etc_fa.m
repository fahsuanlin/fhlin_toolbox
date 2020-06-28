function [fa]=etc_fa(data)
% etc_fa    calculates the anisotrophy of a vector
%
% fa=etc_fa(data)
% data: 1D vector
% fa:   anisotrophy measure
%
% fhlin@feb 11 2015
%

fa=[];

dim=length(data(:)); %dimension of the input vector
avg=mean(data(:)); %average
num=sqrt(sum((data-avg).^2)); %numerator
den=sqrt(sum(data).^2); %denominator

fa=sqrt(dim/2)*num/den;

return;