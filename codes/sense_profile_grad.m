function [p]=sense_profile_grad(sz)
%
% sense_profile_grad	create circular sensitivity profile
%
% [p]=sense_profile_grad(sz)
% sz: 2-element vector describing the dimension of the output matrix
% p: output 2D sensitivity profile
%
% fhlin@sep. 15,2001

sz1_start=floor(sz(1)/2)-sz(1);
sz1_end=sz1_start+sz(1)-1;
sz2_start=floor(sz(2)/2)-sz(2);
sz2_end=sz2_start+sz(2)-1;

[x,y]=meshgrid([sz1_start:sz1_end],[sz2_start:sz2_end]);
p=sqrt(x.^2+y.^2);
