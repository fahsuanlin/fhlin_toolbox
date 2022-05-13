function [ EPIsos,EPIrec ] = MBrecon( filename1,filename2,lambda )

file_raw=filename1;
fprintf('raw data file = [%s]\n',file_raw);


clear global ice_obj;
clear global ice_m_data;


file_in = fopen(file_raw,'r','l','US-ASCII');
fseek(file_in,0,'eof');
fileSize = ftell(file_in);

fseek(file_in,0,'bof');

meas_ID  = fread(file_in,1,'uint32');
n_measraw = fread(file_in,1,'uint32');

meas_ID=fread(file_in,1,'uint32');
file_ID=fread(file_in,1,'uint32');
measOffset = fread(file_in,1,'uint64');
measLength = fread(file_in,1,'uint64');
patientName = fread(file_in,1,'uint64');
protocolName = fread(file_in,1,'uint64');


fseek(file_in,measOffset(1),'bof');

hdrLength  = fread(file_in,1,'uint32');

fprintf('measurement has a header of %d (bytes)\n', hdrLength);

buffer=fread(file_in,hdrLength,'uchar');

fp=fopen(sprintf('vd11_meas.asc'),'w');

fprintf(fp,'%c',char(buffer));
fclose(fp);
mrprot=ice_read_prot_mbsirepi(sprintf('vd11_meas.asc'));

fclose(file_in);

EPI=readVBVD(filename1);
EPI=EPI.sqzData;
EPIacc=readVBVD(filename2);
EPIacc=EPIacc.sqzData;


if ndims(EPIacc)==6
    EPIacc=permute(EPIacc,[1,2,3,5,4,6]);
    EPIacc=reshape(EPIacc,size(EPIacc,1),size(EPIacc,2),size(EPIacc,3),size(EPIacc,4),[]);
end


for ii=2:2:size(EPI,3)
    EPI(:,:,ii,:,:,:)=EPI(end:-1:1,:,ii,:,:,:);
    EPIacc(:,:,ii,:,:)=EPIacc(end:-1:1,:,ii,:,:);
end

EPI1_ref=EPI(1:size(EPI,1)/2,:,:,:,:,1);
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

EPI1_ref=squeeze(mean(EPI(size(EPI,1)/2+1:size(EPI,1),:,:,:,1,4:end),6));
EPI2_ref=squeeze(mean(EPI(size(EPI,1)/2+1:size(EPI,1),:,:,:,2,4:end),6));
EPI3_ref=squeeze(mean(EPI(1:size(EPI,1)/2,:,:,:,1,4:end),6));
EPI4_ref=squeeze(mean(EPI(1:size(EPI,1)/2,:,:,:,2,4:end),6));


EPI1_acc=squeeze(EPIacc(size(EPI,1)/2+1:size(EPI,1),:,:,1,:));
EPI2_acc=squeeze(EPIacc(size(EPI,1)/2+1:size(EPI,1),:,:,2,:));
EPI3_acc=squeeze(EPIacc(1:size(EPI,1)/2,:,:,1,:));
EPI4_acc=squeeze(EPIacc(1:size(EPI,1)/2,:,:,2,:));
clear EPIacc

