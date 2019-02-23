function eeg_update_montage(montage,varargin)

global etc_trace_obj;

flag_add_bcg=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'ch_names'
            etc_trace_obj.ch_names=option_value;
        case 'flag_add_bcg'
            flag_add_bcg=option_value;
        otherwise
            fprintf('unkown option [%s].\nerror!\n',option);
            return;
    end;
end;

try
    %montage=[];
    %load(sprintf('%s/%s',pathname,filename));
    %load(filename);
    
    for midx=1:length(montage)
        found=0;
        if(isfield(etc_trace_obj,'montage'))
            for ii=1:length(etc_trace_obj.montage)
                if(strcmp(etc_trace_obj.montage{ii}.name,montage{midx}.name))
                    found=1;
                end;
            end;
        end;
        if(~found)
            if(~isfield(etc_trace_obj,'montage'))
                etc_trace_obj.montage{1}=montage{midx};
            else
                etc_trace_obj.montage{end+1}=montage{midx};
            end;
            %creating montage matrix
            M=[];
            ecg_idx=[];
            for idx=1:size(etc_trace_obj.montage{end}.config,1)
                m=zeros(1,length(etc_trace_obj.ch_names));
                if(~isempty(etc_trace_obj.montage{end}.config{idx,1}))
                    m(find(strcmp(lower(etc_trace_obj.ch_names),lower(etc_trace_obj.montage{end}.config{idx,1}))))=1;
                    if((strcmp(lower(etc_trace_obj.montage{end}.config{idx,1}),'ecg')|strcmp(lower(etc_trace_obj.montage{end}.config{idx,1}),'ekg')))
                        ecg_idx=union(ecg_idx,idx);
                    end;
                end;
                if(~isempty(etc_trace_obj.montage{end}.config{idx,2}))
                    m(find(strcmp(lower(etc_trace_obj.ch_names),lower(etc_trace_obj.montage{end}.config{idx,2}))))=-1;;
                    if((strcmp(lower(etc_trace_obj.montage{end}.config{idx,2}),'ecg')|strcmp(lower(etc_trace_obj.montage{end}.config{idx,2}),'ekg')))
                        ecg_idx=union(ecg_idx,idx);
                    end;
                end;
                M=cat(1,M,m);
            end;
            
            if(flag_add_bcg)
                M(end+1,end+1)=1;
            end;
            
            etc_trace_obj.montage{end}.config_matrix=M;
            
            S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
            S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
            etc_trace_obj.scaling{end+1}=S;
        end;
    end;
    
    str={};
    for midx=1:length(etc_trace_obj.montage)
        str{midx}=etc_trace_obj.montage{midx}.name;
    end;
    
catch ME
end;