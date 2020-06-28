function [TE,prob_joint,edges]=etc_te(ROI,varargin)
%   etc_te      calculate the empirical transfer entropy between two time
%   series
%
%   [TE,prob_joint,edges]=etc_te([roi_a(:) roi_b(:)]);
%
%   roi_a: 1D data for ROI(A)
%   roi_b: 1D data for ROI(B)
%
%   fhlin@jan. 1 2009
%   fhlin@oct. 28 2012
%   fhlin@nov. 20 2012
%

flag_display=0;
delta_p=0.001;
edges=[];
TTE=[];
prob_joint=[];
baseline_idx=[];
n_bin=[];
t_integrate=[];

to_history=1;
from_history=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'treeroot'
            TreeRoot=option_value;
        case 'delta_p'
            delta_p=option_value;
        case 'edges'
            edges=option_value;
        case 'prob_joint'
            prob_joint=option_value;
        case 'baseline_idx'
            baseline_idx=option_value;
        case 'n_bin'
            n_bin=option_value;
        case 't_integrate'
            t_integrate=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'to_history'
            to_history=option_value;
        case 'from_history'
            from_history=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


if(isempty(n_bin))
    n_bin=length(edges{1})-1;
end;

if(~isempty(t_integrate))
    data=[];
    data0=[];
    for t_idx=1:t_integrate
        data0(1:size(ROI,1)-t_integrate,1)=ROI(1+t_idx:end-t_integrate+t_idx,1);
        data0(1:size(ROI,1)-t_integrate,2)=ROI(1:end-t_integrate,1);
        data0(1:size(ROI,1)-t_integrate,3)=ROI(1:end-t_integrate,2);
        data=cat(1,data0,data);
    end;
else
    
    warning off;
    mat_to=toeplitz(eye(to_history+1).*nan,[1 ROI(:,1)']);
    mat_from=toeplitz(eye(from_history+1).*nan,[1 ROI(:,2)']);
    warning on;
    
    data=[];
    for to_history_idx=1:to_history
        for from_history_idx=1:from_history
            xx=cat(1,mat_to(1,:),mat_to(to_history_idx+1,:),mat_from(from_history_idx+1,:));
            idx=max(to_history_idx+1, from_history_idx+1);
            data=cat(1,data,xx(:,idx:end)');
        end;
    end;
end;

if(isempty(prob_joint))
    if(isempty(baseline_idx))
        baseline_idx=[1:size(data,1)];
    end;
    if(~isempty(edges))
        [hist_roi]=histcn(data(baseline_idx,:),edges{1},edges{2},edges{3});
    else
        [hist_roi,edges]=histcn(data(baseline_idx,:),n_bin,n_bin,n_bin);
    end;
end;

dd=data;

if(~isempty(edges))
    %[hist_roi]=histcn(data(t_idx,:),edges{1},edges{2},edges{3});
    [hist_roi]=histcn(dd,edges{1},edges{2},edges{3});
else
    %[hist_roi]=histcn(data(t_idx,:),n_bin,n_bin,n_bin);
    [hist_roi]=histcn(dd,n_bin,n_bin,n_bin);
end;


prob_joint=hist_roi./size(data,1);
%end of joint probability calculation

prob_12=sum(prob_joint,3); %marginal prob. of p(1,2)
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
return;
