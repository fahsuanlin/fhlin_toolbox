function [eeg_bcg, qrs_i_raw, bcg_all, ecg_all, bad_trials]=eeg_bcg(eeg,ecg,fs,varargin)

%defaults
%BCG_tPre=0.1; %s
%BCG_tPost=0.6; %s
BCG_tPre=0.5; %s; before QRS
BCG_noise_tPre=0.2; %s; the interval [BCG_tPre-BCG_noise_tPre : BCG_tPre] is considered as baseline noise
BCG_tPost=0.5; %s; after QRS
flag_display=1;
flag_anchor_ends=0; %ensure keeping the same values at beginning and end of an interval in BCG removal
flag_badrejection=1;
bcg_nsvd=4;
bcg_post_nsvd=2;
n_ma_bcg=21;

fig_bcg=[];
flag_dyn_bcg=1;
flag_post_ssp=0;
flag_bcgmc=0;
flag_ppca=0;
flag_bcg_nsvd_auto=0;

trigger=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'bcg_nsvd'
            bcg_nsvd=option_value;
        case 'bcg_post_nsvd'
            bcg_post_nsvd=option_value;
        case 'bcg_tpre'
            BCG_tPre=option_value;
        case 'bcg_noise_tpre'
            BCG_noise_tPre=option_value;
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
        case 'flag_post_ssp'
            flag_post_ssp=option_value;
        case 'flag_bcgmc'
            flag_bcgmc=option_value;
        case 'flag_ppca'
            flag_ppca=option_value;
        case 'flag_bcg_nsvd_auto'
            flag_bcg_nsvd_auto=option_value;
        case 'trigger'
            trigger=option_value;
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
BCG_noise_tPre_sample=round(BCG_noise_tPre.*fs);

eeg_bcg=eeg;

non_ecg_channel=[1:size(eeg,1)];

if(flag_bcgmc)
    trigger_pre=round(0.05.*fs); %0.05 s before trigger
    trigger_post=round(0.2.*fs); %0.2 s after trigger
    
    for trigger_idx=1:length(trigger.time)
        eeg(:,trigger.time(trigger_idx)-trigger_pre:trigger.time(trigger_idx)+trigger_post)=nan;
    end;
end;

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
        %bcg_all{non_ecg_channel(ch_idx)}(bad_trial_idx,:)=[];
    end;
    bad_trials{non_ecg_channel(ch_idx)}=zeros(1,length(qrs_i_raw));
    bad_trials{non_ecg_channel(ch_idx)}(bad_trial_idx)=1;
end;

%remove bad trials...
bad_trials_idx_all=[];
for ch_idx=1:length(non_ecg_channel)
    if(ch_idx==1)
        bad_trials_idx_all=find(bad_trials{non_ecg_channel(ch_idx)});
    else
        bad_trials_idx_all=union(bad_trials_idx_all,find(bad_trials{non_ecg_channel(ch_idx)}));
    end;
end;
%for ch_idx=1:length(non_ecg_channel)
%    bcg_all{non_ecg_channel(ch_idx)}(bad_trials_idx_all,:)=[];
%end;

