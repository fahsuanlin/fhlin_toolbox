function [S_m_pos,S_m_neg, L_m_pos, L_m_neg]=etc_delay_toeplitz(data,lag,varargin)
%
% calculate the Toeplitze delayed covariance matrix of the data given a delay
%
% [S_m_pos,S_m_neg]=etc_delay_toeplitz(data,lag);
% 
% data: [n_time, n_var] matrix of n_time time points and n_var variables
% lag: the lag for the Hankel matrix; lag must be equal or larger than 1
%
% S_m_pos: "positive" Toeplitze matrix of lag 0 to lag "lag-1"
% S_m_neg: "negative" Toeplitze matrix of lag 0 to lag "lag-1"
% L_m_pos: Cholesky decomposition of the "positive" Toeplitze matrix of lag 0 to lag "lag-1"
% L_m_neg: Cholesky decomposition of the "negative" Toeplitze matrix of lag 0 to lag "lag-1"
% 
% fhlin@aug. 9 2007
%
flag_display=1;
S_m_pos=[];
S_m_neg=[];
L_m_pos=[];
L_m_neg=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]...!\nerror!\n',option);
            return;
    end;
end;

if(lag<0) 
    fprintf('error! the lag must be >=0!\n');
    return;
end;

if(flag_display)
    fprintf('calculating delayed toeplitz matrix of lag [%d]...\n',lag);
end;

% %prepare delayed covariance matrix
% for i=1:lag
%     C{i}=etc_delay_cov(data,i-1,'flag_display',0);
% end;
% n_row=size(C{1},1);
% n_col=size(C{1},2);

Y_neg=[];
Y_pos=[];

data=data-repmat(mean(data,1),[size(data,1),1]);

for i=1:lag
    Y_neg=cat(1,(data(i:end-2*lag+i-1,:)'),Y_neg);
    Y_pos=cat(1,Y_pos,(data(lag+i:end-lag+i-1,:))');
end;

S_m_pos=Y_pos*(Y_pos)'./size(Y_pos,2);
S_m_neg=Y_neg*(Y_neg)'./size(Y_neg,2);


%cholesky decomposition
L_m_pos=chol(S_m_pos);
L_m_neg=chol(S_m_neg);


return;