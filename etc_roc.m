function [ROC_X,ROC_Y,auc,h_roc]=etc_roc(x,source,varargin)
%   etc_roc     calcuate receiver-operating-characteristic (ROC) curve
%
%  [ROC_X,ROC_Y,auc]=etc_roc(x,source,[option, option_value])
%
%   x: the estimate of source, n-by-1
%   source: the true source indicated by entries of 0 or 1, n-by-1
%
% option:
%   flag_display:   show graphic and text during calculation (default: 1);
%   estimate_steps: the total number of steps for the thresholds of the
%   estimamate in ROC calculation (default: 50)
%   roc_step:   the step size of False-positive-rate (FPR) of detection
%
% ROC_X: the false-positive-rate (FPR) of detection after data gridding
% ROC_Y: the true-positive-rate (TPR) of detection after data gridding
% auc: the area under the ROC curve
%
%
%   fhlin@aug. 14 2008

flag_display=1;
flag_display_verbose=0;
flag_display_dot=1;
estimate_steps=50;
roc_step=0.01;

h_roc=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'flag_display'
            flag_display=option_value;
        case 'flag_display_verbose'
            flag_display_verbose=option_value;
        case 'flag_display_dot'
            flag_display_dot=option_value;
        case 'estimate_steps'
            estimate_steps=option_value;
        case 'roc_step'
            roc_step=option_value;
        otherwise
            fprintf('no [%s] option...\n',option);
            fprintf('error!\n');
            return;
    end;
end;

x=x(:);
source=source(:);

if(length(x)~=length(source))
    fprintf('size of the estimtae and the truth does not match!\n');
    fprintf('error!\n');
    return;
end;

source_idx=find(source);
comp_source_idx=find(source==0);

x_min=min(x);
x_max=max(x);
steps=estimate_steps;

x_step=(x_max-x_min)/(steps-1);
x_max=x_max+x_step;
x_min=x_min-x_step;

if(x_min<0) x_min=0; end;
threshold=[x_min:x_step:x_max];

for th_idx=1:length(threshold)
    if(flag_display_verbose) fprintf('[%d|%d] threshold = %2.2e...',th_idx,length(threshold), threshold(th_idx)); end;
    
    x_pos=find(x>threshold(th_idx));
    
    tpr(th_idx)=length(intersect(x_pos,source_idx))./length(source_idx);
    fpr(th_idx)=length(intersect(x_pos,comp_source_idx))./length(comp_source_idx);   
    
    if(flag_display_verbose) fprintf('TPR=%2.2f%%\tFPR=%2.2f%%\r',tpr(th_idx)*100,fpr(th_idx)*100); end;
end;

tpr=[1; tpr(:); 0];
fpr=[1; fpr(:); 0];

ROC_X=[0:roc_step:1];
ROC_X=ROC_X(:);
%ROC_Y=griddatan(fpr',tpr',ROC_X,'linear');
ii=find(abs(diff(fpr))<eps);
if(~isempty(ii))
    ii=ii+1;
    fpr(ii)=[];
    tpr(ii)=[];
end;

ROC_Y=interp1(flipud(fpr(:)),flipud(tpr(:)),ROC_X(:),'PCHIP','extrap');

nan_idx=find(isnan(ROC_Y));
ROC_Y(nan_idx)=[];
ROC_X(nan_idx)=[];

if(flag_display) h_roc=plot(ROC_X, ROC_Y,'b'); hold on; if(flag_display_dot) plot(fpr,tpr,'r.'); end; end;

auc=sum(ROC_Y.*roc_step);

return;