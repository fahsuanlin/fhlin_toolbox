function [eeg_bcg, qrs_i_raw, eeg_bcg_pred, cccm_D, cccm_IDX, check]=eeg_bcg_dmh_reg(eeg,ecg,fs,varargin)

%defaults
flag_eeg_dyn=0;
flag_eeg_dyn_svd=0;
flag_ecg_dyn=1;
flag_auto_hp=0;
flag_display=0;
nn=[];
delay_time=0; %s
delay=round(fs.*(delay_time));
n_ecg=[]; %search the nearest -n_ecg:+n_ecg; 10 is a good number; consider how this interacts with 'nn'

flag_reg=0;

flag_pan_tompkin2=0;
flag_wavelet_ecg=0;
flag_wavelet_eeg=0;
flag_eegsvd_ecg=0;

eeg_bcg=[];
eeg_bcg_pred=[];

qrs_i_raw=[];
check=[];
cccm_D=[];
cccm_IDX=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'flag_reg'
            flag_reg=option_value;
        case 'flag_auto_hp'
            flag_auto_hp=option_value;
        case 'flag_eeg_dyn'
            flag_eeg_dyn=option_value;
        case 'flag_eeg_dyn_svd'
            flag_eeg_dyn_svd=option_value;
        case 'flag_ecg_dyn'
            flag_ecg_dyn=option_value;
        case 'nn'
            nn=option_value;
        case 'delay_time'
            delay_time=option_value;
        case 'tau'
            tau=option_value;
        case 'e'
            E=option_value;
        case 'n_ecg'
            n_ecg=option_value;
        case 'flag_pan_tompkin2'
            flag_pan_tompkin2=option_value;
        case 'flag_wavelet_ecg'
            flag_wavelet_ecg=option_value;
        case 'flag_wavelet_eeg'
            flag_wavelet_eeg=option_value;
        case 'flag_eegsvd_ecg'
            flag_eegsvd_ecg=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;


%----------------------------
% BCG start;
%----------------------------
hha=[];
hh1=[];
ha=[];
h1=[];
hb=[];
h2=[];

if(flag_auto_hp)
    ecg_fluc=filtfilt(ones(1e2,1)./1e2,1,ecg);
    ecg=ecg-ecg_fluc;
    for ch_idx=1:size(eeg,1)
        eeg_fluc(ch_idx,:)=filtfilt(ones(4e2,1)./4e2,1,eeg(ch_idx,:));
        eeg(ch_idx,:)=eeg(ch_idx,:)-eeg_fluc(ch_idx,:);
    end;
end;

if(isempty(n_ecg))
    n_ecg=ceil(nn+1/2); %search the nearest -n_ecg:+n_ecg
end;
if(n_ecg<10)
    n_ecg=10; %minimum....
end;

if(isempty(nn))
    nn=round(n_ecg/2);
    if(flag_display)
        fprintf('Use [%02d] cycles for data modeling...\n',nn);
    end;
end;

outlier_idx=isoutlier(ecg,'median','ThresholdFactor',4);
ecg_now=ecg;
if(~isempty(outlier_idx))
    if(flag_display)
        fprintf('ECG has outliers...correcting...\n');
    end;
    
    ecg_now(find(outlier_idx))=median(ecg);
end;
ecg=ecg_now;

if(flag_display) fprintf('detecting EKG peaks...\n'); end;
%[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);
%[pks,qrs_i_raw] = findpeaks(ecg,'MINPEAKDISTANCE',round(0.7*fs));
if(flag_wavelet_eeg)
    [uu,ss,vv]=svd(eeg,'econ');
    for ii=1:size(vv,2)
        [Pxx,F] = periodogram(vv(:,ii),[],[10 11 12],fs);
        p_alpha(ii)=sum(Pxx);
    end;
    [~,midx]=max(p_alpha);
    v1=vv(:,midx)';
    
    freqVec=[2:0.1:30];
    
    tfr2=inverse_waveletcoef(freqVec,v1,fs,5); %20 Hz to 120 Hz;  assuming ECG has been decimated by 10x (60 Hz in threory).
    tfr=tfr2;
    wav=fmri_scale(abs(tfr(230,:))./10,200,-200); wav=wav-mean(wav);

    [dummy,pks_tmp]=findpeaks(wav,'MinPeakDistance',30,'MinPeakProminence',10,'Annotate','extents'); %6Hz; assuming ECG has been decimated by 100x (50 Hz in threory).
    qrs_i_raw=pks_tmp;
