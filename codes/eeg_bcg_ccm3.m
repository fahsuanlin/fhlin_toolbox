function [eeg_bcg, qrs_i_raw]=eeg_bcg_ccm3(eeg,ecg,fs,varargin)

%defaults
flag_display=0;
nn=5;
delay_time=0; %s
delay=round(fs.*(delay_time));
tau=10;
E=5;
n_ecg=[]; %search the nearest -n_ecg:+n_ecg; 10 is a good number; consider how this interacts with 'nn'

eeg_bcg=[];
qrs_i_raw=[];

t_pre=0.5; %s; time before QRS complex as the begnnning of one cardiac cycle
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
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
        case 't_pre'
            t_pre=option_value;
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

if(isempty(n_ecg))
    n_ecg=ceil(nn+1/2); %search the nearest -n_ecg:+n_ecg
end;
if(n_ecg<10)
    n_ecg=10; %minimum....
end;

if(flag_display) fprintf('detecting EKG peaks...\n'); end;
%[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);
%[pks,qrs_i_raw] = findpeaks(ecg,'MINPEAKDISTANCE',round(0.7*fs));
[pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);

%     tt=[1:length(ecg)]./fs;
%     figure; plot(tt,ecg); hold on;
%     line(repmat(tt(qrs_i_raw),[2 1]),repmat([min(ecg-mean(ecg))/2; max(ecg-mean(ecg))/2],size(qrs_i_raw)),'LineWidth',2.5,'LineStyle','-.','Color','r');

    
eeg_bcg_pred=zeros(size(eeg));
non_ecg_channel=[1:size(eeg,1)];


%get ECG indices
ecg_idx=zeros(1,size(eeg,2)).*nan;
%ecg_idx(qrs_i_raw)=[1:length(qrs_i_raw)];
qrs_i_raw_shift=qrs_i_raw-round(t_pre*fs); %shift reference time point to -0.5-s before QRS
qrs_i_raw_shift(find(qrs_i_raw_shift<0))=[];
ecg_idx(qrs_i_raw_shift)=[1:length(qrs_i_raw_shift)];

%figure; 
%subplot(311); plot(ecg); set(gca,'xlim',[1 1000]);
%subplot(312); plot(ecg_idx); set(gca,'xlim',[1 1000]);


%ecg_idx=fillmissing(ecg_idx,'nearest');
ecg_idx=fillmissing(ecg_idx,'next');
ecg_idx(find(isnan(ecg_idx)))=max(ecg_idx)+1;

%subplot(313); plot(ecg_idx); set(gca,'xlim',[1 1000]);

%get ECG phases
idx=find(diff(ecg_idx));
ecg_onset_idx=[1 idx+1 size(eeg,2)+1]; %<---ECG onsets    
ecg_offset_idx=[idx size(eeg,2) inf]; %<---ECG offsets
for ii=2:length(ecg_onset_idx)
    ecg_phase_percent(ecg_onset_idx(ii-1):ecg_onset_idx(ii)-1)=[0:ecg_onset_idx(ii)-1-ecg_onset_idx(ii-1)]./(ecg_onset_idx(ii)-1-ecg_onset_idx(ii-1)+1).*100; %<---ECG phase in percentage
end;

qrs_phase_limit=5; %+/-5% of the QRS peak in an ECG cycle
qrs_phase_idx=find((angle(exp(sqrt(-1).*(ecg_phase_percent)./100.*2.*pi))*100/2/pi<=qrs_phase_limit)&(angle(exp(sqrt(-1).*(ecg_phase_percent)./100.*2.*pi))*100/2/pi>=-qrs_phase_limit));

ll=ecg_offset_idx-ecg_onset_idx;
ll([1 end-1 end])=[]; %remove the first and last ECG; potentially incomplete.
mll=min(ll);
if(tau.*(E-1)<=(mll-1))
    tmp=[0:tau:tau.*(E)-1];
else
    tmp=[0:tau:mll-1];
