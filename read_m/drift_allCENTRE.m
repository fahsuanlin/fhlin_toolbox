%[kvol, navs] = myread_meas_out('meas_100.out');

kall=[];
for r=1:100
kall=cat(3,kall,kvol(:,:,1,r));
end;


%for correction

phaseallCENTRE=[];
for r=1:100
phaseallCENTRE(:,:,r)=angle(kall(:,64,r));
phaseallCENTRE_D(:,:,r)=(phaseallCENTRE(:,:,r)*180)/pi;
end;


diffphase=[];
for r=1:100
diffphase(:,:,r)=phaseallCENTRE(:,:,1)-phaseallCENTRE(:,:,r);
end;

factorall=[];
for r=1:100
factorall(:,:,r)=exp(i*diffphase(:,:,r));
end;
kallcorr=zeros(size(kall));
for r=1:100
    for t=1:128
kallcorr(:,t,r)=kall(:,t,r).*factorall(:,:,r);
end;
end;



%Reconstruct corrected volume
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
