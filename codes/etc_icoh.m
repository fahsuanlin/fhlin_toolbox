function [icoh]=etc_icoh(v,ar_order,sf,freqVec,varargin)
% etc_icoh   use AR model for isolated effective coherence (iCoh) in the
% frequency domain
%
% [icoh]=etc_directed_transfer_function(v,ar_order,sf,freqVec,[option, option_value,...]);
%   v: [n,m] timeseries of n-timepoint and m-nodes
%   n-timepoint and k-observations
%
%   ar_order: the order of the AR model
%   sf: sampling frequency
%   freqVec: sweeping frequency range for granger causality test
%
%   option:
%       'ts_name': names for time series, in string cells
%       'g_threshold': the threshold of the granger causlity to be
%       considered significant.
%       'g_threshold_p': the p-value threshold of the granger causlity to be
%       considered significant.
%   granger: [m,m] granger causality matrix. each entry is the variance ratio: (res_orig^2/res_additional_timeseries^2)
%
% fhlin@dec 6 2014
%
% Pascua-Marqui, D. et al (Frontiers in Human Neuroscience 2014(8): 448

flag_display=0;
ts_name={};
g_threshold=[];
g_threshold_p=[];

dtf=[];
dtf_n=[];


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch option
        case 'flag_display'
            flag_display=option_value;
        case 'ts_name'
            ts_name=option_value;
        case 'g_threshold'
            g_threshold=option_value;
        case 'g_threshold_p'
            g_threshold_p=option_value;
    end;
end;

[n,m]=size(v);
dtf=zeros(m,m,length(freqVec));
dtf_n=zeros(m,m,length(freqVec));

[w_12,A_12,C_12,SBC_12,FPE_12,th_12]=arfit(v,ar_order,ar_order);

C_12_inv=inv(C_12);
T=size(v,1);

H=zeros(m,m,length(freqVec));
for ff=1:length(freqVec)
    hh=eye(m);
    for idx=1:ar_order
        hh=hh-A_12(:,(idx-1)*m+1:idx*m).*exp(-sqrt(-1).*2.*pi.*(idx).*freqVec(ff)./sf);
    end;
    H(:,:,ff)=inv(hh);
    S(:,:,ff)=H(:,:,ff)*C_12*H(:,:,ff)'; %power spectrum matrix
    
    
    icoh(2,1,ff)=C_12_inv(2,2)*abs(hh(2,1)).^2/(C_12_inv(2,2)*abs(hh(2,1)).^2+C_12_inv(1,1)*abs(hh(1,1)).^2);
    icoh(1,2,ff)=C_12_inv(1,1)*abs(hh(1,2)).^2/(C_12_inv(1,1)*abs(hh(1,2)).^2+C_12_inv(2,2)*abs(hh(2,2)).^2);

end;


return;

