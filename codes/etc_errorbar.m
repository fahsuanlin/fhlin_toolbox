function [h2,h1]=etc_errorbar(X,Y,E,varargin)

h2=[]; %handle for means
h1=[]; %handle for error bar areas

alpha=0.1;

linestyle='-';

order=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'order'
            order=option_value;
        case 'linestyle'
            linestyle=option_value;
        case 'alpha'
            alpha=option_value;
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;
end;


cc=colororder;
for type_idx=1:size(Y,2)
    y=Y(:,type_idx);
    e=E(:,type_idx);
    
    y_upper=y+e;
    y_lower=y-e;
    

    x_vector = [X(:)', fliplr(X(:)')];
    if(isempty(order))
        h1= fill(x_vector, [y_upper(:)',fliplr(y_lower(:)')], cc(type_idx,:));
    else
        h1= fill(x_vector, [y_upper(:)',fliplr(y_lower(:)')], cc(order,:));    
    end;
    set(h1, 'edgecolor', 'none');
    set(h1, 'FaceAlpha', alpha);
    hold on;
    h2=plot(X(:),y(:));
    if(isempty(order))
        set(h2,'linewidth',2,'color',cc(type_idx,:),'linestyle',linestyle);
    else
        set(h2,'linewidth',2,'color',cc(order,:),'linestyle',linestyle);
    end;
end;