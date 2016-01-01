function [flag]=neuron_write_dat(timeVec, val, fn, varargin)
% write NEURON vector into a file
%
% [flag]=neuron_write_dat(timeVec, val, filename, [label])
%
% timeVec: time vector (ms)
% val: value 
% filename: path/filename of the NEURON vector data file
% [label]: a text label for the description
%
% flag: return 1 if seccessful, 0 otherwise
%
% fhlin@june 26 2006
%
flag=0;

if(nargin==4)
    label=varargin{1};
else
    cc=clock;
    label=sprintf('MATLAB DATA [%s |%d:%d:%d]',date,round(cc(4)),round(cc(5)),round(cc(6)));
end;

fp=fopen(fn,'w');

fprintf(fp,'label:%s\n',label);
fprintf(fp,'%d\n',length(timeVec));
for i=1:length(timeVec)-1
    fprintf(fp,'%f\t%e\n',timeVec(i),val(i));
end;
fprintf(fp,'%f\t%e',timeVec(i+1),val(i+1));
fclose(fp);
flag=1;
return;