end;
ecg_ccm_idx=ones(max(ecg_idx),length(tmp)).*nan;
for ii=2:max(ecg_idx)-1
%    ecg_ccm_idx(ii,:)=[0:mll-1]+ecg_onset_idx(ii);
    if(tau.*(E-1)<=(mll-1))
        ecg_ccm_idx(ii,:)=[0:tau:tau.*(E)-1]+ecg_onset_idx(ii);
    else
        ecg_ccm_idx(ii,:)=[0:tau:mll-1]+ecg_onset_idx(ii);        
    end;
end;

%search over ECG cycles
%[IDX,D] = knnsearch(ecg(ecg_ccm_idx(2:end-1,:)),ecg(ecg_ccm_idx(2:end-1,:)),'K',nn+1);

onset_idx=ones(1,size(eeg,2));
for ii=1:length(ecg_onset_idx) 
    if(~isinf(ecg_offset_idx(ii)))
        onset_idx(ecg_onset_idx(ii):ecg_offset_idx(ii))=ecg_onset_idx(ii); 
    else
        onset_idx(ecg_onset_idx(ii):end)=ecg_onset_idx(ii); 
    end;
end;


manifold_data=ecg(ecg_ccm_idx(2:end-1,:));

manifold_data_offset=repmat(manifold_data(:,1),[1,size(manifold_data,2)]);

manifold_data=manifold_data-manifold_data_offset;

[IDX,D] = knnsearch(manifold_data,manifold_data,'K',nn+1);

IDX=IDX+1; %offset by one ECG cycle, because the first ECG cycle is ignored.

%append indices for the first and last ECG cycles
IDX(2:end+1,:)=IDX;
IDX(1,:)=nan;
IDX(end+1,:)=nan;
D(2:end+1,:)=D;
D(1,:)=nan;
D(end+1,:)=nan;

%remove self;
IDX(:,1)=[];
D(:,1)=[];

ccm_IDX=zeros(size(eeg,2),nn).*nan;
ccm_D=zeros(size(eeg,2),nn).*nan;

