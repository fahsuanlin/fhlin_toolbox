function [h_bar,h_errrorbar]=etc_bar(x,y,e)


h_bar = bar(x, y, 'grouped');




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
