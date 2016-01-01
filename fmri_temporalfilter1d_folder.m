function []=fmri_temporalfilter1d_folder(folder,mask)
%fmri_temporalfilter1d_folder	temporal average the raw data in a folder by 1D mask
%
%[]=fmri_temporalfilter1d_folder(folder,mask)
%
%folder: the name of the folder, each bshort file will be read and filtered by the mask.
%mask: the 1D average mask. mask=[1 1] will do a 2 voxel averaging.
%
%NOTE: all data must be in dimension of [x,y,time].
%
%written by fhlin@aug. 27, 1999


str='reading data file...';
disp(str);


%search all the bshort files
cd(folder);
d=dir('*.bshort');
filename=struct2cell(d);
filename=filename(1,:);
[a,b]=size(filename);
f=sort(filename(1,1:b));
	
%read bshort files in one folder
for j=1:b
	%read all the data file
	str=char(strcat(folder,'/',f(j)));

	s=sprintf('reading [%s]...',str);
	disp(s);
	buffer=fmri_ldbfile(str);
		
	s=sprintf('filtering [%s]...',str);
	disp(s);
	filter_data=fmri_temporalfilter1d(buffer,mask);
		
		
	fn=sprintf('tfil_%s',char(f(j)));
	s=sprintf('saving [%s%s]...',char(strcat(folder,'/')),fn);
	disp(s);
	fmri_svbfile(filter_data,fn);
end;


