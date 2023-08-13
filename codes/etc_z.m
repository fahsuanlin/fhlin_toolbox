function z=etc_z(a,baseline_idx,varargin)
%
% etc_z    calculates the z-score of a 2D matrix
%
% z=etc_z(data,baseline_idx,[option, option_value]);
%
% data: 2D data matrix
% baseline_idx: a vector denoting the indices for the baseline periord
% option;
%   'dim': the dimension of the operation; dim = 1 (across rows) or 2
%   (across columns; default value).
%   'flag_baseline_correct': a flag to remove the average of the baseline
%   interval; default value=0; (no baseline average removal).
%
% fhlin@mar 12 2019
%

flag_baseline_correct=0;
dim=2;
z=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'flag_baseline_correct' %remove the mean of the baseline interval
            flag_baseline_correct=option_value;
        case 'dim' %operation along the dim dimension of the 2D input matrix; 
            dim=option_value;
        otherwise
            fprintf('unknown option [%s].\nerror!\n',option);
            return;
    end;
end;

if(isempty(baseline_idx))
     if(dim==2)
        baseline_idx=[1:size(a,2)];
     else(dim==1)
        baseline_idx=[1:size(a,1)];
     end;
end;

if(flag_baseline_correct)    
    if(dim==2)
        a=bsxfun(@minus,a,mean(a(:,baseline_idx),2));
    elseif(dim==1)
        a=bsxfun(@minus,a,mean(a(baseline_idx,:),1));        
    else
        fprintf('dimension must be 1 or 2.\nerror!\n');
        return;
    end;
end;

if(dim==2)
    z=bsxfun(@rdivide,a,std(a(:,baseline_idx),0,2));
elseif(dim==1)
    z=bsxfun(@rdivide,a,std(a(baseline_idx,:),0,1));    
else
    fprintf('dimension must be 1 or 2.\nerror!\n');
    return;    
end;

return;




