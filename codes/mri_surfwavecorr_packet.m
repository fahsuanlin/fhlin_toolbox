function [RECON,SENSITIVITY0,recon,sensitivity0, var_roi]=mri_surfwavecorr_packet(data,varargin)
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
data=double(data);
data_orig_size=data;
data=imresize(data,[256,256]); %normalize the size of the image to 256*256
data_orig=data;


wavename='daub75';	%wavelet function name
wavelet_add_daub75;
fprintf('using [%s] filter bank...\n',wavename);


if(nargin>1&strcmp(char(varargin{1}),'npp')==1)
	disp('no pre-processing');
else
	%%%%%%%%%%%%%%%%%%%% preprossessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	fprintf('preprocessing...\n');

	%get the edge by 1st level high pass filter
	[cc,ss]=wavedec2(data,10,wavename);
	detail_level=4;

	mask1=zeros(size(data));
	mask2=zeros(size(data));
	mask3=zeros(size(data));
	mask=zeros(size(data));
		
	for i=1:detail_level
		rec1=wrcoef2('h',cc,ss,wavename,i);
		rec2=wrcoef2('v',cc,ss,wavename,i);
		rec3=wrcoef2('d',cc,ss,wavename,i);
		rec=rec1+rec2+rec3;			% wavelet reconstruction of all details at 1st level
		
		%rec_lp=wrcoef2('a',cc,ss,wavename,i);
	
		subplot(221);
		mx=max(max(abs(rec1)));
		mask1(find(abs(rec1)>mx*0.05))=1;
		%mask1=abs(rec1);
		imagesc(mask1);
		axis image;
		axis off;
		colormap(gray(256));
		subplot(222);
		mx=max(max(abs(rec2)));
		mask2(find(abs(rec2)>mx*0.05))=1;
		%mask2=abs(rec2);
		imagesc(mask2);
		axis image;
		axis off;
		colormap(gray(256));
		subplot(223);
		mx=max(max(abs(rec3)));
		mask3(find(abs(rec3)>mx*0.05))=1;
		%mask3=abs(rec3);
		imagesc(mask3);
		axis image;
		axis off;
		colormap(gray(256));
		subplot(224);
		%mask=abs(rec);
		mask=(mask1|mask2|mask3);
		imagesc(mask);
		axis image;
		axis off;
		colormap(gray(256));
		
	end;
	pause;
	
	mx=max(max(data));
	mn=min(min(data));
	rec=fmri_scale(abs(rec),mx,mn);
	[c2,s2]=wavedec2(abs(rec),5,wavename);
	lphp=wrcoef2('a',c2,s2,wavename,3);
	lphp=fmri_scale(lphp,mx,mn);
	
	data0=data;
	%data=(data+lphp)/2;
	
	[cc,ss]=wavedec2(data,10,wavename);
	data=zeros(size(data));
	decomposition_level=10;
	detail_cutoff_level=2;
	for i=1:10
		app=wrcoef2('a',cc,ss,wavename,i);
		data=data+app;
				
		det_v=wrcoef2('v',cc,ss,wavename,i);
		det_h=wrcoef2('h',cc,ss,wavename,i);
		det_d=wrcoef2('d',cc,ss,wavename,i);
		
		data=data+det_v;
		data=data+det_h;
		if (i>detail_cutoff_level)
			data=data+det_d;
		end;
	end;

	
	
	
	subplot(221)
	imagesc(abs(rec)); 
	axis off;
	axis image;
	colormap(gray(256));
	brighten(0.5);
	title('edge detected');
	subplot(222)
	imagesc(lphp);
	axis off;
	axis image;
	colormap(gray(256));
	brighten(0.5);
	title('smoothed edge');
	subplot(223)
	imagesc(data);
	axis off;
	axis image;
	colormap(gray(256));
	brighten(0.5);
	title('local contrast reduced image');
	subplot(224)
	imagesc(data0);
	axis off;
	axis image;
	colormap(gray(256));
	brighten(0.5);
	title('raw image');
	pause;
	
	%graphic output for the preprocessing
	debug=0;
	if(debug==1)
		figure
		subplot(221);
		imagesc(abs(rec));
		axis image;
		axis off;
		title('edge estimation');
		subplot(222);
		imagesc(lphp);
		axis image;
		axis off;
		title('low-pass filtered edge');
		subplot(224);
		imagesc(data);
		axis image;
		axis off;
		title('corrected input image');
		colormap(gray(256));
		brighten(0.5);
		pause;
	end;
	
	fprintf('end of preprocessing \n\n');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%% wavelet decomposition %%%%%%%%%%%%%%%%%%%%%
start_level=1;
end_level=8;		%total level of wavelet decomposition

%determine the cut-off SNR
if((nargin==2)&(varargin{1}~='npp'));
	start_level=varargin{1};		
	end_level=varargin{1};
end;	
levels=end_level-start_level+1;

%maximal 10 levels of decomposition
[cc,ss]=wavedec2(data,10,wavename);
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
	s0=(s0-mmin)./(mmax-mmin)*0.99999+0.0001;
	
		
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

