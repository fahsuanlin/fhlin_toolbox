function [recon,profile]=surfcorr_modify(raw,recon,profile,varargin)
% generate the background mask by sigmoidal function

alpha_p=1;
alpha_r=0.2;

rr=fmri_scale(raw,1,0);
rr(rr<0.01)=0.01;

if(nargin==5)
	alpha_p=varargin{1};
	alpha_r=varargin{2};
end;
	



pp=fmri_scale(profile,1,0);

% mask based on the estimated profile
lambda_p=1-exp(-1.*(-1.*log(0.9))*alpha_p);
mask_p=1./(1+exp(-50.*(pp-lambda_p)));


% mask based on the raw input image
lambda_r=1-exp(-1.*(-1.*log(0.9))*alpha_r);
mask_r=1./(1+exp(-50.*(rr-lambda_r)));
	
% joint mask
mask=mask_p.*mask_r;



%recon0=recon;
recon=mask.*recon+(1-mask).*raw;
idx=find(mask>0.9);
recon(idx)=fmri_scale(recon(idx),max(max(raw)),min(min(raw)));


%figure
subplot(221); imagesc(recon); title('recon');
subplot(222); imagesc(mask_p); title('mask_profile');
subplot(223); imagesc(mask_r); title('mask_raw');
subplot(224); imagesc(mask); title('mask');
colormap(gray(256));
%pause;



%figure
%subplot(221)
%imagesc(raw)
%title('raw');
%subplot(222)
%imagesc(recon0);
%title('recon_orig');
%subplot(223);
%imagesc(mask)
%title('mask');
%subplot(224);
%imagesc(recon);
%title('recon_final');
%colormap(gray(256));
%pause;

%figure
%imagesc(recon);
%colormap(gray(256));
return;
