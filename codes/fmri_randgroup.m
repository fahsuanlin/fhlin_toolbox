function [out]=fmri_randgroup(z,num_groups)
%
% fmri_randgroup	random grouping input index vector into multiple groups
%
% function [out]=fmri_randgroup(z,num_groups)
%
% z: input index vector (1D row or column vector)
% num_groups: total number of groups
%
% out: it is a cell of multiple sets of indices
%
% written by fhlin@apr. 18,2001

total_length=length(z);

separators=randperm(total_length-1)+0.5;
separators=[0.5,sort(separators(1:num_groups-1)),total_length+0.5];

idx=[1:total_length];
for i=1:num_groups
	select_idx=z(ceil(separators(i)):floor(separators(i+1)));
	out{i}=select_idx;
end;
