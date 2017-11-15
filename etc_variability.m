function [var_index, var_index_bstp]=etc_variability(data,varargin)

n_bstp=100;

flag_display=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_bstp'
            n_bstp=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]\n! error!\n', option);
            return;
    end;
end;


[n_trial,n_data]=size(data);

%grand average
%[u,s,v]=svd(data,'econ');
%s=diag(s).^2;
%var_index=s(1)./sum(s(:));

%data=data-mean(data(:));
data=bsxfun(@minus,data,mean(data,2));
res=bsxfun(@minus,data,mean(data,1));
var_index=sum(res(:).^2)./sum(data(:).^2);

%bootstrap
[d0,bstp_sample]=bootstrp(n_bstp,@mean,ones(n_trial,1));
for bstp_idx=1:n_bstp
    tmp=data(bstp_sample(:,bstp_idx),:);
%    [u,s,v]=svd(tmp,'econ');
%    s=diag(s).^2;
%    var_index_bstp(bstp_idx)=s(1)./sum(s(:));

    %tmp=tmp-mean(tmp(:));
    tmp=bsxfun(@minus,tmp,mean(tmp,2));
    res=bsxfun(@minus,tmp,mean(tmp,1));
    var_index_bstp(bstp_idx)=sum(res(:).^2)./sum(data(:).^2);

end;
