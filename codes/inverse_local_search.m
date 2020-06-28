function [local_dipole_pool]=inverse_local_search(surface_file,dip_file,dec_file, start_dipole_idx,dipole_distance)
%
% inverse_local_search         Using Dijkstra algorithm to search the brain mesh for a local area defined by the number of transvered edge
%  
% [local_dipole_pool]=inverse_local_search(surface_file,dip_file,dec_file, start_dipole_idx,dipole_distance)
%
% surface_file: the surface file/name in w file format.
% dip_file: dip file path/name
% dec_file: dec file path/name
% start_dipole: the dipole index as the inital point. This index is the dipole index in dip file (0-based)
% dipole_distance: the number of eges transvered from the start_dipole.
%
% local_dipole_pool: the collection of indices for dipoles who are "within" dipole_distance edges from the start_dipole. Returned indices are 0-based indices
%
%
% note: matlab 6.0 is required to run this program (including the inverse_dijkstra.mexglx).
%
% written by fhlin@apr. 20 2001

% read dip and dec files
	[dipole_info,dec_dipole]=inverse_read_dipdec(dip_file, dec_file);

% read surface data
 	[vertices, faces, vertex_data, face_data]=inverse_read_surf_asc(surface_file);
	
%search nearest dipole collection by Dijkstra algorithm
	[res]=inverse_search_dijk(face_data,start_dipole_idx);

%collect indices
	exceed=0;
	res_idx=1;
	local_dipole=[];
	while((res_idx<=size(res,2))&(~exceed))
		if(res{res_idx}.distance>dipole_distance)
			exceed=1;
			break;
		else
			local_dipole=union(local_dipole,res{res_idx}.indices);
			res_idx=res_idx+1;
		end;
	end;

	[dummy1,dummy2,local_dipole_pool]=intersect(local_dipole, find(dec_dipole)-1);

	local_dipole_pool=local_dipole_pool-1; % 0-based dipole index
	
	fprintf('total [%d] dipoles within [%d] edges from dipole [%d]\n', length(local_dipole_pool), dipole_distance, start_dipole_idx);

