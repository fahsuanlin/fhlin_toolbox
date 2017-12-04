function [eeg_bcg, qrs_i_raw, bcg_all, ecg_all]=eeg_bcg(eeg,ecg,fs,varargin)

%defaults
%BCG_tPre=0.1; %s
%BCG_tPost=0.6; %s
BCG_tPre=0.5; %s
BCG_tPost=0.5; %s
flag_display=1;
bcg_nsvd=4;
n_ma_bcg=21;

fig_bcg=[];
flag_dyn_bcg=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'bcg_nsvd'
            bcg_nsvd=option_value;
        case 'bcg_tpre'
            BCG_tPre=option_value;
        case 'bcg_tpost'
            BCG_tPost=option_value;
        case 'n_ma_bcg'
            n_ma_bcg=option_value;
        case 'flag_dyn_bcg'
            flag_dyn_bcg=option_value;
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
%[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);
%[pks,qrs_i_raw] = findpeaks(ecg,'MINPEAKDISTANCE',round(0.7*fs));
[pks,qrs_i_raw] =etc_pan_tompkin(ecg,fs,1,'flag_fhlin',1);

BCG_tPre_sample=round(BCG_tPre.*fs);
BCG_tPost_sample=round(BCG_tPost.*fs);

eeg_bcg=eeg;

non_ecg_channel=[1:size(eeg,1)];
for ch_idx=1:length(non_ecg_channel)
    %if(flag_display) fprintf('*'); end;
    fprintf('*');
    
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
    
    %     for trial_idx=1:size(bcg_all{non_ecg_channel(ch_idx)},1)
    %              bcg_all{non_ecg_channel(ch_idx)}(trial_idx,:)=sgolayfilt(bcg_all{non_ecg_channel(ch_idx)}(trial_idx,:),6,2*round(fs*0.03)+1); %smoothing out residual GA in ECG
    %     end;
    
    %if(flag_display) fprintf('#'); end;
    fprintf('#');
    
    %ii=1;
    if(~flag_dyn_bcg)
        [uu,ss,vv]=svd(bcg_all{non_ecg_channel(ch_idx)}(:,:),'econ');
        bcg_residual=uu(:,bcg_nsvd+1:end)*ss(bcg_nsvd+1:end,bcg_nsvd+1:end)*vv(:,bcg_nsvd+1:end)';
        
        bcg_bnd_bases=zeros(size(vv,1),2);
        bcg_bnd_bases(:,1)=1; % confound
        bcg_bnd_bases(:,2)=[1:size(vv,1)]'./size(vv,1); % confound
        
        for trial_idx=1:length(qrs_i_raw)
            if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
                y=eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
                
                bnd0=[y(1) y(end)];
                y=bcg_residual(trial_idx,:).';
                bnd1=[y(1) y(end)];
                
                y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=y';
                
                if(flag_display)
                    if(isempty(fig_bcg))
                        fig_bcg=figure;
                    else
                        figure(fig_bcg);
                    end;
                    subplot(311);
                    h=plot(y0); set(gca,'ylim',[-100 100]); hold on; title(sprintf('EEG before BCG [%03d|%03d]',trial_idx,length(qrs_i_raw)));
                    h=plot(y); set(h,'color','r'); set(gca,'ylim',[-100 100]); hold off;
                    subplot(312);
                    plot(bcg_bases(:,1:bcg_nsvd)); title(sprintf('BCG template components nsvd=[%02d]::%2.2f%%',bcg_nsvd,tt(bcg_nsvd).*100));
                    %subplot(312);
                    %plot(y); set(gca,'ylim',[-100 100]); title(sprintf('EEG after AAS [%03d|%03d]',trial_idx,length(qrs_i_raw)));
                    subplot(313);
                    plot(ecg(qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)); hold on; set(gca,'ylim',[-1000 1000]); title('ECG');
                    h=line([BCG_tPre_sample+1 BCG_tPre_sample],[-1000 1000]); set(h,'color','r'); hold off;
                    pause(0.01); drawnow;
                end;
            end;
        end;
        
    else
        
        for trial_idx=1:length(qrs_i_raw)
            if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
                y=eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
                
                if(size(bcg_all{non_ecg_channel(ch_idx)},1)<=n_ma_bcg)
                    trial_sel=[1:n_ma_bcg];
                else
                    if(trial_idx<=round((n_ma_bcg-1)/2))
                        trial_sel=[1:n_ma_bcg];
                    elseif(trial_idx>=size(bcg_all{non_ecg_channel(ch_idx)},1)-round((n_ma_bcg-1)/2))
                        trial_sel=[size(bcg_all{non_ecg_channel(ch_idx)},1)-n_ma_bcg+1:size(bcg_all{non_ecg_channel(ch_idx)},1)];
                    else
                        trial_sel=[trial_idx-round((n_ma_bcg-1)/2):trial_idx+round((n_ma_bcg-1)/2)];
                    end;
                end;
                [uu,ss,vv]=svd(bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:),'econ');
                %            tt=cumsum(diag(ss).^2);
                %            tt=tt./tt(end);
                %             tmp=find(tt>0.8);
                %             if(isempty(bcg_nsvd))
                %                 bcg_nsvd=tmp(1);
                %                 if(flag_display)
                %                     fprintf('automatic choice of n_svd: [%d] (for covering the first 80%% of variance)...',bcg_nsvd);
                %                 end;
                %             end;
                
                bcg_approx=uu(:,1:bcg_nsvd)*ss(1:bcg_nsvd,1:bcg_nsvd)*vv(:,1:bcg_nsvd)';
                bcg_residual=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:)-bcg_approx;
                
                bcg_bases=vv(:,1:bcg_nsvd);
                
                bcg_bnd_bases=zeros(size(bcg_bases,1),2);
                bcg_bnd_bases(:,1)=1; % confound
                bcg_bnd_bases(:,2)=[1:size(bcg_bases,1)]'./size(bcg_bases,1); % confound
                
                y0=y;
                beta=inv(bcg_bases'*bcg_bases)*(bcg_bases'*y);
                bnd0=[y(1) y(end)];
                y=y-bcg_bases(:,1:bcg_nsvd)*beta(1:bcg_nsvd);
                bnd1=[y(1) y(end)];
                
                y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=y';
                
                
                if(flag_display)
                    if(isempty(fig_bcg))
                        fig_bcg=figure;
                    else
                        figure(fig_bcg);
                    end;
                    subplot(311);
                    h=plot(y0); set(gca,'ylim',[-100 100]); hold on; title(sprintf('EEG before BCG [%03d|%03d]',trial_idx,length(qrs_i_raw)));
                    h=plot(y); set(h,'color','r'); set(gca,'ylim',[-100 100]); hold off;
                    subplot(312);
                    plot(bcg_bases(:,1:bcg_nsvd)); title(sprintf('BCG template components nsvd=[%02d]::%2.2f%%',bcg_nsvd,tt(bcg_nsvd).*100));
                    %subplot(312);
                    %plot(y); set(gca,'ylim',[-100 100]); title(sprintf('EEG after AAS [%03d|%03d]',trial_idx,length(qrs_i_raw)));
                    subplot(313);
                    plot(ecg(qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)); hold on; set(gca,'ylim',[-1000 1000]); title('ECG');
                    h=line([BCG_tPre_sample+1 BCG_tPre_sample],[-1000 1000]); set(h,'color','r'); hold off;
                    pause(0.01); drawnow;
                end;
            end;
        end;
    end;
end;

fprintf('\n');
if(flag_display) fprintf('BCG correction done!\n'); end;

%----------------------------
% BCG end;
%----------------------------

return;
