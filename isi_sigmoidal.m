function [y]=isi_sigmoidal(x,a,b,varargin)
% isi_sigmoidal     calculate the value of sigmodal function given two
% parameters
%
% [y]=isi_sigmoidal(x,a,b,[option, option_value,...]);
%
% this gives the output of a sigmodal function y=1/(1+(-exp(x-a).*b))
%
% fhlin@may 28 2008

y=1./(1+exp(-(x-a).*b));