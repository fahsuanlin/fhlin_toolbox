function [dat]=fmri_readbfile(file)
%fmri_readbfile 	read and show the bshort file 
%
%[dat]=fmri_readbfile(file)
%
%file: 	the string cells which contaings bshort file names
%
%written by fhlin@aug. 15, 1999
%
%example:
%
%file={
%'c:\fhlin\attention\941107sa\image7\ahlfors_10366_005_image7_000.bshort',
%'c:\fhlin\attention\941107sa\image7\ahlfors_10366_005_image7_001.bshort',
%'c:\fhlin\attention\941107sa\image7\ahlfors_10366_005_image7_002.bshort'
%};
%

close all;

[files,dummy]=size(file);
fn=char(file);

buffer=fmri_ldbfile(fn(1,:));
[y,x,timepoints]=size(buffer);
sz=[files,size(buffer)];
dat=zeros(sz);

for i=1:files
	str=sprintf('reading [%s]...',fn(i,:));
	disp(str);
	
	dat(i,:,:,:)=fmri_ldbfile(fn(i,:));
end;

for i=1:files
	str=sprintf('show all slices of [%s]? YES=1|NO=0  ',fn(i,:));
	yn=input(str);
	if yn==1
		for j=1:timepoints
			imagesc(reshape(dat(i,:,:,j),y,x));
			str=sprintf('[%d|%d] of [%s]',j,timepoints,fn(i,:));
			title(str);
			maxx=max(max(dat(i,:,:,j)));
			minn=min(min(dat(i,:,:,j)));
			str=sprintf('max=%d min=%d',maxx,minn);
			disp(str);
			pause;
		end;
	end;
	if yn==0
		imagesc(reshape(dat(i,:,:,1),y,x));
		str=sprintf('first slice of [%s]',fn(i,:));
		title(str);
	end;
	disp('press any key for next file');
	pause;
end;

s=sprintf('done!');
disp(s);