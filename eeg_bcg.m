function [eeg_bcg, qrs_i_raw, bcg_all, ecg_all]=eeg_bcg(eeg,ecg,fs,varargin)

%defaults
BCG_tPre=0.1; %s
BCG_tPost=0.6; %s
flag_display=1;
nsvd_bcg=3;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'nsvd_bcg'
            nsvd_bcg=option_value;
        case 'bcg_tpre'
            BCG_tPre=option_value;
        case 'bcg_tpost'
            BCG_tPost=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;


%----------------------------
% BCG start;
%----------------------------
if(flag_display) fprintf('detecting EKG peaks...\n'); end;
[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);


BCG_tPre_sample=round(BCG_tPre.*fs);
BCG_tPost_sample=round(BCG_tPost.*fs);

eeg_bcg=eeg;

non_ecg_channel=[1:size(eeg,1)];
for ch_idx=1:length(non_ecg_channel)
    if(flag_display) fprintf('*'); end;
    
    %generating BCG template
    bcg_all{non_ecg_channel(ch_idx)}=[];
    for trial_idx=1:length(qrs_i_raw)
        if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
            bcg_all{non_ecg_channel(ch_idx)}=cat(1,bcg_all{non_ecg_channel(ch_idx)},eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample));
            if(ch_idx==1)
                if(~exist('ecg_all'))     
                    ecg_all=[]; 
                end;
                ecg_all=cat(1,ecg_all,ecg(qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample));
            end;
        end;
    end;
    [uu,ss,vv]=svd(bcg_all{non_ecg_channel(ch_idx)});
    
    bcg_approx=uu(:,1:nsvd_bcg)*ss(1:nsvd_bcg,1:nsvd_bcg)*vv(:,1:nsvd_bcg)';
    bcg_residual=bcg_all{non_ecg_channel(ch_idx)}-bcg_approx;
    
    bcg_bases=vv(:,1:nsvd_bcg);
    %bcg_bases=mean(bcg_all,1)';
    
    bcg_bases(:,end+1)=1; % confound
    bcg_bases(:,end+1)=[1:size(bcg_bases,1)]'./size(bcg_bases,1); % confound
    
    bcg_proj_prep=inv(bcg_bases'*bcg_bases)*bcg_bases';
    
    
    if(flag_display) fprintf('#'); end;
    %ii=1;
    for trial_idx=1:length(qrs_i_raw)
        
        if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
            y=eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
            
            beta=bcg_proj_prep*y;
            y=y-bcg_bases(:,1:nsvd_bcg)*beta(1:nsvd_bcg);
            eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=y';
            
            
            %eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=bcg_residual(ii,:);
            %bcg_correct_idx(trial_idx)=ii;
            %ii=ii+1;
        end;
    end;
end;

if(flag_display) fprintf('\nBCG correction done!\n'); end;

%----------------------------
% BCG end;
%----------------------------

return;
