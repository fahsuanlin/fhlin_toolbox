function []=fmri_profile(data,para)
%fmri_profile	overlay the time course of data with paradigm in 2D graph
%
%fmri_profile(data,para)
%
%data: data to be drawn (1D)
%para: paradigm (1D)
%
%
%written by fhlin@aug. 30, 1999
%
%----------------------------------------------------------------------
figure;
ll=length(data);
lp=length(para);
if ll~=lp
	disp('length of paradigm and data not the same!');
	return;
end;

xx=[1:1:ll];
%stairs(x,para,'r');
maxx=max(max(data));
minn=min(min(data));
for i=1:length(para)
	if(para(i)==1) color='b'; end;
	if(para(i)==-1) color='w'; end;
	x=[i-0.5,i+0.5,i+0.5,i-0.5];
	y=[minn,minn,maxx,maxx];
	patch(x,y,color);
	hold on;
end;

plot(xx,data,'r');
title('time course');
hold off;