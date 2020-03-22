function [p, r2, beta]=etc_regression(x,y,varargin)
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

p=[];
r2=[];
beta=[];
w=[];
color=[];

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
        case 'w'
            w=option_value;
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

if(flag_display)
    if(isempty(color))
        color='k';
    end;
    
    if(flag_display_data)
        plot(x(:),y(:),'.'); hold on;
    end;
    reg_x=[min(x) max(x)]';
    reg_y=beta(1)+beta(2).*reg_x; 

    if(flag_display_regline)
        h=line(reg_x,reg_y); set(h,'color',color,'linewidth',2);
    end;
    if(flag_display_regline_text)
        h=text((max(x)+min(x))/2,min(y)+(max(y)+min(y))/4,sprintf('Y=%2.2f+%2.2f X',beta(1),beta(2))); set(h,'fontname','helvetica','fontsize',14);
        h=text((max(x)+min(x))/2,min(y)+(max(y)+min(y))/4*0.9,sprintf('(R^2=%1.2f; p=%4.3f)',r2,p)); set(h,'fontname','helvetica','fontsize',14);
        set(gca,'fontname','helvetica','fontsize',14);
    end;
%    set(gca,'xlim',[0.050 0.500],'ylim',[4 6])
%    h=xlabel('MEG TTP (s)'); set(h,'fontname','helvetica','fontsize',14);
%    h=ylabel('fMRI TTP (s)'); set(h,'fontname','helvetica','fontsize',14);

end;
