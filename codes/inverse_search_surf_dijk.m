function [res,d]=inverse_search_surf_dijk(dipoles,face_data,start_vertex_idx)
%using Dijkstra algorithm to search the nearest dipole sets
%
%[res,d]=inverse_search_surf_dijk(dipoles,face_data,start_vertex_idx)
%
%dipoles: number of dipoles
%face_data: a 2 D matrix (4* number of faces) describing the vertex indices for each face on the brain mesh
%start_vertex_idx: the index for the dipole from which the search starts
%
%res: a cell array with the nearest dipole indices
%	res{i} has 3 comonents:
%	res{i}.start: it is the same as start_vertex_idx
%	res{i}.distance: it is the distance from the collection of vertices to the start vertex
%	res{i}.indices: it is the collection of indices for dipole with nearest res{i}.distance from the start index.
%
% written by fhlin@Mar 06, 2001
%
% dijkstra routine required (from 

n_face=size(face_data,2);

%construct the sparse matrix
%disp('allocation sparse matrix...');
%A=spalloc(dipoles,dipoles,n_face*6);

disp('constructing connection graph...');
%assume triangle surface!!
connection=face_data(1:3,:)+1; %shift zero-based dipole indices to 1-based dipole indices

d1=[connection(1,:);connection(2,:);ones(1,size(connection,2))]';
d2=[connection(2,:);connection(1,:);ones(1,size(connection,2))]';
d3=[connection(1,:);connection(3,:);ones(1,size(connection,2))]';
d4=[connection(3,:);connection(1,:);ones(1,size(connection,2))]';
d5=[connection(2,:);connection(3,:);ones(1,size(connection,2))]';
d6=[connection(3,:);connection(2,:);ones(1,size(connection,2))]';
A=spones(spconvert([d1;d2;d3;d4;d5;d6]));


disp('Dijkstra searching...');
D=inverse_dijkstra(A,start_vertex_idx+1);

disp('collecting indices...');
d=round(D);
count=1;
for i=0:max(d)
	res{count}.start=start_vertex_idx;
	res{count}.distance=i;
	res{count}.indices=find(d==i)-1;
	count=count+1;
end;

disp('done!');

