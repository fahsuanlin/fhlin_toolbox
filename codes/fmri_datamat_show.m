function []=fmri_datamat_show(datamat,coords,rows,cols,slices)
% fmri_datamat_show	display the filtered 2D spatiotemporal datamatrix
%
% SYNTAX: fmri_datamat_show(datamat,coords,x,y,z)
%
% INPUT:  	
%		datamat: 1D datamat vector
%		coords: 1D coordinate vector
%	  	x: number of pixels in x dimension in each volume
%	  	y: number of pixels in y dimension in each volume
%	  	z: number of slice in z dimension in each volume
%
%
% written by fhlin@feb. 22, 2000

if(size(datamat,1)>1)
	disp('datamat must be one row only!');
	disp('error!');
	return;
end;

nc=rows*cols*slices;
mask = zeros(1,nc);


%figure;
%mask(coords) = 1;
%fmri_mont(reshape(mask,[rows cols 1 slices]));
%title('datamat mask');

figure;
mask(coords) = datamat;
fmri_mont(reshape(mask,[rows cols 1 slices]));
title('datamat');
