function [datamat,coords,x,y]=fmri_datamat(files,datamat_threshold,datamat_joint_union,varargin)
%fmri_datamat 	generate the datamat 
%
%[datamat,coords]=fmri_datamat(files,datamat_threshold,datamat_joint_union,select_idx)
%
%files: string cell array with filenames conformed to the structure of 2D spatiotemporal data matrix
%datamat_threshold: the threshold to disgard the unnecessary voxels; 0 using the default-1/7 of the maximail value
%datamat_joint_union: to determine either union or joint voxels between slice to be included.
%         'joint': joinly voxels across slices will be included (default)
%         'union': union voxels across slices will be included
%select_idx: 1D vector of selection indices
%	for ANALYZE format (img), this specifies the slices to be extracted.
%	for Bfile format (bshort/bfloat), this specifies the timepoints to be extracted.
%	
%	The default is: all slices (timepoints) are selected.
%datamat: filtered 2D spatiotemporal data matrix
%coords: the coordinate vector associated with filtered 2D spatiotemporal data matrix
%x:	number of pixel in x dimension for each sub image
%y:	number of pixel in y dimension for each sub image
%
%
%written by fhlin@feb. 22, 1999

if (nargin==2)
   datamat_joint_union='joint';
end;

switch(datamat_joint_union)
	case 'joint'
		joint_union=1;
	case 'union'
		joint_union=2;
end;

select_idx=[];
if(nargin==4)
	select_idx=varargin{1};
end;
d=[];
[m,n]=size(files);
for i=1:m
	for j=1:n
		str=lower(files{i,j});
		if(~isempty(findstr(str,'.img')))
			fprintf('loading [%s]...([%s])\n',str,num2str(size(d)));
			buffer=fmri_ldimg(str);
			if(nargin==3|isempty(select_idx))
				sz=size(buffer,3);
				select_idx=[1:sz];
			end;
			buffer=buffer(:,:,select_idx);
			[y,x,z]=size(buffer);
			%data{i,j}=reshape(buffer,[1,x*y*z]);
         d(i,(j-1)*(x*y*z)+1:j*x*y*z)=reshape(buffer,[1,x*y*z]);
         d=int16(d);
		end;
		if(~isempty(findstr(str,'.bshort'))|~isempty(findstr(str,'.bfloat')))
			fprintf('loading [%s]...([%s])\n',str,num2str(size(d)));
			buffer=fmri_ldbfile(str);
			if(nargin==3|isempty(select_idx))
				sz=size(buffer,3);
				select_idx=[1:sz];
			end;
			buffer=buffer(:,:,select_idx);
			[y,x,t]=size(buffer);
			%data{i,j}=reshape(buffer,[x*y,t])';
         d((i-1)*t+1:i*t,(j-1)*(x*y)+1:j*x*y)=reshape(buffer,[x*y,t])';
         d=int16(d);
			z=n;
		end;
	end;
end;

%
% convert data from cell to array
%
%disp('converting data from cell to array...');
%d=[];
%for i=1:size(data,1)
%	data=cat(1,data{:});
%	
%end;
%clear data;


[datamat coords]=fmri_datamat_coords(d,datamat_threshold,joint_union); 	%making the datamat
clear d;

fmri_datamat_show(datamat(1,:),coords,y,x,z); 		%show the datamat



		