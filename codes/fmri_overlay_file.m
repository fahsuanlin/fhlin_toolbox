function fmri_overlay_file(struct_file,func_file,idx,threshold,varargin)
% fmri_overlay_file(struct_file,func_file,idx,threshold,slice_idx)
%
% loading structual underlay and functional overlay images from files
%
%struct_file: file name for the structural underlay
%
%func_file: file name for the functional overlay
%
%idx: a string specifying output mode
%	idx='>': voxels of overlay greater or equal to threshold will be shown
%	idx='<': voxels of overlay smaller or equal to threshold will be shown
%	idx='~': voxels of overlay between 2 thresholds will be shown
%threshold: the threshold for overlay, a 2-element vector
%	idx='>': threshold(1) is the minimal value to be shown.
%		 (threshold(2) is an option; all voxels >=threshold(2) will be set as threshold(2).)
%	idx='<': threshold(1) is the maximal value to be shown.
%		 (threshold(2) is an option; all voxels <=threshold(2) will be set as threshold(2).)
%	idx='~': voxels between threshold(1) and threshold(2) will be shown.
%silce_idx: selected slice indices to be shown. 
%	(default: all slices are shown.)
%
%image toolbox function 'imresize' is used.
%
% written by fhlin@may 22, 2000

disp('loading structural underlay...');
if(~isempty(findstr(struct_file,'bfloat')))
	
	disp('loading bfloat file...');
	struct=fmri_ldbfile(struct_file);

	elseif(~isempty(findstr(struct_file,'bshort')))

		disp('loading bshort...');
		struct=fmri_ldbfile(struct_file);

		elseif(~isempty(findstr(struct_file,'img')))

			disp('loading img...');
			struct=fmri_ldimg(struct_file);
			
			else
				disp('loading structural underlay error!');
				return;
end;

disp('loading functional overlay...');
if(~isempty(findstr(func_file,'bfloat')))
	
	disp('loading bfloat file...');
	func=fmri_ldbfile(func_file);

	elseif(~isempty(findstr(func_file,'bfloat')))

		disp('loading bshort...');
		func=fmri_ldbfile(func_file);

		elseif(~isempty(findstr(func_file,'img')))

			disp('loading img...');
			func=fmri_ldimg(func_file);
			
			else
				disp('loading functional overlay error!');
				return;
end;
		

if(nargin>=5)
	slice_idx=varargin{1};
else
	s=size(struct,3);
	slice_idx=[1:s];	
end;

		
struct=struct(:,:,slice_idx);
func=func(:,:,slice_idx);
	

sz_struct=size(struct);
sz_func=size(func);

if(sz_struct~=sz_func)
	disp('size of structual image is differernt from functional one!');
	disp('error!');
	return;
end;

[y,x,z]=size(struct);

close all;
figure(1);
fmri_mont(reshape(struct,[y,x,1,z]));
data_struct=getimage;
close(1);
figure(1);
fmri_mont(reshape(func,[y,x,1,z]));
data_func=getimage;
close(1);

fmri_overlay(data_struct,data_func,idx,threshold,threshold);


