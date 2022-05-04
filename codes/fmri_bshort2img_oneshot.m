function fmri_bshort2img_oneshot(source_dir,dest_dir,infile_filter,slices,timepoints,vox)

%test of source directory
if(~isdir(source_dir))
	disp('source dir error!');
	return;
end;	

%test of destination directory
if(~isdir(source_dir))
	disp('destination dir error!');
	return;
end;

%delete all files in desitnation directory
disp('deleting all files in destination directory...');
cd(dest_dir);
delete('*.*');

% copy source file to destination file
disp('copy bshort files...');
cd(source_dir);
fil=sprintf(infile_filter);
d=dir(fil);
dd=struct2cell(d);
filename=dd(1,:);
[a,b]=size(filename);
f=filename(1,1:b);
for j=1:b
	ff=[];
	fn1=char(f(j));
	sf=sprintf('%s\\%s',source_dir,fn1);
	df=sprintf('%s\\%s',dest_dir,fn1);
	copyfile(sf,df);
end;

%change directory to destination directory
pwd
cd(dest_dir);


%convert slice to head
disp('convert from slice to head...');
infile_filter2=sprintf('%s.bshort',infile_filter);
fmri_slice2head(pwd,infile_filter2,'head',slices,timepoints);

%delete bshort slice files
disp('delete bshort files...');
delete(infile_filter);


%convert bshort to img
disp('convert from bshort to img...');
fmri_bshort2img(pwd,'img',vox);


%delete bshort files in heads
disp('delete bshort files in head...');
delete('head*');

str='done!';
disp(str);