function [onsets]=etc_onset_adjust(signal, onsets_orig,varargin)

onset_range=5;

flag_display=0;

flag_signal_abs=0;

onsets=onsets_orig;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'onset_range'
            onset_range=option_value;
        case 'flag_signal_abs'
            flag_signal_abs=option_value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option);
            return;
    end;
end;

if(flag_display) %show signal and onsets
     tt=[1:length(signal)];
     plot(tt,signal); hold on;
     line(repmat(tt(onsets_orig),[2 1]),repmat([min(signal-mean(signal))/2; max(signal-mean(signal))/2],size(onsets_orig)),'LineWidth',2.5,'LineStyle','-.','Color','k');
end;

if(flag_signal_abs)
    signal=abs(signal);
end;

for t_idx=1:length(onsets_orig)-1
    duration(t_idx)=onsets_orig(t_idx+1)-onsets_orig(t_idx);
end;
[duration_min]=min(duration);
duration_median=round(median(duration));
duration_median=10;

for t_idx=1:length(onsets_orig)-1
%    tmp=signal(onsets_orig(t_idx):onsets_orig(t_idx)+duration_min-1);
    tmp=signal(onsets_orig(t_idx)-round(duration_median/2):onsets_orig(t_idx)+round(duration_median/2));
    template(:,t_idx)=tmp(:);
end;
template_avg=mean(template,2);


%detect the max correlation by circular convolution
for t_idx=1:length(onsets_orig)-1
    corr=cconv(template(:,t_idx),template_avg,length(template_avg));
    [~,max_corr_idx(t_idx)]=max(corr);
    corr=cconv(template(:,t_idx),template(:,t_idx),length(template_avg));
    [~,ref_corr_idx]=max(corr);

    onsets(t_idx)=onsets_orig(t_idx)-max_corr_idx(t_idx)+ref_corr_idx;
end;


if(flag_display&~isempty(onsets)) %show signal and onsets
     tt=[1:length(signal)];
     %plot(tt,signal); hold on;
     line(repmat(tt(onsets),[2 1]),repmat([min(signal-mean(signal))/2; max(signal-mean(signal))/2],size(onsets)),'LineWidth',2.5,'LineStyle','-.','Color','r');
end;

return;