residual=zeros(length(non_ecg_channel),length(qrs_i_raw),size(bcg_all{non_ecg_channel(1)},2));
for ch_idx=1:length(non_ecg_channel)
    fprintf('#');
    
    if(~flag_dyn_bcg)
        
        if(flag_bcgmc|flag_ppca) %restore matrix
            x=bcg_all{non_ecg_channel(ch_idx)};
            x=max(x,[],2);
            [dummy,idx]=sort(x);
            idx1=round(length(x)*0.2);
            idx2=round(length(x)*0.8);
            if(idx2>=idx1+100)
                idx2=idx1+100;
            end;
            trial_sel=[idx(idx1:idx2)];
            
            x=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:);
            exclude_idx=find(sum(abs(x),2)<eps);
            if(~isempty(exclude_idx))
                trial_sel(exclude_idx)=[];
                x=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:);
            end;
            
            sz=size(x);
            IDX=find(~isnan(x(:)));
            M = opRestriction(prod(sz), IDX);
            % Sampled data
            yy = M(x(:),1);
            %x1=IST_MC(yy,M,sz);
            %bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:)=x1;
            global VERBOSE;
            VERBOSE=0;
            [uu,ss,vv,V,numiter] = SVT([sz(1) sz(2)],IDX,x(IDX),5*sqrt(prod(sz)),1.2/(length(IDX)/prod(sz)));
        else
            %if(non_ecg_channel(ch_idx)==9) keyboard; end;
            
            x=bcg_all{non_ecg_channel(ch_idx)};
            x=max(x,[],2);
            [dummy,idx]=sort(x);
            idx1=round(length(x)*0.2);
            idx2=round(length(x)*0.8);
            if(idx2>=idx1+100)
                idx2=idx1+100;
            end;
            trial_sel=[idx(idx1:idx2)];
            
            x=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:);
            exclude_idx=find(sum(abs(x),2)<eps);
            if(~isempty(exclude_idx))
                trial_sel(exclude_idx)=[];
                x=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:);
            end;
            
            [uu,ss,vv]=svd(x,'econ');
        end;
        bcg_residual=uu(:,bcg_nsvd+1:end)*ss(bcg_nsvd+1:end,bcg_nsvd+1:end)*vv(:,bcg_nsvd+1:end)';
        
        bcg_bnd_bases=zeros(size(vv,1),2);
        bcg_bnd_bases(:,1)=1; % confound
        bcg_bnd_bases(:,2)=[1:size(vv,1)]'./size(vv,1); % confound
        
        for trial_idx=1:length(qrs_i_raw)
            if(bad_trials{non_ecg_channel(ch_idx)}(trial_idx))
                eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=nan; %bad trials; BCG artifact can propagate and thus mark data as NaN.
            else
                if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
                    y=eeg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
                    
                    %                     bnd0=[y(1) y(end)];
                    %                     y=bcg_residual(trial_idx,:).';
                    %                     bnd1=[y(1) y(end)];
                    %
                    %                     if(flag_anchor_ends)
                    %                         y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                    %                     end;
                    %                     eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=y';
                    %
                    %                     residual(non_ecg_channel(ch_idx),trial_idx,:)=y(:);
                    bcg_approx=uu(:,1:bcg_nsvd)*ss(1:bcg_nsvd,1:bcg_nsvd)*vv(:,1:bcg_nsvd)';
                    bcg_residual=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:)-bcg_approx;
                    bcg_bases=vv(:,1:bcg_nsvd);
                    
                    bcg_bnd_bases=zeros(size(bcg_bases,1),2);
                    bcg_bnd_bases(:,1)=1; % confound
                    bcg_bnd_bases(:,2)=[1:size(bcg_bases,1)]'./size(bcg_bases,1); % confound
                    
                    y0=y;
                    non_nan_idx=find(~isnan(y));
                    beta=inv(bcg_bases(non_nan_idx,:)'*bcg_bases(non_nan_idx,:))*(bcg_bases(non_nan_idx,:)'*y(non_nan_idx));
                    bnd0=[y(1) y(end)];
                    y=y-bcg_bases(:,1:bcg_nsvd)*beta(1:bcg_nsvd);
                    bnd1=[y(1) y(end)];
                    
                    if(flag_anchor_ends)
                        y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                    end;
                    eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=y';
                    
                    residual(non_ecg_channel(ch_idx),trial_idx,:)=y(:);
                    bcg_artifact(non_ecg_channel(ch_idx),trial_idx,:)=y0(:)-y(:);
                    
                    
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
            fprintf('ch {%d|%d}...trial [%d|%d]...\r',ch_idx,length(non_ecg_channel),trial_idx,length(qrs_i_raw));
            if(bad_trials{non_ecg_channel(ch_idx)}(trial_idx))
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
                    
                    if(flag_bcgmc|flag_ppca) %restore matrix
                        x=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:);
                        exclude_idx=find(sum(abs(x),2)<eps);
                        if(~isempty(exclude_idx))
                            trial_sel(exclude_idx)=[];
                            x=bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:);
                        end;
                        sz=size(x);
                        IDX=find(~isnan(x(:)));
                        M = opRestriction(prod(sz), IDX);
                        % Sampled data
                        yy = M(x(:),1);
                        %x1=IST_MC(yy,M,sz);
                        %bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:)=x1;
                        global VERBOSE;
                        VERBOSE=0;
                        [uu,ss,vv,V,numiter] = SVT([sz(1) sz(2)],IDX,x(IDX),5*sqrt(prod(sz)),1.2/(length(IDX)/prod(sz)));
                    else
                        %if(non_ecg_channel(ch_idx)==9) keyboard; end;
                        [uu,ss,vv]=svd(bcg_all{non_ecg_channel(ch_idx)}(trial_sel,:),'econ');
                    end;
                    
                    %tt=cumsum(diag(ss).^2);
                    %tt=tt./tt(end);
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
                    non_nan_idx=find(~isnan(y));
                    beta=inv(bcg_bases(non_nan_idx,:)'*bcg_bases(non_nan_idx,:))*(bcg_bases(non_nan_idx,:)'*y(non_nan_idx));
                    bnd0=[y(1) y(end)];
                    y=y-bcg_bases(:,1:bcg_nsvd)*beta(1:bcg_nsvd);
                    bnd1=[y(1) y(end)];
                    
                    if(flag_anchor_ends)
                        y=y-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                    end;
                    eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=y';
                    
                    residual(non_ecg_channel(ch_idx),trial_idx,:)=y(:);
                    bcg_artifact(non_ecg_channel(ch_idx),trial_idx,:)=y0(:)-y(:);
                    
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