for ii=2:max(ecg_idx)-1
    ccm_IDX(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(ecg_onset_idx(IDX(ii,:)),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1])+repmat([0:ecg_offset_idx(ii)-ecg_onset_idx(ii)]',[1,nn]);
    %ccm_IDX(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(IDX(ii,:),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1]);    
    ccm_D(ecg_onset_idx(ii):ecg_offset_idx(ii),:)=repmat(D(ii,:),[ecg_offset_idx(ii)-ecg_onset_idx(ii)+1,1]);    
end;
ccm_IDX(find(ccm_IDX(:)>size(eeg,2)))=nan;

time_idx=[1:size(eeg,2)];
time_idx(find(isnan(ccm_IDX(:,1))))=nan;

time_idx(find(isnan(sum(ccm_IDX,2))))=nan;
if(flag_display)
    fprintf('[%d] (%1.1f%%) time points excluded from CCM because data are out of time series range.\n',length(find(isnan(sum(ccm_IDX,2)))),length(find(isnan(sum(ccm_IDX,2))))./size(eeg,2).*100);
end;

eeg_baseline_corr=eeg;
for ch_idx=1:length(non_ecg_channel)
    tmp=eeg(non_ecg_channel(ch_idx),:);
    eeg_baseline_corr(non_ecg_channel(ch_idx),:)=tmp-tmp(onset_idx);
end;

for t_idx=1:size(eeg,2)
    if(isnan(time_idx(t_idx)))
        
    else
        if(ccm_D(t_idx,1)<eps) ccm_D(t_idx,1)=eps; end;
        U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        W=U./sum(U);
        
        debug_ch=12;
        for ch_idx=1:length(non_ecg_channel)
            %fprintf('*');
            if(flag_display&&mod(t_idx,1000)==0&&t_idx==35000&&ch_idx==debug_ch)
                figure(1); clf;
                subplot(121); hold on;
                h=plot(ecg); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                get(gca,'ylim');
                for ii=1:length(qrs_i_raw)
                    h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
                    set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
                end;
                h=plot(ecg); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                
                subplot(122); hold on;
                plot(eeg(non_ecg_channel(ch_idx),:)); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                get(gca,'ylim');
                for ii=1:length(qrs_i_raw)
                    h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
                    set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
                end;           
                h=plot(eeg(non_ecg_channel(ch_idx),:)); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                
                figure(2); clf;
                subplot(121); hold on;
                h=plot(eeg(non_ecg_channel(ch_idx),:)); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                get(gca,'ylim');
                for ii=1:length(qrs_i_raw)
                    h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
                    set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
                end;           
                h=plot(eeg(non_ecg_channel(ch_idx),:)); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);

                subplot(122); hold on;
                h=plot(eeg(non_ecg_channel(ch_idx),:)); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                get(gca,'ylim');
                for ii=1:length(qrs_i_raw)
                    h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
                    set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
                end;           
                h=plot(eeg(non_ecg_channel(ch_idx),:)); 
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);
                
                ha=[];
                h1=[];
                hb=[];
                h2=[];
                %end;
            end;
            
            
            %get estimates by cross mapping
            try
                %non_nan_idx=find(~isnan(ccm_IDX(t_idx,:)));
                %eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg(non_ecg_channel(ch_idx),ccm_IDX(t_idx,non_nan_idx))*W(non_nan_idx)';
                
                
                %eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg(non_ecg_channel(ch_idx),ccm_IDX(t_idx,:))*W';
                eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg_baseline_corr(non_ecg_channel(ch_idx),ccm_IDX(t_idx,:))*W';
            catch ME
                fprintf('Error in BCG CCM prediction!\n');
                fprintf('t_idx=%d\n',t_idx);
            end;
            if(flag_display&&mod(t_idx,1000)==0&&ch_idx==debug_ch)
                figure(1);
                subplot(121);
                xx=cat(1,t_idx,ccm_IDX(t_idx,:)');
                if(~isempty(ha)) delete(ha); end;
                if(~isempty(h1)) delete(h1); end;
                
                xlabel('time (sample)');
                ylabel('EKG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;
                ha=plot(xx,ecg(xx),'r.'); set(ha,'markersize',40);
                h1=plot(xx(1),ecg(xx(1)),'.'); set(h1,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
                
                subplot(122);
                if(~isempty(hb)) delete(hb); end;
                if(~isempty(h2)) delete(h2); end;
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;
                hb=plot(xx,eeg(non_ecg_channel(ch_idx),xx),'r.'); set(hb,'markersize',40);
                h2=plot(xx(1),eeg(non_ecg_channel(ch_idx),xx(1)),'.'); set(h2,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
                set(gcf,'pos',[100        1000        2100         300]);
                
                figure(2);
                subplot(121)
                h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                set(h,'linewidth',2);
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;

                subplot(122)
                h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                set(h,'linewidth',2);
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1500 2500]);
                etc_plotstyle;
                
                set(gcf,'pos',[100        1000        2100           300]);
                
                figure(3); clf; hold on;
                dd=ecg(ecg_ccm_idx(2:end-1,:));
                plot(dd(:,1),dd(:,2),'.')
                
                if(~isempty(hha)) delete(hha); end;
                if(~isempty(hh1)) delete(hh1); end;
                
                hh1=plot(ecg(ecg_ccm_idx(ecg_idx(t_idx),1)),ecg(ecg_ccm_idx(ecg_idx(t_idx),2)),'o');
                set(hh1,'linewidth',2,'color',[ 0.4660    0.6740    0.1880]);
                hha=plot(ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),1)),ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),2)),'ro');
                set(hha,'linewidth',2);
                xlabel('EKG(t) (a.u.)');
                ylabel('EKG(t+\tau) (a.u.)');
                etc_plotstyle;

                if(t_idx==35000) keyboard; end;
                   
                pause(0.01);
            end;
        end;
    end;
