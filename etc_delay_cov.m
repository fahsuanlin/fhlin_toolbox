function H=etc_delay_cov(data,lag,varargin)
%
% calculate the delayed covariance matrix of the data given a delay
%
% H=etc_delay_cov(data,lag);
% 
% data: [n_time, n_var] matrix of n_time time points and n_var variables
% lag: the lag for the Hankel matrix; lag must be equal or larger than 1
%
% H: Hankel matrix
% 
% fhlin@aug. 9 2007
%
flag_display=1;
H=[];

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
    fprintf('calculating delayed covariance matrix of lag [%d]...\n',lag);
end;

%remove the mean
data_avg=mean(data,1);
data=data-repmat(data_avg,[size(data,1),1]);

d1=data(1:end-lag,:);
d2=data(lag+1:end,:);
H=(d1'*d2)./size(d1,1);

return;