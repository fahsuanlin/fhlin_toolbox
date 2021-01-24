function etc_connect_show(connect_matrix,varargin)
% etc_connect_show  show connectivity calculation
%
% etc_connect_show(connect_matrix,[option1, option_value1, option2,
% option_value2, ...]);
%
% connect_matrix: a N-by-N matrix for N-node connection
%               rows will be "destination" nodes
%               columns will be "source" nodes
% fhlin@dec 28 2006
%

node_name={};
flag_path_value=1;

connect_color_min=[];
connect_color_max=[];
connect_arrow_size=1;

text_color=[0 0 0];
bg_color=[1 1 1].*0.5;
node_color=[0 0 1];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'node_name'
            node_name=option_value;
        case 'flag_path_value'
            flag_path_value=option_value;
        case 'connect_color_max'
            connect_color_max=option_value;
        case 'connect_color_min'
            connect_color_min=option_value;
        case 'connect_arrow_size'
            connect_arrow_size=option_value;
        case 'node_color'
            node_color=option_value;
        case 'text_color'
            text_color=option_value;
        case 'bg_color'
            bg_color=option_value;
        otherwise
            fprintf('no option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

%check size of connectivity matrix
[n1,n2]=size(connect_matrix);
if(n1~=n2)
    fprintf('non-square connectivity matrix!\nerror!\n');
    return;
end;
n=n1;

%node names
if(isempty(node_name))
    for i=1:n
        node_name{i}=sprintf('node %d',i);
    end;
elseif(length(node_name)~=n)
    fprintf('names for nodes do not match connectivity matrix size!\n');
    fprintf('generating default node names...\n');
    for i=1:n
        node_name{i}=sprintf('node %d',i);
    end;
end;


r=10;

for i=1:n
    x(i)=r*cos(2.*pi.*i./n);
    y(i)=r*sin(2.*pi.*i./n);
end;


for i=1:n
    h=plot(x(i),y(i),'.'); set(h,'color',node_color); hold on;
    h=text(x(i)*1.1,y(i).*1.1,node_name{i});  set(h,'interp','none');
    rotation_angle=atan2(y(i),x(i)).*180./pi;
    flag_r=0;
    if(rotation_angle>90|rotation_angle<-90)
        rotation_angle=rotation_angle-180;
        flag_r=1;
    end;
    set(h,'rotation',rotation_angle,'color',text_color);
    if(flag_r)
        set(h,'HorizontalAlignment','r');
    else
        set(h,'HorizontalAlignment','l');
    end;
end;

rr=1;

%for i=1:n
%    for j=1:n
[dummy,idx]=sort(connect_matrix(:));
for ii=1:length(idx)
    [i,j]=ind2sub(size(connect_matrix),idx(ii));

    if(i~=j)
        aa=atan2(y(j)-y(i),x(j)-x(i));

        %default color for arrows
        connect_color=[1 1 1].*0.6;
        if((~isempty(connect_color_min))&(~isempty(connect_color_max)))
            if(connect_matrix(j,i)>connect_color_min)
                connect_color=inverse_get_color(autumn,connect_matrix(j,i),connect_color_max,connect_color_min);
                colormap(autumn);
            end;
        end;
        plot_arrow(x(i)+rr*2*cos(20/180*pi+aa),y(i)+rr*2*sin(20/180*pi+aa),x(j)+rr*cos(-20/180*pi+aa+pi),y(j)+rr*sin(-20/180*pi+aa+pi),'color',connect_color,'linewidth',1.5,'facecolor',connect_color,'edgecolor',connect_color,'flag_fixed_size',1,'fixed_size',connect_arrow_size);
        if(flag_path_value)
            if(connect_matrix(j,i)>connect_color_min)
                path_str=sprintf('%2.2f',connect_matrix(j,i));
                h=text((x(j)+rr*cos(-20/180*pi+aa+pi))*0.4+(x(i)+rr*cos(20/180*pi+aa))*0.6, (y(j)+rr*sin(-20/180*pi+aa+pi))*0.4+(y(i)+rr*sin(20/180*pi+aa))*0.6,path_str);
                rotation_angle=aa.*180./pi;
                flag_r=0;
                if(rotation_angle>90|rotation_angle<-90)
                    rotation_angle=rotation_angle-180;
                    flag_r=1;
                end;
                set(h,'rotation',rotation_angle,'interp','none','hori','center','color',text_color);
            end;
        end;
    end;
end;
%    end;
%end;

axis off image; set(gca,'xlim',[-r*1.5 r*1.5]); set(gca,'ylim',[-r*1.5 r*1.5]);
set(gca,'color',bg_color);
set(gcf,'color',bg_color);




