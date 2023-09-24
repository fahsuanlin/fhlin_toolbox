function [eeg_bcg, qrs_i_raw, eeg_bcg_pred, cccm_D, cccm_IDX, check]=eeg_bcg_cccm(eeg,ecg,fs,varargin)

%defaults
flag_cce=0;
flag_auto_hp=0;
flag_display=0;
nn=5;
delay_time=0; %s
delay=round(fs.*(delay_time));
tau=10;
E=5;
n_ecg=[]; %search the nearest -n_ecg:+n_ecg; 10 is a good number; consider how this interacts with 'nn'

flag_reg=0;

flag_pan_tompkin2=0;
flag_wavelet_ecg=0;
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
        case 'flag_cce'
            flag_cce=option_value;
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
if(flag_wavelet_ecg)
    [uu,ss,vv]=svd(eeg,'econ');
    v1=vv(:,1)';
    
    freqVec=[2:0.1:30];
    
    %tfr1=inverse_waveletcoef([2:0.1:12],v1,fs,5); %20 Hz to 120 Hz;  assuming ECG has been decimated by 10x (60 Hz in threory).
    tfr2=inverse_waveletcoef(freqVec,ecg,fs,5); %20 Hz to 120 Hz;  assuming ECG has been decimated by 10x (60 Hz in threory).
    
    tfr=tfr2;

%     wav1=fmri_scale(-abs(tfr(26,:))./10,200,-200); wav1=wav1-mean(wav1);
%     wav2=fmri_scale(-abs(tfr(31,:))./10,200,-200); wav2=wav2-mean(wav2);
%     wav3=fmri_scale(-abs(tfr(36,:))./10,200,-200); wav3=wav3-mean(wav3);
%     wav4=fmri_scale(-abs(tfr(41,:))./10,200,-200); wav3=wav3-mean(wav3);
%     wav5=fmri_scale(-abs(tfr(46,:))./10,200,-200); wav4=wav4-mean(wav4);
%     wav6=fmri_scale(-abs(tfr(51,:))./10,200,-200); wav5=wav5-mean(wav5);

    wav=fmri_scale(abs(tfr(200,:))./10,200,-200); wav=wav-mean(wav);

    %[dummy,pks_tmp]=findpeaks(wav,'MinPeakDistance',20,'MinPeakProminence',40); %6Hz; assuming ECG has been decimated by 10x (60 Hz in threory).
    [dummy,read_inside_eeg_cccm]=findpeaks(wav,'MinPeakDistance',20,'MinPeakProminence',20,'Annotate','extents'); %6Hz; assuming ECG has been decimated by 10x (60 Hz in threory).
%     for p_idx=1:length(pks_tmp)+1
%         if(p_idx==1)
%             pks_start=1;
%         else
%             pks_start=pks_tmp(p_idx-1);
%         end;
%         if(p_idx==length(pks_tmp)+1)
%             pks_end=length(ecg);
%         else
%             pks_end=pks_tmp(p_idx);
%         end;
        %[dummy,qrs_i_raw_tmp]=max(ecg(pks_start:pks_end));
%         [dummy,qrs_i_raw_tmp]=max(wav(pks_start:pks_end));
%         interv(p_idx)=pks_end-pks_start;
%         qrs_i_raw(p_idx)=qrs_i_raw_tmp+pks_start; %<<--------!!!!!
%         if(p_idx>2)
%         if(qrs_i_raw(p_idx)-qrs_i_raw(p_idx-1)<5) keyboard; end;
%         end;
        qrs_i_raw=pks_tmp;
%    end;
elseif(flag_eegsvd_ecg)
    [uu,ss,vv]=svd(eeg,'econ');
    v1=vv(:,1)';
    [dummy,qrs_i_raw]=findpeaks(fmri_scale(v1, -200, 200),'MinPeakDistance',20,'MinPeakProminence',20,'Annotate','extents'); %6Hz; assuming ECG has been decimated by 10x (60 Hz in threory).
else
    if(flag_pan_tompkin2)
        [pks,qrs_i_raw] =pan_tompkin2(ecg,fs);
    else
        [pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);
    end;
end;
qrs_i_raw=unique(qrs_i_raw,'stable');

check.qrs_i_raw=qrs_i_raw;



% t=zeros(1,size(eeg,2));
% t(qrs_i_raw)=1;
% t=cumsum(t);
% t=((-1).^t).*20;
% %etc_trace([wav; fmri_scale(v1,-100,100); eeg(11,:);t(1:size(eeg,2));ecg./5],'fs',fs);
% %etc_trace([wav1; wav2; wav3; wav4; wav5; wav; fmri_scale(v1,-100,100); eeg(11,:);t;ecg./5],'fs',fs);
% etc_trace([fmri_scale(v1,-100,100); eeg(11,:);t;ecg./5],'fs',fs);
% keyboard;

