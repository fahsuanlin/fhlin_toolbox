function ret=fmri_coord(coords,x,y,z,input_format,input)
%
%fmri_coord 	convert coord idx to 3D coordinate or vice versa
%
% ret=fmri_coord(coords,x,y,z,input_format,input)
%
% coords: 1D coords vector
% x: # of voxels in x dimension in raw data
% y: # of voxels in y dimension in raw data
% z: # of voxels in z dimension in raw data
% input_format: 
%	input_format==1: convert 3D coordinate (x,y,z) to coord index
%	input_format==2: convert coord index to 3D coordinate (x,y,z)
% inpt: input data
%
% written by fhlin @ Dec. 12, 2000
%

ret=[];

if(input_format==1) %input: 3D coord, output: 1D coord
	
	%idx=x*y*(input(3)-1)+x*(input(1)-1)+input(2);
	idx=x*y*(input(3)-1)+y*(input(1)-1)+input(2);
	ret=find(coords==idx);
	
	if(isempty(ret))
		fprintf('input: %s cannot find corresponding index in coord\n',mat2str(input));
		return;
	else
		fprintf('input: %s <---> output: %s\n',mat2str(input),num2str(ret));
	end;
end;

if(input_format==2) %input: 1D coord, output: 3D coord
	if(input>0 & input<length(coords))
		input=coords(input);
	else
		fprintf('coords index exceeds the length!\n');
		return;
	end;
	
	ret(3)=ceil(input/x/y);
	input=mod(input,x*y);
	
	ret(1)=ceil(input/y);
	input=mod(input,y);
	
	ret(2)=input;

	fprintf('input: %s <---> output: %s\n',mat2str(input),num2str(ret));
end;