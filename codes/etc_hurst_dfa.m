function H = etc_hurst_dfa(time_series)
    % Calculates the Hurst exponent using Detrended Fluctuation Analysis (DFA).
    % Highly optimized using vectorized least-squares regression.
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
    min_scale = 10;
    max_scale = floor(N / 4);
    
    % Create logarithmically spaced window sizes
    scales = unique(floor(logspace(log10(min_scale), log10(max_scale), 20)));
    
    % Array to hold the root-mean-square fluctuations
    F = zeros(length(scales), 1);
    
    % 3. Loop through each box scale (Inner loop removed entirely)
    for i = 1:length(scales)
        scale = scales(i);
        n_windows = floor(N / scale);
        
        % Truncate the tail of the integrated series to fit evenly into windows
        y_truncated = y(1:(n_windows * scale));
        
        % Reshape into non-overlapping windows (scale x n_windows)
        % Each column is a separate window
        windows = reshape(y_truncated, scale, n_windows);
        
        % --- VECTORIZED DETRENDING ---
        % Create the design matrix X for a linear fit (y = mx + c)
        % Column 1 is x (1 to scale), Column 2 is a constant (intercepts)
        x = (1:scale)';
        X = [x, ones(scale, 1)]; 
        
        % Solve X * beta = windows for ALL windows simultaneously
        % beta will be a 2 x n_windows matrix (Row 1: slopes, Row 2: intercepts)
        beta = X \ windows;
        
        % Reconstruct the linear trend for all windows at once
        trends = X * beta;
        
        % Calculate residuals (actual data minus the trend)
        residuals = windows - trends;
        
        % Sum the squared errors across all elements simultaneously
        rms_sum = sum(residuals(:).^2);
        
        % Calculate the Root Mean Square fluctuation for this scale
        F(i) = sqrt(rms_sum / (n_windows * scale));
    end
    
    % 4. Fit a line in log-log space to extract the Hurst exponent
    valid_idx = F > 0;
    if sum(valid_idx) < 2
        H = NaN; % Fallback if variance is flat
        return;
    end
    
    log_scales = log10(scales(valid_idx))';
    log_F = log10(F(valid_idx));
    
    % Linear fit: log(F) = H * log(scales) + C
    % Using basic matrix math here instead of polyfit is also slightly faster
    X_final = [log_scales, ones(length(log_scales), 1)];
    beta_final = X_final \ log_F;
    
    H = beta_final(1);
end