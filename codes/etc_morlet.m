function [y, amp,t] = etc_morlet(f,width,Fs)
% function y = morlet(f,t,width)
%
% Morlet's wavelet for frequency f and time t.
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet.
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
%
% Ole Jensen, August 1998


dt = 1/Fs;
sf = f/width;
st = 1/(2*pi*sf);

t=-3.5*st:dt:3.5*st;
%[m, amp] = morlet(f(i),t,width);


sf = f/width;
st = 1/(2*pi*sf);
A = 1/sqrt(st*sqrt(pi));
y = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);
amp=A;