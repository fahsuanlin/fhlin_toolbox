function [output]=etc_erf(input)
% get the CDF of normal distribution from minus inf to X
% [output]=etc_erf(input)
%input: the integration upper bound
%
%fhlin@oc. 25, 1999

output=(1+erf(input/sqrt(2)))/2;