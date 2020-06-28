function [vertex,face]=inverse_read_tri(tri_file, varargin)

% inverse_read_tri	read in triangluated files
%
% [vertex,face]=inverse_read_tri(tri_file)
%
% read TRI file for the location and orientation of the dipoles into matlab
%
% to render the triangulation, use the following commands:
% p=patch('Faces',face,...
%    'Vertices',vertex,...
%	'FaceVertexCData',ones(size(vertex,1),1),...
%	'EdgeColor',[0 0 0],...
%    'FaceColor','none',...
%    'FaceLighting', 'flat',...
%    'SpecularStrength' ,0.7, 'AmbientStrength', 0.7,...
%    'DiffuseStrength', 0.1, 'SpecularExponent', 10.0);
%	 box on; axis image; 
%
% oct 8, 2002
% jul 12, 2003

flag_nmr=1;     %MGH-NMR format 



if(nargin==2&strcmp(varargin{1},'neuromag'))
    flag_nmr=0;
end;


if(flag_nmr);
	fprintf('MGH-NMR format TRI file\n\n');	
	% read TRI file to get the indices of the decimated dipole.
	fprintf('reading tri file [%s]...\n',tri_file);

	n_vertex=textread(tri_file,'%d',1);
	fprintf('[%d] vertices...\n',n_vertex);
	vertex=zeros(n_vertex,3);
	[dummy0,vertex(:,1),vertex(:,2),vertex(:,3)]=textread(tri_file,'%d%f%f%f',n_vertex,'headerlines',1);


	n_face=textread(tri_file,'%d',1,'headerlines',n_vertex+1);
	fprintf('[%d] triangulations...\n',n_face);
	face=zeros(n_face,3);
	[dummy1,face(:,1),face(:,2),face(:,3)]=textread(tri_file,'%d%d%d%d',n_face,'headerlines',2+n_vertex);

else
	fprintf('Neuromag format DIP file\n\n');	
	fprintf('not supported yet....\n');	
end;
	
	
	
