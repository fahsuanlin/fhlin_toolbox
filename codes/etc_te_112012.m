function [te2to1, te1to2,edges]=etc_te(ROI, edges, varargin)

TE2to1=[];
TE1to2=[];
pval2to1=[];
pval1to2=[];



flag_display=1;
flag_self_information_latency=1;
flag_mutual_information_latency=1;

n_repeat=1e3; %number of permutation in null distribution estimation
n_delay=[1]; %latency of time series 
n_bin=2;    %the number of bin in the histogram calculation

source_history=[];
target_future=[];

edges=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_repeat'
            n_repeat=option_value;
        case 'n_delay'
            n_delay=option_value;
        case 'n_bin'
            n_bin=option_value;
        case 'edges'
            edges=option_value;
       case 'flag_self_information_latency'
            flag_self_information_latency=option_value;
        case 'flag_mutual_information_latency'
            flag_mutual_information_latency=option_value;
        case 'source_history'
            source_history=option_value;
        case 'target_future'
            target_future=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;

if(isempty(edges))
    [dummy,e1]=histcn(ROI(:,1),n_bin);
    [dummy,e2]=histcn(ROI(:,2),n_bin);
    edges{1}=e1{1};
    edges{2}=e2{1};
end;

prob_joint=histcn([ROI(2:end,1) ROI(1:end-1,1) ROI(1:end-1,2);],edges{1},edges{1},edges{2});
prob_joint1=prob_joint./sum(prob_joint(:));

prob_joint=histcn([ROI(2:end,2) ROI(1:end-1,2) ROI(1:end-1,1);],edges{2},edges{2},edges{1});
prob_joint2=prob_joint./sum(prob_joint(:));

te2to1=te(prob_joint1);
te1to2=te(prob_joint2);

return;

function xx=te(prob_joint);
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
xx=sum(log(num(idx)./den(idx)).*prob_joint(idx));
return

return;
