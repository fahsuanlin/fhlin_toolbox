function [covv]=fmri_ptselect(bfile)
%fmri_ptselect	select ROI from mouse click after reading bshort or bfloat file
%
%[covv]=fmri_ptselect(bfile)
%bfile: the file name of bshort or bfloat file. with full path
%covv: the cov. matrix of the selected points.
%
%written by fhlin@aug. 27. 1999
close all;
d=fmri_ldbfile(bfile);

[x,y,timepoints]=size(d);

imagesc(d(:,:,1));

[xx,yy]=getpts(gcf);
x=floor(xx);
y=floor(yy);

sets=length(x);

buffer=zeros(timepoints,sets);

figure;
for i=1:sets
	buffer(:,i)=reshape(d(y(i),x(i),:),[timepoints,1]);
	plot(buffer(:,i));
	str=sprintf('[%d] time profile',i);
	title(str);
	pause;
end;

covv=cov(buffer);
