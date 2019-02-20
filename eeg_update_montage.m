function eeg_update_montage(montage)

global etc_trace_obj;

try
    %montage=[];
    %load(sprintf('%s/%s',pathname,filename));
    %load(filename);
    
    for idx=1:length(montage)
        found=0;
        for ii=1:length(etc_trace_obj.montage)
            if(strcmp(etc_trace_obj.montage{ii}.name,montage{idx}.name))
                found=1;
            end;
        end;
        if(~found)
            etc_trace_obj.montage{end+1}=montage{idx};
            
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
            M(end+1,end+1)=1;
            
            etc_trace_obj.montage{end}.config_matrix=M;
            
            S=eye(size(etc_trace_obj.montage{end}.config,1)+1);
            S(ecg_idx,ecg_idx)=S(ecg_idx,ecg_idx)./10;
            etc_trace_obj.scaling{end+1}=S;
        end;
    end;
    
    str={};
    for idx=1:length(etc_trace_obj.montage)
        str{idx}=etc_trace_obj.montage{idx}.name;
    end;
    
catch ME
end;