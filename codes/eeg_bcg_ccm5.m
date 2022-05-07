function [eeg_bcg]=eeg_bcg_ccm5(eeg,ecg,fs,varargin)

%defaults
flag_display=0;
E=75;
nn=6;
delay_time=0; %s
delay=round(fs.*(delay_time));

eeg_bcg=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'nn'
            nn=option_value;
        case 'e'
            E=option_value;
        case 'delay_time'
            delay_time=option_value;
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

% if(isempty(n_ecg))
%     n_ecg=ceil(nn+1/2); %search the nearest -n_ecg:+n_ecg
% end;
% if(n_ecg<10)
%     n_ecg=10; %minimum....
% end;
eeg_bcg_pred=zeros(size(eeg));
non_ecg_channel=[1:size(eeg,1)];

if(flag_display) fprintf('detecting EKG peaks...\n'); end;
%[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag_display,'flag_fhlin',1);
%[pks,qrs_i_raw] = findpeaks(ecg,'MINPEAKDISTANCE',round(0.7*fs));

%[pks,qrs_i_raw] =pan_tompkin(ecg,fs,0,'flag_fhlin',1);
%[R1,qrs_i_raw]  = findpeaks(ecg, 'MinPeakHeight',200,'MinPeakDistance',300);
tic;
if(flag_display) waitbar_h = waitbar(0,'Searching indices over the cardiac manifold...'); end;
ccm_IDX=nan(size(ecg,1),nn);
ccm_D=nan(size(ecg,1),nn);


%dynamics manifold by time instants separated by a Fibonacci sequence.
flag_cont=1;
idx=1;
ss=0;
mll=E;
data_idx=[];
while(flag_cont)
    fi=fibonacci(idx);
    ss=ss+fi;
    
    if(ss>mll/2)
        flag_cont=0;
    else
        data_idx(idx)=fi;
        idx=idx+1;
    end;
end;
tmp=cat(1,0,cumsum(data_idx(:)));
tmp=sort(cat(1,-tmp(2:end),tmp(:)));

%extending the ECG time series by temporal symmetry; preparing for manifold
%construction without worrying the edges
ecg=ecg(:);
ecg_ext=cat(1,ecg(max(tmp):-1:2),ecg(:),ecg(end-1:-1:end-max(tmp)+1));

ecg_manifold=[];
for ii=1:length(tmp)
    ecg_manifold=cat(2,ecg_manifold,circshift(ecg_ext,-tmp(ii)));
end;
ecg_manifold=ecg_manifold(max(tmp)+1:max(tmp)+length(ecg),:);

for idx=1:size(ecg,1)
    %tmp=filter(flipud(ecg_ext(idx:idx+2*E-2)-mean(ecg_ext(idx:idx+2*E-2))),1,ecg_ext);
    %[R1,TR1]  = findpeaks(tmp(E:end-E+1), 'MinPeakDistance',1500,'NPeaks',nn+1,'SortStr','Descend');
    ecg_manifold_tmp=ecg_manifold;
    for search_idx=1:nn+1
        [TR1(search_idx),R1(search_idx)] = knnsearch(ecg_manifold_tmp,ecg_manifold(idx,:),'K',1);
        if(TR1(search_idx)-500<1)
            IDX_start=1;
        else
            IDX_start=TR1(search_idx)-500;
        end;
        if(TR1(search_idx)+500>size(ecg,1))
            IDX_end=size(ecg,1);
        else
            IDX_end=TR1(search_idx)+500;
        end;
        
        ecg_manifold_tmp(IDX_start:IDX_end,:)=nan;
    end;
   
    if(~isempty(find(TR1==idx)))
        self_idx=find(TR1==idx);
        R1(self_idx)=[];
        TR1(self_idx)=[];
    else
        R1=R1(1:nn);
        TR1=TR1(1:nn);
    end;
    
    ccm_IDX(idx,:)=TR1(:);
    ccm_D(idx,:)=R1(:);
    if(flag_display)
        if(mod(idx,1000)==0)
            tt=toc;
            waitbar(idx./size(ecg,1),waitbar_h,sprintf('%2.2f%%, [%2.0f]s',idx./size(ecg,1).*100,tt));
        end;
    end;
end;
if(flag_display)
    delete(waitbar_h);
end;