% for ch_idx=1:length(non_ecg_channel)
%      for trial_idx=1:length(qrs_i_raw)
%         eeg_output0(non_ecg_channel(ch_idx),trial_idx,:)=eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
%      end;
% end;
% for ch_idx=1:31
%     dd0(:,:,ch_idx)=corrcoef(squeeze(eeg_output0(ch_idx,:,:))');
% end;
eeg_bcg0=eeg_bcg;
if(flag_post_ssp)
    fprintf('@@@');
    tmp=[];
    for ch_idx=1:length(non_ecg_channel)
        d=squeeze(residual(non_ecg_channel(ch_idx),:,:));
        d(bad_trials_idx_all,:)=[];
        tmp(ch_idx,:)=d(:).';
        E(ch_idx,:)=eeg_bcg(non_ecg_channel(ch_idx),:);
    end;
    tmp0=tmp;
    D=tmp*tmp'./size(tmp,2); %data covariance matrix;
    
    %[uu,ss,vv]=svd(D);
    %[uu,ss,vv]=svd(tmp,'econ');
    for idx=1:size(residual,2)
        tmp=squeeze(residual(:,idx,:));
        p(idx)=sum(tmp(:).^2);
    end;
    [stmp,s_idx]=sort(p); %sorting power of all trials;
    idx=s_idx(round(length(p).*0.25):round(length(p).*0.75));
    %[uu,ss,vv]=svd(squeeze(mean(residual,2)),'econ');
    [uu,ss,vv]=svd(squeeze(mean(residual(:,idx,:),2)),'econ');
    
    css=cumsum(diag(ss).^2)./sum(diag(ss).^2);
    n_proj_auto=find(css>0.8);
    n_proj_auto=n_proj_auto(1); %automatically determining how many components to be truncated
    
    n_proj=n_proj_auto;
    
    ssp_bases=vv(:,1:n_proj_auto);
    ssp_bases_p=ssp_bases*inv(ssp_bases'*ssp_bases)*ssp_bases';
    for ch_idx=1:length(non_ecg_channel)
        fprintf('post SSP [%d|%d]...\r',ch_idx,length(non_ecg_channel));
        for trial_idx=1:length(qrs_i_raw)
            if(((qrs_i_raw(trial_idx)-BCG_tPre_sample)>0)&((qrs_i_raw(trial_idx)+BCG_tPost_sample)<=size(eeg,2)))
                
                tmp=eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample);
                
                tmp=tmp(:)-ssp_bases_p*tmp(:);
                eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)=tmp';
            end;
        end;
    end;
    fprintf('\n');
    
    
%     if(n_proj>0)
%         P=eye(size(tmp,1))-uu(:,1:n_proj)*uu(:,1:n_proj)';
%     else
%         P=eye(size(tmp,1));
%     end;
%     E_whitened=P*E;
%            
%     for ch_idx=1:length(non_ecg_channel)
%         eeg_bcg(non_ecg_channel(ch_idx),:)=E_whitened(ch_idx,:);
%     end;
end;


% for ch_idx=1:length(non_ecg_channel)
%      for trial_idx=1:length(qrs_i_raw)
%         eeg_output(non_ecg_channel(ch_idx),trial_idx,:)=eeg_bcg(non_ecg_channel(ch_idx),qrs_i_raw(trial_idx)-BCG_tPre_sample:qrs_i_raw(trial_idx)+BCG_tPost_sample)';
%      end;
% end;

fprintf('\n');

if(flag_display) fprintf('BCG correction done!\n'); end;

%----------------------------
% BCG end;
%----------------------------

return;
