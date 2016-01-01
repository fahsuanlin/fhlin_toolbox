function [timeVec,val]=inverse_read_tim(fn)
%
%	inverse_read_tim	read TIM time course file generated from MNE
%
% [timeVec, val]=inverse_read_tim(fn);
%
% fn: the file name of the TIM time course file
%
% timeVec: the time stamp vector
% val:	the value of time course
%
% fhlin@sep 4 2008
%

timeVec=[];
val=[];

fp=fopen(fn,'r');
for i=1:5
	dummy=fgetl(fp);
end;
s=fgetl(fp);
v=fgetl(fp);

timeVec=sscanf(s,'%f');
val=sscanf(v,'%f');
fclose(fp);

return;
