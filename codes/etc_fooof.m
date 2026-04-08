function [exponent, theta_peak, f_band, psd_band, b_int, b_slope, knee] = etc_fooof(time_series, fs, varargin)
    % Outputs:
    %   exponent    - 1/f slope (chi)
    %   theta_peak  - Residual power in 4-8 Hz
    %   f_band      - Frequency vector
    %   psd_band    - Linear Power Spectral Density vector
    %   b_int       - Offset (b)
    %   b_slope     - Negative of exponent (for backward compatibility)
    %   knee        - Knee parameter (k)
    
    freq_range = [];
    use_knee = false; % Default to fixed model unless specified
    
    for i=1:length(varargin)/2
        option = varargin{i*2-1};
        option_value = varargin{i*2};
        switch lower(option)
            case 'freq_range'
                freq_range = option_value;
            case 'knee'
                use_knee = option_value; % Set to true to use knee model
        end
    end
        
    if(fs > 100) 
        if(isempty(freq_range)), freq_range = [4, 200]; end
        window_length = round(2 * fs); 
    else 
        if(isempty(freq_range)), freq_range = [0.01, 0.1]; end
        window_length = round(100 * fs); 
    end
    
    time_series = time_series(:);
    if window_length > length(time_series), window_length = length(time_series); end
    
    [psd, freqs] = pwelch(time_series, hanning(window_length), [], [], fs);
    
    valid_idx = (freqs >= freq_range(1)) & (freqs <= freq_range(2));
    f_band = freqs(valid_idx);
    psd_band = psd(valid_idx);
    
    log_f = log10(f_band);
    log_psd = log10(psd_band);
    
    % Mask for valid fitting data
    valid_mask = isfinite(log_f) & isfinite(log_psd);
    f_clean = f_band(valid_mask);
    log_f_clean = log_f(valid_mask);
    log_psd_clean = log_psd(valid_mask);
    
    if length(log_f_clean) < 4 % Knee model needs at least 3-4 points
        exponent = NaN; theta_peak = NaN; b_int = NaN; b_slope = NaN; knee = NaN;
        return; 
    end

    if ~use_knee
        %% --- FIXED MODEL (Original Linear Fit) ---
        try
            b = robustfit(log_f_clean, log_psd_clean);
            b_int = b(1); b_slope = b(2);
        catch
            p = polyfit(log_f_clean, log_psd_clean, 1);
            b_int = p(2); b_slope = p(1);
        end
        exponent = -b_slope;
        knee = 0;
    else
        %% --- KNEE MODEL (Non-linear Fit) ---
        % Model: log10(P) = b - log10(k + f^chi)
        % beta(1)=offset(b), beta(2)=knee(k), beta(3)=exponent(chi)
        modelfun = @(beta, x) beta(1) - log10(beta(2) + x.^beta(3));
        
        % Initial Guesses
        initial_offset = max(log_psd_clean);
        initial_knee = 10; % Common starting point for knee
        initial_exp = 2;   % Standard 1/f^2 guess
        beta0 = [initial_offset, initial_knee, initial_exp];
        
        opts = statset('nlinfit');
        opts.MaxIter = 400;
        
        try
            beta_fit = nlinfit(f_clean, log_psd_clean, modelfun, beta0, opts);
            b_int = beta_fit(1);
            knee = beta_fit(2);
            exponent = beta_fit(3);
            b_slope = -exponent; % Slp is the high-freq decay
        catch
            % Fallback to fixed if knee fit fails
            p = polyfit(log_f_clean, log_psd_clean, 1);
            b_int = p(2); b_slope = p(1); exponent = -b_slope; knee = 0;
        end
    end
    
    % Function to get residual peaks after aperiodic subtraction
    if ~use_knee
        get_val = @(f) b_int + b_slope * log10(f);
    else
        get_val = @(f) b_int - log10(knee + f.^exponent);
    end
    
    theta_range = (f_clean >= 4 & f_clean <= 8);
    if any(theta_range)
        theta_peak = mean(log_psd_clean(theta_range) - get_val(f_clean(theta_range)));
    else
        theta_peak = NaN;
    end
end