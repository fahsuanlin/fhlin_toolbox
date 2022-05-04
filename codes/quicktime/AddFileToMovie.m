%%%%%%%%%%%%%%%  AddFileToMovie %%%%%%%%%%%%%%%%%
% OK, we've saved out an image file.  Now add it to the end of the movie
% file we are creating.
% We'll copy the JPEG file in 16kbyte chunks to the end of the movie file.
% Keep track of the start and end byte position in the file so we can put
% the right information into the QT header.
function [pos, len] = AddFileToMovie(imageTmp)
global MakeQTMovieStatus
OpenMovieFile
if nargin < 1
	imageTmp = MakeQTMovieStatus.imageTmp;
end
fp = fopen(imageTmp, 'rb');
if fp < 0
	error('Could not reopen QT image temporary file.');
end

len = 0;
pos = ftell(MakeQTMovieStatus.movieFp);
while 1
	data = fread(fp, 1024*16, 'uchar');
	if isempty(data)
		break;
	end
	cnt = fwrite(MakeQTMovieStatus.movieFp, data, 'uchar');
	len = len + cnt;
end
fclose(fp);
