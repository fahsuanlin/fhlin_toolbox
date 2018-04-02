function [eeg_bcg, qrs_i_raw, bcg_all, ecg_all, bad_trials]=eeg_bcg(eeg,ecg,fs,varargin)

%defaults
%BCG_tPre=0.1; %s
%BCG_tPost=0.6; %s
BCG_tPre=0.5; %s
BCG_tPost=0.5; %s
flag_display=1;
flag_anchor_ends=0; %ensure keeping the same values at beginning and end of an interval in BCG removal
flag_badrejection=1;
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
        case 'flag_anchor_ends'
            flag_anchor_ends=option_value;
        case 'flag_badrejection'
            flag_badrejection=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;

bad_trials=[];

%----------------------------
% BCG start;
%----------------------------
if(flag_display) fprintf('detecting EKG peaks...\n'); end;
%[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);
%[pks,qrs_i_raw] = findpeaks(ecg,'MINPEAKDISTANCE',round(0.7*fs));
[pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);

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
        if(trial_idx==1)
            tmp=[qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample];
            ecg_all=zeros(length(qrs_i_raw),length(tmp));
            
            bcg_all{non_ecg_channel(ch_idx)}=zeros(length(qrs_i_raw),length(tmp));
        end;
        
        if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
            %bcg_all{non_ecg_channel(ch_idx)}=cat(1,bcg_all{non_ecg_channel(ch_idx)},eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample));
            bcg_all{non_ecg_channel(ch_idx)}(trial_idx,:)=eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample);
            %if(ch_idx==1)
            %    if(~exist('ecg_all'))
            %        ecg_all=[];
            %    end;
            %    ecg_all=cat(1,ecg_all,ecg(qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample));
            %end;
            ecg_all(trial_idx,:)=ecg(qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample);
        end;
    end;
    
    %     for trial_idx=1:size(bcg_all{non_ecg_channel(ch_idx)},1)
    %              bcg_all{non_ecg_channel(ch_idx)}(trial_idx,:)=sgolayfilt(bcg_all{non_ecg_channel(ch_idx)}(trial_idx,:),6,2*round(fs*0.03)+1); %smoothing out residual GA in ECG
    %     end;
    
    %if(flag_display) fprintf('#'); end;
    bad_trial_idx=[];
    if(flag_badrejection)
        fprintf('^');
        for trial_idx=1:length(qrs_i_raw)
            m(trial_idx)=max(abs(bcg_all{non_ecg_channel(ch_idx)}(trial_idx,:)),[],2);
        end;
        bad_trial_idx=find(m>200); %threshold for rejecting bad trials: 200 muV
        if(length(bad_trial_idx)/length(qrs_i_raw)<=0.02)
            %less than 10% bad trial defined by max voltage = 200 muV
        else
            if(flag_display) fprintf('too many trials with max voltage > 200 muV [%d]|[%d]=[%1.1f%%] ...',length(bad_trial_idx), length(qrs_i_raw), length(bad_trial_idx)/length(qrs_i_raw).*100); end;
            if(flag_display) fprintf('selecting only the most extreme 10% trials ...'); end;
            [dummy, bad_trial_idx]=sort(m);
            bad_trial_idx=bad_trial_idx(end-round(length(qrs_i_raw)/50)+1:end);
        end;
        if(flag_display) fprintf('[%d] cardiac events out of [%d] rejected in BCG correction...',length(bad_trial_idx), length(qrs_i_raw)); end;
        bcg_all{non_ecg_channel(ch_idx)}(bad_trial_idx,:)=[];
    end;
    bad_trials=zeros(1,length(qrs_i_raw));
    bad_trials(bad_trial_idx)=1;
    
    fprintf('#');
    
    if(~flag_dyn_bcg)
        [uu,ss,vv]=svd(bcg_all{non_ecg_channel(ch_idx)}(:,:),'econ');
        bcg_residual=uu(:,bcg_nsvd+1:end)*ss(bcg_nsvd+1:end,bcg_nsvd+1:end)*vv(:,bcg_nsvd+1:end)';
        
        bcg_bnd_bases=zeros(size(vv,1),2);
        bcg_bnd_bases(:,1)=1; % confound
        bcg_bnd_bases(:,2)=[1:size(vv,1)]'./size(vv,1); % confound
        
        for trial_idx=1:length(qrs_i_raw)
            if(bad_trials(trial_idx))
                eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=nan; %bad trials; BCG artifact can propagate and thus mark data as NaN.
            else
                if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
                    y=eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
                    
                    bnd0=[y(1) y(end)];
                    y=bcg_residual(trial_idx,:).';
                    bnd1=[y(1) y(end)];
                    
                    if(flag_anchor_ends)
                        y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                    end;
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
    else
        for trial_idx=1:length(qrs_i_raw)
            if(bad_trials(trial_idx))
                eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=nan; %bad trials; BCG artifact can propagate and thus mark data as NaN.
            else
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
                    
                    if(flag_anchor_ends)
                        y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                    end;
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
end;
fprintf('\n');
if(flag_display) fprintf('BCG correction done!\n'); end;

%----------------------------
% BCG end;
%----------------------------

return;
