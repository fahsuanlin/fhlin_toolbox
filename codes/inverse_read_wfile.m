function [wt,dec_dip] = inverse_read_wfile(fname)

%
% [w,dec_dip] = inverse_read_wfile(fname)
% reads a vector into a binary 'w' file
%				fname - name of file to write to
%				w     - vector of values to be written
%


% open it as a big-endian file
fid = fopen(fname, 'rb', 'b') ;
if (fid < 0)
	 str = sprintf('could not open w file %s.', fname) ;
	 error(str) ;
end


dummy=fread(fid,2,'uchar');
vnum = fread3(fid);

bb=fread(fid,[7,vnum],'uchar')';
bb=bb(:,1:3);
dec_dip=bitshift(bb(:,1),16)+bitshift(bb(:,2),8)+bb(:,3);

%rewinding
fseek(fid,0,-1);
fread(fid,5+3,'uchar');
wt=fread(fid,vnum,'float',3);


fclose(fid) ;

return;

function [retval] = fread3(fid,varargin)

if(nargin==2)
	n=varargin{1};
else
	n=1;
end;

% read a 3 byte integer out of a file

b1 = fread(fid, n, 'uchar');
b2 = fread(fid, n, 'uchar');
b3 = fread(fid, n, 'uchar');
retval = bitshift(b1, 16) + bitshift(b2,8) + b3 ;

return;


