function h=etc_plot_z(x,y,z,varargin);
% etc_plot_z    generic plot with signficance background
%
% h=etc_plot_z(x,y,significance_stat)
%
% x: 1D x data vector
% y: 1D y data vector
% significance_stat: 1D significance statistics vector
%
% h: output plot handle
%
% option
%   'threshold': threshold for signficance (default: 10)
%
% fhlinm@Jan 19 2026

threshold=6;

if(size(y,2)==length(x))
    threshold_aux=mean(y,1);
elseif(size(y,1)==length(x))
    threshold_aux=mean(y,2);
end;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'threshold'
            threshold=option_value;
        case 'threshold_aux'
            threshold_aux=option_value;
        otherwise
            fprintf('unknown option [%s]!error!\n',option);
            return;
    end;
end;


f=figure('visible','off');
plot(x,y); ylim=get(gca,'ylim');
close(f);

pos_significant=find(((z>=threshold)&(threshold_aux>0))|((z<=-threshold)&(threshold_aux<0)));
neg_significant=find(((z<=-threshold)&(threshold_aux>0))|((z>=threshold)&(threshold_aux<0)));

figure; hold on;
for i=1:length(pos_significant)
    if(pos_significant(i)==1)
        pos_start=x(1)-(x(2)-x(1))/2;
        pos_end=(x(pos_significant(i))+x(pos_significant(i)+1))/2;
    elseif(pos_significant(i)==length(y))
        pos_start=(x(pos_significant(i))+x(pos_significant(i)-1))/2;
        pos_end=x(end)+(x(end)-x(end-1))/2;
    else
        pos_start=(x(pos_significant(i))+x(pos_significant(i)-1))/2;
        pos_end=(x(pos_significant(i))+x(pos_significant(i)+1))/2;
    end;
    
    h=rectangle('position',[pos_start,min(ylim),pos_end-pos_start,diff(ylim)],'edgecolor','none','facecolor',[.9 .9 1]);
end;

for i=1:length(neg_significant)
    if(neg_significant(i)==1)
        pos_start=x(1)-(x(2)-x(1))/2;
        pos_end=(x(neg_significant(i))+x(neg_significant(i)+1))/2;
    elseif(neg_significant(i)==length(y))
        pos_start=(x(neg_significant(i))+x(neg_significant(i)-1))/2;
        pos_end=x(end)+(x(end)-x(end-1))/2;
    else
        pos_start=(x(neg_significant(i))+x(neg_significant(i)-1))/2;
        pos_end=(x(neg_significant(i))+x(neg_significant(i)+1))/2;
    end;
    
    h=rectangle('position',[pos_start,min(ylim),pos_end-pos_start,diff(ylim)],'edgecolor','none','facecolor',[1 .9 .9]);
end;

h=plot(x,y);
