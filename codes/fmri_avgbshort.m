function avg=fmri_extractbshort(fil, from, to)
% fmri_extractbshort extracting slices in bshort files specified by the filename filter
%
% fmri_extractbshort(filter, from, to)
% filter: the string to filter the files in current directory for averaging.
% from: the starting slice number
% to: the ending slice number
%
% written by fhlin@dec. 22, 1999


d=dir(fil);
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
f=sort(filename(1,1:b));

str=sprintf('loading [%s]...',char(f(1)));
disp(str);	
avg=fmri_ldbfile(char(f(1)));

for i=2:b
	fn=char(f(i));
	str=sprintf('loading [%s]...',fn);
	disp(str);
	data=fmri_ldbfile(fn);
	avg=(avg.*(i-1)+data)./i;	
end;
disp('done!');