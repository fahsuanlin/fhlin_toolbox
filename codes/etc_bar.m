function [h_bar,h_errrorbar]=etc_bar(x,y,e,varargin)
order=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)        
        case 'order'
            order=option_value;
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;
end;


h_bar = bar(x, y, 'grouped');


if(~isempty(order))
    cc=colororder;
    for b_idx=1:length(h_bar)
        h_bar(b_idx).FaceColor=cc(order(b_idx),:);
    end;
end;

hold on
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(y);
% Get the x coordinate of the bars
xx = nan(nbars, ngroups);
for i = 1:nbars
    xx(i,:) = h_bar(i).XEndPoints;
end
% Plot the errorbars
errorbar(xx',y,e,'k','linestyle','none');
hold off
 
etc_plotstyle;

return;
hold on;
h_errorbar=errorbar(center, y, e);
set(h_errorbar(1),'linewidth',1);            % This changes the thickness of the errorbars
set(h_errorbar(1),'color','k');              % This changes the color of the errorbars
set(h_errorbar(2),'linestyle','none');       % This removes the connecting

return;
