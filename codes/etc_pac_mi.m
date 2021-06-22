function [pac, pac_mi]=etc_pac_mi(freqVec,signal,fs,varargin)
%
% etc_pac_mi calculates the modulation index in phase-amplitude coupling
%
% [pac, pac_mi]=etc_pac_mi(freqVec,signal,fs,[option, option_value,...]);
%
% freqVec: 1D vector of frequencies (Hz)
% signal: 1D time series to be analyzed
% fs: samplng rate (Hz)
%
% pac: phase-amplitude coupling matrix ([#bin, amplitude frequencies, phase frequencies])
% pac_mi: modulation index ([amplitude frequencies, phase frequencies])
%
% fhlin@Jun 20, 2021
%

pac=[];
pac_mi=[];

n_bin=20; %20 bins in phase

flag_display=1;

for i=1:length(varargin)./2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'n_bin'
            n_bin=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'otherwise'
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

%get phase and amplitude time series by applying morlet wavelet transform
tfr=inverse_waveletcoef(freqVec,signal,fs,5);

amp_tfr=abs(tfr);
phase_tfr=angle(tfr);

for phase_freq_idx=1:length(freqVec)
    if(flag_display)
        fprintf('PAC at [%2.2f] Hz...\r',freqVec(phase_freq_idx));
    end;
    phase=phase_tfr(phase_freq_idx,:);
    
    %binning edges
    phase_edges=[-1:(2./n_bin):1].*pi;
    
    [phase_index]=discretize(phase, phase_edges);
    
    %phase-amplitude histogram
    for phase_idx=1:max(phase_index)
        pac(phase_idx,:,phase_freq_idx)=mean(amp_tfr(:,find(phase_index==phase_idx)),2);
    end;
    
    %noramllzed
    tmp=squeeze(pac(:,:,phase_freq_idx));
    tmp=bsxfun(@rdivide,tmp,sum(tmp,1));
    pac(:,:,phase_freq_idx)=tmp;
    
    %modulaton index
    for amp_freq_idx=phase_freq_idx:length(freqVec)
        tmp=squeeze(pac(:,amp_freq_idx,phase_freq_idx));
        %modulation index by K-L divergence
        [pac_mi(amp_freq_idx,phase_freq_idx)]=etc_kldiv([],[],'bin_edge',phase_edges,'flag_display',0,'n_P',tmp,'n_Q',ones(size(tmp))./length(tmp),'edge_P',phase_edges,'edge_Q',phase_edges);
    end;
end;
if(flag_display)
    fprintf('\n');
end;
