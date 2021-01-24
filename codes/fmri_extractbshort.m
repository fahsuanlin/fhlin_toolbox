function avg=fmri_extractbshort(fil, from, to, skip)
% fmri_extractbshort extracting slices in bshort files specified by the filename filter
%
% fmri_extractbshort(filter, from, to)
% filter: the string to filter the files in current directory for averaging.
% from: the starting slice number
% to: the ending slice number
% skip: skip index between slices, 1 means no skipping.
%
% written by fhlin@dec. 22, 1999


d=dir(fil);
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
f=sort(filename(1,1:b));

for i=1:b
	fn=char(f(i));
	str=sprintf('loading [%s]...',fn);
	disp(str);
	data=fmri_ldbfile(fn);
	data=data(:,:,from:skip:to);
	
	fn2=sprintf('sh_%s',fn);
	str=sprintf('savinging [%s]...',fn2);
	disp(str);
	fmri_svbfile(data,fn2);
end;
disp('done!');