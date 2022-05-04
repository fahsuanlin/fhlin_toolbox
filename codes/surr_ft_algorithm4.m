function [s]=surr_ft_algorithm4(time_series,varargin)
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
    y=time_series(:);
    % Make n normal random devaiates
    normal=sort(randn(size(y)),1);
    % Sort y and extract the ranks
    [y,T]=sort(y,1);
    [T,r]=sort(T,1);
    % Assign the ranks of y to the normal deviates and apply the phase
    %  randomization
    normal=phaseran4(normal(r(:)),n);
    % Extract the ranks of the phase randomized normal deviates
    [normal,T]=sort(normal,1);
    [T,r]=sort(T,1);
    % Assign the ranks of the phase randomized normal deviates to y and
    %  obtain the AAFT surrogates
    for ii=1:n
        s(:,ii)=y(r(:,ii));
    end;
