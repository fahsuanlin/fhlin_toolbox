function [lv]=fmri_bfile2datamat(file,coords,varargin)
%fmri_bfile2datamat 	convert/show several bfiles in datamat form, needing coordinate vector
%
%[datamat]=fmri_bfile2datamat(file,coords,title)
%
%file: a array of bfiles
%coords: 1D coordinate vector
%title: the title for the graph
%	the default is '', empty title.
%	
%datamat: 2D datamat associated with the input coords.
%
%
%written by fhlin@nov. 09, 1999


if nargin==3
	til=char(varargin{:});
else
	til='';
end;


close all;
slice=size(file,1);
a=fmri_ldbfile(char(file{1}));
[y,x,dummy]=size(a);
d=zeros(size(file,1),y,x,dummy);
d3=zeros(size(file,1),y,x);
d3flat=zeros(size(file,1),y*x);
dflat=[];

for i=1:4
	d(i,:,:,:)=fmri_ldbfile(char(file{i}));
	d3(i,:,:)=d(i,:,:,3);
	d3flat(i,:)=reshape(d3(i,:,:),[1,y*x]);
	dflat=[dflat d3flat(i,:)];
end;

lv=dflat(coords);
fmri_datamat_show(lv,coords,y,x,slice);
title(til);