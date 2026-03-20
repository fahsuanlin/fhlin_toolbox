function H = etc_hurst_dfa(time_series)
    % Calculates the Hurst exponent using Detrended Fluctuation Analysis (DFA).
    %
    % Inputs:
    %   time_series - 1D array of the fMRI BOLD signal for a single vertex
    %
    % Output:
    %   H           - The Hurst exponent
    
    % Ensure time_series is a column vector
    time_series = time_series(:);
    N = length(time_series);
    
    % 1. Mean-center and integrate the time series (cumulative sum)
    y = cumsum(time_series - mean(time_series));
    
    % 2. Define the window scales (box sizes)
    % Spanning from small windows to N/4
    min_scale = 10;
    max_scale = floor(N / 4);
    
    % Create logarithmically spaced window sizes
    scales = unique(floor(logspace(log10(min_scale), log10(max_scale), 20)));
    
    % Array to hold the root-mean-square fluctuations
    F = zeros(length(scales), 1);
    
    % 3. Loop through each box scale
    for i = 1:length(scales)
        scale = scales(i);
        n_windows = floor(N / scale);
        
        % Truncate the tail of the integrated series to fit evenly into windows
        y_truncated = y(1:(n_windows * scale));
        
        % Reshape into non-overlapping windows (scale x n_windows)
        windows = reshape(y_truncated, scale, n_windows);
        
        rms_sum = 0;
        x = (1:scale)';
        
        % 4. Detrend each window individually
        for w = 1:n_windows
            % Fit a linear trend (polynomial degree 1) to the local window
            p = polyfit(x, windows(:, w), 1);
            trend = polyval(p, x);
            
            % Sum the squared errors (variance from the local trend)
            rms_sum = rms_sum + sum((windows(:, w) - trend).^2);
        end
        
        % Calculate the Root Mean Square fluctuation for this scale
        F(i) = sqrt(rms_sum / (n_windows * scale));
    end
    
    % 5. Fit a line in log-log space to extract the Hurst exponent
    valid_idx = F > 0;
    log_scales = log10(scales(valid_idx))';
    log_F = log10(F(valid_idx));
    
    % Linear fit: log(F) = H * log(scales) + C
    p_fit = polyfit(log_scales, log_F, 1);
    
    H = p_fit(1);
end