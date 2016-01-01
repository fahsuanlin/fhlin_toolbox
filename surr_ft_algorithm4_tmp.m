function [s]=surr_ft_algorithm4_tmp(time_series,varargin)
% function [sur_time_series,sur_time_series_o,time_series,sort_time_series]=surr_ft_algotithm(time_series,mode)

n=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        case 'n'
            n=option_value;
        otherwise
            fprintf('unknown option [%s]!\n',option);
            return;
    end;
end;

% Initialize
y=repmat(time_series(:),[2,n]);

xx=randperm(length(time_series(:)));
xx=repmat(xx(1:n),[length(time_series(:)),1]);
xx0=repmat([0:length(time_series(:))-1]',[1 n]);
s=y(xx+xx0);
return;
