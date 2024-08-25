function [on_target, on_target_efield, on_target_x, auc]=etc_tms_on_target(efield, source, varargin)

on_target=[];
on_target_efield=[];
on_target_x=[];
auc=[];
roc_x=[];
roc_y=[];

source_mask=[];

flag_roc=0;
flag_display=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'source_mask'
            source_mask=option_value;
        case 'flag_roc'
            flag_roc=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

if(size(efield)~=size(source))
    error('size for efield and source must be the same!\n');
    return;
end;

if(~isempty(source_mask))
    if(size(efield)~=size(source_mask))
        error('size for efield and source_mask must be the same!\n');
        return;
    end;
else
    source_mask=[1:length(efield)];
end;

source_idx=find(source_mask);

efield_now=efield(source_idx);
efield_now=efield_now./max(efield_now);
        
source_now=source(source_idx);
source_now_idx=find(source_now);

e_r=[0.2:0.01:0.99];
for idx=1:length(e_r)
    e_idx=find(efield_now>e_r(idx));
    ll=intersect(source_now_idx,e_idx);
    on_target(idx)=length(ll)./length(source_now_idx); %proportion of the detected source 
    on_target_efield(idx)=length(ll)./length(e_idx); %proportion of the e-field that is the source 
end;
on_target_x=e_r(:);

on_target=on_target(:);
on_target_efield=on_target_efield(:);

if(flag_roc)
    [roc_x,roc_y,auc]=etc_roc(efield(source_idx),source(source_idx),'flag_display',0);
end;
