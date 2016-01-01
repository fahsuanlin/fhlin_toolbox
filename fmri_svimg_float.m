function [] = fmri_svimg_float(data,imgfile,vox)
%fmri_svimg_float	save 3d image data into 32-bit float img file format (ANALYZE)
%
%fmri_svimg_float(data,imgfile,vox)
%
%data: 3D data of voxel
%imgfile: the destination img file
%vox: 1D row vector; vox(1:3) represents the X, Y and Z dimension (in mm).
%
% written by fhlin@oct. 18, 1999


%___________________________________________________________________________
%
%refer to SPM spm_hwrite.m and spm_hread.m
%
%
% FORMAT [s] = spm_hwrite(P,DIM,VOX,SCALE,TYPE,OFFSET,ORIGIN,DESCRIP);
%
% P       - filename 	     (e.g 'spm' or 'spm.img')
% DIM     - image size       [i j k [l]] (voxels)
% VOX     - voxel size       [x y z [t]] (mm [sec])
% SCALE   - scale factor
% TYPE    - datatype (integer - see spm_type)
% OFFSET  - offset (bytes)
% ORIGIN  - [i j k] of origin  (default = [0 0 0])
% DESCRIP - description string (default = 'spm compatible')
%
% s       - number of elements successfully written (should be 348)
%__________________________________________________________________________



% ensure correct suffix {.hdr} and open header file
%---------------------------------------------------------------------------

%normalize data
maxx=max(max(max(data)));
minn=min(min(min(data)));
bfile_data=data;



dd=size(bfile_data);
DIM(1)=dd(2);
DIM(2)=dd(1);
if(length(dd)>=3)
	DIM(3)=dd(3);
else	
	DIM(3)=1;
end;
VOX=vox;
OFFSET=0;
ORIGIN=[0 0 0];
DESCRIP='from matlab matrix';
SCALE=1;
TYPE=16;

%preparing img header
P=imgfile;
P               = P(P ~= ' ');
q    		= length(P);
if q>3
	if P(q - 3) == '.'; P = P(1:(q - 4)); end
end;
P1     		= [P '.hdr'];
P2     		= [P '.img'];
P=P1;

fid             = fopen(P,'w','ieee-be');

if (fid == -1),
	error(['Error opening ' P '. Check that you have write permission.']);
end;
%---------------------------------------------------------------------------
data_type 	= ['dsr      ' 0];

P     		= [P '                  '];
db_name		= [P(1:17) 0];

% set header variables
%---------------------------------------------------------------------------
DIM		= DIM(:)'; if size(DIM,2) < 4; DIM = [DIM 1]; end
VOX		= VOX(:)'; if size(VOX,2) < 4; VOX = [VOX 0]; end
dim		= [4 DIM(1:4) 0 0 0];	
pixdim		= [0 VOX(1:4) 0 0 0];
vox_offset      = OFFSET;
funused1	= SCALE;
glmax		= 1;
glmin		= 0;
bitpix 		= 0;
descrip         = zeros(1,80);
aux_file        = ['none                   ' 0];
origin          = [0 0 0 0 0];

%---------------------------------------------------------------------------
%if TYPE == 1;   bitpix = 1;  glmax = 1;        glmin = 0;	end
%if TYPE == 2;   bitpix = 8;  glmax = 255;      glmin = 0;	end
%if TYPE == 4;   bitpix = 16; glmax = 32767;    glmin = 0;  	end
%if TYPE == 8;   bitpix = 32; glmax = (2^31-1); glmin = 0;	end
if TYPE == 16;  bitpix = 32; glmax = 1;        glmin = -1;	end
%if TYPE == 64;  bitpix = 64; glmax = 1;        glmin = 0;	end

%---------------------------------------------------------------------------
if nargin >= 7; origin = [ORIGIN(:)' 0 0];  end
if nargin <  8; DESCRIP = 'spm compatible'; end

d          	= 1:min([length(DESCRIP) 79]);
descrip(d) 	= DESCRIP(d);

fseek(fid,0,'bof');

% write (struct) header_key
%---------------------------------------------------------------------------
fwrite(fid,348,		'int32');
fwrite(fid,data_type,	'char' );
fwrite(fid,db_name,	'char' );
fwrite(fid,0,		'int32');
fwrite(fid,0,		'int16');
fwrite(fid,'r',		'char' );
fwrite(fid,'0',		'char' );

% write (struct) image_dimension
%---------------------------------------------------------------------------
fseek(fid,40,'bof');

fwrite(fid,dim,		'int16');
fwrite(fid,'mm',	'char' );
fwrite(fid,0,		'char' );
fwrite(fid,0,		'char' );

fwrite(fid,zeros(1,8),	'char' );
fwrite(fid,0,		'int16');
fwrite(fid,TYPE,	'int16');
fwrite(fid,bitpix,	'int16');
fwrite(fid,0,		'int16');
fwrite(fid,pixdim,	'float');
fwrite(fid,vox_offset,	'float');
fwrite(fid,funused1,	'float');
fwrite(fid,0,		'float');
fwrite(fid,0,		'float');
fwrite(fid,0,		'float');
fwrite(fid,0,		'float');
fwrite(fid,0,		'int32');
fwrite(fid,0,		'int32');
fwrite(fid,glmax,	'int32');
fwrite(fid,glmin,	'int32');

% write (struct) image_dimension
%---------------------------------------------------------------------------
fwrite(fid,descrip,	'char');
fwrite(fid,aux_file,    'char');
fwrite(fid,0,           'char');
fwrite(fid,origin,      'int16');
if fwrite(fid,zeros(1,85), 'char')~=85
	fclose(fid);
	delete(P);
	error(['Error writing ' P '. Check your disk space.']);
end

s   = ftell(fid);
fclose(fid);



%write data
fid=fopen(P2,'w','ieee-be');
[y,x,t]=size(bfile_data);
total=x*y*t;
buffer=zeros([x y t]);
for i=1:t
	bfile_data(:,:,i)=flipud(bfile_data(:,:,i));
	buffer(:,:,i)=reshape(bfile_data(:,:,i)',[x y]);
end;
c=fwrite(fid,buffer,'float32');
fclose(fid);