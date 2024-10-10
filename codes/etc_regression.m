function [p, r2, beta,h]=etc_regression(x,y,varargin)
%
% etc_regression     linear regression 
%
% [p, r2, beta]=etc_regression(x,y,[option,optoin_value])
%
% x: 1D vector of independent variable
% y: 1D vector of dependent variable
% 
% fhlin@jan 3 2020
%

flag_display=1;
flag_display_data=1;
flag_display_regline=1;
flag_display_regline_text=1;

label_sep=1;

p=[];
r2=[];
beta=[];
w=[];
color=[];
linecolor=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'flag_display_data'
            flag_display_data=option_value;
        case 'flag_display_regline'
            flag_display_regline=option_value;
        case 'flag_display_regline_text'
            flag_display_regline_text=option_value;
        case 'color'
            color=option_value;
        case 'linecolor'
            linecolor=option_value;
        case 'w'
            w=option_value;
        case 'label_sep'
            label_sep=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

y=y(:);
x=x(:);

D=[ones(length(x),1),x(:)];
if(isempty(w))
    W=ones(length(y(:)),1);
else
    W=w(:);
end;

tmp=(repmat(W,[1,size(D,2)]).*D);
beta=inv(D'*tmp)*D'*(W.*y);
res=y-D*beta;
r2=1-(res'*res)./((y-mean(y))'*(y-mean(y)));

SS_total=((y-mean(y))'*(y-mean(y)));
SS_regression=(D*beta-mean(y))'*(D*beta-mean(y));
SS_error=res'*res;
F=(SS_regression./1)/(SS_error/(length(y(:))-2));
p=1-fcdf(F,1,(length(y(:))-2));

h=[];
if(flag_display)
    if(isempty(color))
        color='k';
    end;
    

    % Normally distributed sample points:
    % Bin the data:
%     pts_x = linspace(min(x), max(x), 31);
%     pts_y = linspace(min(y), max(y), 31);
%     N = histcounts2(y(:), x(:), pts_y, pts_x);
%     %h=pcolor(pts_x(1)+cumsum(diff(pts_x)),pts_y(1)+cumsum(diff(pts_y)), N);
%     hp=pcolor(pts_x(1:end-1), pts_y(1:end-1), N); hold on;
%     set(hp,'edgecolor','none','facealpha',0.3)

    if(flag_display_data)
        h(end+1)=plot(x(:),y(:),'.'); hold on;
        set(h(end),'color',color);

        hh=scatplot(x(:),y(:)); hold on; %scattered plot with density!! 
        colorbar off;
        %densityScatterChart(x(:),y(:), 'UseColor', true, 'UseAlpha', true);
        %h(end+1)=gca;
    end;

    reg_x=[min(x) max(x)]';
    reg_y=beta(1)+beta(2).*reg_x; 

    if(flag_display_regline)
        if(isempty(linecolor))
            linecolor='k';
        end;
        h(end+1)=line(reg_x,reg_y); set(h(end),'color',linecolor,'linewidth',2);
    end;
    if(flag_display_regline_text)
        h(end+1)=text((max(x)+min(x))/2,min(y)+(max(y)+min(y))/4,sprintf('Y=%2.2f+%2.2f X',beta(1),beta(2))); set(h(end),'fontname','helvetica','fontsize',14);
        h(end+1)=text((max(x)+min(x))/2,min(y)+(max(y)+min(y))/4*0.9.*label_sep,sprintf('(R^2=%1.2f; p=%4.3f)',r2,p)); set(h(end),'fontname','helvetica','fontsize',14);
        set(gca,'fontname','helvetica','fontsize',14);
    end;

end;
