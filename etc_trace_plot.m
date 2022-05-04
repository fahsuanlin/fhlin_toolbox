function [ax]=etc_trace_plot(data,fs,varargin)
% etc_trace_plot    plot time series in a stack
%
% [ax]=etc_trace_plot(data,fs,[option, option_value,....]);
%
% data: a mxn matrix for m-channel and time series of n time points
% fs: sampling rate (Hz)
% 
% ax: plot axis
%
% names: a string cell of m elements for the names of time series
% x_duration: the length of displayed time series in second. Default: 1.0
% (s)
% time_duration: the length of displayed time series in sample. Default:
% calculated automatically by x_duration and fs.
% ytick_dec: display names by skipping every ytick_dec names. Default: 10
% ytick_char: display the first ytick_char characters for each time series.
% Default: 3
%
% fhlin@April 6 2022
%

ax=[];

names=[];

ylim=[-50 50];

trace_width=2;
trace_color=[0, 0.4470, 0.7410];

x_duration=1.0; %s
time_duration=[]; %samples

ytick_dec=10; %show y tick lables every 10 lables
ytick_char=3; %show the first 3 characters of each y tick label

for i=1:length(varargin)/2
    option_name=varargin{i*2-1};
    option=varargin{i*2};
    switch lower(option_name)
        case 'ax'
            ax=option;
        case 'names'
            names=option;
        case 'x_duration'
            x_duration=option;
        case 'time_duration'
            time_duration=option_value;
        case 'ylim'
            ylim=option;
        case 'trace_width'
            trace_width=option;
        case 'trace_color'
            trace_color=option;
        case 'ytick_dec'
            ytick_dec=option;
        case 'ytick_char'
            ytick_char=option;
    end;
end;

if(isempty(time_duration))
    if(~isempty(x_duration))
        time_duration=round(x_duration*fs);
    else
        fprintf('error! [x_duration] (samples) must be provided!\n');
        return;
    end;
end;


if(isempty(names))
    for idx=1:size(data,1)
        names{idx}=sprintf('%03d',idx);
    end;
end;

if(isempty(ax))
    figure;
    ax=gca;
end;

tmp=cat(1,data,ones(1,size(data,2)));

%vertical shift for display
S=eye(size(tmp,1));

S(1:(size(tmp,1)-1),end)=(diff(sort(ylim)).*[0:size(tmp,1)-2])'; %typical

tmp=S*tmp;
tmp=tmp(1:end-1,:);
tmp=tmp';


hh=[];
hh=plot(ax, tmp);
if(size(trace_color,1)==size(tmp,2))
    for hh_idx=1:length(hh)
        set(hh(hh_idx),'color',trace_color(hh_idx,:));
    end;
else
    set(hh,'color',trace_color(1,:));
end;
if(length(trace_width)==size(tmp,2))
    for hh_idx=1:length(hh)
        set(hh(hh_idx),'linewidth',trace_width(hh_idx));
    end;
else
    set(hh,'linewidth',trace_width(1));
end;



%range
set(ax,'ylim',[min(ylim)-0.5 max(ylim)+0.5+(size(data,1)-2)*diff(sort(ylim))]);
set(ax,'xlim',[1 time_duration]);

%xticks
% set(ax,'xtick',round([0:5]./5.*time_duration)+1);
% xx=(round([0:5]./5.*time_duration))./fs;
% set(ax,'xticklabel',cellstr(num2str(xx')));
set(ax,'xticklabel','');

%yticks
ytick_full=diff(sort(ylim)).*[0:(size(data,1)-1)-1];
ytick_select=[1:ytick_dec:length(ytick_full)];
ytick_names=[];
for y_idx=1:length(ytick_select)
    ytick_names{y_idx}=names{ytick_select(y_idx)}(1:ytick_char);
end;

if(isempty(ytick_names))
    ytick_names=names;
end;

set(ax,'ytick',ytick_full(ytick_select));
set(ax,'yticklabels',ytick_names);
set(ax,'TickLabelInterpreter','none');

%scale plot
xx=round(max(get(gca,'xlim')).*1.03);
xx2=round(max(get(gca,'xlim')).*1.025);
yy=max(get(gca,'ylim'));
h=line([xx xx],[yy-abs(diff(ylim)) yy]);
set(h,'color','k');
h2=text(xx2,yy-abs(diff(ylim))/2,num2str(abs(diff(ylim))));
set(h2,'color','k','fontname','helvetica','fontsize',20,'horizontal','right');

xx=round(max(get(gca,'xlim')).*1.03);
yy=max(get(gca,'ylim'));
yy2=max(get(gca,'ylim'));
h=line([xx xx+time_duration./20],[yy yy]);
set(h,'color','k');
h2=text(xx+time_duration./40,yy2+100,num2str(time_duration./20/fs));
set(h2,'color','k','fontname','helvetica','fontsize',20,'horizontal','center');


%font style
set(ax,'fontname','helvetica','fontsize',12);
set(ax,'color','w')

set(ax,'ydir','reverse');
set(ax,'clipping','off');
set(gcf,'pos',[   700         700        2400         800]);
etc_plotstyle;