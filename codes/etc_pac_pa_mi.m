function [pac_mi, pac_mi_z, pac_pval, pac_matrix] = etc_pac_pa_mi(phase_freqVec, amp_freqVec, phase_signal, amp_signal, fs, varargin)
% etc_pac_pa_mi calculates the modulation index in phase-amplitude coupling
% with independent frequency ranges for phase and amplitude.
%
% [pac_mi, pac_mi_z, pac_pval, pac_matrix] = etc_pac_pa_mi(phase_freqVec, amp_freqVec, phase_signal, amp_signal, fs, [options]);
%
% INPUTS:
% phase_freqVec: 1D vector of frequencies for Phase extraction (Hz)
% amp_freqVec  : 1D vector of frequencies for Amplitude extraction (Hz)
% phase_signal : 1D time series for Phase (e.g., Deep layer)
% amp_signal   : 1D time series for Amplitude (e.g., Superficial layer)
% fs           : sampling rate (Hz)
%
% OPTIONS:
% 'n_bin'      : Number of phase bins (default: 20)
% 'n_surr'     : Number of surrogate iterations for null distribution (default: 200)
% 'phase_tfr'  : Precomputed complex TFR for the phase signal [n_phase_freqs x time]
% 'amp_tfr'    : Precomputed complex TFR for the amplitude signal [n_amp_freqs x time]
%
% OUTPUTS:
% pac_mi       : Raw modulation index matrix [n_amp_freqs x n_phase_freqs]
% pac_mi_z     : Z-scored modulation index matrix
% pac_pval     : P-value matrix based on the surrogate distribution
% pac_matrix   : Phase-amplitude distribution matrix [#bin x n_amp_freqs x n_phase_freqs]

% Default parameters
n_bin = 20;
n_surr = 200;
flag_display = 1;
amp_tfr = [];
phase_tfr = [];

% Parse varargin
for i = 1:2:length(varargin)
    option = varargin{i};
    option_value = varargin{i+1};
    switch lower(option)
        case 'n_bin'
            n_bin = option_value;
        case 'n_surr'
            n_surr = option_value;
        case 'flag_display'
            flag_display = option_value;
        case 'amp_tfr'
            amp_tfr = option_value;
        case 'phase_tfr'
            phase_tfr = option_value;
        otherwise
            fprintf('Unknown option [%s]!\n', option);
            return;
    end
end

% 1. Extract TFRs if not provided in varargin
if isempty(phase_tfr)
    tfr_p = inverse_waveletcoef(phase_freqVec, phase_signal, fs, 5);
    phase_tfr = angle(tfr_p);
end
if isempty(amp_tfr)
    tfr_a = inverse_waveletcoef(amp_freqVec, amp_signal, fs, 5);
    amp_tfr = abs(tfr_a);
end

n_phase_freqs = length(phase_freqVec);
n_amp_freqs   = length(amp_freqVec);
n_times       = size(phase_tfr, 2);

% Preallocate outputs based on the two distinct frequency vectors
pac_matrix = zeros(n_bin, n_amp_freqs, n_phase_freqs);
pac_mi     = zeros(n_amp_freqs, n_phase_freqs);
pac_mi_z   = zeros(n_amp_freqs, n_phase_freqs);
pac_pval   = ones(n_amp_freqs, n_phase_freqs);

phase_edges  = linspace(-pi, pi, n_bin + 1);
uniform_dist = ones(n_bin, 1) / n_bin;

for p_idx = 1:n_phase_freqs
    if flag_display
        fprintf('PAC at Phase [%2.2f] Hz...\r', phase_freqVec(p_idx));
    end

    phase = phase_tfr(p_idx, :);
    phase_index = discretize(phase, phase_edges);

    % Ensure we drop any NaNs from discretization to avoid accumarray errors
    valid_idx = ~isnan(phase_index);
    phase_idx_clean = phase_index(valid_idx);

    % Pre-calculate phase bin counts for this specific phase frequency
    bin_counts = accumarray(phase_idx_clean', 1, [n_bin, 1]);
    bin_counts(bin_counts == 0) = 1; % Avoid division by zero

    for a_idx = 1:n_amp_freqs
        % Optional safeguard: In PAC, amplitude frequency is typically higher than phase frequency.
        % You can uncomment the next two lines to skip calculating pairs where Amp Hz <= Phase Hz.
        if amp_freqVec(a_idx) <= phase_freqVec(p_idx)
            continue;
        end

        amp = amp_tfr(a_idx, valid_idx);

        % --- Calculate True MI ---
        bin_sums = accumarray(phase_idx_clean', amp', [n_bin, 1]);
        mean_amp_per_bin = bin_sums ./ bin_counts;

        % Normalize to create distribution P
        P = mean_amp_per_bin / sum(mean_amp_per_bin);
        pac_matrix(:, a_idx, p_idx) = P;

        % KL Divergence (True MI)
        true_mi = sum(P .* log2((P + eps) ./ uniform_dist)) / log2(n_bin);
        pac_mi(a_idx, p_idx) = true_mi;

        % --- Surrogate Testing ---
        if n_surr > 0
            surr_mi = zeros(n_surr, 1);

            for s = 1:n_surr
                % Shift by at least 1 second to break temporal lock
                shift_val = randi([round(fs), n_times - round(fs)]);
                amp_surr = circshift(amp, shift_val, 2);

                % Re-bin surrogate
                bin_sums_surr = accumarray(phase_idx_clean', amp_surr', [n_bin, 1]);
                mean_amp_surr = bin_sums_surr ./ bin_counts;
                P_surr = mean_amp_surr / sum(mean_amp_surr);

                % Surrogate MI
                surr_mi(s) = sum(P_surr .* log2((P_surr + eps) ./ uniform_dist)) / log2(n_bin);
            end

            % Calculate Z-score and P-value
            mi_mean = mean(surr_mi);
            mi_std  = std(surr_mi);

            pac_mi_z(a_idx, p_idx) = (true_mi - mi_mean) / mi_std;
            pac_pval(a_idx, p_idx) = sum(surr_mi >= true_mi) / n_surr;
        end
    end
end

if flag_display
    fprintf('\nPAC calculation complete.\n');
end
