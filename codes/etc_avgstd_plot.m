function []=etc_avgstd_plot(avg,std,varargin)
% etc_avgstd_plot      plot the average and stanadard deviation of data
% into a line and a shade
%
% etc_avgstd_plot(avg,std,[option1, option_value1,...])
%
% avg: 1D vector of the average
% std: 1D vector of the standard deviation
%
% options:
%
% x=[]; %define abscissa 
% std_alpha=0.5; %transparency of the std shade
% color=[]; %color of average line and std shade
% flag_overlay=1; %flag to overlay the plot over the current figure
%
% fhlin@mar 19 2020
%

x=[]; %define absicca
std_alpha=0.3; %transparency of the std shade
color=[]; %color of average line and std shade
flag_overlay=1; %flag to overlay the plot over the current figure

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'x'
            x=option_value;
        case 'std_alpha'
            std_alpha=option_value;
        case 'color'
            color=option_value;
        case 'flag_overlay'
            flag_overlay=option_value;
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;
end;

%define abscissa 
if(isempty(x))
    x=[1:length(avg)];
end;

%choose color
if(isempty(color))
    colorOrder = get(gca, 'ColorOrder');
    color=colorOrder(mod(length(get(gca, 'Children')), size(colorOrder, 1))+1, :);
end;

%%%%%%%%%%%%%%%%%%%%%%%
% plot the figure
if(~flag_overlay) %generate a new plot
    figure;
else
    figure(gcf);
end;
hold on;

%std shade area
h=fill([x(:)' fliplr(x(:)')],[avg(:)'+std(:)' fliplr(avg(:)'-std(:)')],color, 'FaceAlpha', std_alpha,'linestyle','none');
%average line
h=plot(x(:)',avg(:)','linewidth',1.5);
set(h,'color',color);

return;




