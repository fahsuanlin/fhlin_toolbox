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
    
    % 5. Sanitize and fit the slope
    % Remove Infs and NaNs (e.g., from log10(0) if PSD is completely flat)
    valid_mask = isfinite(log_f) & isfinite(log_psd);
    log_f_clean = log_f(valid_mask);
    log_psd_clean = log_psd(valid_mask);
    
    % Check for sufficient data points and variance
    % We need at least 3 valid points to do robust regression, 
    % and the PSD must have actual variance
    if length(log_f_clean) < 3 || var(log_psd_clean) < 1e-10
        exponent = NaN; 
        return; % Exit early, return NaN for this bad vertex
    end
    
    % Temporarily suppress the iteration warning so it doesn't flood your console
    warning('off', 'stats:statrobustfit:IterationLimit');
    
    try
        % Attempt the robust fit. robustfit returns [intercept; slope]
        b = robustfit(log_f_clean, log_psd_clean);
        exponent = -b(2); % The aperiodic exponent is the negative of the slope
        
        % Check if MATLAB threw the iteration limit warning in the background
        [~, warnId] = lastwarn;
        if strcmp(warnId, 'stats:statrobustfit:IterationLimit')
            % If robustfit struggled, fallback to standard linear regression
            p = polyfit(log_f_clean, log_psd_clean, 1);
            exponent = -p(1);
            lastwarn(''); % Clear the warning
        end
    catch
        % Absolute fallback if robustfit hard-crashes
        p = polyfit(log_f_clean, log_psd_clean, 1);
        exponent = -p(1);
    end
    
    % Turn warnings back on
    warning('on', 'stats:statrobustfit:IterationLimit');
end