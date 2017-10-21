function [eeg_aas, ga_template, shift]=eeg_ga(eeg,eeg_trigger,TR,fs,varargin)

%defaults
flag_display=1;

flag_ma_aas=0;
n_ma_aas=7; %# of movign GA template trials

flag_ga_obs=0;
n_ga_obs=4; %# of GA OBS basis

ecg=[];

fig_ga=[];

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
        case 'flag_ga_obs'
            flag_ga_obs=option_value;
        case 'n_ga_obs'
            n_ga_obs=option_value; %# of GA OBS basis
        case 'ecg'
            ecg=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;

if(~isempty(ecg))
    [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,0,'flag_fhlin',1);
    qrs=zeros(1,size(eeg,2));
    qrs(qrs_i_raw)=1000;
else
    qrs_amp_raw=[];
    qrs_i_raw=[];
    delay=[];
    qrs=[];
end;

%----------------------------
% AAS start;
%----------------------------

trigger=find(eeg_trigger);

if(~isempty(TR))
    n_samp=round(fs*TR);
else
    n_samp=[];
end;

%epoching; only valid for data with MRI triggers
if(sum(abs(eeg_trigger))>0)
    %epoch=zeros(size(eeg,1),n_samp,length(trigger));
    for tr_idx=1:length(trigger)
        if(~isempty(n_samp))
            if(trigger(tr_idx)+n_samp-1<=size(eeg,2))
                epoch(:,:,tr_idx)=eeg(:,trigger(tr_idx):trigger(tr_idx)+n_samp-1);
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
    
    if(flag_display) fprintf('GA: aligning trials...'); end;
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
        if(flag_display) fprintf('*'); end;
        
        %if(tr_idx>=62) keyboard; end;
        
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
    
    
    if(flag_display) fprintf('subtracting GA tamplate (moving average) from data...'); end;
    eeg_aas=eeg;
    for tr_idx=1:size(epoch,3)
        if(flag_display) fprintf('#'); end;
        
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
        
        %estimate the GA template by moving average
        ga_template=mean(epoch_shift(:,:,trial_sel),3);
        
        for ch_idx=1:size(epoch,1)
            if(trigger(tr_idx)+n_samp-1<=size(eeg,2))
                tmp=eeg(ch_idx,trigger(tr_idx):trigger(tr_idx)+n_samp-1);
                tmp0=tmp;
                
                %subtract by regression
                tt=etc_circshift(ga_template(ch_idx,:),shift(tr_idx));
                D=[ones(length(tt),1),tt(:)];
                tmp=tmp(:)-D*inv(D'*D)*D'*tmp(:);
                %tmp=tmp-tt;
                
                %tmp=tmp-etc_circshift(ga_template(ch_idx,:),shift(tr_idx));
                eeg_aas(ch_idx,trigger(tr_idx):trigger(tr_idx)+n_samp-1)=tmp;
                
                %if(tr_idx>30) keyboard; end;
                
                if(flag_display)
                    if(isempty(fig_ga))
                        fig_ga=figure;
                    else
                        figure(fig_ga);
                    end;
                    subplot(511);
                    plot(tmp0); set(gca,'ylim',[-1000 1000]); title('EEG before AAS');
                    subplot(512);
                    plot(squeeze(epoch_shift(ch_idx,:,trial_sel))); set(gca,'ylim',[-1000 1000]); title('template components');
                    subplot(513);
                    plot(tt); set(gca,'ylim',[-1000 1000]); title('artifact template');
                    subplot(514);
                    if(~isempty(ecg))
                        plot(ecg(trigger(tr_idx):trigger(tr_idx)+n_samp-1)); hold on; set(gca,'ylim',[-1000 1000]); title('ECG');
                        h=plot(qrs(trigger(tr_idx):trigger(tr_idx)+n_samp-1)); set(h,'color',[1 1 1].*0.3); hold off set(gca,'ylim',[-1000 1000]); title('ECG');
                    end;
                    subplot(515);
                    plot(tmp); set(gca,'ylim',[-100 100]); title('EEG after AAS');
                    %pause(0.01); drawnow;
                end;
            end;
        end;
    end;
end;


% else
%     %remove gradient artifacts by subtracting the artifact template
%     %    if(~flag_ma_aas)
%     if(flag_display) fprintf('estimating GA template (global)...\n'); end;
%     ga_template=mean(epoch_shift,3);
%
%     if(flag_display) fprintf('subtracting GA tamplate (global) from data...'); end;
%     eeg_aas=eeg;
%     for tr_idx=1:size(epoch,3)
%         if(flag_display) fprintf('#'); end;
%         for ch_idx=1:size(epoch,1)
%             if(trigger(tr_idx)+n_samp-1<=size(eeg,2))
%                 tmp=eeg(ch_idx,trigger(tr_idx):trigger(tr_idx)+n_samp-1);
%
%                 %subtract by regression
%                 tt=etc_circshift(ga_template(ch_idx,:),shift(tr_idx));
%                 D=[ones(length(tt),1),tt(:)];
%                 tmp=tmp(:)-D*inv(D'*D)*D'*tmp(:);
%                 %tmp=tmp-tt;
%
%                 %tmp=tmp-etc_circshift(ga_template(ch_idx,:),shift(tr_idx));
%                 eeg_aas(ch_idx,trigger(tr_idx):trigger(tr_idx)+n_samp-1)=tmp;
%             end;
%         end;
%     end;
% end;

% if(flag_ga_obs)
%     %remove gradient artifacts by OBS
%     for tr_idx=1:length(trigger)
%         if(~isempty(n_samp))
%             if(trigger(tr_idx)+n_samp-1<=size(eeg,2))
%                 epoch(:,:,tr_idx)=eeg_aas(:,trigger(tr_idx):trigger(tr_idx)+n_samp-1);
%             end;
%         end;
%     end;
%     epoch_shift=epoch;
%     for tr_idx=2:size(epoch,3)
%         for ch_idx=1:size(epoch,1)
%             epoch_shift(ch_idx,:,tr_idx)=etc_circshift(squeeze(epoch(ch_idx,:,tr_idx)),-shift(tr_idx));
%         end;
%     end;
%
%     for ch_idx=1:size(epoch,1)
%
%         [uu,ss,vv]=svd(squeeze(epoch_shift(ch_idx,:,:)),0);
%         tt=[];
%         for tr_idx=1:size(epoch,3)
%             if(flag_display) fprintf('.'); end;
%             if(trigger(tr_idx)+n_samp-1<=size(eeg,2))
%                 tmp=eeg_aas(ch_idx,trigger(tr_idx):trigger(tr_idx)+n_samp-1);
%
%                 %subtract by regression
%                 for uu_idx=1:n_ga_obs tt(:,uu_idx)=etc_circshift(uu(:,uu_idx),shift(tr_idx)); end;
%                 D=[ones(size(tt,1),1),tt];
%                 tmp=tmp(:)-D*inv(D'*D)*D'*tmp(:);
%
%                 eeg_aas(ch_idx,trigger(tr_idx):trigger(tr_idx)+n_samp-1)=tmp;
%             end;
%         end;
%     end;
% end;

if(flag_display) fprintf('\n'); end;


%----------------------------
% AAS end;
%----------------------------

return;
