function [eeg_aas, ga_template, shift]=eeg_ga(eeg,eeg_trigger,TR,fs,varargin)

%defaults
flag_display=1;

flag_ma_aas=0;
n_ma_aas=7; %# of movign GA template trials


flag_aas_svd=1; 
aas_svd_threshold=0.95;

flag_anchor_bnd=1;

flag_ga_obs=0;
n_ga_obs=4; %# of GA OBS basis

ecg=[];

fig_ga=[];

t_pre=0;
t_post=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'flag_ma_aas'
            flag_ma_aas=option_value;
        case 'n_ma_aas'
            n_ma_aas=option_value;
        case 'flag_aas_svd'
            flag_aas_svd=option_value;
        case 'aas_svd_threshold'
            aas_svd_threshold=option_value;
        case 'flag_anchor_bnd'
            flag_anchor_bnd=option_value;
        case 'flag_ga_obs'
            flag_ga_obs=option_value;
        case 'n_ga_obs'
            n_ga_obs=option_value; %# of GA OBS basis
        case 'ecg'
            ecg=option_value;
        case 't_pre'
            t_pre=option_value;
        case 't_post'
            t_post=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;

% if(~isempty(ecg))
%     [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,0,'flag_fhlin',1);
%     qrs=zeros(1,size(eeg,2));
%     qrs(qrs_i_raw)=1000;
% else
%     qrs_amp_raw=[];
%     qrs_i_raw=[];
%     delay=[];
%     qrs=[];
% end;

%----------------------------
% AAS start;
%----------------------------

trigger=find(eeg_trigger);

if(~isempty(TR))
    n_samp=round(fs*TR);
else
    n_samp=[];
end;

t_pre_n=round(t_pre.*fs);
t_post_n=round(t_post.*fs);

