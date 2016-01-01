
kall=[];
for r=1:100
kall=cat(3,kall,kvol(:,:,1,r));
end;
%calculate phase
phaseall=[];
for r=1:100
phaseall(:,:,r)=angle(kall(:,:,r));
phaseall_D(:,:,r)=(phaseall(:,:,r)*180)/pi;
end;

%estimate correction factor
diffphase=[];
for r=1:100
diffphase(:,:,r)=phaseall(:,:,1)-phaseall(:,:,r);
end;


factorall=[];
for r=1:100
factorall(:,:,r)=exp(i*diffphase(:,:,r));
end;
%apply correction to volume 2
kallcorr=zeros(size(kall));
for r=1:100
kallcorr(:,:,r)=kall(:,:,r).*factorall(:,:,r);
end;
im100corr=fftshift(abs((ifft2(kallcorr(:,:,100)))));
im1=fftshift(abs((ifft2(kall(:,:,1)))));
im100=fftshift(abs((ifft2(kall(:,:,100)))));

%Calculate the difference
diffb4=im1-im100;
diffafter=im1-im100corr;
figure;
imagesc(diffb4);colorbar;
figure;
imagesc(diffafter);colorbar;


%Phase in Degrees: radians*180/pi
%phase1_D=phase1centre*180/pi
%drift=sum(diffphase/2*pi)
figure;
% for Graph b4corr
phaseall=[];
for r=1:100
phaseall(r)=angle(kall(33,64,r));
end;
phaseall_D=(phaseall*180)/pi;
x=1:100;
plot(x,phaseall_D,'b+');
hold on;
%plot(phaseall_D(1:100),'b+');


%for graph
phaseallcorr=[];
for r=1:100
phaseallcorr(r)=angle(kallcorr(33,64,r));
end;

phaseallcorr_D=(phaseallcorr*180)/pi;
x=1:100;
plot(x,phaseallcorr_D,'ro');