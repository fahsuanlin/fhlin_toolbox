function [d]=inverse_search_dijk(face_data,start_vertex_idx,varargin)
%using Dijkstra algorithm to search the nearest dipole sets
%
%[res,d]=inverse_search_dijk(face_data,start_vertex_idx)
%
%dipoles: number of dipoles
%face_data: a 2 D matrix (4* number of faces) describing the vertex indices for each face on the brain mesh
%start_vertex_idx: the index for the dipole from which the search starts
%
%res: a cell array with the nearest dipole indices
%	res{i} has 3 comonents:
%	res{i}.start: it is the same as start_vertex_idx
%	res{i}.distance: it is the distance from the collection of vertices to the start vertex
%	res{i}.indices: it is the collection of indices for dipole with nearest res{i}.distance from the start index. these are 0-based indices.
%
% written by fhlin@Mar 06, 2001
% 
% dijkstra routine required. 

A=[];
V=[];
flag_display=0;
flag_base0=1;

for i=1:floor(length(varargin)/2)
	option=varargin{2*i-1};
	option_value=varargin{2*i};
	switch lower(option)
	case 'a'
		A=option_value;
	case 'v'
		V=option_value;
	case 'flag_base0'
		flag_base0=option_value;
	case 'flag_display'
		flag_display=option_value;
	otherwise
		fprintf('unknown option [%s]!\n',option);
		fprintf('error!\n');
		return;
	end;
end;

%n_face=size(face_data,2);

%construct the sparse matrix
%disp('allocation sparse matrix...');
%A=spalloc(dipoles,dipoles,n_face*6);

if(isempty(A))
	if(flag_display) disp('constructing connection graph...'); end;
	%assume triangle surface!!
	if(flag_base0)
		connection=face_data(1:3,:)+1; %shift zero-based dipole indices to 1-based dipole indices
	else
		connection=face_data(1:3,:); %shift zero-based dipole indices to 1-based dipole indices
	end;
	if(isempty(V))
		d1=[connection(1,:);connection(2,:);ones(1,size(connection,2))]';
		d2=[connection(2,:);connection(1,:);ones(1,size(connection,2))]';
		d3=[connection(1,:);connection(3,:);ones(1,size(connection,2))]';
		d4=[connection(3,:);connection(1,:);ones(1,size(connection,2))]';
		d5=[connection(2,:);connection(3,:);ones(1,size(connection,2))]';
		d6=[connection(3,:);connection(2,:);ones(1,size(connection,2))]';
	else
		dd=sqrt(sum((V(:,connection(1,:))-V(:,connection(2,:))).^2,1));
		d1=[connection(1,:);connection(2,:);dd]';
		d2=[connection(2,:);connection(1,:);dd]';
		dd=sqrt(sum((V(:,connection(2,:))-V(:,connection(3,:))).^2,1));
		d3=[connection(1,:);connection(3,:);dd]';
		d4=[connection(3,:);connection(1,:);dd]';
		dd=sqrt(sum((V(:,connection(3,:))-V(:,connection(1,:))).^2,1));
		d5=[connection(2,:);connection(3,:);dd]';
		d6=[connection(3,:);connection(2,:);dd]';
	end;
	A=spones(spconvert([d1;d2;d3;d4;d5;d6]));
end;

if(flag_display) disp('Dijkstra searching...'); end;
if(flag_base0)
	if(flag_display)	fprintf('input node is 0-based!\n'); end;
	%D=inverse_dijkstra(A,start_vertex_idx+1);
    D=dijkstra(A,start_vertex_idx+1);
else
	if(flag_display)	fprintf('input node is 1-based!\n'); end;
	%D=inverse_dijkstra(A,start_vertex_idx);
    D=dijkstra(A,start_vertex_idx);
end;

% 
% farthestPreviousHop=[1:size(A,1)];
% farthestNextHop=[1:size(A,1)];
% keyboard;
% for ii=1:size(A,1)
%     [path, D(ii), farthestPreviousHop, farthestNextHop] = dijkstra(size(A,1), A, start_vertex_idx, ii, farthestPreviousHop, farthestNextHop);
% end;

if(flag_display) disp('collecting indices...'); end;
d=round(D);

if(flag_display) disp('done!'); end;

