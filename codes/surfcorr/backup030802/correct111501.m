function [recon_opt,profile_opt,opt_level,recon_all,profile_all,inhomo]=correct111501(raw,dwt_level);

%close all;
%clear all;


%dwt_level=5;
%packet_fine_tune_level=2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%pdir=pwd;

%load raw_reduced;

%cd(pdir);

% wavelet correction for inhomogeneity
[recon_all,profile_all]=surfcorr_maxp_dwt(raw,dwt_level);

% pickup the optimal levelf rom dwt correction
for i=1:dwt_level

	if(ndims(raw)==3)
		recon=squeeze(recon_all(:,:,:,i));
	end;
	if(ndims(raw)==2)
		recon=squeeze(recon_all(:,:,i));
	end;
	
	inhomo(i)=surfcorr_gmm_inhomogeneity(recon);
end;
[dummy,opt_level]=min(inhomo);

	

% wavelet correction for inhomogeneity
%[recon_all_packet,profile_all_packet]=surfcorr_maxp_packet(raw,opt_level,packet_fine_tune_level);

%sz=size(recon_all_packet);

% pickup the optimal level from dwt correction
%for i=1:sz(length(sz))
%
%	if(ndims(raw)==3)
%		recon_packet=squeeze(recon_all_packet(:,:,:,i));
%	end;
%	if(ndims(raw)==2)
%		recon_packet=squeeze(recon_all_packet(:,:,i));
%	end;
% 
%       inhomo_packet(i)=surfcorr_gmm_inhomogeneity(recon_packet);
%end;
%[dummy,opt_level_packet]=min(inhomo_packet);

	
	
if(ndims(raw)==3)
	%get the optimal 3D profile and reconstruction
	profile_opt=profile_all(:,:,:,opt_level);
end;

if(ndims(raw)==2)
	%get the optimal 2D profile and reconstruction
	profile_opt=profile_all(:,:,opt_level);
end;
	
%if(ndims(raw)==3)
%	%get the optimal 3D profile and reconstruction
%	profile_opt=interp3(x_dec,y_dec,z_dec,squeeze(profile_all_packet(:,:,:,opt_level_packet)),x_orig,y_orig,z_orig);
%end;

%if(ndims(raw)==2)
%	%get the optimal 2D profile and reconstruction
%	profile_opt=interp2(x_dec,y_dec,squeeze(profile_all_packet(:,:,opt_level_packet)),x_orig,y_orig);
%end;

profile_opt(profile_opt==0) = inf;
recon_opt = raw ./ profile_opt;

		
%remove singularity (too large voxel values)
sorted=sort(reshape(recon_opt,[prod(size(recon_opt)),1]));
voxel_upperlimit=sorted(length(sorted)-round(length(sorted)*0.01));
idx=find(recon_opt>voxel_upperlimit);
recon_opt(idx)=voxel_upperlimit;
	
%scale back to the original intensity range
recon_opt=fmri_scale(recon_opt,max(max(max(raw))),min(min(min(raw))));


return;
