function color=inverse_get_color(cmap,value,th_hi,th_lo,varargin)

flag_overflow_nan=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_overflow_nan'
            flag_overflow_nan=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;

idx=[1:length(value)];
idx_hi=find(value>th_hi);
idx_lo=find(value<th_lo);
idx_mi=setdiff(setdiff(idx,idx_hi),idx_lo);

color=ones(length(value),3).*nan;

if(flag_overflow_nan)

    idx=int32((value-th_lo)./(th_hi-th_lo).*(size(cmap,1)-1)+1); 
    color(idx_mi,:)=cmap(idx(idx_mi),:); %only values within the range have non-nan color
else
    
%     th_lo_v=ones(size(value)).*th_lo;
%     th_hi_v=ones(size(value)).*th_hi;
%     
%     idx=round((value-th_lo_v)./(th_hi-th_lo).*size(cmap,1));
%     idx(find(idx<1))=1;
%     idx(find(idx>size(cmap,1)))=size(cmap,1);
%     
%     color=cmap(idx,:);
    idx=int32((value-th_lo)./(th_hi-th_lo).*(size(cmap,1)-1)+1); 
    color(idx_mi,:)=cmap(idx(idx_mi),:); %only values within the range have non-nan color

    color(idx_hi,:)=repmat(cmap(end,:),[length(idx_hi),1]);
    color(idx_lo,:)=repmat(cmap(1,:),[length(idx_lo),1]);
end;

return;
