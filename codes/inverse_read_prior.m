function [R]=read_prior(prior_file)

% read_prior.m
%
% read dipole prior matirx into matlab
%
% [R]=read_prior(prior_file)
%
% R: a structure of following fields:
%	R.dipole_index: 0-based undecimated dipole index for the fMRI prior
%	R.dipole_prior: floating point number of fMRI priors.
%
% Apr. 5, 2001
%

if(isempty(prior_file))
	R=[];
	return;
end;

[data,dipole_index]=inverse_read_wfile(prior_file);

R.dipole_index=dipole_index';
R.dipole_prior=data;

disp('Read PRIOR DONE!');

return;

function output=fread3(fp)

d=fread(fp,3,'uchar');
output=d(3)*256+d(2);

return;



