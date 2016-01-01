pdir=pwd;

cd('/homes/nmrnew/home/fhlin/matlab/toolbox/spm99/templates');
old=fmri_ldimg('T2.img');
cd(pdir);

im=fmri_ldimg('hb.tal.rage.hres.img');


im_new=zeros(size(im,1),size(old,2),size(old,3));
for i=1:size(im,1)
	im_new(i,:,:)=imresize(squeeze(im(i,:,:)),[91,91]);
end;

im_new_new=zeros(size(old));
for i=1:size(old,3)
	im_new_new(:,:,i)=imresize(squeeze(im_new(:,:,i)),[109,91]);
end;

fmri_svimg(im_new_new,'hi_res_t2.img',[2 2 2]);
return;
for j=1:size(old,1)
		subplot(121);
		imagesc(squeeze(old(j,:,:)));
		colormap(gray(256));
		axis image;
		axis off;
		title('SPM');
		subplot(122);
		imagesc(squeeze(im_new_new(j,:,:)));
		colormap(gray(256));
		axis image;
		axis off;
		title('hi-res');
		pause(0.2);
end;


for j=1:size(old,2)
		subplot(121);
		imagesc(squeeze(old(:,j,:)));
		colormap(gray(256));
		axis image;
		axis off;
		title('SPM');
		subplot(122);
		imagesc(squeeze(im_new_new(:,j,:)));
		colormap(gray(256));
		axis image;
		axis off;
		title('hi-res');
		pause(0.2);
end;


for j=1:size(old,3)
		subplot(121);
		imagesc(squeeze(old(:,:,j)));
		colormap(gray(256));
		axis image;
		axis off;
		title('SPM');
		subplot(122);
		imagesc(squeeze(im_new_new(:,:,j)));
		colormap(gray(256));
		axis image;
		axis off;
		title('hi-res');
		pause(0.2);
end;
