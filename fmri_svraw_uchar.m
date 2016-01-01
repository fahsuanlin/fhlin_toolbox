function fmri_svraw_uchar(y, rawfile,varargin)
%
% fmri_svraw_uchar(y,RawFileName)
%
% Saves a raw data files using singed 8-bit integer
% non-integer data will be normalized between 0 to 255
%
%
% Dec. 04, 2000

y=floor(fmri_scale(y,255,0));

kr = findstr(rawfile,'.raw');

if( isempty(kr) ) 
   rawfile=strcat(rawfile,'.raw');
end;

fp=fopen(rawfile,'w','ieee-be.l64');
count=fwrite(fp,y,'char');
fclose(fp);

if(count~=prod(size(y)))
	disp('writing error!');
	return;
else
	disp('DONE!');
end;

