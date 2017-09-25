function [efficiency, param]=fmri_design_efficiency(design, hrf, varargin);


efficiency=[];
param=[];

flag_display=1;


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch option
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
para_time=[];
para_type=[];
para_duration=[];
para_name=[];

if(isempty(design.param))
    if(flag_display) fprintf('generating paradigm...\n'); end;
    [design_param,ON]=etc_param_min_isi(design.t_step, design.min_isi, design.n_trial, design.duration);
    idx=find(design_param);
    idx=idx(randperm(length(idx)));

    n=floor(design.n_trial/length(design.rv));

    for ii=1:length(design.rv)-1
        design_param(idx((ii-1)*n+1:ii*n))=design.rv(ii);
    end;
    ii=ii+1;
    design_param(idx((ii-1)*n+1:end))=design.rv(ii);

    for ii=1:length(design_param)
        for jj=0:round(design.t_step/design.TR)-1
            if(jj==0)
                param((ii-1)*round(design.t_step/design.TR)+jj+1)=design_param(ii);
            else
                param((ii-1)*round(design.t_step/design.TR)+jj+1)=0;
            end;
        end;
    end;
    design.param=param;
else
    if(flag_display) fprintf('calculating the efficiency of a given paradigm...\n'); end;
    param=design.param;
end;

p_t=[0:(length(param)-1)].*design.TR;
p_p=param;
p_d=ones(size(p_t)).*design.TR;
p_n=param;

timepoints=length(p_t);

para_time=[para_time; p_t];
para_type=[para_type; p_p];
para_duration=[para_duration;p_d];
para_name=strvcat(para_name,strvcat(p_n));


if(flag_display)
    fprintf('analyzing paradigms and creating contrast matrix...\n');
end;

%preprocessing of exclude time
exclude_time=design.exclude_time;

contrast_count=0;
paradigm_count=0;
scm_count=0;
for para_count=0:max(para_type)
    idx=find(para_type==para_count);
    if(~isempty(idx))
        intersect_cond=intersect(design.exclude_condition,para_count);
        if(isempty(intersect_cond))
            if(flag_display)
                fprintf('paradigm type [%d] found! [%d] items...\n',para_count,length(idx));
            end;
            
            paradigm_count=paradigm_count+1;

            n_avg(paradigm_count)=length(idx);

            scm_buffer=zeros(timepoints,1);
            scm_buffer(idx)=1;
            if(scm_count==0) scm=zeros(size(scm_buffer)); end;
            scm(:,scm_count+1)=scm_buffer;
            scm_type(scm_count+1)=para_count;
            scm_count=scm_count+1;
            contrast_count=contrast_count+1;
        else
            if(flag_display)
                fprintf('paradigm type [%d] excluded!\n',para_count);
            end;
        end;
    end;
end;



HDR=hrf.hrf;
contrast_hdr=zeros(size(scm,1)+size(HDR,1),size(HDR,2)*contrast_count);
hdr_pre_idx=abs(round(hrf.pre./design.TR));
for c_idx=1:contrast_count
    soa=find(scm(:,c_idx));

    for o_idx=1:length(soa)
        if(soa(o_idx)-hdr_pre_idx>0)
            contrast_hdr(soa(o_idx)-hdr_pre_idx:soa(o_idx)+size(HDR,1)-1-hdr_pre_idx,(c_idx-1)*size(HDR,2)+1:(c_idx-1)*size(HDR,2)+size(HDR,2))=contrast_hdr(soa(o_idx)-hdr_pre_idx:soa(o_idx)+size(HDR,1)-1-hdr_pre_idx,(c_idx-1)*size(HDR,2)+1:(c_idx-1)*size(HDR,2)+size(HDR,2))+HDR;
        else
            contrast_hdr(1:size(HDR,1)-hdr_pre_idx+soa(o_idx)-1,(c_idx-1)*size(HDR,2)+1:(c_idx-1)*size(HDR,2)+size(HDR,2))=contrast_hdr(1:size(HDR,1)-hdr_pre_idx+soa(o_idx)-1,(c_idx-1)*size(HDR,2)+1:(c_idx-1)*size(HDR,2)+size(HDR,2))+HDR(hdr_pre_idx-soa(o_idx)+2:end,:);
        end;
    end;
end;
contrast_hdr=contrast_hdr(1:size(scm,1),:);

tmp=zeros(size(HDR,2),1);
if(~isempty(design.rv))
    c_vec=zeros(length(scm_type)*size(HDR,2),size(HDR,2));
    for rv_idx=1:length(design.rv)
        rv=find(scm_type==design.rv(rv_idx));

        for t_idx=1:size(HDR,2)
            c_vec((rv-1)*size(HDR,2)+t_idx,t_idx)=design.cvec(rv_idx);
        end;
    end;
end;
efficiency=1/trace(c_vec'*inv(contrast_hdr'*contrast_hdr)*c_vec).*100;


if(flag_display)
    fprintf('Efficiency=%2.2f \n', efficiency);
end;

return;

