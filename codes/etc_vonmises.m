function pdf=etc_vonmises(x,mu,k)
% proability distribution function of Von Mises distribution
%
% pdf=etc_vonmises(x,mu,k)
%
% x: input argument
% mu: mean
% k: a parameter tuning the "variance" of the normal distribution
%
% pdf: proability distribution function
%
% fhlin@june 4, 2007
%

pdf=exp(k.*cos(x-mu))./2./pi./besseli(0,k);

return;