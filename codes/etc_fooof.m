function exponent = etc_fooof(time_series, fs, varargin)
    % Calculates the 1/f aperiodic exponent using Welch's PSD
    % and robust linear regression. Autodetects fMRI vs EEG based on fs.
    %
    % Inputs:
    %   time_series - 1D array of the signal for a single vertex/ROI
    %   fs          - Sampling rate in Hz (e.g., 1000 for EEG, 1/0.72 for fMRI)
    %   varargin    - Optional key-value pairs (e.g., 'freq_range', [4 200])
    %
    % Output:
    %   exponent    - The steepness of the 1/f slope (beta)
    
    freq_range=[];
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        switch lower(option)
            case 'freq_range'
                freq_range=option_value;
            otherwise
                fprintf('unknown option [%s]. error!\n',option);
                return;
        end;
    end;
        
    % 1. Dynamically set freq range and Welch window based on modality
    if(fs > 100) % EEG 
        if(isempty(freq_range))
           freq_range = [4, 200]; % Default EEG FOOOF range
        end
        % 2-second window for EEG (gives 0.5 Hz frequency resolution)
        window_length = round(2 * fs); 
    else % fMRI
        if(isempty(freq_range))
            freq_range = [0.01, 0.1]; % Default fMRI infra-slow band
        end
        % 100-second window for fMRI to capture 0.01 Hz
        window_length = round(100 * fs); 
    end;
    
    fprintf('frequency range : %s\n', mat2str(freq_range));
    
    % Ensure time_series is a column vector
    time_series = time_series(:);
    
    % Safeguard: Window cannot be longer than the data itself
    if window_length > length(time_series)
        window_length = length(time_series);
    end
    
    % 2. Calculate Power Spectral Density (PSD) using Welch's method
    [psd, freqs] = pwelch(time_series, hanning(window_length), [], [], fs);
    
    % 3. Restrict to the frequency band of interest
    valid_idx = (freqs >= freq_range(1)) & (freqs <= freq_range(2));
    f_band = freqs(valid_idx);
    psd_band = psd(valid_idx);
    
    % 4. Convert to log-log space
    log_f = log10(f_band);
    log_psd = log10(psd_band);
    
    % 5. Sanitize and fit the slope
    valid_mask = isfinite(log_f) & isfinite(log_psd);
    log_f_clean = log_f(valid_mask);
    log_psd_clean = log_psd(valid_mask);
    
    if length(log_f_clean) < 3 || var(log_psd_clean) < 1e-10
        exponent = NaN; 
        return; 
    end
    
    warning('off', 'stats:statrobustfit:IterationLimit');
    
    try
        b = robustfit(log_f_clean, log_psd_clean);
        exponent = -b(2); 
        
        [~, warnId] = lastwarn;
        if strcmp(warnId, 'stats:statrobustfit:IterationLimit')
            p = polyfit(log_f_clean, log_psd_clean, 1);
            exponent = -p(1);
            lastwarn(''); 
        end
    catch
        p = polyfit(log_f_clean, log_psd_clean, 1);
        exponent = -p(1);
    end
    
    warning('on', 'stats:statrobustfit:IterationLimit');
end