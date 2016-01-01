function []=fmri_shrink(folder)
%fmri_shrink	shrink all the bshort files in a folder to 1/2 original size
%               maintain the central 1/2 x dimension while keep the same y dimension
%	
%fmri_shrink(dir)
%
%folder: 	folder path. all bshort files in the folder will be shrinked.
%
%written by fhlin@aug. 21, 1999
pdir=pwd;
cd(folder);
d=dir('*.bshort');
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
fn=char(sort(filename(1,1:b)));

for i=1:b
	buffer=fmri_ldbfile(fn(i,:));
	[y,x,timepoints]=size(buffer);
	buffer2=zeros(y,x/2,timepoints);
	buffer2(:,:,:)=buffer(:,x/4+1:x/4+x/2,:);
	fn2=sprintf('sh_%s',fn(i,:));
	str=sprintf('saving [%s] ...',fn2);
	disp(str);
	cd(pdir);
	fmri_svbfile(buffer2,fn2);
end;

str='done!';
disp(str);