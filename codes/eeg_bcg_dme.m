function [eeg_bcg, qrs_i_raw, eeg_bcg_pred, D, IDX, check]=eeg_bcg_dme(eeg,ecg,fs,varargin)

%defaults
flag_eeg_dyn=1;
flag_eeg_dyn_svd=1;
flag_ecg_dyn=1;
flag_auto_hp=0;
flag_display=0;
flag_avoid_extreme=1;
nn=[];
n_ecg=[]; %search the nearest -n_ecg:+n_ecg; 10 is a good number; consider how this interacts with 'nn'
dyn_duration_idx=round(fs/2); %duration (in samples; # samples in 0.5 s by default) of dyanmics to be examined; this will be the temporal range in feature definition

flag_reg=0;

eeg_bcg=[];
eeg_bcg_pred=[];

qrs_i_raw=[];
check=[];
n_svd=[];

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
        case 'flag_avoid_extreme'
            flag_avoid_extreme=option_value;
        case 'flag_eeg_dyn'
            flag_eeg_dyn=option_value;
        case 'flag_eeg_dyn_svd'
            flag_eeg_dyn_svd=option_value;
        case 'flag_ecg_dyn'
            flag_ecg_dyn=option_value;
        case 'dyn_duration_idx'
            dyn_duration_idx=option_value;
        case 'nn'
            nn=option_value;
        case 'n_ecg'
            n_ecg=option_value;
        case 'n_svd'
            n_svd=option_value;
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
    if(~isempty(ecg))
        ecg_fluc=filtfilt(ones(1e2,1)./1e2,1,ecg);
        ecg=ecg-ecg_fluc;
    end;
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

if(isempty(nn))
    if(~isempty(n_ecg))
        nn=round(n_ecg/2);
    else
        nn=10;
    end;
    if(flag_display)
        fprintf('Use [%02d] cycles for data modeling...\n',nn);
    end;
end;

% outlier_idx=isoutlier(ecg,'median','ThresholdFactor',4);
% ecg_now=ecg;
% if(~isempty(outlier_idx))
%     if(flag_display)
%         fprintf('ECG has outliers...correcting...\n');
%     end;
% 
%     ecg_now(find(outlier_idx))=median(ecg);
% end;
% ecg=ecg_now;

% %get reference time course
% [uu,ss,vv]=svd(eeg,'econ');
% ref=vv(:,1)';


eeg_bcg_pred=zeros(size(eeg));
eeg_bcg_pred_orig=zeros(size(eeg));
non_ecg_channel=[1:size(eeg,1)];



IDX=[];
D=[];
%not_nan=find(~isnan(mean(ecg_ccm_idx,2)));
if(flag_eeg_dyn) %EEG; dynamics
    if(~flag_eeg_dyn_svd)% EEG per-channel;

    else % EEG SVD;
        %            if( ch_idx==1)
        [dummy,s_idx]=sort(sum(abs(eeg),1));

        if(flag_avoid_extreme)
            [uu,ss,vv]=svd(eeg(:,s_idx(1:round(length(s_idx)*0.9))),'econ');
        else
            [uu,ss,vv]=svd(eeg,'econ');
        end;
        tmp=[];
        if(isempty(n_svd))
            if(~flag_avoid_extreme)
                n_svd=3; %more bases for extreme signals
            else
                n_svd=3; %extreme signals have been avoided
            end;
        end;

        for svd_idx=1:n_svd
            %v1=vv(:,svd_idx)';
            %dd=v1.*ss(svd_idx,svd_idx);
            dd=uu(:,svd_idx)'*eeg;


            %dd=ecg;
            %define the duration of dynamic features
            if(isempty(dyn_duration_idx))
                dyn_duration_idx=round(fs/2); %0.5 s by default
            end;


            %collect all dynamic features
            for delay_idx=1:dyn_duration_idx
                tmp0(delay_idx,:)=etc_circshift(dd,-delay_idx+1);
            end;

            tmp=cat(1,tmp,tmp0);
        end;

        tmp=tmp';

        %search the nearest neighbors for dynamic features over
        %time
        for t_idx=1:size(tmp,1)
            [IDX(t_idx,:),D(t_idx,:)] = knnsearch(tmp,tmp(t_idx,:),'K',nn+1);
        end;
    end;
else %ECG; dynamics
end;


%remove self;
IDX(:,1)=[];
D(:,1)=[];


for ch_idx=1:length(non_ecg_channel)
    %get estimates by cross mapping
    try

        for t_idx=1:size(eeg,2)
            dyn=eeg(non_ecg_channel(ch_idx),IDX(t_idx,:));
            dyn_rss=sqrt(sum(abs(dyn).^2));
            U=exp(-D(t_idx,:)./dyn_rss);
            %U=exp(-D(t_idx,:)./D(t_idx,:));
            W=U./sum(U);

            eeg_bcg_pred(non_ecg_channel(ch_idx),t_idx)=dyn*W';
        end;


        if(1)

            figure(1); clf;
            if(~isempty(ecg))
                subplot(221); hold on;
                h=plot(ecg);
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
                ylim=get(gca,'ylim');
                h=plot(ecg);
                set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);
            end;

            subplot(222); hold on;
            plot(eeg(non_ecg_channel(ch_idx),:));
            set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
            ylim=get(gca,'ylim');
            h=plot(eeg(non_ecg_channel(ch_idx),:));
            set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);

            subplot(223); hold on;
            h=plot(eeg(non_ecg_channel(ch_idx),:));
            set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
            ylim=get(gca,'ylim');
            h=plot(eeg(non_ecg_channel(ch_idx),:));
            set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);

            subplot(224); hold on;
            h=plot(eeg(non_ecg_channel(ch_idx),:));
            set(h,'color',[ 0    0.4470    0.7410],'linewidth',2);
            ylim=get(gca,'ylim');
            h=plot(eeg(non_ecg_channel(ch_idx),:));
            set(h,'color',[ 0    0.4470    0.7410],'linewidth',1);

            ha=[];
            h1=[];
            hb=[];
            h2=[];
            %end;



            figure(1);
            if(~isempty(ecg))
                subplot(221);
                xx=cat(1,t_idx,IDX(t_idx,:)');
                if(~isempty(ha)) delete(ha); end;
                if(~isempty(h1)) delete(h1); end;

                xlabel('time (sample)');
                ylabel('EKG signal (a.u.)');
                set(gca,'xlim',[1 size(eeg,2)]);
                %etc_plotstyle;
                %ha=plot(xx,ecg(xx),'r.'); set(ha,'markersize',40);
                %h1=plot(xx(1),ecg(xx(1)),'.'); set(h1,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);
            end;

            subplot(222);
            if(~isempty(hb)) delete(hb); end;
            if(~isempty(h2)) delete(h2); end;
            xlabel('time (sample)');
            ylabel('EEG signal (a.u.)');
            set(gca,'xlim',[1 size(eeg,2)]);
            %etc_plotstyle;
            hb=plot(xx,eeg(non_ecg_channel(ch_idx),xx),'r.'); set(hb,'markersize',40);
            h2=plot(xx(1),eeg(non_ecg_channel(ch_idx),xx(1)),'.'); set(h2,'markersize',40,'color',[ 0.4660    0.6740    0.1880]);

            subplot(223)
            h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
            set(h,'linewidth',2);
            xlabel('time (sample)');
            ylabel('EEG signal (a.u.)');
            set(gca,'xlim',[1 size(eeg,2)]);
            ylim=get(gca,'ylim');
            %etc_plotstyle;

            subplot(224)
            h=plot(eeg_bcg_pred(non_ecg_channel(ch_idx),1:t_idx),'r');
            set(h,'linewidth',2);
            xlabel('time (sample)');
            ylabel('EEG signal (a.u.)');
            set(gca,'xlim',[t_idx-500 t_idx+500],'ylim',ylim);
            %etc_plotstyle;

            set(gcf,'pos',[100        1000        2100           900]);

        end;



    catch ME
        fprintf('Error in BCG DME prediction!\n');
        fprintf('t_idx=%d\n',t_idx);
        keyboard;
    end;
end;

eeg_bcg_pred(find(isnan(eeg_bcg_pred(:))))=0; %no change on these NaN entries.

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
    if(~isempty(ecg))
       ecg=ecg+ecg_fluc;
    end;
    for ch_idx=1:size(eeg,1)
        eeg_bcg(ch_idx,:)=eeg_bcg(ch_idx,:)+eeg_fluc(ch_idx,:);
    end;
end;

if(flag_display) fprintf('BCG DME correction done!\n'); end;



return;

