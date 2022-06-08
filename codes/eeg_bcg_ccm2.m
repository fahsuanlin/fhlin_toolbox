function [eeg_bcg, qrs_i_raw, eeg_bcg_pred]=eeg_bcg_ccm2(eeg,ecg,fs,varargin)

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

flag_pan_tompkin2=0;

eeg_bcg=[];
qrs_i_raw=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
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
    ecg_fluc=filtfilt(ones(4e2,1)./4e2,1,ecg);
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

if(flag_display) fprintf('detecting EKG peaks...\n'); end;
%[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);
%[pks,qrs_i_raw] = findpeaks(ecg,'MINPEAKDISTANCE',round(0.7*fs));
if(flag_pan_tompkin2)
    [pks,qrs_i_raw] =pan_tompkin2(ecg,fs);
else
    [pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);
end;

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
if(~flag_cce)
    [IDX,D] = knnsearch(ecg(ecg_ccm_idx(2:end-1,:)),ecg(ecg_ccm_idx(2:end-1,:)),'K',nn+1);
else
    [uu,ss,vv]=svd(eeg,'econ');
    v1=vv(:,1)';
    [IDX,D] = knnsearch(v1(ecg_ccm_idx(2:end-1,:)),v1(ecg_ccm_idx(2:end-1,:)),'K',nn+1);
end;
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

for t_idx=1:size(eeg,2)
    if(isnan(time_idx(t_idx)))
        
    else
        if(ccm_D(t_idx,1)<eps) ccm_D(t_idx,1)=eps; end;
        U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        W=U./sum(U);
        
        debug_ch=1;
        for ch_idx=1:length(non_ecg_channel)
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
                eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg(non_ecg_channel(ch_idx),ccm_IDX(t_idx,:))*W';
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

                if(t_idx==2000) keyboard; end;
                   
                pause(0.01);
            end;
        end;
    end;
end;

eeg_bcg=eeg-eeg_bcg_pred;

if(flag_auto_hp)
    ecg=ecg+ecg_fluc;
    for ch_idx=1:size(eeg,1)
        eeg_bcg(ch_idx,:)=eeg_bcg(ch_idx,:)+eeg_fluc(ch_idx,:);
    end;
end;

if(flag_display) fprintf('BCG CCM correction done!\n'); end;


return;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prepare search.......
ccm_IDX=zeros(size(eeg,2),nn);
ccm_D=zeros(size(eeg,2),nn);

time_idx=[1:size(eeg,2)];
for dim_idx=1:E
    t0(dim_idx,:)=[1:size(eeg,2)]+(dim_idx-1).*tau+round(fs.*delay_time);
end;
exclude_mask=zeros(size(t0));
exclude_mask(find(t0>size(eeg,2)))=1;
exclude_mask(find(t0<1))=1;

t0(:,find(sum(exclude_mask,1)>eps))=[];

time_idx(find(sum(exclude_mask,1)>eps))=nan;

X0=ecg(t0)';
%tmp=eeg(non_ecg_channel(ch_idx),:);
%Y0=tmp(t0)';

%<---the most time-consuming part!! ----->
% global search takes too long for long time series!!
%[IDX,D] = knnsearch(X0,X0,'K',round((E+1)*fs*1.2));
%<---the most time-consuming part!! ----->

%search preparation DONE!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

