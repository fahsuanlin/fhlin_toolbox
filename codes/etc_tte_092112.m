function [prob_joint,TTE,TreeRoot,M,M_num,M_den,P]=etc_tte(ROI,n_bin,prob_joint,varargin)
%   etc_tte      calculate the empirical temporary transfer entropy
%
%   [joint_prob, TTE, Tree]=etc_tte(roi_a,roi_b,n_bin,joint_prob);
%
%   roi_a: 1D data for ROI(A)
%   roi_b: 1D data for ROI(B)
%   n_bin: the number of bins in histogram counting
%   joint_prob: the joint probability distribution
%
%   fhlin@jan. 1 2009
%

TreeRoot=[];
flag_display=0;
delta_p=0.01;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'treeroot'
            TreeRoot=option_value;
        case 'delta_p'
            delta_p=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

for d_idx=1:size(ROI,2)
    [v]=sort(ROI(:,d_idx));
    max_roi(d_idx)=v(floor(length(v).*0.95));
    min_roi(d_idx)=v(ceil(length(v).*0.05));
    step_roi(d_idx)=(max_roi(d_idx)-min_roi(d_idx))/(n_bin); edge_roi(:,d_idx)=min_roi(d_idx)+step_roi(d_idx).*[0:n_bin];
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

if(ndims(ROI)==2)
    [ ClosestPtIndex, DistB, TreeRoot ] = kdtreeidx([], ROI, TreeRoot);
elseif(ndims(ROI)==3)
    for idx=1:size(ROI,2)
        R(:,idx)=reshape(ROI(:,idx,:),[size(ROI,1)*size(ROI,3),1]);
    end;
    [ ClosestPtIndex, DistB, TreeRoot ] = kdtreeidx([], R, TreeRoot);

    ClosestPtIndex=reshape(ClosestPtIndex,[size(ROI,1),size(ROI,3)]);
end;

M=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);
M_den=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);
M_num=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);
P=zeros([n_bin,n_bin,n_bin,size(ROI,1)]);

for t_idx=1:size(ROI,1)
    hist_roi=zeros(n_bin.*ones(1,size(ROI,2)));

    if(ndims(ROI)==2)
        hist_roi(ClosestPtIndex(t_idx))=hist_roi(ClosestPtIndex(t_idx))+1;
    elseif(ndims(ROI)==3)
        for r_idx=1:size(ClosestPtIndex,2)
            hist_roi(ClosestPtIndex(t_idx,r_idx))=hist_roi(ClosestPtIndex(t_idx,r_idx))+1;
        end;
    end;
    
    %update
    prob_joint0=prob_joint;
%    prob_joint=prob_joint./(1+delta_p.*size(ROI,3))+hist_roi.*delta_p./(1+delta_p.*size(ROI,3));
    hist_roi=hist_roi./size(ROI,3);
    if(~isempty(prob_joint))
        prob_joint=prob_joint./(1+delta_p)+hist_roi.*delta_p./(1+delta_p);
    else
        prob_joint=ones(n_bin,n_bin,n_bin)./n_bin^3./(1+delta_p)+hist_roi.*delta_p./(1+delta_p);
    end;

    P(:,:,:,t_idx)=prob_joint;
    
    %end of joint probability calculation

    prob_12=sum(prob_joint,3); %marginal prob. of (1,2)
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
return;
