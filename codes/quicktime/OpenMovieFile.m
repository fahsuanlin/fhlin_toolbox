
%%%%%%%%%%%%%%%  OpenMovieFile %%%%%%%%%%%%%%%%%
% Open a new movie file.  Write out the initial QT header.  We'll fill in
% the correct length later.
function OpenMovieFile
global MakeQTMovieStatus
if isempty(MakeQTMovieStatus.movieFp)
	fp = fopen(MakeQTMovieStatus.movieName, 'wb');
	if fp < 0
		error('Could not open QT movie output file.');
	end
	MakeQTMovieStatus.movieFp = fp;
	cnt = fwrite(fp, [mb32(0) mbstring('mdat')], 'uchar');
end
