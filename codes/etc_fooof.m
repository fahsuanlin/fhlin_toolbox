function [exponent, theta_peak, f_band, psd_band, b_int, b_slope] = etc_fooof(time_series, fs, varargin)
    % Outputs:
    %   exponent    - 1/f slope
    %   theta_peak  - Residual power in 4-8 Hz
    %   f_band      - Frequency vector (4 to 200 Hz)
    %   psd_band    - Power Spectral Density vector
    %   b_int       - Robust fit y-intercept
    %   b_slope     - Robust fit slope
    
    freq_range=[];
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        switch lower(option)
            case 'freq_range'
                freq_range=option_value;
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
    
    valid_mask = isfinite(log_f) & isfinite(log_psd);
    log_f_clean = log_f(valid_mask);
    log_psd_clean = log_psd(valid_mask);
    
    if length(log_f_clean) < 3 || var(log_psd_clean) < 1e-10
        exponent = NaN; theta_peak = NaN;
        b_int = NaN; b_slope = NaN;
        return; 
    end
    
    warning('off', 'stats:statrobustfit:IterationLimit');
    
    get_theta_peak = @(intc, slp) mean(log_psd_clean(10.^log_f_clean >= 4 & 10.^log_f_clean <= 8) - ...
        (intc + slp * log_f_clean(10.^log_f_clean >= 4 & 10.^log_f_clean <= 8)));

    try
        b = robustfit(log_f_clean, log_psd_clean);
        b_int = b(1); b_slope = b(2);
        exponent = -b_slope; 
        theta_peak = get_theta_peak(b_int, b_slope);
        
        [~, warnId] = lastwarn;
        if strcmp(warnId, 'stats:statrobustfit:IterationLimit')
            p = polyfit(log_f_clean, log_psd_clean, 1);
            b_int = p(2); b_slope = p(1);
            exponent = -b_slope;
            theta_peak = get_theta_peak(b_int, b_slope);
            lastwarn(''); 
        end
    catch
        p = polyfit(log_f_clean, log_psd_clean, 1);
        b_int = p(2); b_slope = p(1);
        exponent = -b_slope;
        theta_peak = get_theta_peak(b_int, b_slope);
    end
    
    if isnan(theta_peak) || isempty(theta_peak), theta_peak = NaN; end
    warning('on', 'stats:statrobustfit:IterationLimit');
end