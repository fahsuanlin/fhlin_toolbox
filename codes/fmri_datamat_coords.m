function[datamat,coords]=fmri_datamat_coords(rawdata,threshold, varargin)

% fmri_datamat_coords	making coordinate vector from 2D spatiotemporal data matrix
%
% syntax: [datamat,coords]=fmri_datamat_coords(rawdata,threshold,switch);
%
%
% INPUT:  rawdata   is the name of the data matrix that you want made
%		    into a datamat 
%         threshold threshold for the voxel extraction, use max/7 as
%                   threshold if not specified
%	  switch:   to determine either union or joint voxels between slice to be included.
%         switch==1: joinly voxels across slices will be included (default)
%         switch==2: union voxels across slices will be included
%
% written by fhlin@feb. 22, 2000

datamat_switch=1;
[r c] = size(rawdata);
coord=zeros(1,c);
if nargin==3
	datamat_switch=varargin{1};
end;

%----------------------------------------------------------
% open and read in file for first time to make the coords
%----------------------------------------------------------
disp('making the coords vector');


% loop through all the rows
for i=1:r

	% load in a row into 'img'
	%img = rawdata(i,:);
	
	if (threshold ==0)
		threshold=max(double(rawdata(i,:))')/7;
	end;
	
	%mbn=zeros(1,c);
	% make a vector of 1 where value is greater than max/7 and 0 elsehwere
	%mbn=(rawdata(i,:)>(threshold));

	if i==1
	    coord=(abs(double(rawdata(i,:)))>(threshold));
	end

	if(datamat_switch==1)
		% make a joint cumulative mask of all scans
		coord=coord.*(abs(double(rawdata(i,:)))>(threshold));
	end;
	
	if(datamat_switch==2)
		% make a union cumulative mask of all scans
		coord=coord+(abs(double(rawdata(i,:)))>(threshold));
		coord(find(coord))=1;
	end;
	
	cc=sum(coord,2);
%	str=sprintf('[%d]: %d voxels',i,cc);
%	disp(str);
end

%create vector listing the location of brain voxels for output
coords=find(coord==1);

% mask out all stuff not in coords
datamat=double(rawdata(:,coords));

s=sum(coord,2);
str=sprintf('total pixels for a row:%d\n',s);
disp(str);

