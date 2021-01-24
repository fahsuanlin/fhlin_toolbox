function [h_bar,h_errrorbar]=etc_bar(x,y,e)


h_bar = bar(x, y, 'grouped');
xdata = get(h_bar, 'XData');
ydata = get(h_bar ,'YData');

% Determine number of bars
sizz = size(y);
nb = sizz(1)*sizz(2);
xb = [];
yb = [];
for i = 1:2,
    xb = [xb xdata{i,1}];
    yb = [yb ydata{i,1}];
end;

% To find the center of each bar - need to look at the output vectors xb, yb
% find where yb is non-zero - for each bar there is a pair of non-zero yb values.
% The center of these values is the middle of the bar

nz = find(yb);
for i = 1:nb,
    center(i) = (xb(nz(i*2))-xb(nz((i*2)-1)))/2 + xb(nz((i*2)-1));
end;

% To place the error bars - use the following:


hold on;
h_errorbar=errorbar(center, y, e);
set(h_errorbar(1),'linewidth',1);            % This changes the thickness of the errorbars
set(h_errorbar(1),'color','k');              % This changes the color of the errorbars
set(h_errorbar(2),'linestyle','none');       % This removes the connecting

return;