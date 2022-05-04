function fmri_svraw(y, rawfile,varargin)
%
% fmri_svraw(y,RawFileName)
%
% Saves a raw data files using int16
% non-integer data will be normalized between 1 to 10000
%
%
% Dec. 04, 2000
if(nargin==3&varargin{1}=='rs') %remove singularity
	%remove singularity by setting upperbound at 99% of the original maxima
	fprintf('remove singularity...\n');
	dd=sort(reshape(y,[prod(size(y)),1]));
	mm=dd(round(prod(size(y))*0.99));
	y(y>mm)=mm;

end;



if( isempty(findstr(rawfile,'.raw')) ) 
   rawfile=strcat(rawfile,'.raw');
end;


fstem=rawfile(1:findstr(rawfile,'.raw')-1);

fp=fopen(rawfile,'w','ieee-be.l64');
count=fwrite(fp,round(fmri_scale(y,16383,0)),'int16');
fclose(fp);

fp=fopen(strcat(fstem,'_8bit.raw'),'w','ieee-be.l64');
count=fwrite(fp,round(fmri_scale(y,255,0)),'uchar');
fclose(fp);


if(count~=prod(size(y)))
	disp('writing error!');
	return;
else
	disp('fmri_svraw DONE!');
end;

