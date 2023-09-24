function [chname,x,y,z]=etc_read_posfile(file_name,varargin)

points=[];


%target_str='//No of rows';

n_headerline=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'n_headerline'
            n_headerline=option_value;
        case 'target_str'
            target_str=option_Value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option);
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%
fid = fopen(file_name);
if(~isempty(n_headerline))
    for l_idx=1:n_headerline
        fgetl(fid);
    end;
end;
count=1;

tline{count} = fgetl(fid);
tmp=tline{count};
count=count+1;

while ischar(tmp)
    try
    flag_ok=0;
    
    if(~flag_ok)
        flag_ok=1;
        type_id=1;
        dd=textscan(tmp, '%d%s%f%f%f', 'EmptyValue', Inf);
        for ii=1:length(dd)
            if(isempty(dd{ii})) flag_ok=0; end;
        end;
    end;
    
    if(~flag_ok)
        flag_ok=1;
        type_id=2;
        dd=textscan(tmp, '%d%f%f%f', 'EmptyValue', Inf);
        for ii=1:length(dd)
            if(isempty(dd{ii})) flag_ok=0; end;
        end;
    end;
    
    if(~flag_ok)
        flag_ok=1;
        type_id=3;
        dd=textscan(tmp, '%s%f%f%f', 'EmptyValue', Inf);
        for ii=1:length(dd)
            if(isempty(dd{ii})) flag_ok=0; end;
        end;
    end;
    
    
    switch(type_id)
        case 1
            if(iscell(dd{2}))
                chname{count-1}=dd{2}{1};
            else
                chname{count-1}=dd{2};
            end;
            x(count-1)=dd{3};
            y(count-1)=dd{4};
            z(count-1)=dd{5};
        case 2
            chname{count-1}='';
            x(count-1)=dd{2};
            y(count-1)=dd{3};
            z(count-1)=dd{4};
        case 3
            if(iscell(dd{1}))
                chname{count-1}=dd{1}{1};
            else
                chname{count-1}=dd{1};
            end;
            x(count-1)=dd{2};
            y(count-1)=dd{3};
            z(count-1)=dd{4};
    end;
    
    tmp = fgetl(fid);
    tline{count} = tmp;
    count=count+1;
    
    catch
        tmp
        keyboard;
    end;
    
end
fclose(fid);

return;
