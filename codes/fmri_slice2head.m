function fmri_slice2head(folder,fil,prefix,slices,timepoints)
%fmri_slice2head 	reorder bshort files from slices into heads
%
%fmri_sice2head(folder,filter,prefix,slices,timepoints)
%
%folder: 	the string which contaings folder's name. 
%filter:	the filename filter to get the bshort files to be reordered.
%prefix:	prefix of the reordered files
%slices:	number of slices
%timepoints:	number of timepoins
%
%		the reordered files will be written at current directory.
%
%written by fhlin@aug. 15, 1999

%--------------------------------------------------------------
%initialization
%--------------------------------------------------------------
PWD=pwd;

cd(folder);

d=dir(fil);
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
f=char(sort(filename(1,1:b)));
b
if b~=slices
	disp('# of bshort files error!');
	return;
end;

%read bshort files
[y,x,timepoints]=size(fmri_ldbfile(f(1,:)));
dat=zeros(slices,y,x,timepoints);
close all;
for s=1:slices
	%read all the data file
  	str=f(s,:);
   
	str2=sprintf('reading [%s]...',str);
	disp(str2);
   
   	buffer=fmri_ldbfile(str);
	   	
   	for t=1:timepoints
   		fn=sprintf('%s_%s.bshort',prefix,num2str(t-1,'%03d'));
   		fmri_svbfile(buffer(:,:,t),fn,'append');
   	end;
end;

str='done!';
disp(str);