try

    for t_idx=1:size(eeg,2)
        if(ccm_D(t_idx,1)<eps) ccm_D(t_idx,1)=eps; end;
        %U=exp(-ccm_D(t_idx,1)./ccm_D(t_idx,:)); %<---different from conventional CCM because a larger D represents a higher similarity
        U=exp(-ccm_D(t_idx,:)./ccm_D(t_idx,1));
        W=U./sum(U);
        
        debug_ch=20;
        for ch_idx=1:length(non_ecg_channel)
            %fprintf('*');
            if(flag_display&&mod(t_idx,1000)==0&&t_idx==1000&&ch_idx==debug_ch)
                flag_debug=1;
            else
                flag_debug=0;
            end;
            
            
            %get estimates by cross mapping
            try
                eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=eeg(non_ecg_channel(ch_idx),ccm_IDX(t_idx,:))*W';
            catch ME
                fprintf('Error in BCG CCM prediction!\n');
                fprintf('t_idx=%d\n',t_idx);
            end;
            if(flag_display&&mod(t_idx,1000)==0&&ch_idx==debug_ch)
                flag_debug=2;
            else
                flag_debug=0;
            end;
            
            EEG_model=eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx);
            EEG_actual=eeg(non_ecg_channel(ch_idx),t_idx);
            
            
            if(flag_debug)
                
                figure(1); clf;
                subplot(221); hold on;
                h=plot(ecg);
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(ecg);
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                
                subplot(222); hold on;
                plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                
                subplot(223); hold on;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);
                
                subplot(224); hold on;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
%                 for ii=1:length(qrs_i_raw)
%                     h=line([qrs_i_raw(ii) qrs_i_raw(ii)],ylim);
%                     set(h,'color',[0.8500    0.3250    0.0980],'linewidth',1);
%                 end;
                h=plot(eeg(non_ecg_channel(ch_idx),:));
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);
                
                ha=[];
                h1=[];
                hb=[];
                h2=[];
                %end;
                
                
                
                figure(1);
                subplot(221);
                xx=cat(1,t_idx,ccm_IDX(t_idx,:)');
                if(~isempty(ha)) delete(ha); end;
                if(~isempty(h1)) delete(h1); end;
                
                xlabel('time (sample)');
                ylabel('EKG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;
                ha=plot(xx,ecg(xx),'r.'); set(ha,'markersize',40);
                h1=plot(xx(1),ecg(xx(1)),'.'); set(h1,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
                
                subplot(222);
                if(~isempty(hb)) delete(hb); end;
                if(~isempty(h2)) delete(h2); end;
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                etc_plotstyle;
                hb=plot(xx,eeg(non_ecg_channel(ch_idx),xx),'r.'); set(hb,'markersize',40);
                h2=plot(xx(1),eeg(non_ecg_channel(ch_idx),xx(1)),'.'); set(h2,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
                
                subplot(223)
                h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                set(h,'linewidth',2);
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[1 length(ecg)]);
                ylim=get(gca,'ylim');
                etc_plotstyle;
                
                subplot(224)
                h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
                set(h,'linewidth',2);
                xlabel('time (sample)');
                ylabel('EEG signal (a.u.)');
                set(gca,'xlim',[t_idx-500 t_idx+500],'ylim',ylim);
                etc_plotstyle;
                
                set(gcf,'pos',[100        1000        2100           900]);
                
%                 figure(2); clf; hold on;
%                 dd=ecg(ccm_IDX(2:end-1,:));
%                 plot(dd(:,1),dd(:,2),'.')
%                 
%                 if(~isempty(hha)) delete(hha); end;
%                 if(~isempty(hh1)) delete(hh1); end;
%                 
%                 hh1=plot(ecg(ecg_ccm_idx(ecg_idx(t_idx),1)),ecg(ecg_ccm_idx(ecg_idx(t_idx),2)),'o');
%                 set(hh1,'linewidth',2,'color',[ 0.4660    0.6740    0.1880]);
%                 try
%                     hha=plot(ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),1)),ecg(ecg_ccm_idx(ecg_idx(ccm_IDX(t_idx,:)),2)),'ro');
%                 catch ME
%                     keyboard;
%                 end;
%                 set(hha,'linewidth',2);
%                 xlabel('EKG(t) (a.u.)');
%                 ylabel('EKG(t+\tau) (a.u.)');
%                 etc_plotstyle;
                
                
                %if(mod(t_idx,2000)==0) keyboard; end;
                
                
                %pause(0.01);
            end;
            
        end;
    end;
    
    eeg_bcg=eeg-eeg_bcg_pred;
    
catch ME
    t_idx
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
