function [dip_number, dec_number, dip_hemi, dec_hemi, dip_coord, dec_coord, dip_dist, dec_dist]=inverse_locate_diople(mri_3d,file_dip,file_dec)
% inverse_locate_diople 	Search the nearest dipole from 3D MRI coordinates
% [dip_idx, dec_idx, dip_hemi, dec_hemi, dip_coord, dec_coord, dip_dist, dec_dist]=inverse_locate_dipole(mri_3d,file_dip,file_dec)
%
% mri_3d: a 3*p matrix of p dipoles of interest. The entries must be the coordinates 
%	of the dipole from Freesurfer 3D volume render, which can be acquired from
%	the TKMEDIT menu in the "VOLUME RAS" box
% file_dip: DIP files in cell array
% file_dec: DEC files in cell array
%
% dip_idx: the indices of the nearest UNDECIMATED dipole
% dip_hemi: indicating the hemisphere of the nearest dipole. It is the index based on 
%	the input parameter DIP_FILE and DEC_FILE
% dip_coord: the 3D cooridinate (in MM) of the nearest UNDECIMATED dipole
% dip_dist: the distance between the target dipole and the sought nearest dipole (in MM)
% dec_idx: the indices of the nearest DECIMATED dipole
% dec_hemi: indicating the hemisphere of the nearest dipole. It is the index based on 
%	the input parameter DIP_FILE and DEC_FILE
% dec_coord: the 3D cooridinate (in MM) of the nearest DECIMATED dipole
% dec_dist: the distance between the target dipole and the sought nearest dipole (in MM)
%
% fhlin@Mar. 08, 2002




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defaults

dip_number=[];
dec_number=[];
dip_hemi=[];
dec_hemi=[];
dip_coord=[];
dec_coord=[];
dip_dist=[];
dec_dist=[];

flag_lh_first=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dip and dec information
for i=1:size(file_dip,1)
	[DIP{i},DEC{i}]=inverse_read_dipdec(file_dip{i}, file_dec{i});
	dec{i}=find(DEC{i});
	dip{i}=DIP{i}(:,dec{i});
end;



for i=1:size(mri_3d,1)
	fprintf('search dipole [%d|%d]...\n',i,size(mri_3d,1));

	%search the undecimated dipoles
	for j=1:length(DIP)

		%search for undecimated dipole
		dip_info=DIP{j};
		dip_info=dip_info(1:3,:);

		r=repmat(mri_3d(i,:)',[1,size(dip_info,2)]);
		dist=sqrt(sum((r-dip_info).^2,1));
		[dip_dist_hemi(i,j),dip_number_hemi(i,j)]=min(dist);
	end;

	[dip_dist(i),idx]=min(dip_dist_hemi(i,:));
	dip_hemi(i)=idx;
	dip_number(i)=dip_number_hemi(i,idx);
	dip_coord(i,:)=DIP{idx}(1:3,dip_number(i))';

	%search the decimated dipoles
	for j=1:length(dip)

		%search for decimated dipole
		dip_info=dip{j};
		dip_info=dip_info(1:3,:);

		r=repmat(mri_3d(i,:)',[1,size(dip_info,2)]);
		dist=sqrt(sum((r-dip_info).^2,1));
		[dec_dist_hemi(i,j),dec_number_hemi(i,j)]=min(dist);
	end;

	[dec_dist(i),idx]=min(dec_dist_hemi(i,:));
	dec_hemi(i)=idx;
	dec_number(i)=dec_number_hemi(i,idx);
	dec_coord(i,:)=dip{idx}(1:3,dec_number(i))';
end;
fprintf('DONE!\n');

return;