%epoching; only valid for data with MRI triggers
if(sum(abs(eeg_trigger))>0)
    epoch=[];
    count=1;
    for tr_idx=1:length(trigger)
        if((trigger(tr_idx)-t_pre_n>0)&&(trigger(tr_idx)+n_samp-1+t_post_n<=length(eeg)))
            if(~isempty(n_samp))
                if(trigger(tr_idx)+n_samp-1<=size(eeg,2))
                    epoch(:,:,count)=eeg(:,trigger(tr_idx)-t_pre_n:trigger(tr_idx)+n_samp-1+t_post_n);
                    epoch_onset(count)=trigger(tr_idx)-t_pre_n;
                    epoch_offset(count)=trigger(tr_idx)+n_samp-1+t_post_n;
                    count=count+1;
                end;
            end;
        end;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % correction with interpolation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %estimating shift
    eeg_sum=squeeze(sum(eeg,1));
    epoch_sum=zeros(n_samp,length(trigger));
    for tr_idx=1:length(trigger)
        if(~isempty(n_samp))
            if(trigger(tr_idx)+n_samp-1<=length(eeg_sum))
                epoch_sum(:,tr_idx)=eeg_sum(trigger(tr_idx):trigger(tr_idx)+n_samp-1);
            end;
        end;
    end;
    
    
    %create AAS template
    %ref_idx=1;
    %ref=epoch_sum(:,ref_idx);
    
    epoch_sum_shift=epoch_sum;
    epoch_shift=epoch;
    
    %if(flag_display) fprintf('GA: aligning trials...'); end;
    for tr_idx=1:size(epoch,3)
        %ss=[-5:1:5];
        %%ss=[-1:0.5:1];
        %dss=1;
        
        if(flag_ma_aas) %dynamic change of reference trials
            
            if(size(epoch,3)<=n_ma_aas)
                trial_sel=[1:size(epoch,3)];
            else
                if(tr_idx<=round((n_ma_aas-1)/2))
                    trial_sel=[1:n_ma_aas];
                elseif(tr_idx>=size(epoch,3)-round((n_ma_aas-1)/2))
                    trial_sel=[size(epoch,3)-(n_ma_aas-1):size(epoch,3)];
                else
                    trial_sel=[tr_idx-round((n_ma_aas-1)/2):tr_idx+round((n_ma_aas-1)/2)];
                end;
            end;
            
        else %all trials
            trial_select=[1,size(epoch_sum,2)];
        end;
        
        
        ref=mean(epoch_sum(:,trial_sel),2);
        
        ss=[-2:0.2:2];
        dss=0.2;
        %if(flag_display) fprintf('*'); end;
        %fprintf('*');
        if(flag_display)
            if(mod(tr_idx,100)==0)
                fprintf('\t\taligning trials...[%d|%d]::%1.1f%%\r',tr_idx,size(epoch,3),tr_idx./size(epoch,3).*100);
            end;
        end;
        
        for repeat_idx=1:4
            D=[];
            for ss_idx=1:length(ss)
                D(:,ss_idx)=etc_circshift(ref(:),ss(ss_idx));
            end;
            
            
            cc=etc_corrcoef(epoch_sum(:,tr_idx),D);
            [dummy,max_idx]=max(cc);
            
            shift(tr_idx)=ss(max_idx); %<-----number of sample shifted over trials!
            
            dss=dss./10;
            if(max_idx>1)
                if((max_idx+1)<length(ss))
                    ss=[ss(max_idx-1):dss:ss(max_idx+1)];
                else
                    ss=[ss(max_idx-1):dss:ss(end)];
                end;
            else
                if((max_idx+1)<length(ss))
                    ss=[ss(1):dss:ss(max_idx+1)];
                else
                    ss=[ss(1):dss:ss(end)];
                end;
            end;
        end;
        
        epoch_sum_shift(:,tr_idx)=etc_circshift(epoch_sum(:,tr_idx),-shift(tr_idx));
        for ch_idx=1:size(epoch,1)
            epoch_shift(ch_idx,:,tr_idx)=etc_circshift(squeeze(epoch(ch_idx,:,tr_idx)),-shift(tr_idx));
        end;
    end;
    if(flag_display) fprintf('\n'); end;
    
    
    %if(flag_display) fprintf('subtracting GA tamplate (moving average) from data...'); end;
    eeg_aas=eeg;
    for ch_idx=1:size(epoch,1)
        buffer=zeros(size(epoch,2),size(epoch,3));
        buffer1=zeros(size(epoch,2),size(epoch,3));
        buffer2=zeros(size(epoch,2),size(epoch,3));
        
        aas_bnd_bases=zeros(size(buffer,1),2);
        aas_bnd_bases(:,1)=1; % confound
        aas_bnd_bases(:,2)=[1:size(buffer,1)]'./size(buffer,1); % confound
        
        for tr_idx=1:size(epoch,3)
            if(flag_display)
                if(mod(tr_idx,20)==0)
                    fprintf('\t\tsubtracting artifact templates...channel [%d]::%1.1f%%\r',ch_idx,tr_idx./size(epoch,3).*100);
                end;
            end;
            
            if(flag_ma_aas)
                if(size(epoch,3)<=n_ma_aas)
                    trial_sel=[1:size(epoch,3)];
                else
                    if(tr_idx<=round((n_ma_aas-1)/2))
                        trial_sel=[1:n_ma_aas];
                    elseif(tr_idx>=size(epoch,3)-round((n_ma_aas-1)/2))
                        trial_sel=[size(epoch,3)-(n_ma_aas-1):size(epoch,3)];
                    else
                        trial_sel=[tr_idx-round((n_ma_aas-1)/2):tr_idx+round((n_ma_aas-1)/2)];
                    end;
                end;
            else %all trials
                trial_select=[1,size(epoch_sum,2)];
            end;
            trial_sel=setdiff(trial_sel,tr_idx);
            
            %estimate the GA template by moving average
            ga_template=mean(epoch_shift(:,:,trial_sel),3);
                        
            %tmp=eeg(ch_idx,trigger(tr_idx)-t_pre_n:trigger(tr_idx)+n_samp-1+t_post_n);
            tmp=squeeze(epoch(ch_idx,:,tr_idx));
            
            %AAS by regression
            tt=etc_circshift(ga_template(ch_idx,:),shift(tr_idx));
            D=[tt(:)];
            
            bnd0(tr_idx,:)=[tmp(1) tmp(end)]; %aligning ends (prep.)
            tmp=tmp(:)-D*inv(D'*D)*D'*tmp(:); %AAS by regression 

            buffer(:,tr_idx)=tmp(:);
        end;
        
        
        if(flag_aas_svd)
            [u,s,v]=svd(buffer,'econ');
            s=diag(s);
            cs=cumsum(s.^2)./sum(s.^2);
            cutoff=find(cs>aas_svd_threshold);
            if(flag_display)
                fprintf('\t\tSVD at channel [%d]:: first [%d] components were taken as artifacts (thresholded at %1.1f%%)\r',ch_idx,cutoff(1),aas_svd_threshold.*100);
            end;
            cutoff=cutoff(1)+1;
            s=diag(s);
            buffer=u(:,cutoff:end)*s(cutoff:end,cutoff:end)*v(:,cutoff:end)';
        end;
        
        
        for tr_idx=1:size(epoch,3)
            
            if(flag_anchor_bnd)
                tmp=buffer(:,tr_idx);
                bnd1=[tmp(1) tmp(end)]; %aligning ends (prep.)
                buffer(:,tr_idx)=tmp-aas_bnd_bases*inv(aas_bnd_bases([1,end],:)'*aas_bnd_bases([1,end],:))*aas_bnd_bases([1,end],:)'*(bnd1-bnd0(tr_idx,:))'; 
            end;
            
            eeg_aas(ch_idx,epoch_onset(tr_idx):epoch_offset(tr_idx))=buffer(:,tr_idx);
            
            if(flag_display&&(ch_idx==1))
                if(isempty(fig_ga))
                    fig_ga=figure;
                else
                    figure(fig_ga);
                end;
                subplot(211);
                tt=[epoch_onset(tr_idx):epoch_offset(tr_idx)]./fs;
                plot(tt,squeeze(epoch(ch_idx,:,tr_idx))); hold on; set(gca,'ylim',[-1000 1000]); title(sprintf('trials [%04d|%4d]',tr_idx,size(epoch,3)));
                h=plot(tt,buffer(:,tr_idx));  hold off; set(h,'linewidth',3,'color','r');
                subplot(212);
                plot(tt,squeeze(epoch(ch_idx,:,tr_idx))); hold on; set(gca,'ylim',[-100 100]); title(sprintf('trials [%04d|%4d]',tr_idx,size(epoch,3)));
                h=plot(tt,buffer(:,tr_idx));  hold off; set(h,'linewidth',3,'color','r');
                pause(0.01); drawnow;
            end;
        end;
    end;
else
    fprintf('no MR trigger detected!!\n');
    eeg_aas=[];
    ga_template=[];
    shift=[];
end;

fprintf('\n');


%----------------------------
% AAS end;
%----------------------------

return;
