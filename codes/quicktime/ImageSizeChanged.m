%%%%%%%%%%%%%%%  ImageSizeChanged %%%%%%%%%%%%%%%%%
% Check to see if the image size has changed.  This m-file can't 
% deal with that, so we'll return an error.
function err = ImageSizeChanged(newsize)
global MakeQTMovieStatus

newsize = newsize(1:2);			% Don't care about RGB info, if present
oldsize = MakeQTMovieStatus.imageSize;
err = 0;

if sum(oldsize) == 0
	MakeQTMovieStatus.imageSize = newsize;
else
	if sum(newsize ~= oldsize) > 0
		fprintf('MakeQTMovie Error: New image size');
		fprintf('(%dx%d) doesn''t match old size (%dx%d)\n', ...
			newsize(1), newsize(2), oldsize(1), oldsize(2));
		fprintf('   Can''t add this image to the movie.\n');
		err = 1;
	end
end