end;

suppress_method=3;
switch(suppress_method)
    case 1 % direct subtraction
        eeg_bcg=eeg-eeg_bcg_pred;
    case 2 %regression
        eeg_bcg=eeg;
        eeg_bcg(:)=nan;
        try
        for ch_idx=1:length(non_ecg_channel)
            for idx=1:length(ecg_onset_idx)-1
                bcg_now=eeg_bcg_pred(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx));
                if(sum(abs(bcg_now))>eps)
                    eeg_now=eeg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx));
                    D=cat(2,ones(length(bcg_now(:)),1),bcg_now(:)); %DC offset + BCG for regression
                    beta=inv(D'*D)*D'*eeg_now(:);
                    eeg_bcg_corr_now=eeg_now(:)-D(:,2)*beta(2); %remove only BCG part
                    eeg_bcg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx))=eeg_bcg_corr_now(:)';
                else
                    eeg_bcg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx))=eeg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx));
                end;
            end;
            if(length(find(isnan(eeg_bcg(non_ecg_channel(ch_idx),:))))>0)
                keyboard;
            end;
        end;
        catch ME
                fprintf('error in BCG regression...\n');
        end;
    case 3 %regression with end-point anchoring
        eeg_bcg=eeg;
        eeg_bcg(:)=nan;
        try
        for ch_idx=1:length(non_ecg_channel)
            for idx=1:length(ecg_onset_idx)-1
                bcg_now=eeg_bcg_pred(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx));
                if(sum(abs(bcg_now))>eps)
                    %figure(1); hold on;
                    %plot(eeg(non_ecg_channel(ch_idx),1:ecg_offset_idx(idx)),'k');
                    
                    eeg_now=eeg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx));
                    bnd0=[eeg_now(1) eeg_now(end)];
                    
                    D=cat(2,ones(length(bcg_now(:)),1),bcg_now(:)); %DC offset + BCG for regression
                    beta=inv(D'*D)*D'*eeg_now(:);
                    eeg_bcg_corr_now=eeg_now(:)-D(:,:)*beta; %remove only BCG part
                    
                    eeg_bcg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx))=eeg_bcg_corr_now(:)';
                    %plot(eeg_bcg(non_ecg_channel(ch_idx),1:ecg_offset_idx(idx)),'r');
                    %plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:ecg_offset_idx(idx)),'g');
                    bnd1=[eeg_bcg_corr_now(1) eeg_bcg_corr_now(end)];

                    bcg_bnd_bases=zeros(length(eeg_bcg_corr_now),2);
                    bcg_bnd_bases(:,1)=1; % confound
                    bcg_bnd_bases(:,2)=[1:length(eeg_bcg_corr_now)]'./length(eeg_bcg_corr_now); % confound
                    
                    eeg_bcg_corr_now=eeg_bcg_corr_now-bcg_bnd_bases*inv(bcg_bnd_bases([1,end],:)'*bcg_bnd_bases([1,end],:))*(bcg_bnd_bases([1,end],:)'*(bnd1-bnd0)');
                    
                    eeg_bcg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx))=eeg_bcg_corr_now(:)';
                    %plot(eeg_bcg(non_ecg_channel(ch_idx),1:ecg_offset_idx(idx)),'b');

                    
                    %keyboard;
                else
                    eeg_bcg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx))=eeg(non_ecg_channel(ch_idx),ecg_onset_idx(idx):ecg_offset_idx(idx));
                end;
            end;
            if(length(find(isnan(eeg_bcg(non_ecg_channel(ch_idx),:))))>0)
                keyboard;
            end;
        end;
        catch ME
                fprintf('error in BCG regression...\n');
        end;
        
        
end;
if(flag_display) fprintf('BCG CCM correction done!\n'); end;


return;%----------------------------
% BCG CCM end;
%----------------------------

return;