dSlice=sqrt((mrprot.dCor(5)-mrprot.dCor(1)).^2+(mrprot.dTra(5)-mrprot.dTra(1)).^2);
center=[mrprot.dCor(1)-(mrprot.dCor(end)-mrprot.dCor(1))*((mrprot.dCor(1)*(mrprot.dCor(end)-mrprot.dCor(1))+mrprot.dTra(1)*(mrprot.dTra(end)-mrprot.dTra(1)))/((mrprot.dCor(end)-mrprot.dCor(1))^2+(mrprot.dTra(end)-mrprot.dTra(1))^2)),mrprot.dTra(1)-(mrprot.dTra(end)-mrprot.dTra(1))*((mrprot.dCor(1)*(mrprot.dCor(end)-mrprot.dCor(1))+mrprot.dTra(1)*(mrprot.dTra(end)-mrprot.dTra(1)))/((mrprot.dCor(end)-mrprot.dCor(1))^2+(mrprot.dTra(end)-mrprot.dTra(1))^2))];
d_s1=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1)]*[mrprot.dCor(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)])*sqrt((mrprot.dCor(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(1+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2);
d_s2=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1)]*[mrprot.dCor(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)])*sqrt((mrprot.dCor(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(2+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2);
d_s3=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1)]*[mrprot.dCor(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)])*sqrt((mrprot.dCor(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(3+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2);
d_s4=-sign([mrprot.dCor(5)-mrprot.dCor(1),mrprot.dTra(5)-mrprot.dTra(1)]*[mrprot.dCor(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(1);mrprot.dTra(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)])*sqrt((mrprot.dCor(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(1)).^2+(mrprot.dTra(4+4*(round(mrprot.lSlices/4/2-1/2)))-center(2)).^2);
d_center=sign(center(1))*sqrt(center(1).^2+center(2).^2);

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


for ii=1:size(EPI,3)
    if mod(ii,3)==2
        if floor(StartStep/5*3) <2
            EPI1_acc(:,:,ii,:)=EPI1_acc(:,:,ii,:)*exp(1i*2*pi/3*d_s1/dSlice);
            EPI2_acc(:,:,ii,:)=EPI2_acc(:,:,ii,:)*exp(1i*2*pi/3*d_s2/dSlice);
            EPI3_acc(:,:,ii,:)=EPI3_acc(:,:,ii,:)*exp(1i*2*pi/3*d_s3/dSlice);
            EPI4_acc(:,:,ii,:)=EPI4_acc(:,:,ii,:)*exp(1i*2*pi/3*d_s4/dSlice);
        else
            EPI1_acc(:,:,ii,:)=EPI1_acc(:,:,ii,:)*exp(-1i*4*pi/3*d_s1/dSlice);
            EPI2_acc(:,:,ii,:)=EPI2_acc(:,:,ii,:)*exp(-1i*4*pi/3*d_s2/dSlice);
            EPI3_acc(:,:,ii,:)=EPI3_acc(:,:,ii,:)*exp(-1i*4*pi/3*d_s3/dSlice);
            EPI4_acc(:,:,ii,:)=EPI4_acc(:,:,ii,:)*exp(-1i*4*pi/3*d_s4/dSlice);
        end
    elseif mod(ii,3)==0
        if floor(StartStep/5*3) <1
            EPI1_acc(:,:,ii,:)=EPI1_acc(:,:,ii,:)*exp(1i*4*pi/3*d_s1/dSlice);
            EPI2_acc(:,:,ii,:)=EPI2_acc(:,:,ii,:)*exp(1i*4*pi/3*d_s2/dSlice);
            EPI3_acc(:,:,ii,:)=EPI3_acc(:,:,ii,:)*exp(1i*4*pi/3*d_s3/dSlice);
            EPI4_acc(:,:,ii,:)=EPI4_acc(:,:,ii,:)*exp(1i*4*pi/3*d_s4/dSlice);
        else
            EPI1_acc(:,:,ii,:)=EPI1_acc(:,:,ii,:)*exp(-1i*2*pi/3*d_s1/dSlice);
            EPI2_acc(:,:,ii,:)=EPI2_acc(:,:,ii,:)*exp(-1i*2*pi/3*d_s2/dSlice);
            EPI3_acc(:,:,ii,:)=EPI3_acc(:,:,ii,:)*exp(-1i*2*pi/3*d_s3/dSlice);
            EPI4_acc(:,:,ii,:)=EPI4_acc(:,:,ii,:)*exp(-1i*2*pi/3*d_s4/dSlice);
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
EPI1_acc=fftshift(fft(fftshift(EPI1_acc,1),[],1),1);
EPI2_acc=fftshift(fft(fftshift(EPI2_acc,1),[],1),1);
EPI3_acc=fftshift(fft(fftshift(EPI3_acc,1),[],1),1);
EPI4_acc=fftshift(fft(fftshift(EPI4_acc,1),[],1),1);


for ii=2:2:size(EPI1_ref,3)
    for jj=1:size(EPI1_ref,1)
        EPI1_ref(jj,:,ii,:)=EPI1_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI2_ref(jj,:,ii,:)=EPI2_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI3_ref(jj,:,ii,:)=EPI3_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI4_ref(jj,:,ii,:)=EPI4_ref(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI1_acc(jj,:,ii,:)=EPI1_acc(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI2_acc(jj,:,ii,:)=EPI2_acc(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI3_acc(jj,:,ii,:)=EPI3_acc(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        EPI4_acc(jj,:,ii,:)=EPI4_acc(jj,:,ii,:)*exp(1i*phase*jj*2*pi/size(EPI1_ref,1)-1i*phase*(size(EPI1_ref,1)/2+1)*2*pi/size(EPI1_ref,1));
        
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

EPI1_acc=fftshift(fft(fftshift(EPI1_acc,3),[],3),3);
EPI2_acc=fftshift(fft(fftshift(EPI2_acc,3),[],3),3);
EPI3_acc=fftshift(fft(fftshift(EPI3_acc,3),[],3),3);
EPI4_acc=fftshift(fft(fftshift(EPI4_acc,3),[],3),3);

ReadRes=mrprot.lReadFoV/mrprot.lBaseResolution;
PhaseRes=mrprot.lPhaseFoV/mrprot.lPhaseEncodingLines;
PixelShift=round(d_center/ReadRes);

if mrprot.dInPlaneRot>pi/4
    EPI1_ref=permute(EPI1_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI2_ref=permute(EPI2_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI3_ref=permute(EPI3_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI4_ref=permute(EPI4_ref(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI1_acc=permute(EPI1_acc(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI2_acc=permute(EPI2_acc(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI3_acc=permute(EPI3_acc(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
    EPI4_acc=permute(EPI4_acc(round(mrprot.lBaseResolution/2)+1+PixelShift:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution+PixelShift,:,:,:),[1,3,2,4]);
else
    EPI1_ref=permute(EPI1_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI2_ref=permute(EPI2_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI3_ref=permute(EPI3_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI4_ref=permute(EPI4_ref(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI1_acc=permute(EPI1_acc(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI2_acc=permute(EPI2_acc(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI3_acc=permute(EPI3_acc(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
    EPI4_acc=permute(EPI4_acc(round(mrprot.lBaseResolution/2)+1:round(mrprot.lBaseResolution/2)+mrprot.lBaseResolution,:,:,:),[1,3,2,4]);
end



% EPI1_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI1_ref,4),size(EPI1_acc,4));
% EPI2_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI2_ref,4),size(EPI2_acc,4));
% EPI3_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI3_ref,4),size(EPI3_acc,4));
% EPI4_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI4_ref,4),size(EPI4_acc,4));
%
% for jj=1:mrprot.lBaseResolution
%     for kk=1:mrprot.lPhaseEncodingLines
%         temp1=squeeze(EPI1_ref(jj,kk,:,:));
%         EPI1_rec(jj,kk,:,:)=(temp1'*temp1+lambda*eye(size(EPI1_rec,3)))\(temp1'*squeeze(EPI1_acc(jj,kk,:,:)));
%         temp2=squeeze(EPI2_ref(jj,kk,:,:));
%         EPI2_rec(jj,kk,:,:)=(temp2'*temp2+lambda*eye(size(EPI1_rec,3)))\(temp2'*squeeze(EPI2_acc(jj,kk,:,:)));
%         temp3=squeeze(EPI3_ref(jj,kk,:,:));
%         EPI3_rec(jj,kk,:,:)=(temp3'*temp3+lambda*eye(size(EPI1_rec,3)))\(temp3'*squeeze(EPI3_acc(jj,kk,:,:)));
%         temp4=squeeze(EPI4_ref(jj,kk,:,:));
%         EPI4_rec(jj,kk,:,:)=(temp4'*temp4+lambda*eye(size(EPI1_rec,3)))\(temp4'*squeeze(EPI4_acc(jj,kk,:,:)));
%     end
% end

EPI1_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI1_ref,4),size(EPI1_acc,4));
for jj=1:mrprot.lBaseResolution
    for kk=1:mrprot.lPhaseEncodingLines
        temp1=squeeze(EPI1_ref(jj,kk,:,:));
        EPI1_rec(jj,kk,:,:)=(temp1'*temp1+lambda*eye(size(EPI1_rec,3)))\(temp1'*squeeze(EPI1_acc(jj,kk,:,:)));
    end
end
clear EPI1_acc

EPI2_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI2_ref,4),size(EPI2_acc,4));
for jj=1:mrprot.lBaseResolution
    for kk=1:mrprot.lPhaseEncodingLines
        temp2=squeeze(EPI2_ref(jj,kk,:,:));
        EPI2_rec(jj,kk,:,:)=(temp2'*temp2+lambda*eye(size(EPI1_rec,3)))\(temp2'*squeeze(EPI2_acc(jj,kk,:,:)));
    end
end
clear EPI2_acc

EPI3_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI3_ref,4),size(EPI3_acc,4));
for jj=1:mrprot.lBaseResolution
    for kk=1:mrprot.lPhaseEncodingLines
        temp3=squeeze(EPI3_ref(jj,kk,:,:));
        EPI3_rec(jj,kk,:,:)=(temp3'*temp3+lambda*eye(size(EPI1_rec,3)))\(temp3'*squeeze(EPI3_acc(jj,kk,:,:)));
    end
end
clear EPI3_acc

EPI4_rec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI4_ref,4),size(EPI4_acc,4));
for jj=1:mrprot.lBaseResolution
    for kk=1:mrprot.lPhaseEncodingLines
        temp4=squeeze(EPI4_ref(jj,kk,:,:));
        EPI4_rec(jj,kk,:,:)=(temp4'*temp4+lambda*eye(size(EPI1_rec,3)))\(temp4'*squeeze(EPI4_acc(jj,kk,:,:)));
    end
end
clear EPI4_acc

EPI1_sos=sqrt(sum(abs(EPI1_ref).^2,3));
EPI2_sos=sqrt(sum(abs(EPI2_ref).^2,3));
EPI3_sos=sqrt(sum(abs(EPI3_ref).^2,3));
EPI4_sos=sqrt(sum(abs(EPI4_ref).^2,3));

EPI1_rec=shiftback_rec(EPI1_rec);
EPI2_rec=shiftback_rec(EPI2_rec);
EPI3_rec=shiftback_rec(EPI3_rec);
EPI4_rec=shiftback_rec(EPI4_rec);

EPI1_sos=shiftback_ref(EPI1_sos);
EPI2_sos=shiftback_ref(EPI2_sos);
EPI3_sos=shiftback_ref(EPI3_sos);
EPI4_sos=shiftback_ref(EPI4_sos);



EPIsos=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,1,size(EPI1_sos,4)*4);
EPIsos(:,:,:,1:4:end)=EPI1_sos;
EPIsos(:,:,:,2:4:end)=EPI2_sos;
EPIsos(:,:,:,3:4:end)=EPI3_sos;
EPIsos(:,:,:,4:4:end)=EPI4_sos;


EPIrec=zeros(mrprot.lBaseResolution,mrprot.lPhaseEncodingLines,size(EPI1_rec,3)*4,size(EPI1_rec,4));
EPIrec(:,:,1:4:end,:)=EPI1_rec;
EPIrec(:,:,2:4:end,:)=EPI2_rec;
EPIrec(:,:,3:4:end,:)=EPI3_rec;
EPIrec(:,:,4:4:end,:)=EPI4_rec;

if mrprot.dInPlaneRot<pi/4
    temp=repmat(EPIsos,[1,2,1,1]);
    EPIsos=temp(:,1+PixelShift:mrprot.lPhaseEncodingLines+PixelShift,:,:);
    EPIsos=permute(EPIsos,[2,1,3,4]);
    temp=repmat(EPIrec,[1,2,1,1]);
    EPIrec=temp(:,1+PixelShift:mrprot.lPhaseEncodingLines+PixelShift,:,:);
    EPIrec=permute(EPIrec,[2,1,3,4]);
end
    function Image=shiftback_ref(Image)
        Imagetemp=repmat(Image,[1,2,1,1]);
        for ii=1:size(Image,4)
            Image(:,:,:,ii)=Imagetemp(:,mod(ii-round(size(Image,4)/2+1/2),3)*size(Image,2)/3+1:mod(ii-round(size(Image,4)/2+1/2),3)*size(Image,2)/3+size(Image,2),:,ii);
        end
    end
    function Image=shiftback_rec(Image)
        Imagetemp=repmat(Image,[1,2,1,1]);
        for ii=1:size(Image,3)
            Image(:,:,ii,:)=Imagetemp(:,mod(ii-round(size(Image,3)/2+1/2),3)*size(Image,2)/3+1:mod(ii-round(size(Image,3)/2+1/2),3)*size(Image,2)/3+size(Image,2),ii,:);
        end
    end
end

