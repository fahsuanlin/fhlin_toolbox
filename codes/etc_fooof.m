function exponent = etc_fooof(time_series, tr)
    % Calculates the 1/f aperiodic exponent for fMRI using Welch's PSD
    % and robust linear regression.
    %
    % Inputs:
    %   time_series - 1D array of the fMRI BOLD signal for a single vertex
    %   tr          - Repetition Time (TR) in seconds (e.g., 0.72)
    %
    % Output:
    %   exponent    - The steepness of the 1/f slope (beta)
    
    % 1. Define sampling frequency and fMRI infra-slow band
    fs = 1.0 / tr;
    freq_range = [0.01, 0.1]; 
    
    % 2. Calculate Power Spectral Density (PSD) using Welch's method
    % A window of ~100 seconds is needed to reliably capture 0.01 Hz
    window_length = round(100 / tr); 
    
    % Ensure time_series is a column vector
    time_series = time_series(:);
    
    % Compute PSD
    [psd, freqs] = pwelch(time_series, hanning(window_length), [], [], fs);
    
    % 3. Restrict to the frequency band of interest
    valid_idx = (freqs >= freq_range(1)) & (freqs <= freq_range(2));
    f_band = freqs(valid_idx);
    psd_band = psd(valid_idx);
    
    % 4. Convert to log-log space
    log_f = log10(f_band);
    log_psd = log10(psd_band);
    
    % 5. Fit the slope using robust regression to ignore periodic bumps
    % robustfit returns [intercept; slope]
    b = robustfit(log_f, log_psd);
    
    % The aperiodic exponent is the negative of the slope
    exponent = -b(2);
end