function y=fmri_ldraw(rawfile,sz,varargin)
%
% fmri_ldraw(y,sz,RawFileName)
%
% Loads a raw data files of int16
% non-integer data will be normalized between 1 to 10000
%
%
% Dec. 04, 2000


kr = findstr(rawfile,'.raw');

if( isempty(kr) ) 
   rawfile=strcat(rawfile,'.raw');
end;

fp=fopen(rawfile,'r','ieee-be.l64');
[y,count]=fread(fp,sz,'int16');
fclose(fp);

disp('DONE!');


