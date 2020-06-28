function [timeVec, val]=neuron_read_dat(fn)
% read NEURON vector file
%
% [timeVec, val]=neuron_read_dat(filename)
%
% filename: path/filename of the NEURON vector data file
%
% timeVec: time vector (ms)
% val: value 
%
% fhlin@june 26 2006
%

[timeVec,val]=textread(fn,'%f%f','headerlines',2);
return;