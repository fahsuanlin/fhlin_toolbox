function [psi_values, freqs, psi_se, psi_ci, psi_segments] = etc_psi(source_data, fs, target_band, do_segment, n_boot)
% Phase slope index: calculate the phase slope between two time series.
%
% [psi_values, freqs, psi_se, psi_ci, psi_segments] = etc_psi(source_data, fs, target_band, do_segment, n_boot);
%
% INPUTS:
% source_data : [locations(depths) x time]
% fs          : sampling rate (Hz)
% target_band : [f_start f_end] (e.g., [30 80] for Gamma)
% do_segment  : boolean (true/false). If true, segments data into 20s windows with 50% overlap.
% n_boot      : integer. Number of bootstrap iterations (e.g., 1000). Set to 0 to skip.
%
% OUTPUTS:
% psi_values  : [locations(depths) x 1] Mean PSI across all segments/data.
% freqs       : Frequency vector from cpsd.
% psi_se      : [locations(depths) x 1] Standard error of the bootstrapped PSI.
% psi_ci      : [locations(depths) x 2] 95% Confidence Intervals [lower, upper].
% psi_segments: [locations(depths) x n_segments] PSI values for each individual segment.

    % Input handling
    if nargin < 4 || isempty(do_segment), do_segment = false; end
    if nargin < 5 || isempty(n_boot), n_boot = 0; end
    
    [n_depths, n_samples] = size(source_data);
    
    % Force segmentation if bootstrapping is requested to ensure we have blocks to sample
    if n_boot > 0 && ~do_segment
        warning('Bootstrapping requires multiple segments. Automatically enabling do_segment = true.');
        do_segment = true;
    end
    
    % 1. Setup Segmentation Parameters
    if do_segment
        seg_len = 20 * fs;             % 20 seconds
        overlap = seg_len / 2;         % 50% overlap (10 seconds)
        step    = seg_len - overlap;
        
        % Calculate start indices for each segment
        starts = 1:step:(n_samples - seg_len + 1);
        n_segs = length(starts);
    else
        seg_len = n_samples;
        starts  = 1;
        n_segs  = 1;
    end
    
    % Use a reference depth (e.g., middle depth/index 5)
    ref_idx = round(n_depths/2);
    
    % Parameters for Cross-Power Spectral Density
    win = fs; % 1-second window for 1Hz resolution
    noverlap = win/2;
    
    % Preallocate array to hold PSI for each segment and depth
    psi_segments = zeros(n_depths, n_segs);
    
    % 2. Calculate PSI for each segment
    for k = 1:n_segs
        % Extract current segment
        idx_range = starts(k) : (starts(k) + seg_len - 1);
        seg_ref   = source_data(ref_idx, idx_range);
        
        for d = 1:n_depths
            seg_target = source_data(d, idx_range);
            
            % Compute Cross-Power Spectral Density and Auto-Spectra
            [Sxy, freqs] = cpsd(seg_ref, seg_target, win, noverlap, win, fs);
            [Sxx, ~]     = pwelch(seg_ref, win, noverlap, win, fs);
            [Syy, ~]     = pwelch(seg_target, win, noverlap, win, fs);
            
            % Calculate Complex Coherency
            coherency = Sxy ./ sqrt(Sxx .* Syy);
            
            % Find indices for the frequency band of interest
            f_idx = find(freqs >= target_band(1) & freqs <= target_band(2));
            
            % Compute PSI (Imaginary part of the summed phase slope)
            % Vectorized for speed instead of a for-loop
            curr_f_vals = coherency(f_idx(1:end-1));
            next_f_vals = coherency(f_idx(2:end));
            sum_val     = sum(conj(curr_f_vals) .* next_f_vals);
            
            psi_segments(d, k) = imag(sum_val);
        end
    end
    
    % 3. Calculate final PSI (Mean across segments)
    psi_values = mean(psi_segments, 2);
    
    % 4. Bootstrapping
    if n_boot > 0 && n_segs > 1
        boot_dist = zeros(n_depths, n_boot);
        
        for b = 1:n_boot
            % Sample segment indices with replacement
            boot_idx = randi(n_segs, n_segs, 1);
            
            % Calculate mean PSI for this bootstrap sample
            boot_dist(:, b) = mean(psi_segments(:, boot_idx), 2);
        end
        
        % Calculate Standard Error and 95% Confidence Intervals
        psi_se = std(boot_dist, 0, 2);
        psi_ci = prctile(boot_dist, [2.5, 97.5], 2);
    else
        psi_se = [];
        psi_ci = [];
    end

end