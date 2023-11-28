function [ EPIsos] = MBrecon_VE_ref( filename1)

EPI=mapVBVD(filename1);
EPI=EPI(end-1:end);

mrprot.dCor=zeros(size(EPI{2}.hdr().MeasYaps.sSliceArray.asSlice));
mrprot.dTra=zeros(size(EPI{2}.hdr().MeasYaps.sSliceArray.asSlice));
mrprot.dSag=zeros(size(EPI{2}.hdr().MeasYaps.sSliceArray.asSlice));
for ii=1:length(mrprot.dTra);
    if isfield(EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{2}.sPosition,'dTra')
        mrprot.dTra(ii)=EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{ii}.sPosition.dTra;
    end
    if isfield(EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{2}.sPosition,'dCor')
        mrprot.dCor(ii)=EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{ii}.sPosition.dCor;
    end
    if isfield(EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{2}.sPosition,'dSag')
        mrprot.dSag(ii)=EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{ii}.sPosition.dSag;
    end
end
mrprot.lReadFoV=EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{1}.dReadoutFOV;
mrprot.lBaseResolution=EPI{2}.hdr().Config.BaseResolution;
mrprot.lPhaseEncodingLines=EPI{2}.hdr().Config.PhaseEncodingLines;

% mrprot.dInPlaneRot=EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{1}.dInPlaneRot;
mrprot.dInPlaneRot=pi/2;
mrprot.lSlices=EPI{2}.hdr().Config.NSlcMeas;
mrprot.lPhaseFoV=EPI{2}.hdr().MeasYaps.sSliceArray.asSlice{1}.dPhaseFOV;

EPI=squeeze(EPI{2}.image());


%n_readout, n_coil, n_phase, n_partition, n_slice, n_repeat
%even readout flipping
for ii=2:2:size(EPI,3)
    EPI(:,:,ii,:,:,:)=EPI(end:-1:1,:,ii,:,:,:);
end
EPI1_ref=EPI(1:size(EPI,1)/2,:,:,:,:,1); %cropping the 1st echo?
ref1=squeeze(EPI1_ref(:,:,:,round(size(EPI1_ref,4)/2-1)+1,1));
ref1=fftshift(fft(fftshift(ref1,1),[],1),1);
newref1=zeros(size(ref1,1)*29,size(ref1,2),size(ref1,3));
newref1(size(ref1,1)*14+1:size(ref1,1)*15,:,:)=ref1;
newref1=ifftshift(ifft(ifftshift(newref1,1),[],1),1);
for ii=1:size(newref1,2)
    for jj=1:size(newref1,3)
        [~,phase1(ii,jj)]=max(abs(newref1(:,ii,jj)));
        phase1_cor(ii,jj)=angle(newref1(phase1(ii,jj),ii,jj));
        phase1(ii,jj)=(phase1(ii,jj)-((size(ref1,1)/2-1)*29+1))/29;
    end
end

phase1=mean(phase1(:,:),1);
phase=mean(phase1(2:2:end))-mean(phase1(1:2:end));


if(ndims(EPI)==6)
    EPI1_ref=squeeze(mean(EPI(size(EPI,1)/2+1:size(EPI,1),:,:,:,1,4:end),6));
    EPI2_ref=squeeze(mean(EPI(size(EPI,1)/2+1:size(EPI,1),:,:,:,2,4:end),6));
    EPI3_ref=squeeze(mean(EPI(1:size(EPI,1)/2,:,:,:,1,4:end),6));
    EPI4_ref=squeeze(mean(EPI(1:size(EPI,1)/2,:,:,:,2,4:end),6));
elseif(ndims(EPI)==5)
    EPI1_ref=squeeze(EPI(size(EPI,1)/2+1:size(EPI,1),:,:,:,1));
    EPI2_ref=squeeze(EPI(size(EPI,1)/2+1:size(EPI,1),:,:,:,2));
    EPI3_ref=squeeze(EPI(1:size(EPI,1)/2,:,:,:,1));
    EPI4_ref=squeeze(EPI(1:size(EPI,1)/2,:,:,:,2));
end;


