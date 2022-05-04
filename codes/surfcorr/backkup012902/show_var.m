clear all;
close all;

load brain_mask
load wp wp_recon

mask=zeros([256,256]);
mask(find(brain_mask>(max(max(brain_mask)).*0.4)))=1;
imagesc(mask);
axis off image;
title('brain mask');
pause(0.3);


d=zeros(size(wp_recon,3),length(find(mask)));

for i=1:size(wp_recon,3)
	tmp=squeeze(wp_recon(:,:,i));
	fmri_scale(tmp,1,0);
	
	d(i,:)=tmp(find(mask))';
	
end;

stdd=std(d,0,2);

for i=1:size(wp_recon,3)
	fprintf('level [%d]-var=%3.3f\n',i,stdd(i));
end;
	



