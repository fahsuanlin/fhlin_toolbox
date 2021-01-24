clear all;
close all;

load results

recon=fmri_scale(recon_opt,256,0);
raw=fmri_scale(raw,256,0);
mask=zeros([256,256]);
mask(find(brain_mask>(max(max(brain_mask)).*0.4)))=1;
imagesc(mask);
colormap(gray(256));
pause;
close all;

recon_mask=recon.*mask;
raw_mask=raw.*mask;

recon_mask=fmri_scale(recon_mask,256,0);
raw_mask=fmri_scale(raw_mask,256,0);

recon_mask_1d=recon_mask(find(mask));
raw_mask_1d=raw_mask(find(mask));

subplot(211);
hist(recon_mask_1d,256);
axis([0 256 0 400]);
title('recon');
subplot(212);
hist(raw_mask_1d,256);
axis([0 256 0 400]);
title('raw');




