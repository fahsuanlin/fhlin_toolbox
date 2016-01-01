function [snr]=mri_localsnr(data)
% mri_localsnr 		estimate local SNR
%
%	snr=mri_localsnr(data)
% 	
%	data: 2D image matrix
%	snr:  2D SNR image
%
%	written by fhlin@Apr. 22, 2000


orig_sz=size(data);
data=imresize(data,[256,256]);

%do block variance calculation
snr=zeros(16,16);

%block transform to get signalco
signal=blkproc(data,[16,16],'mean2');

%block transform to get noise
noise=blkproc(data,[16,16],'std2');
idx0=find(noise==0);
idx1=find(noise~=0);

%transform SNR into dB
snr(idx1)=10.*log(signal(idx1)./noise(idx1));
snr(idx0)=50;
idx=find(snr<0);
snr(idx)=0;


snr=imresize(snr,size(data),'bilinear');
snr=imresize(snr,orig_sz);
