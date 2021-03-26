function [points ch_names]=etc_read_hspfile(file_name,varargin)

points=[];
ch_name={};


target_str='//Sensor name';

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
    %disp(tline);
    tmp = fgetl(fid);
    tline{count} = tmp;
    count=count+1;

end
fclose(fid);

idx=find(~cellfun(@isempty,cellfun(@(x) strfind(x,target_str), tline,'UniformOutput',0)));

for ii=1:length(idx)
    [tmp1 tmp2]=textscan(tline{idx(ii)+1},'%s %s');
    ch_names{ii}=tmp1{2}{1};
    
    tmp = str2num(tline{idx(ii)+2});
    points(ii,1)=tmp(1);
    points(ii,2)=tmp(2);
    points(ii,3)=tmp(3);
end;


return;
