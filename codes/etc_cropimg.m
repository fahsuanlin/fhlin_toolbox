function [img_crop,rect]=etc_cropimg(filename,varargin)
% etc_cropimg      crop image boundary automatically
% etc_cropimg(filename,[option1, option_value1,...])
%
%
% options:
%
%
% fhlin@jul 1 2020
%

img_crop=[];
rect=[];

flag_replace=0;
flag_display=1;
flag_show=1;
flag_save=0;
flag_auto_boundary=1;
input_img={};

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_replace'
            flag_replace=option_value;        
        case 'flag_show'
            flag_show=option_value;        
        case 'flag_save'
            flag_save=option_value;    
        case 'flag_auto_boundary'
            flag_auto_boundary=option_value;
        case 'flag_display'
            flag_display=option_value;  
        case 'input_img'
            input_img=option_value;
        case 'rect'
            rect=option_value;
        otherwise
            fprintf('no option [%s]. error!\n',option);
            return;
    end;
end;

if(~isempty(filename))
    if(~iscell(filename))
        tmp{1}=filename;
        filename=tmp;
    end;
end;

n_img=0;
if(~isempty(filename))
    for c_idx=1:length(filename)
        if(flag_display)
            fprintf('loading [%s]...\n',filename{c_idx});
        end;
        try
            [input_img{n_img+1},map]= imread(filename{c_idx});
            %img=double(img);
        catch ME
            fprintf('error in loading file [%s]!\n',filename{c_idx});
            return;
        end;
        n_img=n_img+1;
    end;
else
    n_img=length(input_img);
    map=hsv;
end;

for c_idx=1:n_img
    img=input_img{c_idx};
    if(isempty(rect))
        imgs=sum(img,3);
        imgy=min(imgs,[],2);
        imgx=min(imgs,[],1);
        if(flag_auto_boundary)
            boundary_value_x=max(imgx(:));
        else
            boundary_value_x=255*3; %pure white
        end;
        idxx=sort(find(imgx<boundary_value_x));
        idxx_1=idxx(1);
        idxx_2=idxx(end);
        if(flag_auto_boundary)
            boundary_value_y=max(imgy(:));
        else
            boundary_value_y=255*3; %pure white
        end;
        idxy=sort(find(imgy<boundary_value_y));
        idxy_1=idxy(1);
        idxy_2=idxy(end);
    else
        idxx_1=rect(1);
        idxx_2=rect(2);
        idxy_1=rect(3);
        idxy_2=rect(4);
    end;
    
    if(flag_display)
        fprintf('cropping...\n');
    end;
    img_crop=img(idxy_1:idxy_2,idxx_1:idxx_2,:);

    rect=[idxx_1,idxx_2,idxy_1,idxy_2];
    
    if(flag_show)
        image(img(idxy_1:idxy_2,idxx_1:idxx_2,:));
    end;
    
    if(~isempty(map))
        colormap(map);
    end;
    axis off image;
    
    if(~isempty(filename))
        [dummy,fstem,fext]=fileparts(filename{c_idx});
        if(flag_replace)
            fn=sprintf('%s%s',fstem,fext);
        else
            fn=sprintf('%s_crop%s',fstem,fext);
        end;
        
        if(flag_save)
            if(isempty(map))
                if(flag_display)
                    fprintf('saving [%s]...\n',fn);
                end;
                imwrite(img(idxy_1:idxy_2,idxx_1:idxx_2,:),fn);
            else
                if(flag_display)
                    fprintf('saving [%s]...\n',fn);
                end;
                imwrite(img(idxy_1:idxy_2,idxx_1:idxx_2,:),map,fn);
            end;
        end;
    end;
end;

return;