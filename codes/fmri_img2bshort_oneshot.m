function fmri_img2bshort_oneshot(source_dir,dest_dir,infile_filter,slices,timepoints)
% fmri_img2bshort_oneshot	convert img files to bshort files
%
% fmri_img2bshort_oneshot(source_dir,dest_dir,infile_filter,slices,timepoints)
%
% source_dir: source img file directory
% dest_dir: destinateion bshort file directory
% infile_filter: the file filter for img file included for conversion
% slices: total number of slices
% timepoints: total time points
%
% written by fhlin@jun 2000

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
disp('copy img files...');
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

%convert img to bshort
disp('convert from img to bshort...');
fmri_img2bshort;

%delete img files
disp('delete img files...');
delete(infile_filter);

%convert head to slice
disp('convert from head to slice...');
cd(dest_dir);
infile_filter2=sprintf('bshort_%s',infile_filter)
infile_filter3=sprintf('%s.bshort',infile_filter2)
fmri_head2slice(pwd,infile_filter3,'slice',slices,timepoints);

%delete bshort files in heads
disp('delete bshort files in head...');
delete(infile_filter2);

str='done!';
disp(str);