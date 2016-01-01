function [RECON,SENSITIVITY,SENSITIVITY0,recon,sensitivity,sensitivity0,var_roi]=mri_surfwavecorr(data,varargin)
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
%	SENSITIVITY0: adaptive sensitivity map for the corrected image
%	recon: corrected image at different levels
%	sensitivity: estimated sensitivity map for the corrected image at different levels
%	sensitivity0: adaptive sensitivity map for the corrected image at different levels
%	var_roi: homogeneity index at different level
%
%	written by fhlin@Apr. 22, 2000

close all

data_orig_size=data;
%data=imresize(double(data),[256,256]);
data_orig=data;


wavename='daub97';	%wavelet function name
wavelet_add_daub97;
fprintf('using [%s] filter bank...\n',wavename);


%%%%%%%%%%%%%%%%%%%% get edge %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%try to get the mask
[cc,ss]=wavedec2(data,10,wavename);
rec1=wrcoef2('h',cc,ss,wavename,1);
rec2=wrcoef2('v',cc,ss,wavename,1);
rec3=wrcoef2('d',cc,ss,wavename,1);
rec=rec1+rec2+rec3;		% wavelet reconstruction of all details at 1st level

mask=zeros(size(data));

%thresholding
rec_sort=sort(reshape(abs(rec),[1,size(data,1)*size(data,2)]));		%get the CDF of abs(reconstruction of detail)
threshold=rec_sort(round(length(rec_sort)*0.7));			%set the threshold of the edge
mask_idx=find(abs(rec)>threshold);
mask(mask_idx)=1;


%low-pass filtering of edge detected by wavelet.
mm=fmri_scale(conv2(mask,ones(16,16),'same'),1,0);

%getting center of mass
[x_grid,y_grid]=meshgrid([1:size(data,1)],[1:size(data,2)]);
s2=sum(data_orig,2);
idx=find(s2~=0);
s2=s2(idx);
p2=sum(x_grid.*data_orig,2);
p2=p2(idx);

s1=sum(data_orig,1);
idx=find(s1~=0);
s1=s1(idx);
p1=sum(y_grid.*data_orig,1);
p1=p1(idx);


cm_x=round(mean(p2./s2));
cm_y=round(mean(p1./s1));


xx=mod(mask_idx,size(data,2));
yy=floor(mask_idx./size(data,2));
dist=sqrt((xx-cm_x).^2+(yy-cm_y).^2);
transit_shift=round(mean(dist));
transit=round(std(dist))*4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% 2-D mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Z=zeros(size(data));
mask_switch='edge';

fprintf('masking by [%s]...\n',mask_switch);

if(strcmp(mask_switch,'guassian')==1)
	center=[size(data,1)/2,size(data,2)/2];
	sig=size(data,1)*1;
	[X,Y] = meshgrid(1:size(data,1), 1:size(data,2));
	Z =1./exp(-1.*sqrt(((X-center(1)).^2 +( Y-center(2)).^2))./sig);
	Z=fmri_scale(Z,1,0);
end;


if(strcmp(mask_switch,'sigmoidal')==1)
	%get lambda
	x=[1:0.1:size(data,1)];
	Y=0.85;
	X=transit/2;
	lambda=log(1/Y-1)/X/(-1);

	%mask 2D mask
	[X,Y] = meshgrid(1:size(data,1), 1:size(data,2));
	R=sqrt((X-cm_x).^2+(Y-cm_y).^2);
	Z =1./(1+exp(-lambda*(R-transit_shift)));
	Z=fmri_scale(Z,1,0);
	ZZ=Z;
end;

if(strcmp(mask_switch,'edge')==1)
	Z=mm;
end;


dd=sort(reshape(data,[size(data,1)*size(data,2),1]));
maxx=dd(round(length(dd)-10));
data=Z.*maxx+(1-Z).*data;



figure
subplot(221);
imagesc(data_orig);
axis image;
axis off;
title('raw data');
subplot(222);
imagesc(mask);
axis image;
axis off;
title('edge estimation');
subplot(223);
imagesc(Z);
title('sigmoidal mask');
axis image;
axis off;
subplot(224);
imagesc(data);
axis image;
axis off;
title('corrected input image');
colormap(gray(256));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%get local SNR
snr=mri_localsnr(data);
idx=find(snr<=0);
snr(idx)=0;

start_level=3;
end_level=8;		%total level of wavelet decomposition

%determine the cut-off SNR
if(nargin==1)
	%disp('select region to be reconstructed');
	%imagesc(data);
	%axis off;
	%axis image;
	%bw=roipoly;
	%close;
	%snr_cutoff=median(snr(bw));
	tt=sort(reshape(snr,[1,size(snr,1)*size(snr,2)]));
	snr_cutoff=median(tt(1:round(length(tt)/2)))