elseif(flag_wavelet_ecg)
    v1=ecg;
    freqVec=[2:0.1:30];
    
    tfr2=inverse_waveletcoef(freqVec,ecg,fs,5); %20 Hz to 120 Hz;  assuming ECG has been decimated by 10x (60 Hz in threory).
    tfr=tfr2;
    wav=fmri_scale(abs(tfr(230,:))./10,200,-200); wav=wav-mean(wav);

    [dummy,pks_tmp]=findpeaks(wav,'MinPeakDistance',30,'MinPeakProminence',10,'Annotate','extents'); %6Hz; assuming ECG has been decimated by 100x (50 Hz in threory).
    qrs_i_raw=pks_tmp;    
elseif(flag_eegsvd_ecg)
    [uu,ss,vv]=svd(eeg,'econ');
    for ii=1:size(vv,2)
        [Pxx,F] = periodogram(vv(:,ii),[],[10 11 12],fs);
        p_alpha(ii)=sum(Pxx);
    end;
    [~,midx]=max(p_alpha)
    v1=vv(:,midx)';
    [dummy,qrs_i_raw]=findpeaks(fmri_scale(v1, -200, 200),'MinPeakDistance',20,'MinPeakProminence',20,'Annotate','extents'); %6Hz; assuming ECG has been decimated by 10x (60 Hz in threory).
else
    if(flag_pan_tompkin2)
        [pks,qrs_i_raw] =pan_tompkin2(ecg,fs);
        v1=ecg;
    else
        [pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);
        v1=ecg;
    end;
end;
qrs_i_raw=unique(qrs_i_raw,'stable');

check.qrs_i_raw=qrs_i_raw;


%qrs_i_raw=etc_onset_adjust(ecg,qrs_i_raw, 'flag_display',flag_display,'flag_signal_abs',0);
qrs_i_raw=etc_onset_adjust(v1,qrs_i_raw, 'flag_display',flag_display,'flag_signal_abs',0);


%     tt=[1:length(ecg)]./fs;
%     figure; plot(tt,ecg); hold on;
%     line(repmat(tt(qrs_i_raw),[2 1]),repmat([min(ecg-mean(ecg))/2; max(ecg-mean(ecg))/2],size(qrs_i_raw)),'LineWidth',2.5,'LineStyle','-.','Color','r');
%keyboard;


eeg_bcg_pred=zeros(size(eeg));
eeg_bcg_pred_orig=zeros(size(eeg));
non_ecg_channel=[1:size(eeg,1)];


%get ECG indices
ecg_idx=zeros(1,size(eeg,2)).*nan;
ecg_idx(qrs_i_raw)=[1:length(qrs_i_raw)];



%%%% ecg_idx (length = N_time) indicates which ECG cycle (from 1 at the beginning to N_ecg) at each time instant. 
%ecg_idx=fillmissing(ecg_idx,'nearest');
ecg_idx=fillmissing(ecg_idx,'next');
ecg_idx(find(isnan(ecg_idx)))=max(ecg_idx)+1;
check.ecg_idx=ecg_idx;

%subplot(313); plot(ecg_idx); set(gca,'xlim',[1 1000]);

%%%% ecg_onset_idx (length = N_ecg+1) includes the indices to the onset of each ECG cycle
%%%% ecg_offset_idx (length = N_ecg+1) includes the indices to the offset of each ECG cycle
%%%% ecg_phase_percent (length = N_time) indicates the phase of the cardiac cycle at each time instant

%get ECG phases
idx=find(diff(ecg_idx));
ecg_onset_idx=[1 idx+1 ]; %<---ECG onsets    
ecg_offset_idx=[idx size(eeg,2)]; %<---ECG offsets
%for ii=2:length(ecg_onset_idx)
%    ecg_phase_percent(ecg_onset_idx(ii-1):ecg_onset_idx(ii)-1)=[0:ecg_onset_idx(ii)-1-ecg_onset_idx(ii-1)]./(ecg_onset_idx(ii)-1-ecg_onset_idx(ii-1)+1).*100; %<---ECG phase in percentage
%end;
check.ecg_onset_idx=ecg_onset_idx;
check.ecg_offset_idx=ecg_offset_idx;

