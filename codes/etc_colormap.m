function cmap=etc_colormap(threshold,varargin)

h=gca;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'h'
            h=option_value;
        otherwise
            fprintf('unknown option [%s].\neerror!\n',option);
            return;
    end;
end;


width_L=128*min(threshold)./(abs(diff(threshold)));

%colormap
a1=ones(1,64);
a0=ones(1,ceil(width_L));
ag=linspace(0,1,64);
rr=[a1,a0,fliplr(ag)];
gg=[ag,a0,fliplr(ag)];
bb=[ag,a0,a1];
cmap=flipud([rr(:),gg(:),bb(:)]);

colormap(h,cmap); 
set(h,'clim',[-max(abs(threshold)) max(abs(threshold))]);