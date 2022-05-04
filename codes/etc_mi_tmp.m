function [mi, mi_corr, prob_a, prob_b, prob_ab, edge_a, edge_b]=etc_mi(roi_a,roi_b,varargin)
%   etc_mi      calculate the empirical mutual information
%
%   [mi, mi_corr, prob_a, prob_b, prob_ab, edge_a, edge_b]=etc_mi(roi_a,roi_b,n_bin);
%
%   roi_a: 1D data for ROI(A)
%   roi_b: 1D data for ROI(B)
%   n_bin: the number of bins in histogram counting
%
%   mi: the mutual information between ROI(A) and ROI(B)
%   mi_corr: the corrected mutual information between ROI(A) and ROI(B)
%   using correction (Ref: Neuron, volumn 51(3), pp 1-10, 2006.)
%   prob_a: the marginal probability of ROI(A);
%   prob_b: the marginal probability of ROI(B);
%   prob_ab: the joint probability between ROI(A) and ROI(B);
%   edge_a: the boundaries of the histogram in ROI(A)
%   edge_b: the boundaries of the histogram in ROI(B)
%
%   fhlin@jan. 1 2009
%

edge_a=[];
edge_b=[];
edges=[];
n_bin=5;

flag_display=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_bin'
            n_bin=option_value;
        case 'edges'
            edges=option_value;
        case 'edge_a'
            edge_a=option_value;
        case 'edge_b'
            edge_b=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            fprintf('error!\n');
            return;
    end;
end;


roi_a=roi_a(:);
roi_b=roi_b(:);

if(~isempty(edges))
    edge_a=edges{1};
    edge_b=edges{2};
end;

%empirical histogram/probability
if(isempty(edge_a))
    max_a=max(roi_a); min_a=min(roi_a); 
    %max_a=inf; min_a=-inf;
    %step_a=(max_a-min_a)/(n_bin-2-1); edge_a=(min_a-step_a)+[0:n_bin-1].*step_a;
    step_a=(max_a-min_a)/(n_bin); edge_a=(min_a)+[0:n_bin-1].*step_a; edge_a(1)=edge_a(1)-step_a; edge_a(end)=edge_a(end)+step_a;
    %step_a=(max_a-min_a)/(n_bin-1); edge_a=(min_a-step_a)+[0:n_bin-1].*step_a;
else
    n_bin=length(edge_a(:))-1;
end;

if(isempty(edge_b))
    max_b=max(roi_b); min_b=min(roi_b); 
    %max_b=inf; min_b=-inf;
    %step_b=(max_b-min_b)/(n_bin-2-1); edge_b=(min_b-step_b)+[0:n_bin-1].*step_b;
    step_b=(max_b-min_b)/(n_bin); edge_b=(min_b)+[0:n_bin-1].*step_b; edge_b(1)=edge_b(1)-step_b; edge_b(end)=edge_b(end)+step_b;
else
    n_bin=length(edge_b(:))-1;
end;


hist_a=histc(roi_a,edge_a);
hist_b=histc(roi_b,edge_b);

hist_ab=zeros(n_bin,n_bin);
for ii=1:length(edge_b)
    if(ii~=length(edge_b))
        idx=find((roi_b>=edge_b(ii))&(roi_b<edge_b(ii+1)));
    else
        idx=find(roi_b==edge_b(ii));
    end;
    %keyboard;
    if(~isempty(idx))
        tmp=histc(roi_a(idx),edge_a);
        %hist_ab(:,ii)=tmp(1:end-1);
        hist_ab(:,ii)=tmp(1:end);
    end;
end;
prob_ab=hist_ab./length(roi_a);
prob_a=hist_a./length(roi_a);
prob_b=hist_b./length(roi_b);


%calculating mutual information
mi=0;
for idx_a=1:size(prob_ab,1)
    for idx_b=1:size(prob_ab,2)
        if(prob_a(idx_a)>0&prob_b(idx_b)>0&prob_ab(idx_a,idx_b)>0)
            mi=mi+prob_ab(idx_a,idx_b)*log(prob_ab(idx_a,idx_b)/prob_a(idx_a)/prob_b(idx_b));
        end;
    end;
end;
mi_corr=mi-length(prob_a)/2/length(roi_a)/log(2); %corrected for histogram; Neuron, volumn 51(3), pp 1-10, 2006.

return;
