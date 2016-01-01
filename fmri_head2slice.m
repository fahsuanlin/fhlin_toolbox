function fmri_head2slice(folder,fil,prefix,slices,timepoints)
%fmri_head2slice 	reorder bshort files from heads into slices
%
%fmri_head2slice(folder,filter,prefix,slices,timepoints)
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

if b~=timepoints
	disp('# of bshort files error!');
	fprintf('file filter: [%s]\n', fil);
	fprintf('total number of files filtered: %d\n', b);
	fprintf('time point: %d \n',timepoints);
	return;
end;

%read bshort file
[y,x,slices]=size(fmri_ldbfile(f(1,:)));
for t=1:timepoints
	%read all the data file
   	str=f(t,:);
   
	str2=sprintf('reading [%s]...',str);
	disp(str2);
   
   	buffer=fmri_ldbfile(str);
   	
   	for s=1:slices
   		fn=sprintf('%s_%s.bshort',prefix,num2str(s-1,'%03d'));
   		fmri_svbfile(buffer(:,:,s),fn,'append');
   	end;
end;

str='done!';
disp(str);