elseif(nargin==2);
	
	snr_cutoff=varargin{1};
	
	elseif(nargin==3)
		snr_cutoff=varargin{1};

		start_level=varargin{2};		
		end_level=varargin{2};
end;	
levels=end_level-start_level+1;
fprintf('SNR cut-off:%2.2f dB\n',snr_cutoff);


[cc,ss]=wavedec2(data,10,wavename);
recon=zeros([size(data),levels]);
sensitivity0=zeros([size(data),levels]);
sensitivity=zeros([size(data),levels]);



for i=start_level:end_level;
	%wavelet reconstruction
	s0=wrcoef2('a',cc,ss,wavename,i);

	%normalize the profile
	mmin=min(min(s0));
	mmax=max(max(s0));
	
	% normalize the estimated sensitivity map
	s0=(s0-mmin)./(mmax-mmin)*0.99999+0.0001;
	
	% create adaptive sensitivity map based on estimation and local SNR
	%s=(1-exp(-snr./snr_cutoff*2)).*s0+exp(-snr./snr_cutoff*2).*1.0;
	s=s0;
	
	sensitivity0(:,:,i)=s0;
	sensitivity(:,:,i)=s;

	% reconstruction by division
	reconstruct=data_orig./s;
	
	%remove singularity (too large voxels)
	sorted=sort(reshape(reconstruct,[size(data,1)*size(data,2),1]));
	th=sorted(length(sorted)-100);
	idx=find(reconstruct>th);
	reconstruct(idx)=th;
	
	%xx=find(ZZ>0.85);
	%reconstruct(xx)=0;

	recon(:,:,i)=reconstruct;
	
	% get homogneneity index
	rr=squeeze(recon(:,:,i));
	[var_roi(i),hh(i),hhh(i)]=mri_homogeneous(rr,1-Z);
	fprintf('level [%d] homogeneity index: %2.4f\n',i,var_roi(i));
end;

%figure;
%subplot(311);
%stem(hh);
%title('den');
%subplot(312);
%stem(hhh);
%title('num');
%subplot(313);
%stem(hhh./hh);


var_roi=var_roi(start_level:end_level);
recon=recon(:,:,start_level:end_level);
sensitivity=sensitivity(:,:,start_level:end_level);
sensitivity0=sensitivity0(:,:,start_level:end_level);


%collect reconstruction info
if(levels>1)
	sz=size(recon);
	recon=reshape(recon,[sz(1),sz(2),1,sz(3)]);

	sz=size(sensitivity);
	sensitivity=reshape(sensitivity,[sz(1),sz(2),1,sz(3)]);

	sz=size(sensitivity0);
	sensitivity0=reshape(sensitivity0,[sz(1),sz(2),1,sz(3)]);

	[dummy,idx]=max(var_roi);
	RECON=imresize(squeeze(recon(:,:,1,idx)),size(data_orig_size));
	SENSITIVITY=imresize(squeeze(sensitivity(:,:,1,idx)),size(data_orig_size));
	SENSITIVITY0=imresize(squeeze(sensitivity0(:,:,1,idx)),size(data_orig_size));
	
		
	%resize to [256,256]
	%SENSITIVITY0=imresize(SENSITIVITY0,[size(data,1),size(data,2)]);
	%SENSITIVITY=imresize(SENSITIVITY,[size(data,1),size(data,2)]);


	recon(:,:,1,levels+1)=data_orig;
	m1=max(max(SENSITIVITY));
	m0=min(min(SENSITIVITY));
	mx=max(max(data));
	mn=min(min(data));
	dd=(data-mn).*(m1-m0)./(mx-mn)+m0;
	sensitivity(:,:,1,levels+1)=dd;
	m1=max(max(SENSITIVITY0));
	m0=min(min(SENSITIVITY0));
	mx=max(max(data));
	mn=min(min(data));
	dd=(data-mn).*(m1-m0)./(mx-mn)+m0;
	sensitivity0(:,:,1,levels+1)=dd;
else
	SENSITIVITY=sensitivity;
	SENSITIVITY0=sensitivity0;

	%resize to orig. image size
	SENSITIVITY0=imresize(SENSITIVITY0,[size(data,1),size(data,2)]);
	SENSITIVITY=imresize(SENSITIVITY,[size(data,1),size(data,2)]);
	
	figure;
	imagesc(SENSITIVITY0);
	colormap(gray(256));
	imagesc(data_orig);
		

	%RECON=data_orig./SENSITIVITY;
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
title('reconstruction');
axis off;
axis image;
colormap(gray(256));

subplot(223);
imagesc(SENSITIVITY0);
title('sensitivity map');
axis off;
axis image;
colormap(gray(256));

subplot(224);
imagesc(SENSITIVITY);
title('adaptive sensitivitiy map');
axis off;
axis image;
colormap(gray(256));