knn_idx=0;
for t_idx=1:size(eeg,2)
    if(isnan(time_idx(t_idx)))
        
    else
        if(flag_display) if(mod(t_idx,1000)==0) fprintf('[%d|%d]...\r',t_idx,size(eeg,2)); end; end;
        ecg_idx_now=ecg_idx(t_idx);
        ecg_idx_buffer=ecg_idx; %<----you can limit the search range in time here
        
        ecg_phase_percent_now=ecg_phase_percent(t_idx);
        ecg_phase_percent_buffer=ecg_phase_percent;
        
        phase_limit=5; %+/-5% of an ECG cycle
        phase_idx=find((angle(exp(sqrt(-1).*(ecg_phase_percent_buffer-ecg_phase_percent_now)./100.*2.*pi))*100/2/pi<=phase_limit)&(angle(exp(sqrt(-1).*(ecg_phase_percent_buffer-ecg_phase_percent_now)./100.*2.*pi))*100/2/pi>=-phase_limit));
        
        ecg_count_limit=n_ecg; %-10:10 ecg included
        ecg_count_idx=find(abs(ecg_idx_buffer-ecg_idx_now)<=ecg_count_limit);
        ecg_count_idx(find(ecg_idx_buffer(ecg_count_idx)==ecg_idx_now))=[];
        
        knn_idx=intersect(ecg_count_idx,phase_idx);
        
        %exclude search from time points outside the manifold range
        knn_idx(find(isnan(time_idx(knn_idx))))=[];
        
        
        [IDX,D] = knnsearch(X0(knn_idx,:),X0(t_idx,:),'K',nn);
        
        ccm_IDX(t_idx,:)=knn_idx(IDX(1,1:end));
        ccm_D(t_idx,:)=D(1,1:end);
        
        %cross mapping
        if(ccm_D(t_idx,1)<eps) ccm_D(t_idx,1)=eps; end;
        U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        W=U./sum(U);
        
        
        %     ecg_idx_buffer(find(ecg_idx_buffer==ecg_idx_now))=nan;
        %
        %     if(knn_idx~=ecg_idx_now)
        %         if(flag_display)
        %             fprintf('#');
        %         end;
        %
        %         knn_begin_idx=[];
        %         knn_end_idx=[];
        %
        %         if(ecg_idx_now-n_ecg>0)
        %             knn_begin_idx=min(find(ecg_idx==ecg_idx_now-n_ecg));
        %         else
        %             knn_begin_idx=1;
        %
        %             ecg_idx_begin=ecg_idx(1);
        %             if(ecg_idx_begin+2*n_ecg<=max(ecg_idx))
        %                 knn_end_idx=max(find(ecg_idx==ecg_idx_begin+2*n_ecg));
        %                 if(knn_end_idx>size(X0,1)) knn_end_idx=size(X0,1); end;
        %             else
        %                 knn_end_idx=size(X0,1);
        %             end;
        %         end;
        %
        %         if(isempty(knn_end_idx))
        %         if(ecg_idx_now+n_ecg<=max(ecg_idx))
        %             knn_end_idx=max(find(ecg_idx==(ecg_idx_now+n_ecg)));
        %             if(knn_end_idx>size(X0,1)) knn_end_idx=size(X0,1); end;
        %         else
        %             knn_end_idx=size(X0,1);
        %
        %             ecg_idx_end=ecg_idx(end);
        %             if(ecg_idx_end-2*n_ecg>0)
        %                 knn_begin_idx=min(find(ecg_idx==ecg_idx_end-2*n_ecg));
        %             else
        %                 knn_begin_idx=1;
        %             end;
        %         end;
        %         end;
        %
        %
        %         %<---the most time-consuming part!! ----->
        %         [IDX,D] = knnsearch(X0(knn_begin_idx:knn_end_idx,:),X0(knn_begin_idx:knn_end_idx,:),'K',knn_end_idx-knn_begin_idx+1);
        %         %<---the most time-consuming part!! ----->
        %
        %         knn_idx=ecg_idx_now;
        %     end;
        %
        %     if(isnan(time_idx(t_idx)))
        %
        %     else
        %
        %
        %         idx_buffer=IDX(t_idx-(knn_begin_idx-1),:)+(knn_begin_idx-1);
        %         [C,ia,ic]=unique(ecg_idx(idx_buffer),'stable');
        %         ccm_IDX(t_idx,:)=IDX(t_idx-(knn_begin_idx-1),ia(2:nn+1));
        %         ccm_D(t_idx,:)=D(t_idx-(knn_begin_idx-1),ia(2:nn+1));
        %
        %         %cross mapping
        %         U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        %         W=U./sum(U);
        %
        
        
        for ch_idx=1:length(non_ecg_channel)
            %fprintf('*');
            if(flag_display&&mod(t_idx,1000)==0&&t_idx==1000)
                %if(t_idx==1)
                    figure(1); clf;
                    subplot(121);
                    plot(ecg); hold on;
                    set(gca,'xlim',[1 5e3]);
                    subplot(122);
                    plot(eeg(non_ecg_channel(ch_idx),:)); hold on;
                    set(gca,'xlim',[1 5e3]);
                    
                    figure(2); clf;
                    plot(eeg(non_ecg_channel(ch_idx),:)); hold on;
                    set(gca,'xlim',[1 5e3]);
                    
                    ha=[];
                    h1=[];
                    hb=[];
                    h2=[];
                %end;
            end;
            
            tic;
            
            %get estimates by cross mapping
            eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg(non_ecg_channel(ch_idx),ccm_IDX(t_idx,:))*W';
            
            if(flag_display&&mod(t_idx,1000)==0)
                figure(1);
                subplot(121);
                xx=cat(1,t_idx,ccm_IDX(t_idx,:)');
                if(~isempty(ha)) delete(ha); end;
                if(~isempty(h1)) delete(h1); end;
                
                ha=plot(xx,ecg(xx),'ro');
                h1=plot(xx(1),ecg(xx(1)),'go');
                
                
                subplot(122);
                %plot(t_idx,y_m(t_idx),'r.');
                %set(gca,'xlim',[1 1000]);
                if(~isempty(hb)) delete(hb); end;
                if(~isempty(h2)) delete(h2); end;
                hb=plot(xx,eeg(xx),'ro');
                h2=plot(xx(1),eeg(xx(1)),'go');
                
                figure(2);
                plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                %set(gca,'xlim',[knn_begin_idx knn_end_idx]);
                set(gca,'xlim',[1 5e3]);
                
                pause(0.01);
            end;
        end;
    end;
end;

eeg_bcg=eeg-eeg_bcg_pred;


if(flag_display) fprintf('BCG CCM correction done!\n'); end;

%----------------------------
% BCG CCM end;
%----------------------------

return;
