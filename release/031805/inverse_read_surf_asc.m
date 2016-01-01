function [vertices, faces, vertex_data, face_data,idx_2d]=inverse_read_surf_asc(fn,varargin);
%inverse_read_surf_asc	read surface file given the file name
%
%[vertices, faces, vertex_data, face_data]=inverse_read_surf_asc(fn,[option]);
%
%fn: input surface file name (in ASCII format)
%option: 'full' (default): whole brain surface
%	 'patch' :patched surface
%vertices: number of vertices
%faces: number of faces
%vertex_data: 3-by-vertices matrix; storing the x,y,and z coordinate of the vertices
%face_data: 4-by-faces matrix: storing the indices of the vertices for each surface (quadrangle)
%
% fhlin@Dec. 03, 2000
%

flag_full=1;
flag_patch=0;

if(nargin==2)
	if(strcmp(lower(varargin{1}),'patch'))
		flag_patch=1;
		flag_full=0;
	end;
end;

fprintf('reading ascii surface file [%s]...\n', fn);

fp=fopen(fn,'r','ieee-be.l64');

fprintf('file title:[%s]\n',fgetl(fp));

d=fscanf(fp,'%d',[1 2]);
vertices=d(1);
faces=d(2);

fprintf('ASCII surface: [%d] dipoles (vertices) and [%d] faces\n',vertices,faces);

if(flag_full)
	vertex_data=fscanf(fp,'%f',[4,vertices]);
	%vertex_data=vertex_data(1:3,:);

	face_data=fscanf(fp,'%d',[4,faces]);
	%face_data=face_data(1:3,:);
elseif(flag_patch)
	vertex_data_buffer=fscanf(fp,'%f',[4,vertices]);
	%vertex_idx=vertex_data_buffer(1,:);
	idx_2d=vertex_data_buffer(1,:)';
	%vertex_r_idx(vertex_idx+1)=[1:length(vertex_idx)]-1;    %vertex_r_idx(vertex_idx+1)=[1:length(vertex_idx)];	vertex_data(:,vertex_data_buffer(1,:)+1)=vertex_data_buffer(2:4,:);


	face_data=fscanf(fp,'%d',[4,faces]);
	face_data=face_data(2:4,:);    %ff=vertex_r_idx(face_data+1);
	%face_data=reshape(vertex_r_idx(face_data+1),size(face_data));    %face_data=reshape(ff,size(face_data))-1;

  
else
	fprintf('unknown ascii surface!\n');
	fprintf('error!\n');
end;
fclose(fp);


return;







