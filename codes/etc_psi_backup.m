function [psi_values, freqs] = etc_psi(source_data, fs, target_band)
% Phase sloe index: calculate the phase slope between two time series.
%
% [psi_values, freqs] = etc_psi(source_data, fs, target_band);
%
% *Note* the reference is the time series of round(n_depths/2);
%
% source_data: [locations(depths) x time]
% fs: sampling rate (Hz)
% target_band: [f_start f_end] (e.g., [30 80] for Gamma)
%
% psi_values: [location(depths) x 1]
%    

    [n_depths, n_samples] = size(source_data);
    
    % Use a reference depth (e.g., middle depth/index 5)
    ref_idx = round(n_depths/2);
    sig_ref = source_data(ref_idx, :);
    
    % Parameters for Cross-Power Spectral Density
    win = fs; % 1-second window for 1Hz resolution
    noverlap = win/2;
    
    psi_values = zeros(n_depths, 1);
    
    for d = 1:n_depths
        sig_target = source_data(d, :);
        
        % 1. Compute Cross-Power Spectral Density
        [Sxy, freqs] = cpsd(sig_ref, sig_target, win, noverlap, win, fs);
        [Sxx, ~]     = pwelch(sig_ref, win, noverlap, win, fs);
        [Syy, ~]     = pwelch(sig_target, win, noverlap, win, fs);
        
        % 2. Calculate Complex Coherence
        coherency = Sxy ./ sqrt(Sxx .* Syy);
        
        % 3. Find indices for the frequency band of interest
        f_idx = find(freqs >= target_band(1) & freqs <= target_band(2));
        
        % 4. Compute PSI (Imaginary part of the summed phase slope)
        % We look at the product of the complex conjugate of one bin 
        % and the next bin to find the phase rotation.
        sum_val = 0;
        for j = 1:length(f_idx)-1
            curr_f = f_idx(j);
            next_f = f_idx(j+1);
            sum_val = sum_val + conj(coherency(curr_f)) * coherency(next_f);
        end
        
        psi_values(d) = imag(sum_val);
    end
