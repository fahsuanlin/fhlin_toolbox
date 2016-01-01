%%%%%%%%%%%%%%%  AddQTHeader %%%%%%%%%%%%%%%%%
% Go back and write the atom information that allows
% QuickTime to skip the image and sound data and find
% its movie description information.
function AddQTHeader()
global MakeQTMovieStatus

pos = ftell(MakeQTMovieStatus.movieFp);
header = moov_atom;
cnt = fwrite(MakeQTMovieStatus.movieFp, header, 'uchar');
fseek(MakeQTMovieStatus.movieFp, 0, -1);
cnt = fwrite(MakeQTMovieStatus.movieFp, mb32(pos), 'uchar');
fclose(MakeQTMovieStatus.movieFp);
MakeQTMovieStatus.movieFp = [];
