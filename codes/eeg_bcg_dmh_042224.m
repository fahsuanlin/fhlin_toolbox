function [eeg_bcg, qrs_i_raw, eeg_bcg_pred, cccm_D, cccm_IDX, check]=eeg_bcg_dmh_042224(eeg,ecg,fs,varargin)

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

%get reference time course
[uu,ss,vv]=svd(eeg,'econ');
ref=vv(:,1)';


%     tt=[1:length(ecg)]./fs;
%     figure; plot(tt,ecg); hold on;
%     line(repmat(tt(qrs_i_raw),[2 1]),repmat([min(ecg-mean(ecg))/2; max(ecg-mean(ecg))/2],size(qrs_i_raw)),'LineWidth',2.5,'LineStyle','-.','Color','r');
%keyboard;


eeg_bcg_pred=zeros(size(eeg));
eeg_bcg_pred_orig=zeros(size(eeg));
non_ecg_channel=[1:size(eeg,1)];



%for ch_idx=1:length(non_ecg_channel)

%     peak_idx=[0:max(ll)-1]; %<---all time points are chosen as features. length is the longest one!!
% 
%     check.peak_idx(:,ch_idx)=peak_idx(:);
% 
%     %%%% ecg_ccm_idx (size = N_ecg x N_dynamics)indicates the time indices for each cardiac cycle
%     %ecg_ccm_idx=ones(max(ecg_idx),length(tmp)).*nan;
%     ecg_ccm_idx=ones(max(ecg_idx),length(peak_idx)).*nan;
%     %for ii=2:max(ecg_idx)-1
%     for ii=1:length(ecg_onset_idx)
%         ecg_ccm_idx(ii,:)=peak_idx+ecg_onset_idx(ii);
%     end;
% 
%     ecg_ccm_idx(find(ecg_ccm_idx(:)>length(ecg)))=nan;
%     ecg_ccm_idx(find(ecg_ccm_idx(:)<1))=nan;
% 
%     check.ecg_ccm_idx=ecg_ccm_idx;


    %search over ECG cycles
    %%%% IDX (size = N_ecg x N_neighbor) gives the time indices to the nearest EEG dynamics
    %%%% D (size = N_ecg x N_neighbor) gives the distance to the nearest EEG dynamics
    IDX=[];
    D=[];
    %not_nan=find(~isnan(mean(ecg_ccm_idx,2)));
    if(flag_eeg_dyn) %EEG; dynamics
        if(~flag_eeg_dyn_svd)% EEG per-channel;
%             dd=eeg(non_ecg_channel(ch_idx),:);
% 
%             for ii=1:max(ecg_idx)
%                 try
%                     ecg_ccm_idx_now=ecg_ccm_idx;
%                     ecg_ccm_idx_now=ecg_ccm_idx_now(:,1:ecg_offset_idx(ii)-ecg_onset_idx(ii)+1);
%                     if(isempty(find(isnan(ecg_ccm_idx_now(ii,:)))))
%                         non_nan_idx=find(~isnan(ecg_ccm_idx_now));
%                         nan_idx=find(isnan(ecg_ccm_idx_now));
%                         tmp=nan(size(ecg_ccm_idx_now));
%                         tmp(non_nan_idx)=dd(ecg_ccm_idx_now(non_nan_idx));
%                         if(size(tmp,2)>2)
%                             for trial_idx=1:size(tmp,1)
%                                 tmp(trial_idx,:)=detrend(tmp(trial_idx,:));
%                             end;
%                         end;
%                         [IDX(ii,:),D(ii,:)] = knnsearch(tmp,tmp(ii,:),'K',nn+1);
%                     end;
%                 catch
%                     fprintf('error in knnsearch...\n');
%                     keyboard;
%                 end;
%             end;

        else % EEG SVD;
%            if( ch_idx==1)
                [uu,ss,vv]=svd(eeg,'econ');
                tmp=[];
                for svd_idx=1:3
                    v1=vv(:,svd_idx)';
                    dd=v1.*ss(svd_idx,svd_idx);


                    %dd=ecg;
                    %1-s for dynamics
                    for delay_idx=1:fs
                        tmp0(delay_idx,:)=etc_circshift(dd,-delay_idx+1);
                    end;

                    tmp=cat(1,tmp,tmp0);
                end;

                tmp=tmp';

                for t_idx=1:size(tmp,1)
                    [IDX(t_idx,:),D(t_idx,:)] = knnsearch(tmp,tmp(t_idx,:),'K',nn+1);
                end;