dSlice=sqrt((mrprot.dCor(5)-mrprot.dCor(1)).^2+(mrprot.dTra(5)-mrprot.dTra(1)).^2+(mrprot.dSag(5)-mrprot.dSag(1)).^2);
a1=[mrprot.dCor(1),mrprot.dTra(1),mrprot.dSag(1)];
a2=[mrprot.dCor(end),mrprot.dTra(end),mrprot.dSag(end)];
center=a1-(a1*(a2-a1)')*(a2-a1)/sum(abs(a2-a1).^2);
% center=[mrprot.dCor(1)-(mrprot.dCor(end)-mrprot.dCor(1))*((mrprot.dCor(1)*(mrprot.dCor(end)-mrprot.dCor(1))+mrprot.dTra(1)*(mrprot.dTra(end)-mrprot.dTra(1)))/((mrprot.dCor(end)-mrprot.dCor(1))^2+(mrprot.dTra(end)-mrprot.dTra(1))^2)),mrprot.dTra(1)-(mrprot.dTra(end)-mrprot.dTra(1))*((mrprot.dCor(1)*(mrprot.dCor(end)-mrprot.dCor(1))+mrprot.dTra(1)*(mrprot.dTra(end)-mrprot.dTra(1)))/((mrprot.dCor(end)-mrprot.dCor(1))^2+(mrprot.dTra(end)-mrprot.dTra(1))^2))];
d_s1=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1),mrprot.dSag(5)-mrprot.dSag(1)]*[mrprot.dCor(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(2);mrprot.dSag(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)])*sqrt((mrprot.dCor(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2+(mrprot.dSag(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)).^2);
d_s2=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1),mrprot.dSag(5)-mrprot.dSag(1)]*[mrprot.dCor(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(2);mrprot.dSag(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)])*sqrt((mrprot.dCor(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2+(mrprot.dSag(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)).^2);
d_s3=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1),mrprot.dSag(5)-mrprot.dSag(1)]*[mrprot.dCor(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(2);mrprot.dSag(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)])*sqrt((mrprot.dCor(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2+(mrprot.dSag(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)).^2);
d_s4=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1),mrprot.dSag(5)-mrprot.dSag(1)]*[mrprot.dCor(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(2);mrprot.dSag(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)])*sqrt((mrprot.dCor(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2+(mrprot.dSag(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(3)).^2);
d_center=sign(center(1))*sqrt(center(1).^2+center(2).^2+center(3).^2);

StartStep=floor((1/3/2)/(1/5));

for jj=1:size(EPI,4)
    for ii=1:size(EPI,3)
        if mod(ii,3)==2
            if floor((jj-1)/5*3) <2
                EPI1_ref(:,:,ii,jj)=EPI1_ref(:,:,ii,jj)*exp(1i*2*pi/3*d_s1/dSlice);
                EPI2_ref(:,:,ii,jj)=EPI2_ref(:,:,ii,jj)*exp(1i*2*pi/3*d_s2/dSlice);
                EPI3_ref(:,:,ii,jj)=EPI3_ref(:,:,ii,jj)*exp(1i*2*pi/3*d_s3/dSlice);
                EPI4_ref(:,:,ii,jj)=EPI4_ref(:,:,ii,jj)*exp(1i*2*pi/3*d_s4/dSlice);
            else
                EPI1_ref(:,:,ii,jj)=EPI1_ref(:,:,ii,jj)*exp(-1i*4*pi/3*d_s1/dSlice);
                EPI2_ref(:,:,ii,jj)=EPI2_ref(:,:,ii,jj)*exp(-1i*4*pi/3*d_s2/dSlice);
                EPI3_ref(:,:,ii,jj)=EPI3_ref(:,:,ii,jj)*exp(-1i*4*pi/3*d_s3/dSlice);
                EPI4_ref(:,:,ii,jj)=EPI4_ref(:,:,ii,jj)*exp(-1i*4*pi/3*d_s4/dSlice);
            end
        elseif mod(ii,3)==0
            if floor((jj-1)/5*3) <1
                EPI1_ref(:,:,ii,jj)=EPI1_ref(:,:,ii,jj)*exp(1i*4*pi/3*d_s1/dSlice);
                EPI2_ref(:,:,ii,jj)=EPI2_ref(:,:,ii,jj)*exp(1i*4*pi/3*d_s2/dSlice);
                EPI3_ref(:,:,ii,jj)=EPI3_ref(:,:,ii,jj)*exp(1i*4*pi/3*d_s3/dSlice);
                EPI4_ref(:,:,ii,jj)=EPI4_ref(:,:,ii,jj)*exp(1i*4*pi/3*d_s4/dSlice);
            else
                EPI1_ref(:,:,ii,jj)=EPI1_ref(:,:,ii,jj)*exp(-1i*2*pi/3*d_s1/dSlice);
                EPI2_ref(:,:,ii,jj)=EPI2_ref(:,:,ii,jj)*exp(-1i*2*pi/3*d_s2/dSlice);
                EPI3_ref(:,:,ii,jj)=EPI3_ref(:,:,ii,jj)*exp(-1i*2*pi/3*d_s3/dSlice);
                EPI4_ref(:,:,ii,jj)=EPI4_ref(:,:,ii,jj)*exp(-1i*2*pi/3*d_s4/dSlice);
            end
        end
    end
end



for ii=1:size(EPI,4)
    EPI1_ref(:,:,:,ii)=EPI1_ref(:,:,:,ii)*exp(1i*(-1/2+(ii-1)/size(EPI,4))*2*pi*d_s1/dSlice);
    EPI2_ref(:,:,:,ii)=EPI2_ref(:,:,:,ii)*exp(1i*(-1/2+(ii-1)/size(EPI,4))*2*pi*d_s2/dSlice);
    EPI3_ref(:,:,:,ii)=EPI3_ref(:,:,:,ii)*exp(1i*(-1/2+(ii-1)/size(EPI,4))*2*pi*d_s3/dSlice);
    EPI4_ref(:,:,:,ii)=EPI4_ref(:,:,:,ii)*exp(1i*(-1/2+(ii-1)/size(EPI,4))*2*pi*d_s4/dSlice);
end


EPI1_ref=fftshift(fft(fftshift(EPI1_ref,1),[],1),1);
EPI2_ref=fftshift(fft(fftshift(EPI2_ref,1),[],1),1);
EPI3_ref=fftshift(fft(fftshift(EPI3_ref,1),[],1),1);
EPI4_ref=fftshift(fft(fftshift(EPI4_ref,1),[],1),1);


for ii=2:2:size(EPI1_ref,3)
    for jj=1:size(EPI1_ref,1)
        EPI1_ref(jj,:,ii,:)=EPI1_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI2_ref(jj,:,ii,:)=EPI2_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI3_ref(jj,:,ii,:)=EPI3_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI4_ref(jj,:,ii,:)=EPI4_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));       
    end
end

EPI1_ref=fftshift(fft(fftshift(EPI1_ref,3),[],3),3);
EPI1_ref=fftshift(fft(fftshift(EPI1_ref,4),[],4),4);
EPI2_ref=fftshift(fft(fftshift(EPI2_ref,3),[],3),3);
EPI2_ref=fftshift(fft(fftshift(EPI2_ref,4),[],4),4);
EPI3_ref=fftshift(fft(fftshift(EPI3_ref,3),[],3),3);
EPI3_ref=fftshift(fft(fftshift(EPI3_ref,4),[],4),4);
EPI4_ref=fftshift(fft(fftshift(EPI4_ref,3),[],3),3);
EPI4_ref=fftshift(fft(fftshift(EPI4_ref,4),[],4),4);


ReadRes=mrprot.lReadFoV/mrprot.lBaseResolution;
PhaseRes=mrprot.lPhaseFoV/mrprot.lPhaseEncodingLines;
PixelShift=round(d_center/ReadRes);

if mrprot.dInPlaneRot>pi/4
    EPI1_ref=permute(EPI1_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI2_ref=permute(EPI2_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI3_ref=permute(EPI3_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI4_ref=permute(EPI4_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
else
    EPI1_ref=permute(EPI1_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI2_ref=permute(EPI2_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI3_ref=permute(EPI3_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI4_ref=permute(EPI4_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
end




EPI1_sos=sqrt(sum(abs(EPI1_ref).^2,3));
EPI2_sos=sqrt(sum(abs(EPI2_ref).^2,3));
EPI3_sos=sqrt(sum(abs(EPI3_ref).^2,3));
EPI4_sos=sqrt(sum(abs(EPI4_ref).^2,3));


EPI1_sos=shiftback_ref(EPI1_sos);
EPI2_sos=shiftback_ref(EPI2_sos);
EPI3_sos=shiftback_ref(EPI3_sos);
EPI4_sos=shiftback_ref(EPI4_sos);



EPIsos=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,1,size(EPI1_sos,4)*4);
EPIsos(:,:,:,1:4:end)=EPI1_sos;
EPIsos(:,:,:,2:4:end)=EPI2_sos;
EPIsos(:,:,:,3:4:end)=EPI3_sos;
EPIsos(:,:,:,4:4:end)=EPI4_sos;



if mrprot.dInPlaneRot<pi/4
    temp=repmat(EPIsos,[1,2,1,1]);
    EPIsos=temp(:,1+PixelShift:mrprot.lPhaseEncodingLines+PixelShift,:,:);
    EPIsos=permute(EPIsos,[2,1,3,4]);
end

function Image=shiftback_ref(Image)
Imagetemp=repmat(Image,[1,2,1,1]);
for ii=1:size(Image,4)
    Image(:,:,:,ii)=Imagetemp(:,mod(ii-round(size(Image,4)/2+1/2),3)*size(Image,2)/3+1:mod(ii-round(size(Image,4)/2+1/2),3)*size(Image,2)/3+size(Image,2),:,ii);
end
return;


