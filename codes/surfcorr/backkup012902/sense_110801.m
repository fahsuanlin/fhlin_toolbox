close all;
clear all;


img={
   'e:/user/fhlin/workspace/sense/data/sense-110701/head_phantom_full_1_1_1_1_1_1_1_1_1_img',
% 'e:/user/fhlin/workspace/sense/data/sense-110601/sense_birdcage_2mode_full_2_1_1_1_1_1_1_1_1_img',
};
dec=1;
dwt_level=5;
packet_fine_tune_level=2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pdir=pwd;

for j=1:length(img)
t=load(img{j});
raw_orig=t.img;

%raw_orig=squeeze(raw_orig(126,:,:))';
%imagesc(raw_orig);
%axis image off;
%colormap(gray(256));
%pause;

raw=zeros(size(raw_orig)./dec);

if(ndims(raw_orig)==3)
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
end;


if(ndims(raw_orig)==2)
	for i=1:size(raw_orig,1)/dec
		for j=1:size(raw_orig,2)/dec
			data=raw_orig((i-1)*dec+1:i*dec,...
				(j-1)*dec+1:j*dec);

			data=reshape(data,[1,prod(size(data))]);
			raw(i,j)=mean(data);
		end;
	end;

	[x_dec,y_dec]=meshgrid(dec/2:dec:size(raw_orig,1),dec/2:dec:size(raw_orig,2));
	[x_orig,y_orig]=meshgrid(1:size(raw_orig,1),1:size(raw_orig,2));
end;
	
cd(pdir);

% wavelet correction for inhomogeneity

subplot(221)
imagesc(real(raw))
axis off image;
colormap(gray(256));
colorbar
subplot(222)
imagesc(imag(raw))
axis off image;
colormap(gray(256));
colorbar
subplot(223)
imagesc(abs(raw))
axis off image;
colormap(gray(256));
colorbar
subplot(224)
imagesc(angle(raw))
axis off image;
colormap(gray(256));
colorbar

pause

raw=real(raw);
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
[recon_all_packet,profile_all_packet]=surfcorr_maxp_packet(raw,opt_level,packet_fine_tune_level);

sz=size(recon_all_packet);

% pickup the optimal levelf rom dwt correction
for i=1:sz(length(sz))

	if(ndims(raw)==3)
		recon_packet=squeeze(recon_all_packet(:,:,:,i));
	end;
	if(ndims(raw)==2)
		recon_packet=squeeze(recon_all_packet(:,:,i));
	end;
 
        inhomo_packet(i)=surfcorr_gmm_inhomogeneity(recon_packet);
end;
[dummy,opt_level_packet]=min(inhomo_packet);

	
if(ndims(raw)==3)
	%get the optimal 3D profile and reconstruction
	profile_opt=interp3(x_dec,y_dec,z_dec,squeeze(profile_all_packet(:,:,:,opt_level_packet)),x_orig,y_orig,z_orig);
end;

if(ndims(raw)==2)
	%get the optimal 2D profile and reconstruction
	profile_opt=interp2(x_dec,y_dec,squeeze(profile_all_packet(:,:,opt_level_packet)),x_orig,y_orig);
end;

profile_opt(profile_opt==0) = inf;
recon_opt = raw_orig ./ profile_opt;

		
%remove singularity (too large voxel values)
sorted=sort(reshape(recon_opt,[prod(size(recon_opt)),1]));
voxel_upperlimit=sorted(length(sorted)-round(length(sorted)*0.01));
idx=find(recon_opt>voxel_upperlimit);
recon_opt(idx)=voxel_upperlimit;
	
%scale back to the original intensity range
recon_opt=fmri_scale(recon_opt,max(max(max(raw_orig))),min(min(min(raw_orig))));
end;

return;
