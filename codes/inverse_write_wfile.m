function [w] = inverse_write_wfile(fname, w, vertex_index)

%
% [w] = inverse_write_wfile(fname, w, vertex_index)
% writes a vector into a binary 'w' file
%		fname - name of file to write to
%		w     - vector of values to be written
%		vertex_index  - vector of index values
%


% open it as a big-endian file
fid = fopen(fname, 'wb', 'b') ;
vnum = length(w) ;

%vi = vertex_index - 1;
vi = vertex_index;

count=fwrite(fid, 0, 'int16');
count=fwrite3(fid, vnum);

for i=1:vnum
		     fwrite3(fid, vi(i)) ;
		     wt = w(i) ;
		     fwrite(fid, wt, 'float') ;
end

fclose(fid) ;

return;

function count=fwrite3(fid, val)

count=0;
% write a 3 byte integer out of a file
%fwrite(fid, val, '3*uchar') ;
b1 = bitand(bitshift(val, -16), 255) ;
b2 = bitand(bitshift(val, -8), 255) ;
b3 = bitand(val, 255) ;
count=count+fwrite(fid, b1, 'uchar') ;
count=count+fwrite(fid, b2, 'uchar') ;
count=count+fwrite(fid, b3, 'uchar') ;

return;
