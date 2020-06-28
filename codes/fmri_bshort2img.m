function []=fmri_bshort2img(folders,prefix,vox)
%fmri_bshort2img 	convert all bshort files in current folder into int16 img format
%
%[]=fmri_bshort2img(folder,prefix,vox)
%
%folders: 	the string defining the target directory. all bshort files in 
%	  	the folder will be converted
%prefix: 	the prefix for the img file
%vox: 1D row vector; vox(1:3) specify the X, Y and Z dimension (in mm) of the data
%
%		the converted files will be written at current directory.
%
%written by fhlin@dec. 23, 1999


d=dir('*.bshort');
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
f=sort(filename(1,1:b));
	
%read bshort files in one folder
for j=1:b
   fn=char(f(j));
   str=sprintf('reading [%s]...',fn);
   disp(str);
   data=fmri_ldbfile(fn);
   
   fn2=sprintf('%s_%s.img',prefix,fn(1:length(fn)-7));
   fn2=lower(fn2);
   str=sprintf('saving [%s]...',fn2);
   disp(str);
   fmri_svimg_int16(data,fn2,vox);
end;
disp('done!');
