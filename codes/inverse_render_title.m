function inverse_render_title(title,varargin)

if(nargin==2)
	ax=varargin{1};
else
	ax=gca;
end;

xx=get(ax,'xlim');
my=max(get(ax,'ylim'));
mz=max(get(ax,'zlim'));
mx=mean(xx);
h=text(mx,my,mz,title);
set(h,'color',[1 1 1]);

