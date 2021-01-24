function [p, papp]=inverse_sync_stat(R,n)
% inverse_sync_stat		using rayleigh test to test if there exists an unspecificed mean direction
%
% [p, papp]=inverse_sync_stat(r,n)
%
% r: the averaged radius after n trials (0<=r<=1)
% n: the number of trial
%
% p: p-value
% papp: approximate p-value when n>=50
%
% ref: statistical analysis of circular data, N.I. Fisher, 1993, cambridge press (p. 70)
%
% fhlin@jul. 29, 2003




z=n.*R;

p=exp(-z).*(1+(2.*z-z.^2)/4/n-(24.*z-132.*z.^2+76.*z.^3-9.*z.^4)./288./n.^2);
papp=exp(-z);