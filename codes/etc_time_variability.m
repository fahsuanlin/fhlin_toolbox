function [var_index, var_index_bstp]=etc_time_variability(data,varargin)

var_index=[];
var_index_bstp=[];

n_bstp=100;
bstp_ratio=1.0;

corr_time_sample=[-50 50];

flag_display=1;

flag_normalize=1;
normalize_baseline_idx=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'n_bstp'
            n_bstp=option_value;
        case 'bstp_ratio'
	    bstp_ratio=option_value;
	case 'corr_time_sample'
            corr_time_sample=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_normalize'
            flag_normalize=option_value; %normalize the data to be zero-mean and unit-variance
        case 'normalize_baseline_idx'
            normalize_baseline_idx=option_value; %indices for normalizing the data to be zero-mean and unit-variance
        otherwise
            fprintf('unknown option [%s]\n! error!\n', option);
            return;
    end;
end;


[n_trial,n_data]=size(data);

if(flag_normalize)
    if(isempty(normalize_baseline_idx))
        normalize_baseline_idx=[1:size(data,2)];
    end;
    data=bsxfun(@minus,data,mean(data(:,normalize_baseline_idx),2));
    data=bsxfun(@rdivide,data,std(data(:,normalize_baseline_idx),0,2));
end;

%grand average
%[u,s,v]=svd(data,'econ');
%s=diag(s).^2;
%var_index=s(1)./sum(s(:));

% %data=data-mean(data(:));
% %data=bsxfun(@minus,data,mean(data,2));
% avg=repmat(mean(data,1),[size(data,1) 1]);
% res=data(:)-avg(:)*(inv(avg(:)'*avg(:))*(avg(:)'*data(:)));
% res=reshape(res,size(data));
% %res=bsxfun(@minus,data,mean(data,1));
% var_index=sum(res(:).^2)./sum(data(:).^2);

%bootstrap
[d0,bstp_sample]=bootstrp(n_bstp,@mean,ones(n_trial,1));
for bstp_idx=1:n_bstp
    tmp=data(bstp_sample(:,bstp_idx),:); 
    %    [u,s,v]=svd(tmp,'econ');
    %    s=diag(s).^2;
    %    var_index_bstp(bstp_idx)=s(1)./sum(s(:));
    
<<<<<<< HEAD
    
    buffer(bstp_idx,:)=mean(tmp,1);
=======
    tmp=tmp(1:round(size(tmp,1).*bstp_ratio),:);
>>>>>>> 8b1a58c1250fc23286674122c3857f50838389fb
    
    
    D=[];
    ss=[min(corr_time_sample):max(corr_time_sample)];
    for ss_idx=1:length(ss)
        dd(:,ss_idx)=circshift(mean(data,1),ss(ss_idx));
    end;
    D=cat(1,D,dd);
    cc=etc_corrcoef(mean(tmp,1)',D);
        
    buffer_cc(bstp_idx,:)=cc;
    
    [corr_value(bstp_idx),ii]=max(cc);
    var_index_bstp(bstp_idx)=ss(ii);    
%     %tmp=tmp-mean(tmp(:));
%     %tmp=bsxfun(@minus,tmp,mean(tmp,2));
%     avg=repmat(mean(tmp,1),[size(tmp,1) 1]);
%     res=tmp(:)-avg(:)*(inv(avg(:)'*avg(:))*(avg(:)'*tmp(:)));
%     res=reshape(res,size(tmp));
%     %res=bsxfun(@minus,tmp,mean(tmp,1));
%     var_index_bstp(bstp_idx)=sum(res(:).^2)./sum(tmp(:).^2);

end;
var_index=std(var_index_bstp);
