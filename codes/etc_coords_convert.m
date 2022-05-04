function output=etc_coords_convert(input,box,varargin)

input=round(input);

flag_display=1;
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
    case 'flag_display'
        flag_display=option_value;
    otherwise
        fprintf('unknown option [%s]...\n', option);
        fprintf('error!\n');
        return;
    end;
end;
    
        
     



%get the number of rows/columns for montage
if(box(3)==1)
    nn=1;
    mm=1;
else
    nn = sqrt(prod(box))/box(1);
    mm = box(3)/nn;
    if (ceil(nn)-nn) < (ceil(mm)-mm),
        nn = ceil(nn); mm = ceil(box(3)/nn);
    else
        mm = ceil(mm); nn = ceil(box(3)/mm);
    end
end;


if(length(input)==3)
    if(flag_display)
        fprintf('input 3D coordinate: %s (x,y,z)\n',mat2str(input));
        fprintf('box= %s\n',mat2str(box));
    end;
    
    row_image=ceil(input(3)/nn);
    col_image=mod((input(3)-1),nn)+1;
    
    row=(row_image-1)*box(2)+input(2);
    col=(col_image-1)*box(1)+input(1);
    
    output=[col,row];
    
    if(flag_display)
        fprintf('output for 2D: %s (row, col)\n',mat2str(output));
    end;
    
end;

if(length(input)==2)
    if(flag_display)
        fprintf('input 2D coordinate: %s (row col)\n',mat2str(input));
        fprintf('box= %s\n',mat2str(box));
    end;

    sx=ceil(input(1)/box(1));
    sy=ceil(input(2)/box(2));
    
    zz=(sy-1)*nn+sx;
    xx=input(1)-(sx-1)*box(1);
    yy=input(2)-(sy-1)*box(2);
    
    output=[xx,yy,zz];
    
    if(flag_display)
        fprintf('output for 3D: %s (x,y,z)\n',mat2str(output));
    end;
    
end;


return;