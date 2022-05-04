function [motion_x,motion_y]=fmri_motionvector(data)
%fmri_motionvector	draw the motion in the time-series of fMRI data
%[motion_x,motion_y]=fmri_motionvector(data)
%data: 3D data matrix, in (Y,X,timepoints)
%
%fhlin@sep. 14, 1999
[y,x,timepoints]=size(data);
buffer=zeros(y,x);
for i=1:timepoints
	buffer=reshape(data(:,:,i),y,x);
	sumx=sum(buffer,1);
	sumy=sum(buffer,2);
	wx=sum(sumx);
	wy=sum(sumy);
	sx=[1:1:length(sumx)];
	sy=[1:1:length(sumy)];
	motion_x(i)=sx*sumx'/wx;
	motion_y(i)=sy*sumy/wy;
end;

idx=[1:1:timepoints];
subplot(211);
plot(idx,motion_x);
title('x-motion');
grid;
xlabel('timepoints');
ylabel('center of mass');

subplot(212);
plot(idx,motion_y);
title('y-motion');
grid;
xlabel('timepoints');
ylabel('center of mass');

