function fmri_img2bshort()
%
% fmri_img2bshort
%
% convert all *.img files in the current directory to bshort file
% the converted file will be named as 'bshort_XXXX.bshort', where
% 'XXXX' is the original file name without '.img' suffix
% converted files will be stored in the current working directory.
%
% written by fhlin@dec. 22, 1999

d=dir('*.img');
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
f=sort(filename(1,1:b));
	
%read img files in one folder
for i=1:b
	fn=char(f(i));
	str=sprintf('loading [%s]...',fn);
	disp(str);
	data=fmri_ldimg(fn);
		
	fn2=sprintf('bshort_%s.bshort',fn(1:length(fn)-4));
        fn2=lower(fn2);
	str=sprintf('saving [%s]...',fn2);
	disp(str);
	fmri_svbfile(data,fn2);
end;
