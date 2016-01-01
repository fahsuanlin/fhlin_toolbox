function [prob_joint,TE,TreeRoot, max_roi, min_roi, step_roi, edge_roi]=etc_mi_nd(ROI,n_bin,varargin)
%   etc_mi      calculate the empirical mutual information
%
%   [prob_joint,TE,TreeRoot, max_roi, min_roi, step_roi, edge_roi]=etc_mi_nd(ROI,n_bin);
%
%   ROI: 2D data for time series of [x(t+1) x(t) and y(t)], size is n-by-3
%   with n time points.
%   n_bin: the number of bins in histogram counting
%
%   prob_joint: joint probability density function: n_bin-by-n_bin-by-n_bin
%   TE: transfer entropy from y(t) -> x(t)
%   TreeRoot: root tree for joint PDF estimation, required by "kdtree"
%   process
%   max_roi: maximum of [x(t+1) x(t) y(t)];
%   min_roi: minimum of [x(t+1) x(t) y(t)]
%   step_roi: step sizes for [x(t+1) x(t) y(t)] histogram/PDF estimation
%   edge_roi:  edges for [x(t+1) x(t) y(t)] histogram/PDF estimation
%
%   fhlin@jan. 1 2009
%

TreeRoot=[];
min_roi=[];
max_roi=[];
edge_roi=[];
step_roi=[];
flag_display=0;
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'treeroot'
            TreeRoot=option_value;
        case 'edge_roi'
            edge_roi=option_value;
        case 'step_roi'
            step_roi=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

if(isempty(edge_roi))
    for d_idx=1:size(ROI,2)
        [v]=sort(ROI(:,d_idx));
        max_roi(d_idx)=v(floor(length(v).*0.95));
        min_roi(d_idx)=v(ceil(length(v).*0.05));
        step_roi(d_idx)=(max_roi(d_idx)-min_roi(d_idx))/(n_bin); edge_roi(:,d_idx)=min_roi(d_idx)+step_roi(d_idx).*[0:n_bin];
    end;
else
    min_roi=min(edge_roi,[],1);
    max_roi=max(edge_roi,[],1);
    step_roi=mean(diff(edge_roi,1));
end;

if(isempty(TreeRoot))
    if(flag_display) fprintf('preparing tree...\n'); end;
    cmd_left='[';
    for d_idx=1:size(ROI,2)
        cmd_left=strcat(cmd_left,sprintf('X%d',d_idx));
        if(d_idx~=size(ROI,2))
            cmd_left=strcat(cmd_left,',');
        else
            cmd_left=strcat(cmd_left,']');
        end;
    end;
    cmd_right='ndgrid(';
    for d_idx=1:size(ROI,2)
        cmd_right=strcat(cmd_right,sprintf('edge_roi(1:end-1,%d)+step_roi(%d)/2',d_idx,d_idx));
        %    cmd_right=strcat(cmd_right,sprintf('edge_roi(:,%d)',d_idx));
        if(d_idx~=size(ROI,2))
            cmd_right=strcat(cmd_right,',');
        else
            if(size(ROI,2)==1)
                cmd_right=strcat(cmd_right,',1);');
            else
                cmd_right=strcat(cmd_right,');');
            end;
        end;
    end;
    eval(sprintf('%s=%s;',cmd_left,cmd_right));

    cmd_rr='reference_data=[';
    for d_idx=1:size(ROI,2)
        cmd_rr=strcat(cmd_rr,sprintf('X%d(:)',d_idx));
        if(d_idx~=size(ROI,2))
            cmd_rr=strcat(cmd_rr,',');
        else
            cmd_rr=strcat(cmd_rr,'];');
        end;
    end;
    eval(cmd_rr);

    [tmp, tmp, TreeRoot] = kdtree( reference_data, []);
end;

[ ClosestPtIndex, DistB, TreeRoot ] = kdtreeidx([], ROI, TreeRoot);

hist_roi=zeros(n_bin.*ones(1,size(ROI,2)));
for data_idx=1:size(ROI,1)
    %    hist_roi(ClosestPtIndex(data_idx))=hist_roi(ClosestPtIndex(data_idx))+1;
    hist_roi(ClosestPtIndex(data_idx))=hist_roi(ClosestPtIndex(data_idx))+1;
end;

prob_joint=hist_roi./size(ROI,1);

%end of joint probability calculation

prob_12=sum(prob_joint,3); %marginal prob. of (1,2)
TE=0;
method_2=1;
if(method_2)
    %p(1|2,3)
    tmp=repmat(sum(prob_joint,1),[size(prob_joint,1),1,1]);
    num=zeros(size(prob_joint));
    idx=find(tmp(:));
    num(idx)=prob_joint(idx)./tmp(idx);

    %p(1|2)
    prob_120=repmat(sum(prob_joint,3),[1 1 size(prob_joint,3)]);
    tmp=repmat(sum(prob_120,1),[size(prob_joint,1),1,1]);
    den=zeros(size(prob_joint));
    idx=find(tmp(:));
    den(idx)=prob_120(idx)./tmp(idx);

    idx=find((den(:)>0)&(num(:)>0));
    xx=log(num(idx)./den(idx)).*prob_joint(idx);
    TE=sum(xx(:));

    den0=den;
    num0=num;
else
    for d2_idx=1:size(prob_joint,2)
        for d3_idx=1:size(prob_joint,3)
            %p(1|2,3)
            num=prob_joint(:,d2_idx,d3_idx);
            if(sum(num)>0)
                num=num./sum(num);
            else
                num=zeros(size(num));
            end;
            NUM(:,d2_idx,d3_idx)=num;

            %p(1|2)
            den=prob_12(:,d2_idx);
            if(sum(den)>0)
                den=den./sum(den);
            else
                den=zeros(size(den));
            end;
            DEN(:,d2_idx,d3_idx)=den;

            idx=find(den>0&num>0);
            TE=TE+sum(log(num(idx)./den(idx)).*prob_joint(idx,d2_idx,d3_idx));
        end;
    end;
end;
return;
