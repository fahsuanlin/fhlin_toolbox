function [Y,C,snr,signal,noise]=inverse_stim(A,x,SNR,varargin)
% inverse_stim      generate simulated signal based on artificial dipole waveform(s), forward model and SNR
%
%   [Y,C,signal,noise]=inverse_stim(A,x,SNR)
%
%   A: 2D forward matrix
%   x: 1D column vecror or 2D matrix of dipole activations
%   SNR: power signal to noise ratio (NOT square root of SNR!)
%   Y: observed signal
%   C: noise covariance matrix
%
%   Y=A*x+noise
%
%   cov(noise)=C; noise covariance matrix
%   signal=sum of squares of (A*x)
% 
% fhlin@nov. 13, 2001


mode='avg';
if(nargin>3)
	mode=varargin{1};
end;

%   nc: number of sensors (MEG: 306 or 122....)
nc=size(A,1);	
fprintf('[%d] channels\n',nc);


%sensor noise: Gaussian white noise on sensor space
noise=randn(nc,size(x,2));


%noise covariance matrix
if(size(noise,2)==1)
	C=noise*noise';
else
	C=cov(noise',1);
end;

[u,s,v]=svd(eye(nc));

C_white=eye(size(C,1));
noise_white=u*inv(sqrt(s))*u'*noise;

if(strcmp(mode,'avg'))

	noise_var=trace(C_white);

elseif(strcmp(mode,'max_instant'))

	noise_var=max(max(abs(noise_white).^2));

else
	
	fprintf('unknown type option [%s]!\n',mode);
	error;

end;

signal=A*x;

%signal_collapse=max(abs(signal),[],1);
%[dummy,signal_collapse_idx]=max(signal_collapse);

%whitening signal
signal_white=u*inv(sqrt(s))*u'*signal;

if(strcmp(mode,'avg'))
	S=(signal_white*signal_white')./size(signal_white,2);

	signal_var=trace(S);
elseif(strcmp(mode,'max_instant'))

	signal_var=max(max(abs(signal_white).^2));

else
	
	fprintf('unknown type option [%s]!\n',mode);
	error;
end;

%adjusting noise level based on noise level and SNR
noise=noise.*sqrt(signal_var./SNR./noise_var);

%observared signal and SNR
Y=signal+noise;

signal_white=inv(sqrt(s))*u'*signal;
snr=squeeze(sum(signal_white.^2,1))./noise_var;

Y_white=inv(sqrt(s))*u'*Y;

% snr1=sum(signal.^2,1)./sum(noise.^2,1);
% snr2=sum(Y.^2,1)./trace(C)-1;  %this one is not meaningful because the unit between gradiaometers, magnetometers and EEG channels are different. Additional whitening process is required to collapse all channels together as metrics of signal and noise power.
% snr3=sum(Y_white.^2,1)./size(Y_white,1)-1;


