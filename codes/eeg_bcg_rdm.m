function [eeg_bcg, cluster_bases_by_run]=eeg_bcg_rme(eeg,fs,varargin)

%recurrent dynamics modeling


%defaults
% flag_eeg_dyn=1;
% flag_eeg_dyn_svd=1;
% flag_ecg_dyn=1;
% flag_auto_hp=0;
% flag_display=0;
% flag_avoid_extreme=0;
% nn=[];
% n_ecg=[]; %search the nearest -n_ecg:+n_ecg; 10 is a good number; consider how this interacts with 'nn'
% dyn_duration_idx=round(fs/2); %duration (in samples; # samples in 0.5 s by default) of dyanmics to be examined; this will be the temporal range in feature definition
% 
% flag_reg=0;
flag_dec=1;
fs_dec=50; %Hz;


block_sec=1.0; %s
block_step_sec=0.1; %s
min_cluster_size=10;

flag_avoid_extreme=1;

flag_dyn_hp=1;
dyn_hp_hz=0.5;


eeg_bcg=[];
eeg_bcg_pred=[];

cluster_bases_by_run={}; %empty kernel will trigger the kernel estimation

%check=[];
%n_svd=[];

eeg_process=[];
bad_ints=[];
bad_ints_process={};


cfg=struct( ...
    'name','dme_shared_eoonly_badtrain_svdsubK30_nsvd2_g1p25', ...
    'n_cluster',30, ...
    'n_feat_svd',3, ...
    'n_template_svd',2, ...
    'block_sec',1.0, ...
    'block_step_sec',0.1, ...
    'min_cluster_size',10, ...
    'flag_avoid_extreme',1, ...
    'flag_dyn_hp',1, ...
    'dyn_hp_hz',0.5, ...
    'flag_exclude_bad_train',1, ...
    'flag_exclude_bad_apply',1, ...
    'flag_leave_run_out',0, ...
    'ridge_lambda',0, ...
    'subtract_gain',1.25, ...
    'pred_rms_cap',0, ...
    'template_mode','svd');


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
%         case 'flag_reg'
%             flag_reg=option_value;
%         case 'flag_auto_hp'
%             flag_auto_hp=option_value;
        case 'flag_avoid_extreme'
            flag_avoid_extreme=option_value;
%         case 'flag_eeg_dyn'
%             flag_eeg_dyn=option_value;
%         case 'flag_eeg_dyn_svd'
%             flag_eeg_dyn_svd=option_value;
%         case 'flag_ecg_dyn'
%             flag_ecg_dyn=option_value;
%         case 'dyn_duration_idx'
%             dyn_duration_idx=option_value;
%         case 'nn'
%             nn=option_value;
%         case 'n_ecg'
%             n_ecg=option_value;
%         case 'n_svd'
%             n_svd=option_value;
        case 'eeg_process'
            eeg_process=option_value;
        case 'flag_dec'
            flag_dec=option_value;
        case 'fs_dec'
            fs_dec=option_value;
        case 'bad_ints'
            bad_ints=option_value;
        case 'bad_ints_process'
            bad_ints_process=option_value;
        case 'cluster_bases_by_run'
            cluster_bases_by_run=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            fprintf('error!\n');
            return;
    end;
end;

if(isempty(eeg_process))
    %apply RDM to the input EEG data.
    eeg_process{1}=eeg;
end;

if(isempty(bad_ints_process))
    %bad intervals adopted for the input EEG data.
    bad_ints_process{1}=bad_ints;
end;

%----------------------------
% BCG start;
%----------------------------
% hha=[];
% hh1=[];
% ha=[];
% h1=[];
% hb=[];
% h2=[];

eeg_orig=eeg;
eeg_process_orig=eeg_process;
flag_upsample=0;
if(flag_dec)
    if(fs_dec<fs)
        decim_factor=round(fs/fs_dec);
        fprintf('down sampling from [%1.0f] Hz to [%1.0f] Hz...\n', fs, fs_dec);

        eeg_dec=zeros(size(eeg,1),ceil(size(eeg,2)./decim_factor));
        for ch_idx=1:size(eeg,1)
            tmp=filtfilt(ones(decim_factor,1)./decim_factor,1,eeg(ch_idx,:));
            eeg_dec(ch_idx,:)=tmp(1:decim_factor:end);
        end
        for e_idx=1:length(eeg_process)
            for ch_idx=1:size(eeg,1)
                tmp=filtfilt(ones(decim_factor,1)./decim_factor,1,eeg_process{e_idx}(ch_idx,:));
                eeg_process_dec{e_idx}(ch_idx,:)=tmp(1:decim_factor:end);
            end
        end;
        eeg_process=eeg_process_dec;

        eeg=eeg_dec;
        fs=fs_dec;

        flag_upsample=1;
    else
    end;
else
end;
%now EEG has been decimated, if any


block_len_idx=max(1,round(block_sec.*fs_dec));
block_step_idx=max(1,round(block_step_sec.*fs_dec));


n_run=numel(eeg_process);
n_ch=size(eeg,1);
train_blocks=[];
apply_blocks=[];
all_blocks=[];

n_t=size(eeg,2);
starts=1:block_step_idx:(n_t-block_len_idx+1);
if(starts(end)~=n_t-block_len_idx+1), starts(end+1)=n_t-block_len_idx+1; end

%prepare block indices for RDM kernel estimation
r_idx=1; %index for the kernel estimation data
for s_idx=1:numel(starts)
    if(cfg.flag_exclude_bad_train && block_overlaps_bad(starts(s_idx),block_len_idx,fs,bad_ints))
        continue;
    end
    q=starts(s_idx):(starts(s_idx)+block_len_idx-1);
    all_blocks=cat(3,all_blocks,eeg(:,q)); %#ok<AGROW>
    train_blocks(end+1,:)=[r_idx,starts(s_idx)]; %#ok<SAGROW>
end


%prepare block indices for RDM kernel application
for r_idx=1:n_run
    n_t=size(eeg_process{r_idx},2);
    starts=1:block_step_idx:(n_t-block_len_idx+1);
    if(starts(end)~=n_t-block_len_idx+1), starts(end+1)=n_t-block_len_idx+1; end
    for s_idx=1:numel(starts)
        if(cfg.flag_exclude_bad_apply && block_overlaps_bad(starts(s_idx),block_len_idx,fs,bad_ints_process{r_idx}))
            continue;
        end
        apply_blocks(end+1,:)=[r_idx,starts(s_idx)]; %#ok<SAGROW>
    end
end


n_block=size(all_blocks,3);
if(n_block<1), error('No training blocks survived bad-interval exclusion.'); end
n_cluster=min(cfg.n_cluster,n_block);

%kernel estimation data
eeg_dyn_runs=eeg;
if(cfg.flag_dyn_hp)
    wn=cfg.dyn_hp_hz./(fs./2);
    if(wn>0 && wn<1)
        [bb,aa]=butter(4,wn,'high');
        for ch_idx=1:n_ch
            eeg_dyn_runs(ch_idx,:)=filtfilt(bb,aa,eeg_dyn_runs(ch_idx,:));
        end
    end
end


%kernel application data
apply_eeg_dyn_runs=eeg_process;
if(cfg.flag_dyn_hp)
    wn=cfg.dyn_hp_hz./(fs./2);
    if(wn>0 && wn<1)
        [bb,aa]=butter(4,wn,'high');
        for r_idx=1:n_run
            for ch_idx=1:n_ch
                apply_eeg_dyn_runs{r_idx}(ch_idx,:)=filtfilt(bb,aa,eeg_process{r_idx}(ch_idx,:));
            end
        end
    end
end



[~,s_idx]=sort(sum(abs(eeg),1));
if(cfg.flag_avoid_extreme)
    keep_idx=s_idx(1:round(length(s_idx).*0.9));
    [uu,~,~]=svd(eeg(:,keep_idx),'econ');
else
    [uu,~,~]=svd(eeg,'econ');
end
n_feat_svd=min(cfg.n_feat_svd,size(uu,2));


feat=zeros(n_block,block_len_idx.*n_feat_svd);
for svd_idx=1:n_feat_svd
    cols=(svd_idx-1).*block_len_idx+(1:block_len_idx);
    for b_idx=1:n_block
        start_idx=train_blocks(b_idx,2);
        q=start_idx:(start_idx+block_len_idx-1);
        dd=uu(:,svd_idx)'*eeg_dyn_runs;
        x=dd(q);
        x=x-mean(x,'omitnan');
        sx=std(x,'omitnan');
        if(sx>0), x=x./sx; end
        feat(b_idx,cols)=x;
    end
end

opts=statset('MaxIter',200,'Display','off');
[cluster_id,cluster_ctr]=kmeans(feat,n_cluster,'Distance','sqeuclidean','Replicates',3,'Options',opts);

n_apply_block=size(apply_blocks,1);
apply_feat=zeros(n_apply_block,block_len_idx.*n_feat_svd);
for svd_idx=1:n_feat_svd
    cols=(svd_idx-1).*block_len_idx+(1:block_len_idx);
    for b_idx=1:n_apply_block
        r_idx=apply_blocks(b_idx,1);
        start_idx=apply_blocks(b_idx,2);
        q=start_idx:(start_idx+block_len_idx-1);
        dd=uu(:,svd_idx)'*apply_eeg_dyn_runs{r_idx};
        x=dd(q);
        x=x-mean(x,'omitnan');
        sx=std(x,'omitnan');
        if(sx>0), x=x./sx; end
        apply_feat(b_idx,cols)=x;
    end
end
cluster_id_apply=knnsearch(cluster_ctr,apply_feat);

all_blocks_basis=all_blocks;
[cluster_bases_all,cluster_sizes]=make_cluster_bases(all_blocks_basis,cluster_id,train_blocks,n_ch,n_cluster,cfg,[]);
if(isempty(cluster_bases_by_run)) %only estimate kernels when it's not provided.
    cluster_bases_by_run=cell(n_run,1);
    for r_idx=1:n_run
        if(cfg.flag_leave_run_out && any(train_idx==r_idx))
            cluster_bases_by_run{r_idx}=make_cluster_bases(all_blocks_basis,cluster_id,train_blocks,n_ch,n_cluster,cfg,r_idx);
        else
            cluster_bases_by_run{r_idx}=cluster_bases_all;
        end
    end
end;


eeg_bcg=cell(size(eeg_process));
wacc_runs=cell(size(eeg_process));
for r_idx=1:n_run
    eeg_bcg{r_idx}=zeros(size(eeg_process{r_idx}));
    wacc_runs{r_idx}=zeros(1,size(eeg_process{r_idx},2));
end
taper=hann(block_len_idx)';
if(all(taper==0)), taper=ones(1,block_len_idx); end

for b_idx=1:n_apply_block
    r_idx=apply_blocks(b_idx,1);
    start_idx=apply_blocks(b_idx,2);
    q=start_idx:(start_idx+block_len_idx-1);
    c_idx=cluster_id_apply(b_idx);
    cluster_bases=cluster_bases_by_run{r_idx};
    for ch_idx=1:n_ch
        y=eeg_process{r_idx}(ch_idx,q)';
        bases=cluster_bases{ch_idx,c_idx};
        if(strcmp(cfg.template_mode,'mean') || strcmp(cfg.template_mode,'median'))
            pred=bases;
        else
            lambda=cfg.ridge_lambda;
            beta=(bases'*bases+lambda.*eye(size(bases,2)))\(bases'*y);
            pred=bases*beta;
        end
        if(cfg.pred_rms_cap>0)
            pred_rms=sqrt(mean(pred.^2));
            y_rms=sqrt(mean(y.^2));
            max_pred_rms=cfg.pred_rms_cap.*y_rms;
            if(pred_rms>max_pred_rms && pred_rms>0)
                pred=pred.*(max_pred_rms./pred_rms);
            end
        end
        clean=y-cfg.subtract_gain.*pred;
        eeg_bcg{r_idx}(ch_idx,q)=eeg_bcg{r_idx}(ch_idx,q)+(clean'.*taper);
    end
    wacc_runs{r_idx}(q)=wacc_runs{r_idx}(q)+taper;
end

for r_idx=1:n_run
    good=wacc_runs{r_idx}>eps;
    for ch_idx=1:n_ch
        eeg_bcg{r_idx}(ch_idx,good)=eeg_bcg{r_idx}(ch_idx,good)./wacc_runs{r_idx}(good);
    end
    eeg_bcg{r_idx}(:,~good)=eeg_process{r_idx}(:,~good);
end

if(flag_upsample)
    fprintf('up sampling by [%1.0f] fold...\n', decim_factor);
    for r_idx=1:numel(eeg_process_orig)
        eeg_up=zeros(size(eeg_process_orig{r_idx}));
        for ch_idx=1:size(eeg_bcg{r_idx},1)
            tmp=interp(eeg_bcg{r_idx}(ch_idx,:),decim_factor);
            eeg_up(ch_idx,:)=tmp(1:size(eeg_process_orig{r_idx},2));
        end
        eeg_bcg{r_idx}=eeg_up;
    end
end

if(flag_display) fprintf('BCG RDM correction done!\n'); end;

end

function tf=block_overlaps_bad(start_idx,block_len_idx,fs,bad_ints)
if(isempty(bad_ints))
    tf=false;
    return;
end
t1=(start_idx-1)./fs;
t2=(start_idx+block_len_idx-1)./fs;
tf=any(t1<bad_ints(:,2) & t2>bad_ints(:,1));
end


function [cluster_bases,cluster_sizes]=make_cluster_bases(all_blocks_basis,cluster_id,train_blocks,n_ch,n_cluster,cfg,exclude_run)
n_block=size(all_blocks_basis,3);
keep=true(n_block,1);
if(~isempty(exclude_run))
    keep=train_blocks(:,1)~=exclude_run;
    if(~any(keep))
        keep=true(n_block,1);
    end
end

global_bases=cell(n_ch,1);
for ch_idx=1:n_ch
    x=block_matrix(all_blocks_basis,ch_idx,find(keep));
    global_bases{ch_idx}=template_from_blocks(x,cfg);
end

cluster_sizes=zeros(1,n_cluster);
cluster_bases=cell(n_ch,n_cluster);
for c_idx=1:n_cluster
    members=find(cluster_id==c_idx & keep);
    cluster_sizes(c_idx)=numel(members);
    for ch_idx=1:n_ch
        if(numel(members)>=cfg.min_cluster_size)
            x=block_matrix(all_blocks_basis,ch_idx,members);
            cluster_bases{ch_idx,c_idx}=template_from_blocks(x,cfg);
        else
            cluster_bases{ch_idx,c_idx}=global_bases{ch_idx};
        end
    end
end
end

function tmpl=template_from_blocks(x,cfg)
if(strcmp(cfg.template_mode,'mean'))
    tmpl=mean(x,2,'omitnan');
elseif(strcmp(cfg.template_mode,'median'))
    tmpl=median(x,2,'omitnan');
else
    [u,~,~]=svd(x,'econ');
    tmpl=u(:,1:min(cfg.n_template_svd,size(u,2)));
end
end

function x=block_matrix(all_blocks_basis,ch_idx,members)
x=squeeze(all_blocks_basis(ch_idx,:,members));
if(isvector(x))
    x=x(:);
elseif(size(x,1)~=size(all_blocks_basis,2))
    x=x';
end
end