%     tt=[1:length(ecg)]./fs;
%     figure; plot(tt,ecg); hold on;
%     line(repmat(tt(qrs_i_raw),[2 1]),repmat([min(ecg-mean(ecg))/2; max(ecg-mean(ecg))/2],size(qrs_i_raw)),'LineWidth',2.5,'LineStyle','-.','Color','r');

    
eeg_bcg_pred=zeros(size(eeg));
non_ecg_channel=[1:size(eeg,1)];


%get ECG indices
ecg_idx=zeros(1,size(eeg,2)).*nan;
ecg_idx(qrs_i_raw)=[1:length(qrs_i_raw)];

%figure; 
%subplot(311); plot(ecg); set(gca,'xlim',[1 1000]);
%subplot(312); plot(ecg_idx); set(gca,'xlim',[1 1000]);


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
ecg_onset_idx=[1 idx+1 size(eeg,2)+1]; %<---ECG onsets    
ecg_offset_idx=[idx size(eeg,2) inf]; %<---ECG offsets
for ii=2:length(ecg_onset_idx)
    ecg_phase_percent(ecg_onset_idx(ii-1):ecg_onset_idx(ii)-1)=[0:ecg_onset_idx(ii)-1-ecg_onset_idx(ii-1)]./(ecg_onset_idx(ii)-1-ecg_onset_idx(ii-1)+1).*100; %<---ECG phase in percentage
end;
check.ecg_onset_idx=ecg_onset_idx;
check.ecg_offset_idx=ecg_offset_idx;

qrs_phase_limit=5; %+/-5% of the QRS peak in an ECG cycle
qrs_phase_idx=find((angle(exp(sqrt(-1).*(ecg_phase_percent)./100.*2.*pi))*100/2/pi<=qrs_phase_limit)&(angle(exp(sqrt(-1).*(ecg_phase_percent)./100.*2.*pi))*100/2/pi>=-qrs_phase_limit));

ll=ecg_offset_idx-ecg_onset_idx;
ll([1 end-1 end])=[]; %remove the first and last ECG; potentially incomplete.
mll=min(ll);
% if(tau.*(E-1)<=(mll-1))
%     tmp=[0:tau:tau.*(E)-1];
%     %tmp=[1-tau.*(E):tau:tau.*(E)-1];
% else
%     tmp=[0:tau:mll-1];
%     %tmp=[1-mll:tau:mll-1];
% end;
tmp=[1-tau.*(E):tau:tau.*(2*E)-1];



for ch_idx=1:length(non_ecg_channel)

    dd=eeg(non_ecg_channel(ch_idx),:);
    dd_buffer=zeros(max(max(ecg_idx))-2,round(median(ll)));
    try
        for ii=2:max(ecg_idx)-1
            dd_buffer(ii-1,:)=dd(ecg_onset_idx(ii):ecg_onset_idx(ii)+median(ll)-1);
        end;

    catch
    end;
    [dummy, peak_idx]=sort(mean(abs(dd_buffer),1));
    peak_idx=peak_idx(end-E:end); %<--- only the most significant 2*E time points are chosen as features.
    peak_idx=[0:median(ll)-1]; %<---all time points are chosen as features.

    check.peak_idx(:,ch_idx)=peak_idx(:);

    %%%% ecg_ccm_idx (size = N_ecg x N_dynamics)indicates the time indices for each cardiac cycle
    %ecg_ccm_idx=ones(max(ecg_idx),length(tmp)).*nan;
    ecg_ccm_idx=ones(max(ecg_idx),length(peak_idx)).*nan;
    for ii=2:max(ecg_idx)-1
        %     if(tau.*(E-1)<=(mll-1))
        %         ecg_ccm_idx(ii,:)=[0:tau:tau.*(E)-1]+ecg_onset_idx(ii);
        %         %ecg_ccm_idx(ii,:)=[1-tau.*(E):tau:tau.*(E)-1]+ecg_onset_idx(ii);
        %     else
        %         ecg_ccm_idx(ii,:)=[0:tau:mll-1]+ecg_onset_idx(ii);
        %         %ecg_ccm_idx(ii,:)=[1-mll:tau:mll-1]+ecg_onset_idx(ii);
        %     end;
        
        
        %ecg_ccm_idx(ii,:)=[1-tau.*(E):tau:tau.*(2*E)-1]+ecg_onset_idx(ii);
        ecg_ccm_idx(ii,:)=peak_idx+ecg_onset_idx(ii);
    end;

    ecg_ccm_idx(find(ecg_ccm_idx(:)>length(ecg)))=nan;
    ecg_ccm_idx(find(ecg_ccm_idx(:)<1))=nan;

    check.ecg_ccm_idx=ecg_ccm_idx;



    %search over ECG cycles
    %%%% IDX (size = N_ecg x N_neighbor) gives the time indices to the nearest EEG dynamics
    %%%% D (size = N_ecg x N_neighbor) gives the distance to the nearest EEG dynamics
    not_nan=find(~isnan(mean(ecg_ccm_idx,2)));
    if(~flag_cce)
        %[IDX,D] = knnsearch(ecg(ecg_ccm_idx(2:end-1,:)),ecg(ecg_ccm_idx(2:end-1,:)),'K',nn+1);
        %[IDX,D] = knnsearch(ecg(ecg_ccm_idx(not_nan,:)),ecg(ecg_ccm_idx(not_nan,:)),'K',nn+1);
        dd=eeg(non_ecg_channel(ch_idx),:);
        [IDX,D] = knnsearch(dd(ecg_ccm_idx(not_nan,:)),dd(ecg_ccm_idx(not_nan,:)),'K',nn+1);
        
    else
        [uu,ss,vv]=svd(eeg,'econ');
        v1=vv(:,1)';
        %[IDX,D] = knnsearch(v1(ecg_ccm_idx(2:end-1,:)),v1(ecg_ccm_idx(2:end-1,:)),'K',nn+1);
        %[IDX,D] = knnsearch(v1(ecg_ccm_idx(not_nan,:)),v1(ecg_ccm_idx(not_nan,:)),'K',nn+1);
        [IDX,D] = knnsearch(v1(non_ecg_channel(ch_idx), ecg_ccm_idx(not_nan,:)),v1(non_ecg_channel(ch_idx), ecg_ccm_idx(not_nan,:)),'K',nn+1);
    end;
    eeg_ch_now=eeg(non_ecg_channel(ch_idx),:);
    check.eeg_dyn(:,:,ch_idx)=eeg_ch_now(ecg_ccm_idx(not_nan,:));

    %IDX=IDX+1; %offset by one ECG cycle, because the first ECG cycle is ignored.
    IDX=not_nan(IDX); %IDX back to the full ECG cycles

    %append indices for the first and last ECG cycles
    % IDX_buffer=ones(size(IDX,1)+2,size(IDX,2)).*nan;
    % IDX_buffer(2:end-1,:)=IDX;
    % IDX=IDX_buffer;
    %
    % D_buffer=ones(size(D,1)+2,size(D,2)).*nan;
    % D_buffer(2:end-1,:)=D;
    % D=D_buffer;

    IDX_buffer=ones(size(ecg_ccm_idx,1),size(IDX,2)).*nan;
    IDX_buffer(not_nan,:)=IDX;
    IDX=IDX_buffer;

    D_buffer=ones(size(ecg_ccm_idx,1),size(D,2)).*nan;
    D_buffer(not_nan,:)=D;
    D=D_buffer;

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

            eeg_ch_now();

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
end;

