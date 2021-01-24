function [TTE,prob_joint,edges]=etc_tte(ROI,varargin)
%   etc_tte      calculate the empirical temporary transfer entropy
%
%   [TTE,prob_joint,edges]=etc_tte([roi_a(:) roi_b(:)]);
%
%   roi_a: 1D data for ROI(A)
%   roi_b: 1D data for ROI(B)
%
%   fhlin@jan. 1 2009
%   fhlin@oct. 28 2012
%

flag_display=0;
delta_p=0.001;
edges=[];
TTE=[];
prob_joint=[];
baseline_idx=[];
n_bin=[];
t_integrate=1;

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
        case 'to_history'
            to_history=option_value;
        case 'from_history'
            from_history=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


if(isempty(n_bin))
    n_bin=length(edges{1})-1;
end;

data(1:size(ROI,1)-1,1)=ROI(2:end,1);
data(1:size(ROI,1)-1,2)=ROI(1:end-1,1);
data(1:size(ROI,1)-1,3)=ROI(1:end-1,2);

M=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);
M_den=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);
M_num=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);
P=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);

if(isempty(prob_joint))
    if(isempty(baseline_idx))
        baseline_idx=[1:size(data,1)];
        
        if(~isempty(edges))
            [hist_roi]=histcn(data,edges{1},edges{2},edges{3});
        else
            [hist_roi,edges]=histcn(data,n_bin,n_bin,n_bin);
        end;
    else
        fprintf('cannot determine baseline joint probabilty distribution! error!\n');
        return;
    end
end;

for t_idx=1:size(data,1)-t_integrate+1
    if(flag_display) if(mod(t_idx,1000)==0) fprintf('<%1.1f%%>....\r',t_idx./size(data,1).*100); end; end;
    hist_roi=zeros(n_bin.*ones(1,size(data,2)));

    if(~isempty(t_integrate))
        dd=data(t_idx:t_idx+t_integrate-1,:);
        dd(:,[2 3])=repmat(dd(1,[2 3]),[size(dd,1),1]);
    else
        
    end
    
    if(~isempty(edges))
        %[hist_roi]=histcn(data(t_idx,:),edges{1},edges{2},edges{3});
        [hist_roi]=histcn(dd,edges{1},edges{2},edges{3});
    else
        %[hist_roi]=histcn(data(t_idx,:),n_bin,n_bin,n_bin);
        [hist_roi]=histcn(dd,n_bin,n_bin,n_bin);
    end;
    
    %update
    prob_joint0=prob_joint;
    %hist_roi=hist_roi./size(data,3);
    hist_roi=hist_roi./size(dd,1);
    if(~isempty(prob_joint))
        prob_joint=prob_joint./(1+delta_p)+hist_roi.*delta_p./(1+delta_p);
    else
        prob_joint=ones(n_bin,n_bin,n_bin)./n_bin^3./(1+delta_p)+hist_roi.*delta_p./(1+delta_p);
    end;

    P(:,:,:,t_idx)=prob_joint;
    
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
    tmp=zeros(size(prob_joint));
    tmp(idx)=num(idx)./den(idx);
    M_num(:,:,:,t_idx)=num;
    M_den(:,:,:,t_idx)=den;
    M(:,:,:,t_idx)=tmp;
	TTE(t_idx)=sum(xx(:));
end;
%fprintf('\n');
return;
