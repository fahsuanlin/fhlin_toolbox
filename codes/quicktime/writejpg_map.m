%%%%%%%%%%%%%%%  writejpg_map %%%%%%%%%%%%%%%%%
% Like the imwrite routine, but first pass the image data through the indicated
% RGB map.
function writejpg_map(name,I,map)
global MakeQTMovieStatus

[y,x] = size(I);

% Force values to be valid indexes.  This fixes a bug that occasionally 
% occurs in frame2im in Matlab 5.2 which incorrectly produces values of I 
% equal to zero.
I = max(1,min(I,size(map,1)));

rgb = zeros(y, x, 3);
t = zeros(y,x);
t(:) = map(I(:),1)*255; rgb(:,:,1) = t;
t(:) = map(I(:),2)*255; rgb(:,:,2) = t;
t(:) = map(I(:),3)*255; rgb(:,:,3) = t;

imwrite(uint8(rgb),name,'jpeg','Quality',MakeQTMovieStatus.spatialQual*100);
