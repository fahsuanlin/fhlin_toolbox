function [psi_values, freqs, psi_se, psi_ci, psi_segment] = etc_psi(source_data, fs, target_band, do_boot, n_boot)
% Phase slope index calculated on the WHOLE time series with Spectral Bootstrapping.
%
% [psi_values, freqs, psi_se, psi_ci] = etc_psi(source_data, fs, target_band, do_boot, n_boot);
%
% INPUTS:
% source_data : [locations(depths) x time]
% fs          : sampling rate (Hz)
% target_band : [f_start f_end] (e.g., [70 150] for High Gamma)
% do_segment  : boolean (true/false). If true, do bootstrapping
% n_boot      : integer. Number of bootstrap iterations (e.g., 1000). Set to 0 to skip.
%
% OUTPUTS:
% psi_values  : [locations(depths) x 1] The true PSI of the entire unbroken time series.
% freqs       : Frequency vector.
% psi_se      : [locations(depths) x 1] Standard error of the bootstrapped PSI.
% psi_ci      : [locations(depths) x 2] 95% Confidence Intervals [lower, upper].

psi_segment=[];

    % Input handling
    if nargin < 4 || isempty(do_boot), do_boot = false; end
    if nargin < 5 || isempty(n_boot), n_boot = 0; end
      
    [n_depths, ~] = size(source_data);


    % Force segmentation if bootstrapping is requested to ensure we have blocks to sample
    if n_boot > 0 && ~do_boot
        warning('Bootstrapping requested... Automatically enabling do_boot = true.');
        do_boot = true;
    end


    % Use a reference depth (middle depth)
    ref_idx = round(n_depths/2);
    sig_ref = source_data(ref_idx, :);
    
    % 1. Setup Parameters to exactly mirror the original cpsd function
    win_len  = round(fs);          % 1-second window for 1Hz resolution
    noverlap = round(win_len / 2); % 50% overlap
    window   = hamming(win_len);   % Default window for spectral density
    
    % 2. Calculate the Short-Time Fourier Transform (STFT) for the reference signal
    [S_ref, freqs, ~] = spectrogram(sig_ref, window, noverlap, win_len, fs);
    PSD_ref_all       = abs(S_ref).^2; % Auto-power spectrum of reference
    
    % Find indices for the frequency band of interest
    f_idx = find(freqs >= target_band(1) & freqs <= target_band(2));
    
    % Preallocate outputs
    psi_values = zeros(n_depths, 1);
    psi_se     = zeros(n_depths, 1);
    psi_ci     = zeros(n_depths, 2);
    
    % 3. Iterate through depths
    for d = 1:n_depths
        sig_target = source_data(d, :);
        
        % STFT for the target signal
        [S_tgt, ~, ~] = spectrogram(sig_target, window, noverlap, win_len, fs);
        
        % Compute Cross-Spectral Density (CSD) and target Auto-Power Spectrum (PSD) for all windows
        %CSD_all     = conj(S_ref) .* S_tgt;
        CSD_all     = (S_ref) .* conj(S_tgt);
        PSD_tgt_all = abs(S_tgt).^2;
        
        % --- ORIGINAL WHOLE-DATA CALCULATION ---
        % Average the spectra across the entire 3 minutes FIRST
        CSD_mean     = mean(CSD_all, 2);
        PSD_ref_mean = mean(PSD_ref_all, 2);
        PSD_tgt_mean = mean(PSD_tgt_all, 2);
        
        % Calculate Complex Coherency and PSI
        coherency = CSD_mean ./ sqrt(PSD_ref_mean .* PSD_tgt_mean);
        curr_f = coherency(f_idx(1:end-1));
        next_f = coherency(f_idx(2:end));
        
        psi_values(d) = imag(sum(conj(curr_f) .* next_f));
        
        % --- SPECTRAL BOOTSTRAPPING ---
        if n_boot > 0
            n_windows = size(CSD_all, 2);
            boot_psi  = zeros(n_boot, 1);
            
            for b = 1:n_boot
                % Resample the 1-second Welch windows with replacement
                boot_idx = randi(n_windows, n_windows, 1);
                
                % Create the bootstrapped grand-average spectra
                CSD_boot     = mean(CSD_all(:, boot_idx), 2);
                PSD_ref_boot = mean(PSD_ref_all(:, boot_idx), 2);
                PSD_tgt_boot = mean(PSD_tgt_all(:, boot_idx), 2);
                
                % Calculate Coherency and PSI for this bootstrap iteration
                coh_boot = CSD_boot ./ sqrt(PSD_ref_boot .* PSD_tgt_boot);
                curr_b   = coh_boot(f_idx(1:end-1));
                next_b   = coh_boot(f_idx(2:end));
                
                boot_psi(b) = imag(sum(conj(curr_b) .* next_b));
            end
            
            % Compute stats
            psi_se(d)    = std(boot_psi);
            psi_ci(d, :) = prctile(boot_psi, [2.5, 97.5]);
        end
    end
end