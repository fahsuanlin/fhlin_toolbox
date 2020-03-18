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
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;
end;

if(isempty(figure_handel))
    figure_handel=gcf;
end;

if(isempty(axis_handel))
    axis_handel=gca;
end;

set(figure_handel,'color',figure_color);

set(axis_handel,'color',axis_color,'fontname',fontname,'fontsize',fontsize);
