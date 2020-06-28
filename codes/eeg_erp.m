function [erp, erp_avg,epoch_timeVec]=eeg_erp(data,sfreq,TRIGGER,erp_event,varargin)
% eeg_erp   get ERP
%
% [erp, erp_avg, erp_timeVec]=eeg_erp(data,sfreq,TRIGGER,erp_event,[option,
% option_value....]);
%
% data: 2D data matrix (channels x time points of raw data)
% sfreq: sampling frequency (Hz)
% TRIGGER: a trigger object with the following fields
%    event: a string vector codes for the occurance of the name of each event
%    time: a integer vector coes fo the occurence of the time index for each event
% erp_event: a string cell denotes the triggers to be averaged. 
%
% erp: a cell object with the following fields:
%    trials: raw trial data (channels x time points x trials)
%    n_trial: number of trials for the erp
%    trial_idx: 1D vector denotes the trials for the corresponding event
%    erp: 2D ERP (channels x time points)
%    timeVec: 1D time vector 
%    trigger: a string cell for the corresponding event
%    electrode_name: a string cell for the names of all channels
%
% erp_avg: the same cell object like erp; except there is no 'trials' field for a smaller data size
%
% fhlin@may 4, 2020
%


erp=[];
erp_avg=[];

erp_pre=0.2; %s; pre-stimulus interval
erp_post=1.0; %s; post-stimulus interval
flag_badrejection=1; %automatic bad trial rejection
badrejection_threshold=100; %microV; threshold to consider as a bad trial
flag_baseline_corr=0;
flag_display=1;

ch_names={};
%erp_event={2, 3, [2 3]};

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'erp_pre'
            erp_pre=option_value;
        case 'erp_post'
            erp_post=option_value;
        case 'flag_badrejection'
            flag_badrejection=option_value;
        case 'badrejection_threshold'
            badrejection_threshold=option_value;
        case'flag_baseline_corr'
            flag_baseline_corr=option_value;
        case 'ch_names'
            ch_names=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;


%epoching
if(~isempty(TRIGGER))
    time_pre=round(erp_pre.*sfreq);
    time_total=round((erp_post+erp_pre).*sfreq);
    epoch_data=zeros(size(data,1),time_total,length(TRIGGER.event)); %erp: channel x time x trials
    epoch_timeVec=([1:time_total]-1)./sfreq-erp_pre;
    
    if(flag_display)
        fprintf('\tERP epoching');
    end;
    
    for epoch_idx=1:length(TRIGGER.event)
        if(flag_display)
            fprintf('.');
        end;
        if((TRIGGER.time(epoch_idx)-time_pre)>1)
            if(TRIGGER.time(epoch_idx)+time_total-time_pre<size(data,2))
                epoch_data(:,:,epoch_idx)=data(:,TRIGGER.time(epoch_idx)-time_pre:TRIGGER.time(epoch_idx)+time_total-time_pre-1);
            end;
        end;
    end;
    if(flag_display)
        fprintf('\n');
    end;
    
    %automatic bad trial rejection
    if(flag_badrejection)
        if(flag_display)
            fprintf('\tbad trial rejection...');
        end;
        n_badtrial=0;
        for epoch_idx=1:length(TRIGGER.event)
            tmp=epoch_data(:,:,epoch_idx);
            
            if(~isempty(find(isnan(tmp))))
                n_badtrial=n_badtrial+1;
                tmp=ones(size(tmp)).*inf;
            end;
            
            epoch_abs_max(:,epoch_idx)=max(abs(tmp),[],2);
        end
        reject_trial=find(max(epoch_abs_max,[],1)>badrejection_threshold);
        if(flag_display)
            fprintf('trials {%s} with maximum higher than %1.1f (uV).\n',mat2str(reject_trial),badrejection_threshold);
        end;
        %epoch_data(:,:,reject_trial)=[];
        %TRIGGER.event(reject_trial)=[];
    else
        reject_trial=[];
    end;
    
    %baseline correction
    if(flag_baseline_corr)
        if(flag_display)
            fprintf('\tbaseline correction',f_idx);
        end;
        baseline_idx=find(epoch_timeVec<0);
        for epoch_idx=1:size(epoch_data,3)
            fprintf('.');
            epoch_data(:,:,epoch_idx)=epoch_data(:,:,epoch_idx)-repmat(squeeze(mean(epoch_data(:,baseline_idx,epoch_idx),2)),[1,size(epoch_data,2)]);
        end
        if(flag_display)
            fprintf('\n');
        end;
    end;
    
    %getting ERP
    if(~iscell(TRIGGER.event))
        str={};
        for idx=1:length(TRIGGER.event)
            str{idx}=sprintf('%d',TRIGGER.event(idx));
        end;
        TRIGGER.event=str;
    end;
    
    
    for event_idx=1:length(erp_event)
        tmp=erp_event{event_idx};
        str={}; for i=1:length(tmp) str{i}=sprintf('%d',tmp(i)); end; tmp=str;
        trials=[];
        for ii=1:length(tmp)
            %trials=union(trials,find(TRIGGER.event==tmp(ii)));
            trials=union(trials,find(strcmp(TRIGGER.event, tmp{ii})));
        end;
        trials=setdiff(trials,reject_trial);
        if(flag_display)
            fprintf('\t[%d] events found for trigger [%s]...\n',length(trials),num2str(erp_event{event_idx}));
        end;
        erp{event_idx}.trials=epoch_data(:,:,trials);
        erp{event_idx}.n_trial=length(trials);
        erp{event_idx}.trial_idx=trials;
        erp{event_idx}.erp=mean(epoch_data(:,:,trials),3);
        erp{event_idx}.timeVec=epoch_timeVec;
        erp{event_idx}.trigger=erp_event(event_idx);
        erp{event_idx}.electrode_name=ch_names;
        
        erp_avg{event_idx}=erp{event_idx};
        erp_avg{event_idx}.trials=[];
    end;
else
    erp=[];
end;
    
    
