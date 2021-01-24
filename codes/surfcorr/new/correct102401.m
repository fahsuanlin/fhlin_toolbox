close all;
clear all;


cordir='/space/estimate/1/users/fhlin/workspace/surfcorr/data/042401-andre/3danat/002';
dec=4;
dwt_level=5;
packet_fine_tune_level=2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pdir=pwd;


raw_orig=fmri_ldcor(cordir);
raw=zeros(size(raw_orig)./dec);

for i=1:size(raw_orig,1)/dec
	for j=1:size(raw_orig,2)/dec
		for k=1:size(raw_orig,3)/dec
			data=raw_orig((i-1)*dec+1:i*dec,...
			(j-1)*dec+1:j*dec,...
			(k-1)*dec+1:k*dec);
			data=reshape(data,[1,prod(size(data))]);

			raw(i,j,k)=mean(data);
		end;
	end;
end;

[x_dec,y_dec,z_dec]=meshgrid(dec/2:dec:size(raw_orig,1),dec/2:dec:size(raw_orig,2),dec/2:dec:size(raw_orig,3));
[x_orig,y_orig,z_orig]=meshgrid(1:size(raw_orig,1),1:size(raw_orig,2),1:size(raw_orig,3));

cd(pdir);

% wavelet correction for inhomogeneity
[recon_all,profile_all]=surfcorr_maxp_dwt(raw,dwt_level);

% pickup the optimal levelf rom dwt correction
for i=1:dwt_level

	%fn=sprintf('surfcorr_maxp_dwt_%s.mat',num2str(i,'%03d'));

	%load(fn,'recon_all');

	recon=squeeze(recon_all(:,:,:,i));

	inhomo(i)=surfcorr_gmm_inhomogeneity(recon);
end;
[dummy,opt_level]=min(inhomo);

	

% wavelet correction for inhomogeneity
[recon_all_packet,profile_all_packet]=surfcorr_maxp_packet(raw,opt_level,packet_fine_tune_level);

sz=size(recon_all_packet);

% pickup the optimal levelf rom dwt correction
for i=1:sz(length(sz))

        %fn=sprintf('surfcorr_maxp_dwt_%s.mat',num2str(i,'%03d'));

        %load(fn,'recon_all');

        recon_packet=squeeze(recon_all_packet(:,:,:,i));

        inhomo_packet(i)=surfcorr_gmm_inhomogeneity(recon_packet);
end;
[dummy,opt_level_packet]=min(inhomo_packet);

	
%get the optimal 3D profile and reconstruction
profile_opt=interp3(x_dec,y_dec,z_dec,squeeze(recon_all_packet(:,:,:,opt_level_packet)),x_orig,y_orig,z_orig);

profile_opt(profile_opt==0) = inf;
recon_opt = raw_orig ./ profile_opt;
	
%remove singularity (too large voxel values)
sorted=sort(reshape(recon_opt,[prod(size(recon_opt)),1]));
voxel_upperlimit=sorted(length(sorted)-round(length(sorted)*0.01));
idx=find(recon_opt>voxel_upperlimit);
recon(idx)=voxel_upperlimit;
	
%scale back to the original intensity range
recon_opt=fmri_scale(recon_opt,max(max(max(raw_orig))),min(min(min(raw_orig))));


return;
