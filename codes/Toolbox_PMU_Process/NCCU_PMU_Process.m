function clean = NCCU_PMU_Process(FileDir,STCFile,TR)
% Input Format: NCCU_PMU_Process(FileDir,STCFile,TR)
% STCFile: 4D-lh.stc or 4D.nii
% TR: unit--ms
% edit by Yi-Tien Li 2017/11/16
%% Read stc
CurrentDir=pwd;
cd(FileDir);
%remember to addpath "Archieve" folder
addpath('/autofs/space/maki6_001/users/yitien/Archive');
addpath('/autofs/space/home/fhlin/matlab/toolbox/fhlin_toolbox');
addpath(genpath('/autofs/space/maki6_001/users/yitien/toolbox_matlab_nifti'));
% addpath('E:\PMU_remove34\Archive');
type = 0;
if strcmp(STCFile(end-2:end),'nii')
type=1;
nii=MRIread(STCFile);
data_stc=reshape(nii.vol,size(nii.vol,1)*size(nii.vol,2)*size(nii.vol,3),size(nii.vol,4));
else
[data_stc,Vv_lh]=inverse_read_stc(STCFile);
end
%% Load PMU Data
RESP_File = cellstr(ls('*.resp'));
ECG_File = cellstr(ls('*.ecg'));
EXT_File = cellstr(ls('*.ext'));
RESP_Data2 = siemens_NCCU_RESPLoad(RESP_File{1});
[ECG_Data2 trg_Data2] = siemens_NCCU_ECGLoad(ECG_File{1});
EXT_Data = siemens_NCCU_EXTLoad(EXT_File{1});

%% Adjust Time Shift
len_ext = size(EXT_Data,2);
len_resp = size(RESP_Data2,2);
len_trg = size(trg_Data2,2);
if len_ext < len_resp
    RESP_Data(1,1:len_ext) = RESP_Data2(1,1+len_resp-len_ext:len_resp);
    RESP_Data(2,1:len_ext) = RESP_Data2(2,1:len_ext);
elseif len_ext > len_resp
    RESP_Data(1,:) = [zeros(1,len_ext-len_resp) RESP_Data2(1,:)];
    RESP_Data(2,:) = EXT_Data(2,:);
end
if len_ext < len_trg
    trg_Data(1,1:len_ext) = trg_Data2(1,1+len_trg-len_ext:len_trg);
    trg_Data(2,1:len_ext) = trg_Data2(2,1:len_ext);
elseif len_ext > len_resp
    trg_Data(1,:) = [zeros(1,len_ext-len_trg) trg_Data2(1,:)];
    trg_Data(2,:) = EXT_Data(2,:);
end

%% PMU Preprocessing
trg = abs(diff(EXT_Data(1,:)));
trg = [0 trg];
ind = find(trg~=0);
if TR>=1000
    trg_in = EXT_Data(2,ind(1)); %epi
    fprintf('Start PMU processing on epi data!!\n');
else
    trg_in = EXT_Data(2,ind(61)); %sms
    fprintf('Start PMU processing on SMS-InI data!!\n');
end
trg_stop = EXT_Data(2,ind(end))+EXT_Data(2,ind(2))-EXT_Data(2,ind(1));
ind1 = find(abs(RESP_Data(2,:)-trg_in)<0.0001);
ind2 = find(abs(RESP_Data(2,:)-trg_stop)<0.0001);
data_resp = RESP_Data(1,ind1+1:ind2);
sR = sgolayfilt(data_resp,3,1199);
dR = diff(sR);dR = [0 dR];
sR(abs(dR)<=std(dR)/2.5 & abs(sR)<=std(sR)/2.5)=median(sR);
ind1 = find(abs(trg_Data(2,:)-trg_in)<0.0001);
ind2 = find(abs(trg_Data(2,:)-trg_stop)<0.0001);
data_ecg = trg_Data(1,ind1+1:ind2);
data_ecg = conv(data_ecg,[0.0125:0.0125:1 0.9875:-0.0125:0.0125],'same');
%% RETROICOR & RVHRCOR
dt_ecg = TR*size(data_stc,2)/length(data_ecg);
dt_resp = TR*size(data_stc,2)/length(data_resp);
[clean,card,resp] = retroicor_rvhrcor(data_stc,data_ecg,data_resp,[TR dt_ecg dt_resp],2,2);
%% Write STC
filename=['r_' STCFile];
if type ==0
  timeVec=((1:size(data_stc,2))-1).*TR;
  inverse_write_stc(clean,(0:size(data_stc,1)-1),timeVec(1).*1e3,mean(diff(timeVec)).*1e3,filename);
%   save temp.mat data_stc clean
else
    err = MRIwrite(reshape(clean,size(nii.vol,1),size(nii.vol,2),size(nii.vol,3),size(nii.vol,4)),'filename','double');
end
  cd(CurrentDir);
return