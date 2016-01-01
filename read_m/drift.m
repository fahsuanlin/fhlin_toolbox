%calculate phase of central point 31-64
%phase1=angle(k1(33,65));
%phase2=angle(k2(33,65));

%load data1
phase1=angle(kvol1(:,65));
phase100=angle(kvol100(:,65));

%estimate correction factor
diffphase=phase1-phase100;
factor=exp(i*diffphase);

%apply correction to volume 2
%k2corr=(k2(:,:)).*factor;
for r=1:128
    k100corr(:,r)=(kvol100(:,r)).*factor;
end;

%Reconstruct corrected volume
im100corr=fftshift(abs((ifft2(k100corr(:,:)))));
im1=fftshift(abs((ifft2(kvol1(:,:)))));
im100=fftshift(abs((ifft2(kvol100(:,:)))));

%Calculate the difference
diffb4=im1-im100;
diffafter=im1-im100corr;
subplot(211);
imagesc(diffb4);axis image;colorbar;
subplot(212);
imagesc(diffafter);axis image;colorbar;

%Phase in Degrees: radians*180/pi
%phase1_D=phase1centre*180/pi

