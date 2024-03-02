function [ppi, ppi_pval]=etc_ppi(data,freqVec,timeVec)

% etc_ppi   calculate the phase-perservation index (PPI) for repeated
% measurements of a response
%
% [ppi, ppi_val]=etc_ppi(data,freqVec,timeVec,[option, option_value]);
%
% data: txn 2D array for n repeated measurement of time series of length t
% freqVec: 1D frequency vector (in Hz)
% timeVec: 1D time vector (in s)
% 
% data_baseline: txm 2D array for n repeated measurement of "baseline" time
% series of length t, m>=n; This is for statistical inference of PPI.
% n_perm: number of permutation (e.g., 100).
%
% Ref: https://www.pnas.org/doi/full/10.1073/pnas.0505785103
%
% fhlin@sep 29 2023
%

ppi=[];
ppi_pval=[];

n_perm=[];
data_baseline=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'data_baseline'
            data_baseline=option_value;
        case 'n_perm'
            n_perm=option_value;
        otherwise
            fprintf('unknown optino [%s]!\nerror!\n',option);
            return;
    end;
end;



for trial_idx=1:size(data,2)
    tfr_phase=angle(inverse_waveletcoef(freqVec,double(data(:,trial_idx))',1e3/mean(diff(timeVec)),5));


    for freq_idx=1:length(freqVec)
        ppi_ref_time=-1e3/freqVec(freq_idx).*5;

        [dummy,ref_idx]=min(abs(timeVec-ppi_ref_time)); %zero as the reference time point
        tfr_phase_ref(freq_idx,:)=repmat(tfr_phase(freq_idx,ref_idx),[1,length(tfr_phase)]);
    end;
    ppi(:,:,trial_idx)=exp(sqrt(-1).*(tfr_phase-tfr_phase_ref));
end;
ppi=abs(mean(ppi,3));

ppi_pval=[];
if(~isempty(data_baseline))
    if(~isempty(n_perm))
        if(n_perm>1)
            for perm_idx=1:n_perm
                fprintf('.');
                perm_trial_idx=randperm(size(data_baseline,2));
                perm_trial_idx=perm_trial_idx(1:size(data_baseline,2));

                for trial_idx=1:size(data_baseline,2)
                    tfr_phase=angle(inverse_waveletcoef(freqVec,double(data_baseline(:,perm_trial_idx(trial_idx)))',1e3/mean(diff(timeVec)),5));


                    for freq_idx=1:length(freqVec)
                        ppi_ref_time=-1e3/freqVec(freq_idx).*2;

                        [dummy,ref_idx]=min(abs(timeVec-ppi_ref_time)); %zero as the reference time point
                        tfr_phase_ref(freq_idx,:)=repmat(tfr_phase(freq_idx,ref_idx),[1,length(tfr_phase)]);
                    end;
                    ppi_perm_tmp(:,:,trial_idx)=exp(sqrt(-1).*(tfr_phase-tfr_phase_ref));
                end;
                ppi_perm(:,:,perm_idx)=abs(mean(ppi_perm_tmp,3));
            end;
            fprintf('\n');


            ppi_pval=sum((ppi_perm<repmat(ppi,[1 1 n_perm])),3)./n_perm;

        end;
    end;
end;
