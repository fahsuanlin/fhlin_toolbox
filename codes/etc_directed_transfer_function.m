function [dtf_n,dtf,ddtf_n,ffdtf_n,pcoh]=etc_directed_transfer_function(v,ar_order,sf,freqVec,varargin)
% etc_directed_transfer_function   use AR model for granger causality test on frequency domain
%
% [dtf_n,dtf,ddtf_n,ffdtf_n,pcoh]=etc_directed_transfer_function(v,ar_order,sf,freqVec,[option, option_value,...]);
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
% fhlin@jun 13 2014
%

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

T=size(v,1);

H=zeros(m,m,length(freqVec));
for ff=1:length(freqVec)
    hh=eye(m);
    for idx=1:ar_order
        hh=hh-A_12(:,(idx-1)*m+1:idx*m).*exp(-sqrt(-1).*2.*pi.*(idx).*freqVec(ff)./sf);
    end;
    H(:,:,ff)=inv(hh);
    S(:,:,ff)=H(:,:,ff)*C_12*H(:,:,ff)'; %power spectrum matrix
    
    
    %partial coherence
    % J Neurosci Methods. 2003 May 30;125(1-2):195-207.
    % Determination of information flow direction among brain structures by a modified directed transfer function (dDTF) method.
    % Korzeniewska A1, Ma?czak M, Kami?ski M, Blinowska KJ, Kasicki S.

    for rr=1:size(S,1)
        for cc=1:size(S,2)
            tmp1=S(:,:,ff);
            tmp1(rr,:)=[];
            tmp1(:,cc)=[];
            
            tmp2=S(:,:,ff);
            tmp2(rr,:)=[];
            tmp2(:,rr)=[];
            
            tmp3=S(:,:,ff);
            tmp3(cc,:)=[];
            tmp3(:,cc)=[];
            
            pcoh(rr,cc,ff)=det(tmp1)/det(tmp2)/det(tmp3);
        end;
    end;
    
    dtf(:,:,ff)=abs(H(:,:,ff)).^2;
    dtf_n(:,:,ff)=abs(H(:,:,ff)).^2./repmat(sum(abs(H(:,:,ff)).^2,2),[1,size(H(:,:,ff),2)]);
end;

% full frequency Directed Transfer Function (ffDTF)
% J Neurosci Methods. 2003 May 30;125(1-2):195-207.
% Determination of information flow direction among brain structures by a modified directed transfer function (dDTF) method.
% Korzeniewska A1, Ma?czak M, Kami?ski M, Blinowska KJ, Kasicki S.

for ff=1:length(freqVec)
    ffdtf_n(:,:,ff)=abs(H(:,:,ff)).^2./repmat(sum(sum(abs(H(:,:,:)).^2,3),2),[1,size(H(:,:,ff),2)]);
end;

%direct directed transfer function (dDTF)
% J Neurosci Methods. 2003 May 30;125(1-2):195-207.
% Determination of information flow direction among brain structures by a modified directed transfer function (dDTF) method.
% Korzeniewska A1, Ma?czak M, Kami?ski M, Blinowska KJ, Kasicki S.
ddtf_n=dtf_n.*ffdtf_n;

return;



return;

