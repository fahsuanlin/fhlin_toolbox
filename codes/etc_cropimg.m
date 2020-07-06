function img_crop=etc_cropimg(filename,varargin)
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

flag_replace=0;
flag_display=1;
flag_show=1;
flag_save=0;

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
        case 'flag_display'
            flag_display=option_value;        
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

for c_idx=1:length(filename)
    if(flag_display)
        fprintf('loading [%s]...\n',filename{c_idx});
    end;
    try
        [img,map]= imread(filename{c_idx});
        %img=double(img);
    catch ME
        fprintf('error in loading file [%s]!\n',filename{c_idx});
        return;
    end;
    imgs=sum(img,3);
    imgy=min(imgs,[],2);
    imgx=min(imgs,[],1);
    idxx=sort(find(imgx<255*3));
    idxx_1=idxx(1);
    idxx_2=idxx(end);
    idxy=sort(find(imgy<255*3));
    idxy_1=idxy(1);
    idxy_2=idxy(end);
    
    if(flag_display)
        fprintf('cropping...\n');
    end;
    img_crop=img(idxy_1:idxy_2,idxx_1:idxx_2,:);

    if(flag_show)
        image(img(idxy_1:idxy_2,idxx_1:idxx_2,:));
    end;
    
    if(~isempty(map))
        colormap(map);
    end;
    axis off image;
    
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

return;