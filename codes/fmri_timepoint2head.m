function [dat]=fmri_timepoint2head(inputprefix,outputprefix)
%fmri_timepoint2head 	load the bfiles which are the same slice at different timepoint and repack them into individual heads
%
%[]=fmri_avg(timepoint_prefix,head_prefix)
%
%timepoint_prefix: the prefix of the input bfiles, which are of the same slice at different timepoint
%head_prefix: the prefix of the output bfiles, which are of the same timepoints for different slice
%
%
%
%written by fhlin@oct. 18, 1999

%--------------------------------------------------------------
%initialization
%--------------------------------------------------------------
dirnow=pwd;


str='reading data file...';
disp(str);
fn=[];

disp('scaning bfiles...');
%search all the bshort files
filter=strcat(inputprefix,'*.bshort');
d=dir(filter);
filename=struct2cell(d);
filename=filename(1,:);
[a,slice]=size(filename);
f=sort(filename(1,1:slice));
	
%read bshort files in one folder
for j=1:slice
	str=char(strcat(pwd,'/',f(j)));
	fn=strvcat(fn,str);
end;


for i=1:slice
	str=fn(i,:);
	s=sprintf('reading [%s]...',str);
	disp(s);

	buffer=fmri_ldbfile(str);
	dat(i,:,:,:)=buffer;
end;

[slice,x,y,timepoint]=size(dat);

for i=1:timepoint
	f=strcat(outputprefix,'_',num2str(i,'%03d'),'.bshort');
	str=sprintf('saving [%s]...',f);
	disp(str);
	data=shiftdim(dat,1);
	d=reshape(data(:,:,i,:),[x,y,slice]);
	fmri_svbfile(d,f);
end;
	

str='done!';
disp(str);