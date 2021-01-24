function [prob_joint,TE,TreeRoot, max_roi, min_roi, step_roi, edge_roi]=etc_mi_nd(ROI,varargin)
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
n_bin=[];
edges=[];

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
        case 'n_bin'
            n_bin=option_value;
        case 'edges'
            edges=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;



if(~isempty(n_bin))
    [hist_roi,edge_roi]=histcn(ROI,n_bin,n_bin,n_bin);
elseif(~isempty(edges))
    [hist_roi,edge_roi]=histcn(ROI,edges{1},edges{2},edges{3});
    n_bin=length(edges{1});
else
    fprintf('error! neiterh [n_bin] nor [edges] was specified!\n');
    return;
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
