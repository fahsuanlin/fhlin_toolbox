[kvol, navs] = myread_meas_out('meas_100.out');

imall=[];
for i=1:100
imvol=fftshift(abs((ifft2(kvol(:,:,1,i)))));
imall=cat(3,imall,imvol);
end;
figure;
im1=imall(:,:,1);
imagesc(im1);
figure;
im100=imall(:,:,100);
imagesc(im100);
figure;colormap gray;
imagesc(im1-im100);




kall=[];
for r=1:100
kvol_new=kvol(:,:,1,r);
kall=cat(3,kall,kvol_new);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
previous centre of kspce for first and last images only
%select 2 kvolumes
%kvol1=kvol(:,:,1,1);
%kvol100=kvol(:,:,1,100);


%calculate phase of central point 31-64
%phase1=angle(kvol1(33,65));
%phase100=angle(kvol100(33,65));

%calculate phase of central line
%phase1=angle(kvol1(33,:));
%phase100=angle(kvol100(33,:));



%estimate correction factor
%diffphase=phase1-phase100;
%factor=exp(i*diffphase);

%apply correction to volume 2
%kvol100corr=(kvol100(:,:)).*factor;

%Reconstruct corrected volume
%im100corr=fftshift(abs((ifft2(kvol100corr(:,:)))));

%Calculate the difference
%imagesc(im1-im100corr);


%Phase in Degrees: radians*180/pi
%phase1_D=phase1centre*180/pi

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Graph b4corr
phaseall=[];
for r=1:100
phase=angle(kall(33,65,r));
phaseall(r)=phase;
end;
phaseall_D=(phaseall*180)/pi;
x=1:100;
%plot(phaseall_D(1:100),'b+');
plot(x,phaseall_D,'b+');


diffall=[];
for r=1:100
diffphase=phaseall(1)-phaseall(r);
diffall(r)=diffphase;
end;

factorall=[];
for r=1:100
factor=exp(i*diffall(r));
factorall(r)=factor;
end;

kall1=zeros(size(kall));
kvolcorr=zeros(size(kall));
for r=1:100
kall1(:,:,r)=kall(:,:,r)*factorall(r);
kvolcorr=kall1;
end;



phaseallcorr=[];
for r=1:100
phasecorr=angle(kall1(33,65,r));
phaseallcorr(r)=phasecorr;

end;
phaseallcorr_D=(phaseallcorr*180)/pi;
x=1:100;
plot(x,phaseallcorr_D,'r+');