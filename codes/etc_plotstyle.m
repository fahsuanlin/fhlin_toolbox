function []=etc_plotstyle(varargin)
% etc_plotstyle      apply the plot style settings
%
% etc_plotstyle([option1, option_value1,...])
%
%
% options:
%
%
% fhlin@mar 19 2020
%

figure_handel=[];
axis_handel=[];
linewidth=2; %line width
fontname='helvetica';
fontsize=20;
figure_color='w';
axis_color='w';

MarkerSize=16;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'figure_handel'
            figure_handel=option_value;
        case 'axis_handel'
            axis_handel=option_value;
        case 'linewidth'
            linewidth=option_value;
        case 'fontname'
            fontname=option_value;
        case 'fontsize'
            fontsize=option_value;
        case 'figure_color'
            figure_color=option_value;
        case 'axis_color'
            axis_color=option_value;
        case 'markersize'
            MarkerSize=option_value;
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;
end;

if(isempty(figure_handel))
    figure_handel=gcf;
end;

if(isempty(axis_handel))
    axis_handel=get(figure_handel,'child');
end;

set(figure_handel,'color',figure_color);

for ax_idx=length(axis_handel):-1:1
%    set(axis_handel(ax_idx),'color',axis_color,'fontname',fontname,'fontsize',fontsize);
    set(axis_handel(ax_idx),'fontname',fontname,'fontsize',fontsize);
end;

for ax_idx=length(axis_handel):-1:1
    h=get(axis_handel(ax_idx),'child');
    for i=1:length(h)
        if(isprop(h(i),'MarkerSize'))
            set(h(i),'MarkerSize',MarkerSize);
        end;
    end;
end;
return;
