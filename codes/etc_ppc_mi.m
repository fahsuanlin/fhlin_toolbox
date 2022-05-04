function [ppc, ppc_mi]=etc_ppc_mi(freqVec,signal,fs,varargin)
%
% etc_ppc_mi calculates the modulation index in phase-phase coupling
%
% [ppc, ppc_mi]=etc_ppc_mi(freqVec,signal,fs,[option, option_value,...]);
%
% freqVec: 1D vector of frequencies (Hz)
% signal: 1D time series to be analyzed
% fs: samplng rate (Hz)
%
% ppc: phase-phase coupling matrix ([#bin, phase frequencies, phase frequencies])
% ppc_mi: modulation index ([phase frequencies, phase frequencies])
%
% fhlin@Jun 20, 2021
%

ppc=[];
ppc_mi=[];

phase_ref_tfr=[];
phase_mod_tfr=[];

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
        case 'phase_ref_tfr'
            phasee_ref_tfr=option_value;
        case 'phase_mod_tfr'
            phase_mod_tfr=option_value;
        case 'otherwise'
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

if(isempty(phase_mod_tfr)&&isempty(phase_ref_tfr))
    %get two phase time series by applying morlet wavelet transform
    tfr=inverse_waveletcoef(freqVec,signal,fs,5);

    phase_mod_tfr=angle(tfr);
    phase_ref_tfr=angle(tfr);
end;

for phase_freq_idx=1:length(freqVec)
    if(flag_display)
        fprintf('PPC at [%2.2f] Hz...\r',freqVec(phase_freq_idx));
    end;
    phase=phase_ref_tfr(phase_freq_idx,:);
    
    %binning edges
    phase_edges=[-1:(2./n_bin):1].*pi;
    
    [phase_index]=discretize(phase, phase_edges);
    
    %phase-phase histogram
    for phase_idx=1:max(phase_index)
        %tmp=mean(phase_mod_tfr(:,find(phase_index==phase_idx)),2);
        tmp=abs(mean(exp(sqrt(-1).*(phase_mod_tfr(:,find(phase_index==phase_idx)))),2));
        ppc(phase_idx,:,phase_freq_idx)=tmp;
    end;
    
    %noramllzed
    tmp=squeeze(ppc(:,:,phase_freq_idx));
    tmp=bsxfun(@rdivide,tmp,sum(tmp,1));
    ppc(:,:,phase_freq_idx)=tmp;
    
    %modulaton index
    for phase_mod_idx=phase_freq_idx:length(freqVec)
        tmp=squeeze(ppc(:,phase_mod_idx,phase_freq_idx));
        %modulation index by K-L divergence
        [ppc_mi(phase_mod_idx,phase_freq_idx)]=etc_kldiv([],[],'bin_edge',phase_edges,'flag_display',0,'n_P',tmp,'n_Q',ones(size(tmp))./length(tmp),'edge_P',phase_edges,'edge_Q',phase_edges);
    end;
end;
if(flag_display)
    fprintf('\n');
end;
