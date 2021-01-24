function bar=inverse_colorbar(ax,th,varargin)
% inverse_colorbar	add color bar on the inverse figure
%
% inverse_colorbar(ax,th,[colormap]);
%
% ax: the axis to attach the colorbar;
% th: 2-element vector of the threshold, which was used to generated the figure;
% colormap: 3*M matrix for the colormap
%
% fhlin@sep. 08, 2002

	cmap=hot(128);
	cmap=cmap(49:128,:);
	cmap=autumn(80);

	if(nargin==3)
		cmap=varargin{1};
	end;
	
	pos=get(ax,'pos');
	hcolor=axes('pos',pos);
	set(hcolor,'visible','off');
	%set(get(ax,'parent'),'colormap',cmap);
	set(ax,'colormap',cmap);
	bar=colorbar(hcolor);
    set(bar,'pos',[0 0 1 0.1]);
	set(bar,'xcolor',[1,1,1]);

	xtick=get(bar,'xtick');
	for i=1:length(xtick)-1

		label=sprintf('%1.1e',(max(th)-min(th))/(length(xtick))*i+min(th));
		h=text(abs(diff(get(bar,'xlim')))/length(xtick)*i,mean(get(bar,'ylim')),label);
		set(h,'color',[0 0 0]);
		set(h,'HorizontalAlignment','center');
		set(h,'VerticalAlignment','middle');
	end;


