function [chname,chid,x,y,z]=etc_read_datfile(file_name,varargin)

points=[];


%target_str='//No of rows';

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch(lower(option))
        case 'target_str'
            target_str=option_Value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option);
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%
fid = fopen(file_name);
count=1;

tline{count} = fgetl(fid);
tmp=tline{count};
count=count+1;

while ischar(tmp)
    %disp(tmp);
    dd=textscan(tmp, '%s%d%f%f%f', 'EmptyValue', Inf);
    for ii=1:length(dd)
        if(~iscell(dd{ii}))
            if(isempty(dd{ii}))
                dd=textscan(tmp, '%d%f%f%f', 'EmptyValue', Inf);
            end;
        end;
    end;

    if(length(dd)==5)
        chname{count-1}=dd{1}{1};
        chid(count-1)=dd{2};
        x(count-1)=dd{3};
        y(count-1)=dd{4};
        z(count-1)=dd{5};        
    else
        chname{count-1}='';
        chid(count-1)=dd{1};
        x(count-1)=dd{2};
        y(count-1)=dd{3};
        z(count-1)=dd{4};         
    end;
    
    tmp = fgetl(fid);
    tline{count} = tmp;
    count=count+1;
    
end
fclose(fid);

% idx=find(~cellfun(@isempty,cellfun(@(x) strfind(x,target_str), tline,'UniformOutput',0)));
% 
% tmp = str2num(tline{idx+1});
% n_points=tmp(1);
% n_dim=tmp(2);
% 
% for ii=1:n_points
%     tmp = str2num(tline{idx+ii+1});
%     points(ii,1)=tmp(1);
%     points(ii,2)=tmp(2);
%     points(ii,3)=tmp(3);
% end;

return;


return;
