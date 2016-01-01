%[kvol, navs] = myread_meas_out('meas_100.out');

imall=[];
for rr=1:100
imvol=fftshift(abs((ifft2(kvol(:,:,4,rr,1)))));
imall=cat(4,imall,imvol);
end;
figure;
im1=imall(:,:,1);
imagesc(im1);
figure;
im100=imall(:,:,100);
imagesc(im100);
figure;colormap gray;
imagesc(im1-im100);


%select 2 kvolumes
kvol1=kvol(:,:,1,1);
kvol100=kvol(:,:,1,100);


%calculate phase
phase1=angle(kvol1);
phase100=angle(kvol100);

%estimate correction factor
diffphase=phase1-phase100;
factor=exp(i*diffphase);

%apply correction to volume 2
kvol100corr=(kvol100(:,:)).*factor;

%Reconstruct corrected volume
im100corr=fftshift(abs((ifft2(kvol100corr(:,:)))));
figure;colormap gray;
%Calculate the difference
imagesc(im1-im100corr);colorbar;