check.dyn_all=zeros(size(eeg,2),nn,length(non_ecg_channel)).*nan;

for t_idx=1:size(eeg,2)
    
    
    if(isnan(time_idx(t_idx)))
        
    else
        if(ccm_D(t_idx,1)<eps) ccm_D(t_idx,1)=eps; end;
        U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        W=U./sum(U);
        manifold_w(t_idx,:)=W;
        
        debug_ch=1;
        for ch_idx=1:length(non_ecg_channel)
        %for ch_idx=1:1

            dyn_idx=cccm_IDX(t_idx,:,ch_idx);
            dd=eeg(non_ecg_channel(ch_idx),:);
            if(isempty(find(isnan(dyn_idx))))
                check.dyn_all(t_idx,:,ch_idx)=dd(dyn_idx);
            end;
            
            U=exp(-cccm_D(t_idx,:,ch_idx)./cccm_D(t_idx,1,ch_idx));
            W=U./sum(U);


            %fprintf('*');
            if(flag_display&&mod(t_idx,1000)==0&&t_idx==1000&&ch_idx==debug_ch)
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
                
                W_now=W;
                cccm_IDX_now=cccm_IDX(t_idx,:,ch_idx);
                not_nan_idx=find(~isnan(cccm_IDX_now));
                nan_idx=find(isnan(cccm_IDX_now));
                data_now=eeg(non_ecg_channel(ch_idx),cccm_IDX(t_idx,not_nan_idx,ch_idx));
                W_now(nan_idx)=[];
                eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=data_now*W_now';


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
                
%                 figure(3); clf; hold on;
%                 dd=ecg(ecg_ccm_idx(2:end-1,:));
%                 plot(dd(:,1),dd(:,2),'.')
%                 
%                 if(~isempty(hha)) delete(hha); end;
%                 if(~isempty(hh1)) delete(hh1); end;
%                 
%                 hh1=plot(ecg(ecg_ccm_idx(ecg_idx(t_idx),1)),ecg(ecg_ccm_idx(ecg_idx(t_idx),2)),'o');
%                 set(hh1,'linewidth',2,'color',[ 0.4660    0.6740    0.1880]);
%                 hha=plot(ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),1)),ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),2)),'ro');
%                 set(hha,'linewidth',2);
%                 xlabel('EKG(t) (a.u.)');
%                 ylabel('EKG(t+\tau) (a.u.)');
%                 etc_plotstyle;

                if(t_idx==2000) keyboard; end;
                   
                pause(0.01);
            end;
        end;
    end;
end;


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
        
