clear all;
close all;

load results
recon=recon_opt;
raw=fmri_scale(raw,255,0);
recon=fmri_scale(recon,255,0);


close;
fprintf('select gray matter ROI\n');
[recon_roi_gray,rect_gray]=imcrop(recon,gray(256));
fprintf('select white matter ROI\n');
[recon_roi_white,rect_white]=imcrop(recon,gray(256));

recon_gray=mean2(recon_roi_gray);
recon_white=mean2(recon_roi_white);
fprintf('before scale: [recon]: GM=%3.3f WM=%3.3f\n',recon_gray, recon_white);

close;
imagesc(raw);
axis off image;
colormap(gray(256));
[raw_roi_gray]=imcrop(raw,gray(256),rect_gray);
[raw_roi_white]=imcrop(raw,gray(256),rect_white);
raw_gray=mean2(raw_roi_gray);
raw_white=mean2(raw_roi_white);
fprintf('before scale: [raw]: GM=%3.3f WM=%3.3f\n',raw_gray, raw_white);

gm=70.0;
wm=100.0;

raw=(raw-raw_gray).*(wm-gm)./(raw_white-raw_gray)+gm;
recon=(recon-recon_gray).*(wm-gm)./(recon_white-recon_gray)+gm;


close;
imagesc(recon);
axis off image;
colormap(gray(256));
[recon_roi_gray]=imcrop(recon,gray(256),rect_gray);
[recon_roi_white]=imcrop(recon,gray(256),rect_white);
recon_gray=mean2(recon_roi_gray);
recon_white=mean2(recon_roi_white);
fprintf('after scale: [recon]: GM=%3.3f WM=%3.3f\n',recon_gray, recon_white);



close;
imagesc(raw);
axis off image;
colormap(gray(256));
[raw_roi_gray]=imcrop(raw,gray(256),rect_gray);
[raw_roi_white]=imcrop(raw,gray(256),rect_white);
raw_gray=mean2(raw_roi_gray);
raw_white=mean2(raw_roi_white);
fprintf('after scale: [raw]: GM=%3.3f WM=%3.3f\n',raw_gray, raw_white);


close;
mask=zeros([256,256]);
mask(find(brain_mask>(max(max(brain_mask)).*0.4)))=1;
imagesc(mask);
colormap(gray(256));
pause(1);

recon_mask=recon.*mask;
raw_mask=raw.*mask;

recon_mask_1d=recon_mask(find(mask));
raw_mask_1d=raw_mask(find(mask));

subplot(211);
hist(recon_mask_1d,256);
%axis([0 256 0 400]);
title('recon');
subplot(212);
hist(raw_mask_1d,256);
%axis([0 256 0 400]);
title('raw');

fprintf('recon: max=%3.3f min=%3.3f diff=%3.3f\n',max(recon_mask_1d),min(recon_mask_1d),max(recon_mask_1d)-min(recon_mask_1d));
fprintf('raw: max=%3.3f min=%3.3f diff=%3.3f\n',max(raw_mask_1d),min(raw_mask_1d),max(raw_mask_1d)-min(raw_mask_1d));




