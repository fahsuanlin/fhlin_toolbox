function [lambda_lcurve, LAMBDA_lcurve, lambda_gcv, LAMBDA_gcv, lambda_whitened_y, LAMBDA_whitened_y,eta,rho,gcv,reg_param]=inverse_snr_estimate(A,C,R,Y,varargin)
% inverse_snr_estimate     estimate SNR using regularization
%
% [lambda,LAMBDA,eta,rho,reg_param]=inverse_snr_estimate(A,C,R,Y,[method])
%
% A: forward matrix
% C: noise covariance matrix
% R: source covariance matrix (fMRI weighting)
% Y: observation data
%
% fhlin@jan. 23, 2002
%whitening of noise covariance, source covariance and observation 

flag_lcurve=1;
flag_gcv=0;
flag_snr_maxavg=0;

snr_white_estimate=[];
eta=[];
rho=[];
gcv=[];
reg_corner_lcurve=[];
reg_corner_gcv=[];

lambda_lcurve=[];
LAMBDA_lcurve=[];

lambda_gcv=[];
LAMBDA_gcv=[];

lambda_whitened_y=[];
LAMBDA_whitened_y=[];


for i=1:floor(length(varargin)/2)
	option=varargin{i*2-1};
	option_value=varargin{2*i};

	switch lower(option)
	case 'flag_gcv'
		flag_gcv=option_value;
	case 'flag_lcurve'
		flag_lcurve=option_value;
	case 'flag_snr_maxavg'
		flag_snr_maxavg=option_value;
	end;
end;


fprintf('preparation by whitening noise covariance matrix...\n');
[u,s,v]=svd(C);

%centerize the measurement
%Y_mean=mean(Y,2);
%Y_center=Y-repmat(Y_mean,[1,size(Y,2)]);
Y_white=inv(sqrt(s))*u'*Y;

r=rank(C);
Y_white=Y_white(1:r,:);

switch flag_snr_maxavg
case 0
	snr_white_estimate=abs((sum(Y_white.^2,1)./size(Y,1))-1);
case 1
	snr_white_estimate=abs((max(Y_white.^2,[],1))-1);
end;

Y_tildor=pinv(sqrt(s))*u'*Y;
A_tildor=pinv(sqrt(s))*u'*A;
M=sqrt(R);  %assuming R is a vector
Y_tildor=Y_tildor(1:r,:);
A_tildor=A_tildor(1:r,:);


% estimate SNR using regularization
fprintf('SVD forward model..\n');
[v,s,u]=svd(A_tildor',0);

power_signal=trace(A_tildor*A_tildor');
power_noise=size(A,1);

fprintf('estimation..\n');


for i=1:size(Y,2)
    rr=(1e-4).^(1/199);
%    rp=(power_signal./power_noise./(snr_white_estimate(i).*100)).*(rr.^([1:200]-1));
	rp=[];

	if(flag_lcurve)
		[reg_corner_lcurve(i),eta(:,i),rho(:,i),reg_param(:,i)] = inverse_lcurve(u,diag(s),Y_tildor(:,i),'v',v,'reg_param',rp);
	    fprintf('l-curve estimate of SNR [%d|%d]...corner: [%3.3e]  snr: %3.3e\n', i,size(Y,2),reg_corner_lcurve(i),power_signal./power_noise./reg_corner_lcurve(i)./reg_corner_lcurve(i));
	end;

	if(flag_gcv)
	    [reg_corner_gcv(i),gcv(:,i),reg_param(:,i)] = gcv(u,diag(s),Y_tildor(:,i),'tikh','reg_param',rp'); 	
	    fprintf('GCV estimate of SNR [%d|%d]...corner: [%3.3e]  snr: %3.3e\n', i,size(Y,2),reg_corner_gcv(i),power_signal./power_noise./reg_corner_gcv(i)./reg_corner_gcv(i));

	end;
end;

if(~isempty(reg_corner_lcurve))
	LAMBDA_lcurve=(power_signal./power_noise./reg_corner_lcurve.^2);
	lambda_lcurve=squeeze(mean(LAMBDA_lcurve));	
end;

if(~isempty(reg_corner_gcv))
	LAMBDA_gcv=(power_signal./power_noise./reg_corner_gcv.^2)  ;
	lambda_gcv=squeeze(mean(LAMBDA_gcv));	
end;

if(~isempty(snr_white_estimate))
	LAMBDA_whitened_y=snr_white_estimate;
	lambda_whitened_y=squeeze(mean(LAMBDA_whitened_y));
end;









