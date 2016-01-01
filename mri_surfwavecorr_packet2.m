function [RECON,SENSITIVITY0,recon,sensitivity0, var_roi,edge,lphp_all]=mri_surfwavecorr_packet(data,varargin)
% mri_surfwavecorr 	using wavelet transform to estimate and correct the inhomogeneous images
%
%	[RECON,SENSITIVITY,SENSITIVITY0,recon,sensitivity,sensitivity0,var_roi]=mri_surfwavecorr(data,SNR_cutoff, decomp_level)
%
%	data: 2D raw data matrix
%	SNR_cutoff: cut-off SNR (default: determined automatically by ROI selected)
%	decomp_level: total levels of decomposition (default: level 3 to leve 10, 8 levels)
%
%	RECON: corrected image
%	SENSITIVITY: estimated sensitivity map for the corrected image
%	recon: corrected image at different levels
%	sensitivity: estimated sensitivity map for the corrected image at different levels
%	var_roi: homogeneity index at different level
%
%	written by fhlin@Apr. 22, 2000

close all

data_orig_size=data;
data=imresize(double(data),[256,256]);
data_orig=data;


wavename='daub97';	%wavelet function name
wavelet_add_daub97;
fprintf('using [%s] filter bank...\n',wavename);


%%%%%%%%%%%%%%%%%%%% preprossessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('preprocessing...\n');

%get the edge by 1st level high pass filter
[cc,ss]=wavedec2(data,10,wavename);

for i=1:1
	rec1=wrcoef2('h',cc,ss,wavename,i);
	rec2=wrcoef2('v',cc,ss,wavename,i);
	rec3=wrcoef2('d',cc,ss,wavename,i);
	rec=rec1+rec2+rec3;			% wavelet reconstruction of all details at 1st level
end;
edge=rec;


[c2,s2]=wavedec2(abs(rec),5,wavename);
for i=1:5
	lphp_all(i,:,:)=wrcoef2('a',c2,s2,wavename,i);
end;
lphp=squeeze(lphp_all(4,:,:));
mx=max(max(data));
mn=min(min(data));
lphp=fmri_scale(lphp,mx,mn);

data0=data;
data=(data+lphp)/2;


subplot(221)
imagesc(abs(rec)); 
axis off;
axis image;
colormap(gray(256));
brighten(0.5);
subplot(222)
imagesc(lphp);
axis off;
axis image;
colormap(gray(256));
brighten(0.5);
subplot(223)
imagesc(data);
axis off;
axis image;
colormap(gray(256));
brighten(0.5);
subplot(224)
imagesc(data0);
axis off;
axis image;
colormap(gray(256));
brighten(0.5);
pause;


fprintf('end of preprocessing \n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%% wavelet decomposition %%%%%%%%%%%%%%%%%%%%%
start_level=1;
end_level=8;		%total level of wavelet decomposition

%determine the cut-off SNR
if(nargin==2);
	start_level=varargin{1};		
	end_level=varargin{1};
end;	
levels=end_level-start_level+1;

%multi levels of decomposition
[cc,ss]=wavedec2(data,end_level,wavename);
recon=zeros([size(data),end_level]);
sensitivity0=zeros([size(data),end_level]);


%an initial guess of optimal filtered sensitivity profile
filtered_guess=conv2(data,ones([32,32]),'same');
filtered_guess=filtered_guess-mean(mean(filtered_guess));
filtered_guess=filtered_guess./sqrt(sum(sum(filtered_guess.^2)));


for i=start_level:end_level;
	%wavelet reconstruction
	s0=wrcoef2('a',cc,ss,wavename,i);

	%normalize the profile
	mmin=min(min(s0));
	mmax=max(max(s0));
	
	% normalize the estimated sensitivity map
	%s0=(s0-mmin)./(mmax-mmin)*0.99999+0.0001;
	s0=fmri_scale(s0,1,1e-10);
	
		
	sensitivity0(:,:,i)=s0;
	

	% reconstruction by division
	reconstruct=data_orig./s0;
	
	%remove singularity (too large voxel values)
	sorted=sort(reshape(reconstruct,[65536,1]));
	voxel_upperlimit=sorted(length(sorted)-100);
	idx=find(reconstruct>voxel_upperlimit);
	reconstruct(idx)=voxel_upperlimit;
	
	recon(:,:,i)=reconstruct;
	
	% get homogneneity index
	%rr=squeeze(recon(:,:,i));
	profile=s0;
	profile=profile-mean(mean(profile));
	profile=profile./sqrt(sum(sum(profile.^2)));
	var_roi(i)=sum(sum(profile.*filtered_guess));
	%[var_roi(i),h1(i),h2(i)]=mri_homogeneous(rr,1-sigmoidal_mask);
	fprintf('level [%d] homogeneity index: %2.4f\n',i,var_roi(i));
end;


recon=recon(:,:,start_level:end_level);
sensitivity0=sensitivity0(:,:,start_level:end_level);


%collect reconstruction info
if(levels>1)
	%h1=(fmri_scale(h1(start_level:end_level),1,0)).^3
	%h2=(fmri_scale(h2(start_level:end_level),1,0)).^(1/3)

	sz=size(recon);
	recon=reshape(recon,[sz(1),sz(2),1,sz(3)]);

	sz=size(sensitivity0);
	sensitivity0=reshape(sensitivity0,[sz(1),sz(2),1,sz(3)]);

	%search the maximal homogeneous reconstruction
	[dummy,idx]=max(var_roi);
	RECON=imresize(squeeze(recon(:,:,1,idx)),size(data_orig_size));
	SENSITIVITY0=imresize(squeeze(sensitivity0(:,:,1,idx)),size(data_orig_size));
	
	%append raw image to reconstruction list and sensitivity map list
	recon(:,:,1,levels+1)=data_orig;
	m1=max(max(SENSITIVITY0));
	m0=min(min(SENSITIVITY0));
	mx=max(max(data_orig));
	mn=min(min(data_orig));
	sensitivity0(:,:,1,levels+1)=(data_orig-mn).*(m1-m0)./(mx-mn)+m0;
	mx=max(max(data));
	mn=min(min(data));
	sensitivity0(:,:,1,levels+1)=(data-mn).*(m1-m0)./(mx-mn)+m0;
else
	SENSITIVITY0=sensitivity0;

	%resize to [256,256]
	SENSITIVITY0=imresize(SENSITIVITY0,[256,256]);
		
	figure;
	imagesc(SENSITIVITY0);
	colormap(gray(256));
	imagesc(data_orig);
		

	RECON=recon;
	imagesc(RECON);
end;

%%%%%graphic output section%%%%%%
subplot(221);
imagesc(data_orig);
title('raw image');
axis off;
axis image;
colormap(gray(256));

subplot(222);
imagesc(RECON);
title('opt. recon');
axis off;
axis image;
colormap(gray(256));

subplot(223);
imagesc(SENSITIVITY0);
title('sensitivity map');
axis off;
axis image;
colormap(gray(256));