%                 for ii=1:max(ecg_idx)
%                     try
%                         ecg_ccm_idx_now=ecg_ccm_idx;
%                         ecg_ccm_idx_now=ecg_ccm_idx_now(:,1:ecg_offset_idx(ii)-ecg_onset_idx(ii)+1);
%                         if(isempty(find(isnan(ecg_ccm_idx_now(ii,:)))))
%                             non_nan_idx=find(~isnan(ecg_ccm_idx_now));
%                             nan_idx=find(isnan(ecg_ccm_idx_now));
%                             tmp=nan(size(ecg_ccm_idx_now));
%                             tmp(non_nan_idx)=dd(ecg_ccm_idx_now(non_nan_idx));
%                             if(size(tmp,2)>2)
%                                 for trial_idx=1:size(tmp,1)
%                                     tmp(trial_idx,:)=detrend(tmp(trial_idx,:));
%                                 end;
%                             end;
%                             [IDX(ii,:),D(ii,:)] = knnsearch(tmp,tmp(ii,:),'K',nn+1);
%                         end;
%                     catch
%                         fprintf('error in knnsearch...\n');
%                         keyboard;
%                     end;
%                 end;
%            end;
        end;
    else %ECG; dynamics
%         if( ch_idx==1)
%             dd=ecg;
% 
%             for ii=1:length(ecg_onset_idx)
%                 try
%                     ecg_ccm_idx_now=ecg_ccm_idx;
%                     ecg_ccm_idx_now=ecg_ccm_idx_now(:,1:ecg_offset_idx(ii)-ecg_onset_idx(ii)+1);
%                     if(isempty(find(isnan(ecg_ccm_idx_now(ii,:)))))
%                         non_nan_idx=find(~isnan(ecg_ccm_idx_now));
%                         nan_idx=find(isnan(ecg_ccm_idx_now));
%                         tmp=nan(size(ecg_ccm_idx_now));
%                         tmp(non_nan_idx)=dd(ecg_ccm_idx_now(non_nan_idx));
%                         if(size(tmp,2)>2)
%                             for trial_idx=1:size(tmp,1)
%                                 tmp(trial_idx,:)=detrend(tmp(trial_idx,:));
%                             end;
%                         end;
%                         [IDX(ii,:),D(ii,:)] = knnsearch(tmp,tmp(ii,:),'K',nn+1);
%                     end;
%                 catch
%                     fprintf('error in knnsearch...\n');
%                     keyboard;
%                 end;
%             end;
%         end;
    end;

%     eeg_ch_now=eeg(non_ecg_channel(ch_idx),:);
%     check.eeg_dyn(:,:,ch_idx)=eeg_ch_now(ecg_ccm_idx(not_nan,:));

    %remove self;
    IDX(:,1)=[];
    D(:,1)=[];

%     check.IDX(:,:,ch_idx)=IDX;
%     check.D(:,:,ch_idx)=D;
% 
    %%%% ccm_IDX (size = N_time x N_neighbor) gives the time indices to the nearest EEG dynamics
    %%%% ccm_D (size = N_time x N_neighbor) gives the distance to the nearest EEG dynamics

%    ccm_IDX=zeros(size(eeg,2),nn).*nan;
%    ccm_D=zeros(size(eeg,2),nn).*nan;

