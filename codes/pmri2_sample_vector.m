function [s]=pmri2_sample_vector(full_size,acc,varargin)
%
%	pmri2_sample_vector		generate sampling vector in k-space for 2D
%	parallel MRI
%
% 	[s]=pmri2_sample_vector(full_size,acc,[option, option_value]);
% 
%	INPUT:
%	full_size: [#PE1, #PE2], # of phase encoding steps in the full k-space size 
% 	acc: [acc1, acc2], acceleration ratio in two directions. must be integer
% 	option:
%	'flag_center': centerized the sampling vector for center k-space line. the center line is (N/2)+1 in even number k-space size
%	'flag_display': value of either 0 or 1
%		It indicates of debugging information is on or off.
%
%	OUTPUT:
%	s: 2D matrix with entries of 0 or 1 [#PE1, #PE2]
%		#PE1: # of phase encoding in direction 1
%		#PE1: # of phase encoding in direction 2
%		"0" indicates the correponding entries are included.
%		"1" indicates the correponding entries are excluded.
%
%---------------------------------------------------------------------------------------
%	Fa-Hsuan Lin, Athinoula A. Martinos Center, Mass General Hospital
%
%	fhlin@nmr.mgh.harvard.edu
%
%	fhlin@feb. 27, 2006
%


flag_center=1;
symfs=[];
symfs_fixed_r=[];
sample_shift=0;
for i=1:length(varargin)/2
	option=varargin{i*2-1};
	option_value=varargin{i*2};
	
	switch option
	case 'flag_center'
		flag_center=option_value;
	case 'sample_shift'
		sample_shift=option_value;
	case 'symfs'
		symfs=option_value;
	case 'symfs_fixed_r'
		symfs_fixed_r=option_value;
	otherwise
		fprintf('no [%s] option provided. \n',option);
		return;
	end;
end;

[s1]=pmri_sample_vector(full_size(1),acc(1),'flag_center',flag_center,'sample_shift',sample_shift,'symfs',symfs,'symfs_fixed_r',symfs_fixed_r);
[s2]=pmri_sample_vector(full_size(2),acc(2),'flag_center',flag_center,'sample_shift',sample_shift,'symfs',symfs,'symfs_fixed_r',symfs_fixed_r);
s=s1(:)*s2(:)';
return;
