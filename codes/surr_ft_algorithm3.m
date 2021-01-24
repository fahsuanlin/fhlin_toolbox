function [s]=surr_ft_algorithm3(time_series)
% function [sur_time_series,sur_time_series_o,time_series,sort_time_series]=surr_ft_algotithm(time_series,mode)

    % Initialize
    y=time_series;
    % Make n normal random devaiates
    normal=sort(randn(size(y)));
    % Sort y and extract the ranks
    [y,T]=sort(y);
    [T,r]=sort(T);
    % Assign the ranks of y to the normal deviates and apply the phase
    %  randomization
    normal=phaseran(normal(r));
    % Extract the ranks of the phase randomized normal deviates
    [normal,T]=sort(normal);
    [T,r]=sort(T);
    % Assign the ranks of the phase randomized normal deviates to y and
    %  obtain the AAFT surrogates
    s=y(r);
