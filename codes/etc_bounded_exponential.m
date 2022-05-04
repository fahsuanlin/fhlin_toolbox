function samples=etc_bounded_exponetial(sz,lambda,varargin)
%
% etc_bounded_exponential	generates random samples bounded between a range based on an exponential distribution
%
% samples=etc_bounded_exponetial(sz,lambda,varargin)
%
% sz: the size of the sample
% lambda: the lambda parameter of the exponential distribution
% upper: the positive upper bound of the sample (default: 1)
% lower: the positive lower bound of the sample (default: 0)
%
% samples: the generated random samples
%
% fhlin@oct. 20 2010
%

samples=[];
upper=1;
lower=0;

%CDF
cdf_upper=1-exp(-lambda.*upper);
cdf_lower=1-exp(-lambda.*lower);
scaling=1./(cdf_upper-cdf_lower);

%generating uniformly distributed random numbers
samples=rand(sz);

%inverse_transform
samples=-log(1-(samples.*(cdf_upper-cdf_lower)+cdf_lower))./lambda;

return;
