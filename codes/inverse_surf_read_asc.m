function [vertices, faces, vertex_data, face_data]=inverse_read_surf_asc(fn);
%inverse_read_surf_asc	read surface file given the file name
%
%[vertices, faces, vertex_data, face_data]=inverse_read_surf_asc(fn);
%
%fn: input surface file name (in ASCII format)
%vertices: number of vertices
%faces: number of faces
%vertex_data: 3-by-vertices matrix; storing the x,y,and z coordinate of the vertices
%face_data: 4-by-faces matrix: storing the indices of the vertices for each surface (quadrangle)
%
% Dec. 03, 2000
%

fprintf('reading ascii surface file [%s]...\n', fn);

fp=fopen(fn,'r','ieee-be.l64');

fprintf('file title:[%s]\n',fgetl(fp));

d=fscanf(fp,'%d',[1 2]);
vertices=d(1);
faces=d(2);

fprintf('ASCII surface: [%d] dipoles (vertices) and [%d] faces\n',vertices,faces);

vertex_data=fscanf(fp,'%f',[4,vertices]);
%vertex_data=vertex_data(1:3,:);

face_data=fscanf(fp,'%d',[4,faces]);
%face_data=face_data(1:3,:);

fclose(fp);


return;







