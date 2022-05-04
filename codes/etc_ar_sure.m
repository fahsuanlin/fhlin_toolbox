function [AIC, AIC1, BIC]=etc_ar_sure(v,sf, window_length,ar_order,varargin)
%
% sf: sampling rate (in Hz)
% window_length: 1 D vector of different temporal window length (in seconds)
% ar_order: 1 D vector of different AR model orders 
%



%window_length=[50:50:200]; % 100 msec moving window
%ar_order=[2:2:40];
v=v(:);

for window_idx=1:length(window_length)
    fprintf('window = [%f] s',window_length(window_idx));
    window_size=round(window_length(window_idx).*sf);
    
    if(window_size>length(v))
        window_size=length(v);
    end;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % define here the timeVec to be calculated
    
    %     timeVec_dyn=[];
    %     for w_idx=1:length(data.timeVec)-window_size+1
    %         timeVec_w_idx=[w_idx:window_size+w_idx-1];
    %         timeVec_dyn(w_idx)=data.timeVec(timeVec_w_idx(end));
    %     end;
    
    for ar_idx=1:length(ar_order)
        fprintf('.');

        for w_idx=1:size(v,1)-window_size+1
            timeVec_idx=[w_idx:window_size+w_idx-1];
            
            %model estimation within the window
            [w{w_idx},A{w_idx},C{w_idx}]=arfit(v(timeVec_idx,:),ar_order(ar_idx),ar_order(ar_idx));

            %modified SURE
            M{w_idx}=zeros(ar_order(ar_idx),ar_order(ar_idx));
            vv=v(timeVec_idx,:);
            for ll=1:size(vv,1)-ar_order(ar_idx)
                M{w_idx}=M{w_idx}+vv(ll+ar_order(ar_idx)-1:-1:ll,:)*vv(ll+ar_order(ar_idx)-1:-1:ll,:)';
            end;
            M{w_idx}=M{w_idx}./length(timeVec_idx);
        end;
        
       
        %residual estimation
        res=[];

        m=size(v,2);                    % dimension of state vectors
        p=size(A{1},2)/m;               % order of model
        n=size(v,1);                    % number of observations
        nres = n-p;                     % number of residuals
        
        l = [p:nres+p-1];
        l = [1:nres];
        l = [floor(window_size/2):floor(window_size/2)+size(v,1)-window_size];
        
        %for w_idx=1:min([length(v)-window_size+1,length(l)])
        alpha=0;
        for w_idx=1:length(l)
            %res(l(w_idx),:) = v(l(w_idx)+p,:) -w{w_idx};
            res(w_idx,:) = v(l(w_idx)+p,:) -w{w_idx};
            for j=1:p
                res(w_idx,:) = res(w_idx,:) - v(l(w_idx)-j+p,:)*A{w_idx}(:, (j-1)*m+1:j*m)';
            end;
            
            vv=v(l(w_idx)-1+p:-1:l(w_idx),:);
            alpha=alpha+vv'*pinv(M{w_idx})*vv;
        end;
        alpha=alpha./length(l)./ar_order(ar_idx);
        
        %res=res-repmat(mean(res,1),[size(res,1),1]);
        %plot([1:length(res)],v(l(1)+p:l(w_idx)+p),'b',[1:length(res)],res,'r');
        %keyboard;

        AIC(window_idx,ar_idx)=log(mean(res.^2))+2.*ar_order(ar_idx)./window_size.*alpha;
        BIC(window_idx,ar_idx)=log(mean(res.^2))+1.*ar_order(ar_idx)./window_size.*alpha;
        AIC1(window_idx,ar_idx)=log(mean(res.^2)*(1+2.*ar_order(ar_idx)./window_size));
    end;
    fprintf('\n');
end;