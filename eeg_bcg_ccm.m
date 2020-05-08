function [eeg_bcg, qrs_i_raw]=eeg_bcg_ccm(eeg,ecg,fs,varargin)

%defaults
flag_display=0;
nn=5;
delay_time=0; %s
delay=round(fs.*(delay_time));
tau=10;
E=5;
n_ecg=10; %search the nearest -n_ecg:+n_ecg

eeg_bcg=[]; 
qrs_i_raw=[]; 

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
[pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);

eeg_bcg_pred=eeg;
non_ecg_channel=[1:size(eeg,1)];


%get ECG indices
ecg_idx=zeros(1,size(eeg,2)).*nan;
ecg_idx(qrs_i_raw)=[1:length(qrs_i_raw)];
ecg_idx=fillmissing(ecg_idx,'nearest');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%prepare search.......
ccm_IDX=zeros(size(eeg,2),nn);
ccm_D=zeros(size(eeg,2),nn);

time_idx=[1:size(eeg,2)];
for dim_idx=1:E
    t0(dim_idx,:)=[1:size(eeg,2)]+(dim_idx-1).*tau;
end;
mask=zeros(size(t0));
mask(find(t0>size(eeg,2)))=1;
mask(find(t0<1))=1;
t0(:,find(sum(mask,1)>eps))=[];

time_idx(find(sum(mask,1)>eps))=nan;

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
    if(flag_display) if(mod(t_idx,1000)==0) fprintf('[%d|%d]...\r',t_idx,size(eeg,2)); end; end;
    ecg_idx_now=ecg_idx(t_idx);
    ecg_idx_buffer=ecg_idx; %<----you can limit the search range in time here
    
    ecg_idx_buffer(find(ecg_idx_buffer==ecg_idx_now))=nan;
    
    if(knn_idx~=ecg_idx_now)
        if(flag_display)
            fprintf('#');
        end;
        
        knn_begin_idx=[];
        knn_end_idx=[];
        
        if(ecg_idx_now-n_ecg>0)
            knn_begin_idx=min(find(ecg_idx==ecg_idx_now-n_ecg));
        else
            knn_begin_idx=1;
            
            ecg_idx_begin=ecg_idx(1);
            if(ecg_idx_begin+2*n_ecg<=max(ecg_idx))
                knn_end_idx=max(find(ecg_idx==ecg_idx_begin+2*n_ecg));
                if(knn_end_idx>size(X0,1)) knn_end_idx=size(X0,1); end;
            else
                knn_end_idx=size(X0,1);
            end;
        end;
        
        if(isempty(knn_end_idx))
        if(ecg_idx_now+n_ecg<=max(ecg_idx))
            knn_end_idx=max(find(ecg_idx==(ecg_idx_now+n_ecg)));
            if(knn_end_idx>size(X0,1)) knn_end_idx=size(X0,1); end;
        else
            knn_end_idx=size(X0,1);
            
            ecg_idx_end=ecg_idx(end);
            if(ecg_idx_end-2*n_ecg>0)
                knn_begin_idx=min(find(ecg_idx==ecg_idx_end-2*n_ecg));
            else
                knn_begin_idx=1;
            end;
        end;
        end;
        
        
        %<---the most time-consuming part!! ----->
        [IDX,D] = knnsearch(X0(knn_begin_idx:knn_end_idx,:),X0(knn_begin_idx:knn_end_idx,:),'K',knn_end_idx-knn_begin_idx+1);
        %<---the most time-consuming part!! ----->       
        
        knn_idx=ecg_idx_now;
    end;
    
    if(isnan(time_idx(t_idx)))
        
    else
        
        
        idx_buffer=IDX(t_idx-(knn_begin_idx-1),:)+(knn_begin_idx-1);
        [C,ia,ic]=unique(ecg_idx(idx_buffer),'stable');
        ccm_IDX(t_idx,:)=IDX(t_idx-(knn_begin_idx-1),ia(2:nn+1));
        ccm_D(t_idx,:)=D(t_idx-(knn_begin_idx-1),ia(2:nn+1));
        
        %cross mapping
        U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        W=U./sum(U);
        
        
        
        for ch_idx=1:length(non_ecg_channel)
            %fprintf('*');
            if(flag_display)
                if(t_idx==1)
                    figure(1); clf;
                    subplot(121);
                    plot(ecg); hold on;
                    set(gca,'xlim',[1 253870]);
                    subplot(122);
                    plot(eeg(non_ecg_channel(ch_idx),:)); hold on;
                    set(gca,'xlim',[1 253870]);
                    
                    figure(2); clf;
                    plot(eeg(non_ecg_channel(ch_idx),:)); hold on;
                    set(gca,'xlim',[1 253870]);
                    
                    ha=[];
                    h1=[];
                    hb=[];
                    h2=[];
                end;
            end;
            
            tic;
            
            %get estimates by cross mapping
            eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg(non_ecg_channel(ch_idx),ccm_IDX(t_idx,:))*W';
            
            if(flag_display)
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
                set(gca,'xlim',[knn_begin_idx knn_end_idx]);
                
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