%     for ii=min(not_nan):max(not_nan)
%         try
%             ccm_IDX(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(ecg_onset_idx(IDX(ii,:)),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1])+repmat([0:ecg_offset_idx(ii)-ecg_onset_idx(ii)]',[1,nn]);
%             %ccm_IDX(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(IDX(ii,:),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1]);
%             ccm_D(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(D(ii,:),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1]);
% 
%             %eeg_ch_now();
% 
%         catch ME
%             fprintf('incorrect ccm_IDX for cycle [%d]!\n',ii)
%         end;
%     end;
%     ccm_IDX(find(ccm_IDX(:)>size(eeg,2)))=nan;
% 
%     time_idx=[1:size(eeg,2)];
%     time_idx(find(isnan(ccm_IDX(:,1))))=nan;
% 
%     time_idx(find(isnan(sum(ccm_IDX,2))))=nan;
%     if(flag_display)
%         fprintf('[%d] (%1.1f%%) time points excluded from CCM because data are out of time series range.\n',length(find(isnan(sum(ccm_IDX,2)))),length(find(isnan(sum(ccm_IDX,2))))./size(eeg,2).*100);
%     end;
% 
%     check.ccm_IDX(:,:,ch_idx)=ccm_IDX;
%     check.ccm_D(:,:,ch_idx)=ccm_D;
% 
%     cccm_IDX(:,:,ch_idx)=ccm_IDX;
%     cccm_D(:,:,ch_idx)=ccm_D;
% 
%     if(flag_eeg_dyn) %EEG; dynamics
%         if(~flag_eeg_dyn_svd)% EEG per-channel;
%                 IDX_all{ch_idx}=IDX;
%                 D_all{ch_idx}=D;
%         else
%             for ch_idx_now=1:length(non_ecg_channel)
%                 IDX_all{ch_idx_now}=IDX;
%                 D_all{ch_idx_now}=D;
%             end;
%             break;
%         end;
%     else
%             for ch_idx_now=1:length(non_ecg_channel)
%                 IDX_all{ch_idx_now}=IDX;
%                 D_all{ch_idx_now}=D;
%             end;
%             break;
%     end;
%end;

% check.dyn_all=zeros(size(eeg,2),nn,length(non_ecg_channel)).*nan;



% for seg_idx=1:length(ecg_onset_idx)
%     if(isnan(ecg_onset_idx(seg_idx)))
%         
%     else
%         debug_ch=1;
        for ch_idx=1:length(non_ecg_channel)
            %get estimates by cross mapping
            try

                for t_idx=1:size(eeg,2)
                    dyn=eeg(non_ecg_channel(ch_idx),IDX(t_idx,:));
                    U=exp(-D(t_idx,:)./D(t_idx,:));
                    W=U./sum(U);

                    eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=dyn*W';
                end;


            if(1)
                
                figure(1); clf;
                subplot(221); hold on;
                h=plot(ecg);
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(ecg);
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                
                subplot(222); hold on;
                plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                
                subplot(223); hold on;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);
                
                subplot(224); hold on;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);
                
                ha=[];
                h1=[];
                hb=[];
                h2=[];
                %end;
                
                
                
                figure(1);
                subplot(221);
                xx=cat(1,t_idx,IDX(t_idx,:)');
                if(~isempty(ha)) delete(ha); end;
                if(~isempty(h1)) delete(h1); end;
                
                xlabel('time (sample)');
                ylabel('EKG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;
                ha=plot(xx,ecg(xx),'r.'); set(ha,'markersize',40);
                h1=plot(xx(1),ecg(xx(1)),'.'); set(h1,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
                
                subplot(222);
                if(~isempty(hb)) delete(hb); end;
                if(~isempty(h2)) delete(h2); end;
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;
                hb=plot(xx,eeg(non_ecg_channel(ch_idx),xx),'r.'); set(hb,'markersize',40);
                h2=plot(xx(1),eeg(non_ecg_channel(ch_idx),xx(1)),'.'); set(h2,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
                
                subplot(223)
                h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                set(h,'linewidth',2);
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                ylim=get(gca,'ylim');
                etc_plotstyle;
                
                subplot(224)
                h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                set(h,'linewidth',2);
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[t_idx-500 t_idx+500],'ylim',ylim);
                etc_plotstyle;
                
                set(gcf,'pos',[100        1000        2100           900]);
                
%                 figure(2); clf; hold on;
%                 dd=ecg(ccm_IDX(2:end-1,:));
%                 plot(dd(:,1),dd(:,2),'.')
%                 
%                 if(~isempty(hha)) delete(hha); end;
%                 if(~isempty(hh1)) delete(hh1); end;
%                 
%                 hh1=plot(ecg(ecg_ccm_idx(ecg_idx(t_idx),1)),ecg(ecg_ccm_idx(ecg_idx(t_idx),2)),'o');
%                 set(hh1,'linewidth',2,'color',[ 0.4660    0.6740    0.1880]);
%                 try
%                     hha=plot(ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),1)),ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),2)),'ro');
%                 catch ME
%                     keyboard;
%                 end;
%                 set(hha,'linewidth',2);
%                 xlabel('EKG(t) (a.u.)');
%                 ylabel('EKG(t+\tau) (a.u.)');
%                 etc_plotstyle;
                
                
                %if(mod(t_idx,2000)==0) keyboard; end;
                
                
                %pause(0.01);
            end;



            catch ME
                fprintf('Error in BCG CCM prediction!\n');
                fprintf('t_idx=%d\n',t_idx);
                keyboard;
            end;
        end;
%     end;
% end;

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
        
