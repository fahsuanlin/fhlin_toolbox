function []=fmri_avg_img(folders,outputprefix)
%fmri_avg 	average the raw data in bshort format in different folders
%
%[]=fmri_avg(folders,outputprefix)
%
%folders: 	the string cells which contaings folders' names. all bshort files in 
%	  	the folders will be averaged
%outputprefix: 	the prefix for the averaged file
%
%		the averaged files will be written at current directory.
%
%written by fhlin@aug. 15, 1999


%--------------------------------------------------------------
%environment parameters
%--------------------------------------------------------------
OUTPUTFILEPREFIX='avg';
OUTPUTFILEPREFIX=outputprefix;


%--------------------------------------------------------------
%initialization
%--------------------------------------------------------------
dirnow=pwd;


[Dir,len]=size(folders);

str='reading data file...';
disp(str);
fn=[];

disp('scaning img...');
for i=1:Dir
	%search all the bshort files
	cd(char(folders(i,:)));
	d=dir('*.img');
	filename=struct2cell(d);
	filename=filename(1,:);
	[a,b]=size(filename);
	f=sort(filename(1,1:b));
	
	%read bshort files in one folder
	for j=1:b
		str=char(strcat(folders(i,:),'/',f(j)));
		
		fn=strvcat(fn,str);
	end;
end;


for i=1:b
	for j=1:Dir
		str=fn((i+(j-1)*b),:);
		s=sprintf('reading [%s]...',str);
		disp(s);

		[buffer,vox]=fmri_ldimg(str);
		dat(j,:,:,:)=buffer;
	end;
	avgdat=mean(dat);
	clear dat;
	
	[dummy,y,x,z]=size(avgdat);
	buffer=reshape(avgdat,[y,x,z]);
	
	ffn=sprintf('%s%s.img',OUTPUTFILEPREFIX,num2str(i-1,'%.3d'));
	str=sprintf('writing %s...',ffn);
	disp(str);
	cd(dirnow);
	fmri_svimg_int16(buffer,ffn,vox);
end;


str='done!';
disp(str);