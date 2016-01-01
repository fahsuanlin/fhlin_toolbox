function inverse_plot(data,channel,varargin)
% inverse_plot	plot data in subplots
%
% inverse_plot(data,channel,[title])
% 
% data: 2D matrix (c*t) for c channels and t timepoints
% channel: a 1D vector of indicating rows of data to be drawn
% title: the title to be shown
%
% fhlin@oct 2, 2002

d=data(channel,:);

ti=[];
if(length(varargin)>0)
	ti=varargin{1};
end;

for i=1:size(d,1)
	subplot(size(d,1),1,i);
	plot(d(i,:));
	axis tight off;
end;

% showing title
if(~isempty(ti))
	ax=axes('Units','Normal','Position',[.075 .075 .85 .85],'Visible','off');
	set(get(ax,'Title'),'Visible','on')
	title(ti);
	h=get(ax,'Title');
end;