function [y_filtered, res]=etc_window_regression(y,d,varargin)

% etc_kalman    Filtering auto-regressive signal with Kalman filter
%
% [y_filtered, res]=etc_window_regression(y,d)
%
% y: n_y x n_t signals to be filtered
% d: n_x * n_t signals as the regressors
%
% y_filtered: filtered signal
% res: filtered residual
%
% option:
%   'window_length': window_length (default=1000 samples)
%
% fhlin@Oct 28 2023
%

y_filtered=[];
res=[];

window_length=1000; %default with a 1000-sample window

flag_add_confound=1;

flag_display=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'window_length'
            window_length=option_value;
        case 'flag_add_confound'
            flag_add_confound=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]. error!\n',option);
            return;
    end;
end;


if(size(y,2)>window_length)
%    for idx=size(y,1)-window_length+1:size(y,1)
 
    res=zeros(size(y));
    y_filtered=zeros(size(y));

    for idx=1:ceil(size(y,2)/window_length)
        if(idx*window_length<=size(y,2))
            y_now=y(:,(idx-1)*window_length+1:idx*window_length);
            d_now=d(:,(idx-1)*window_length+1:idx*window_length);
        else
            y_now=y(:,(idx-1)*window_length+1:end);
            d_now=d(:,(idx-1)*window_length+1:end);
        end;

        if(flag_add_confound)
            d_now(end+1,:)=1;
        end;

        d_now=d_now.';
        y_now=y_now.';

        beta=inv(d_now'*d_now)*d_now'*y_now;
        if(idx*window_length<=size(y,2))
            y_filtered(:,(idx-1)*window_length+1:idx*window_length)=(d_now*beta).';
            res(:,(idx-1)*window_length+1:idx*window_length)=(y_now-d_now*beta).';
        else
            y_filtered(:,(idx-1)*window_length+1:end)=(d_now*beta).';
            res(:,(idx-1)*window_length+1:end)=(y_now-d_now*beta).';
        end;
    end;
end;