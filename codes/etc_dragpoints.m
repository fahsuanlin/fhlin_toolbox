function etc_dragpoints(point_coords,ax)
% figure;
% x = xData;
% y = yData;
% 
% ax = axes('xlimmode','manual','ylimmode','manual');
% ax.XLim = [xLower xUpper];
% ax.YLim = [yLower yUpper];

%can change the marker size or marker type to make it more visible.
%Currently is set to small points at a size of 2 so is not very visible.
%line(x,y,'marker','.','markersize',2,'hittest','on','buttondownfcn',@clickmarker)
h=plot3(point_coords(:,1),point_coords(:,2),point_coords(:,3),'marker','.','markersize',2,'hittest','on','buttondownfcn',@clickmarker);

function clickmarker(src,ev)
set(ancestor(src,'figure'),'windowbuttonmotionfcn',{@dragmarker,src})
set(ancestor(src,'figure'),'windowbuttonupfcn',@stopdragging)

function dragmarker(fig,ev,src)

%get current axes and coords
h1=gca;
coords=get(h1,'currentpoint');

%get all x and y data 
x=h1.Children.XData;
y=h1.Children.YData;

%check which data point has the smallest distance to the dragged point
x_diff=abs(x-coords(1,1,1));
y_diff=abs(y-coords(1,2,1));
[value index]=min(x_diff+y_diff);

%create new x and y data and exchange coords for the dragged point
x_new=x;
y_new=y;
x_new(index)=coords(1,1,1);
y_new(index)=coords(1,2,1);

%update plot
set(src,'xdata',x_new,'ydata',y_new);

function stopdragging(fig,ev)
set(fig,'windowbuttonmotionfcn','')
set(fig,'windowbuttonupfcn','')