%qrs_phase_limit=5; %+/-5% of the QRS peak in an ECG cycle
%qrs_phase_idx=find((angle(exp(sqrt(-1).*(ecg_phase_percent)./100.*2.*pi))*100/2/pi<=qrs_phase_limit)&(angle(exp(sqrt(-1).*(ecg_phase_percent)./100.*2.*pi))*100/2/pi>=-qrs_phase_limit));

ll=ecg_offset_idx-ecg_onset_idx+1;


for ch_idx=1:length(non_ecg_channel)

    peak_idx=[0:max(ll)-1]; %<---all time points are chosen as features. length is the longest one!!

    check.peak_idx(:,ch_idx)=peak_idx(:);

    %%%% ecg_ccm_idx (size = N_ecg x N_dynamics)indicates the time indices for each cardiac cycle
    %ecg_ccm_idx=ones(max(ecg_idx),length(tmp)).*nan;
    ecg_ccm_idx=ones(max(ecg_idx),length(peak_idx)).*nan;
    %for ii=2:max(ecg_idx)-1
    for ii=1:length(ecg_onset_idx)
        ecg_ccm_idx(ii,:)=peak_idx+ecg_onset_idx(ii);
    end;

    ecg_ccm_idx(find(ecg_ccm_idx(:)>length(ecg)))=nan;
    ecg_ccm_idx(find(ecg_ccm_idx(:)<1))=nan;

    check.ecg_ccm_idx=ecg_ccm_idx;


    %search over ECG cycles
    %%%% IDX (size = N_ecg x N_neighbor) gives the time indices to the nearest EEG dynamics
    %%%% D (size = N_ecg x N_neighbor) gives the distance to the nearest EEG dynamics
    IDX=[];
    D=[];
    not_nan=find(~isnan(mean(ecg_ccm_idx,2)));
    if(flag_eeg_dyn) %EEG; dynamics
        if(~flag_eeg_dyn_svd)% EEG per-channel;
            dd=eeg(non_ecg_channel(ch_idx),:);

            for ii=1:max(ecg_idx)
                try
                    ecg_ccm_idx_now=ecg_ccm_idx;
                    ecg_ccm_idx_now=ecg_ccm_idx_now(:,1:ecg_offset_idx(ii)-ecg_onset_idx(ii)+1);
                    if(isempty(find(isnan(ecg_ccm_idx_now(ii,:)))))
                        non_nan_idx=find(~isnan(ecg_ccm_idx_now));
                        nan_idx=find(isnan(ecg_ccm_idx_now));
                        tmp=nan(size(ecg_ccm_idx_now));
                        tmp(non_nan_idx)=dd(ecg_ccm_idx_now(non_nan_idx));
                        if(size(tmp,2)>2)
                            for trial_idx=1:size(tmp,1)
                                tmp(trial_idx,:)=detrend(tmp(trial_idx,:));
                            end;
                        end;
                        [IDX(ii,:),D(ii,:)] = knnsearch(tmp,tmp(ii,:),'K',nn+1);
                    end;
                catch
                    fprintf('error in knnsearch...\n');
                    keyboard;
                end;
            end;

        else % EEG SVD;
            if( ch_idx==1)
                [uu,ss,vv]=svd(eeg,'econ');
                v1=vv(:,1)';
                dd=v1;

                for ii=1:max(ecg_idx)
                    try
                        ecg_ccm_idx_now=ecg_ccm_idx;
                        ecg_ccm_idx_now=ecg_ccm_idx_now(:,1:ecg_offset_idx(ii)-ecg_onset_idx(ii)+1);
                        if(isempty(find(isnan(ecg_ccm_idx_now(ii,:)))))
                            non_nan_idx=find(~isnan(ecg_ccm_idx_now));
                            nan_idx=find(isnan(ecg_ccm_idx_now));
                            tmp=nan(size(ecg_ccm_idx_now));
                            tmp(non_nan_idx)=dd(ecg_ccm_idx_now(non_nan_idx));
                            if(size(tmp,2)>2)
                                for trial_idx=1:size(tmp,1)
                                    tmp(trial_idx,:)=detrend(tmp(trial_idx,:));
                                end;
                            end;
                            [IDX(ii,:),D(ii,:)] = knnsearch(tmp,tmp(ii,:),'K',nn+1);
                        end;
                    catch
                        fprintf('error in knnsearch...\n');
                        keyboard;
                    end;
                end;
            end;
        end;
    else %ECG; dynamics
        if( ch_idx==1)
            dd=ecg;

            for ii=1:length(ecg_onset_idx)
                try
                    ecg_ccm_idx_now=ecg_ccm_idx;
                    ecg_ccm_idx_now=ecg_ccm_idx_now(:,1:ecg_offset_idx(ii)-ecg_onset_idx(ii)+1);
                    if(isempty(find(isnan(ecg_ccm_idx_now(ii,:)))))
                        non_nan_idx=find(~isnan(ecg_ccm_idx_now));
                        nan_idx=find(isnan(ecg_ccm_idx_now));
                        tmp=nan(size(ecg_ccm_idx_now));
                        tmp(non_nan_idx)=dd(ecg_ccm_idx_now(non_nan_idx));
                        if(size(tmp,2)>2)
                            for trial_idx=1:size(tmp,1)
                                tmp(trial_idx,:)=detrend(tmp(trial_idx,:));
                            end;
                        end;
                        [IDX(ii,:),D(ii,:)] = knnsearch(tmp,tmp(ii,:),'K',nn+1);
                    end;
                catch
                    fprintf('error in knnsearch...\n');
                    keyboard;
                end;
            end;
        end;
    end;

    eeg_ch_now=eeg(non_ecg_channel(ch_idx),:);
    check.eeg_dyn(:,:,ch_idx)=eeg_ch_now(ecg_ccm_idx(not_nan,:));

    %remove self;
    IDX(:,1)=[];
    D(:,1)=[];

    check.IDX(:,:,ch_idx)=IDX;
    check.D(:,:,ch_idx)=D;

    %%%% ccm_IDX (size = N_time x N_neighbor) gives the time indices to the nearest EEG dynamics
    %%%% ccm_D (size = N_time x N_neighbor) gives the distance to the nearest EEG dynamics

    ccm_IDX=zeros(size(eeg,2),nn).*nan;
    ccm_D=zeros(size(eeg,2),nn).*nan;

    for ii=min(not_nan):max(not_nan)
        try
            ccm_IDX(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(ecg_onset_idx(IDX(ii,:)),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1])+repmat([0:ecg_offset_idx(ii)-ecg_onset_idx(ii)]',[1,nn]);
            %ccm_IDX(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(IDX(ii,:),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1]);
            ccm_D(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(D(ii,:),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1]);

            %eeg_ch_now();

        catch ME
            fprintf('incorrect ccm_IDX for cycle [%d]!\n',ii)
        end;
    end;
    ccm_IDX(find(ccm_IDX(:)>size(eeg,2)))=nan;

    time_idx=[1:size(eeg,2)];
    time_idx(find(isnan(ccm_IDX(:,1))))=nan;

    time_idx(find(isnan(sum(ccm_IDX,2))))=nan;
    if(flag_display)
        fprintf('[%d] (%1.1f%%) time points excluded from CCM because data are out of time series range.\n',length(find(isnan(sum(ccm_IDX,2)))),length(find(isnan(sum(ccm_IDX,2))))./size(eeg,2).*100);
    end;

    check.ccm_IDX(:,:,ch_idx)=ccm_IDX;
    check.ccm_D(:,:,ch_idx)=ccm_D;

    cccm_IDX(:,:,ch_idx)=ccm_IDX;
    cccm_D(:,:,ch_idx)=ccm_D;

    if(flag_eeg_dyn) %EEG; dynamics
        if(~flag_eeg_dyn_svd)% EEG per-channel;
                IDX_all{ch_idx}=IDX;
                D_all{ch_idx}=D;
        else
            for ch_idx_now=1:length(non_ecg_channel)
                IDX_all{ch_idx_now}=IDX;
                D_all{ch_idx_now}=D;
            end;
            break;
        end;
    else
            for ch_idx_now=1:length(non_ecg_channel)
                IDX_all{ch_idx_now}=IDX;
                D_all{ch_idx_now}=D;
            end;
            break;
    end;
end;

check.dyn_all=zeros(size(eeg,2),nn,length(non_ecg_channel)).*nan;



for seg_idx=1:length(ecg_onset_idx)
    if(isnan(ecg_onset_idx(seg_idx)))
        
    else
        debug_ch=1;
        for ch_idx=1:length(non_ecg_channel)
            %get estimates by cross mapping
            try
                data_now_segment=[];
                data_now_segment_detrend=[];
                ll_now=ecg_offset_idx(seg_idx)-ecg_onset_idx(seg_idx)+1;
                for dyn_idx=1:size(IDX,2)
                    data_now_segment(dyn_idx,:)=eeg(non_ecg_channel(ch_idx),ecg_onset_idx(IDX_all{ch_idx}(seg_idx,dyn_idx)):ecg_onset_idx(IDX_all{ch_idx}(seg_idx,dyn_idx))+ll_now-1);
                    data_now_segment_detrend(dyn_idx,:)=detrend(data_now_segment(dyn_idx,:));
                end;
 
                target_now_segment=eeg(non_ecg_channel(ch_idx),ecg_onset_idx(seg_idx):ecg_offset_idx(seg_idx)).';
            
 


                target_D=cat(2,data_now_segment_detrend',[ones(length(target_now_segment),1) [0:length(target_now_segment)-1].'./length(target_now_segment)]);
                beta=inv(target_D'*target_D)*target_D'*target_now_segment;

                %eeg_bcg_pred(non_ecg_channel(ch_idx),ecg_onset_idx(seg_idx):ecg_offset_idx(seg_idx))=(target_D(:,1:end-2)*beta(1:end-2)).';
                eeg_bcg_pred(non_ecg_channel(ch_idx),ecg_onset_idx(seg_idx):ecg_offset_idx(seg_idx))=(target_D(:,1:end)*beta(1:end)).';


%                  t_idx=ecg_offset_idx(seg_idx);
%                  if((t_idx>70)&&ch_idx==1)
%                     subplot(211); 
%                     plot(eeg(non_ecg_channel(ch_idx),t_idx-70:t_idx)); hold on;
% 
%                     plot(eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx-70:t_idx)); hold off; 
%                     set(gca,'ylim',[-200 200])
% 
%                     %plot(eeg_bcg_pred_orig(non_ecg_channel(ch_idx),t_idx-50:t_idx)); hold on;
%                     subplot(212); 
% 
%                     plot(eeg(non_ecg_channel(ch_idx),t_idx-70:t_idx)-eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx-70:t_idx));
%                     set(gca,'ylim',[-50 50])
%                     drawnow;
%                     pause(0.05);
%                  end;


            catch ME
                fprintf('Error in BCG CCM prediction!\n');
                fprintf('t_idx=%d\n',t_idx);
                keyboard;
            end;
        end;
    end;
end;

eeg_bcg_pred(find(isnan(eeg_bcg_pred(:))))=0; %no change on these NaN entries.

if(~flag_reg) %subtraction to suppress BCG artifacts
    eeg_bcg=eeg-eeg_bcg_pred;
elseif(flag_reg) %regression to suppress BCG artifacts
    for ii=1:max(ecg_idx)
        time_idx=find(ecg_idx==ii);
        A=[];
        for ch_idx=1:size(eeg,1)
            y=eeg(ch_idx,time_idx);
            A(:,1)=eeg_bcg_pred(ch_idx,time_idx);
            A(:,2)=1;
            if(rank(A)==2)
                eeg_bcg(ch_idx,time_idx)=y(:)-A*inv(A'*A)*A'*y(:);
            else
                eeg_bcg(ch_idx,time_idx)=eeg(ch_idx,time_idx);
            end;
        end;
    end;
end;

if(flag_auto_hp)
    ecg=ecg+ecg_fluc;
    for ch_idx=1:size(eeg,1)
        eeg_bcg(ch_idx,:)=eeg_bcg(ch_idx,:)+eeg_fluc(ch_idx,:);
    end;
end;

if(flag_display) fprintf('BCG CCM correction done!\n'); end;



return;
        
