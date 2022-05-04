function [prob_joint,edge_roi]=etc_jointprob_nd(ROI,varargin)
%   etc_jointprob_nd      calculate the n-dimensional joint probability
%
%   [prob_joint,edges]=etc_jointprob_nd(ROI,n_bin);
%
%   ROI: n-D data for time series size is m-by-n
%   with m time points.
%   n_bin: the number of bins in histogram counting
%
%   prob_joint: joint probability density distributionPDF estimation
%
%   fhlin@sep.26 2012
%

flag_display=0;
n_bin=[];
edge_roi=[];
prob_joint=[];
edges=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_bin'
            n_bin=option_value;
        case 'edges'
            edges=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;


if(ndims(ROI)==2&size(ROI,1)==1) ROI=ROI(:); end;

if(~isempty(n_bin))
    cmd=sprintf('[hist_roi,edge_roi]=histcn(ROI');
    for ii=1:size(ROI,2)
        %cmd=sprintf('%s, %d',cmd,n_bin-1);
        cmd=sprintf('%s, %d',cmd,n_bin);
    end;
    cmd=sprintf('%s);',cmd);
    
    eval(cmd);
    
    %[hist_roi,edge_roi]=histcn(ROI,n_bin,n_bin,n_bin);
elseif(~isempty(edges))
    cmd=sprintf('[hist_roi,edge_roi]=histcn(ROI');
    for ii=1:size(ROI,2)
        cmd=sprintf('%s, edges{%d}',cmd,ii);
    end;
    cmd=sprintf('%s);',cmd);
    
    eval(cmd);
    
    
    %[hist_roi,edge_roi]=histcn(ROI,edges{1},edges{2},edges{3});
    n_bin=length(edges{1});
else
    fprintf('error! neiterh [n_bin] nor [edges] was specified!\n');
    return;
end;

prob_joint=hist_roi./size(ROI,1);


return;
