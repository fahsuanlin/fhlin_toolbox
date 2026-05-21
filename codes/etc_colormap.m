function cmap=etc_colormap(threshold,varargin)

h=gca;
width_L=[];
mode='both'; %'pos','neg','both'

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'h'
            h=option_value;
        case 'width_l'
            width_L=option_value;
        case 'mode'
            mode=option_value;
        otherwise
            fprintf('unknown option [%s].\neerror!\n',option);
            return;
    end;
end;

if(isempty(width_L))
    %width_L=128*min(threshold)./(abs(diff(threshold)));
    width_L=round(2*min(threshold)/abs(diff(threshold))*64);
end;

switch(mode)
    case 'both'
        %colormap: default +/- values with red/blue colors;
        a1=ones(1,64);
        a0=ones(1,ceil(width_L));
        ag=linspace(0,1,64);
        rr=[a1,a0,fliplr(ag)];
        gg=[ag,a0,fliplr(ag)];
        bb=[ag,a0,a1];
        cmap=flipud([rr(:),gg(:),bb(:)]);
        colormap(h,cmap);
        set(h,'clim',[-max(abs(threshold)) max(abs(threshold))]);

    case 'pos'
        cmap_color=autumn(64);
        cmap_nocolor=ones(width_L,3);
        cmap=cat(1,flipud(cmap_color),cmap_nocolor,cmap_color);
        colormap(h,cmap);
        set(h,'clim',[-max(abs(threshold)) max(abs(threshold))]);


    case 'neg'
        cmap_color=cool(64);
        cmap_nocolor=ones(width_L,3);
        cmap=cat(1,flipud(cmap_color),cmap_nocolor,cmap_color);
        colormap(h,cmap);
        set(h,'clim',[-max(abs(threshold)) max(abs(threshold))]);
end;
