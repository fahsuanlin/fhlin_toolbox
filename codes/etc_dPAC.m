function [MI_all, time_centers]=etc_dPAC(your_time_series,fs,f_phase, f_amp,varargin)

MI_time=[];
time_centers=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'twin'
        case 'tstep'
        otherwise
            fprintf('unknown option [%s]! error!\n',option);
            return;
    end;
end;
% Input data and parameters
%fs = 1000;                 % Sampling rate (Hz)
data = your_time_series;  % Time series vector
twin = round(5*fs);                % Window size (samples)
tstep = round(fs/2);                % Step size (samples)
%f_phase = 4:2:8;        % e.g., [4 6 8] Hz
%f_amp   = 80:20:150;    % e.g., [80 100 120 140] Hz
%bw_phase = 2;              % Bandwidth around phase frequencies
%bw_amp   = 20;             % Bandwidth around amplitude frequencies

tmp=diff(f_phase)/2;
tmp(end+1)=tmp(end);
f_phase_l=f_phase-tmp;
f_phase_u=f_phase+tmp;

tmp=diff(f_amp)/2;
tmp(end+1)=tmp(end);
f_amp_l=f_amp-tmp;
f_amp_u=f_amp+tmp;

% PAC bins
nbins = 18;
edges = linspace(-pi, pi, nbins+1);
centers = edges(1:end-1) + diff(edges)/2;

% Precompute number of windows
nwin = floor((length(data) - twin) / tstep) + 1;
time_centers = nan(nwin,1);

% Output matrix: [n_phase_freqs x n_amp_freqs x time_windows]
MI_all = nan(length(f_phase), length(f_amp), nwin);

% Loop over frequency combinations
for ip = 1:length(f_phase)
    for ia = 1:length(f_amp)
        % Filter design
        fp = f_phase(ip);
        fa = f_amp(ia);
        %[bp,ap] = butter(3, [(fp - bw_phase/2), (fp + bw_phase/2)] / (fs/2), 'bandpass');
        %[ba,aa] = butter(3, [(fa - bw_amp/2), (fa + bw_amp/2)] / (fs/2), 'bandpass');
        [bp,ap] = butter(3, [f_phase_l(ip), f_phase_u(ip)] / (fs/2), 'bandpass');
        [ba,aa] = butter(3, [f_amp_l(ia), f_amp_u(ia)] / (fs/2), 'bandpass');
        % Apply filters
        phase_sig = filtfilt(bp, ap, data);
        amp_sig   = filtfilt(ba, aa, data);

        % Hilbert transforms
        inst_phase = angle(hilbert(phase_sig));
        inst_amp   = abs(hilbert(amp_sig));

        % Compute PAC in sliding windows
        for wi = 1:nwin
            idx = (1:twin) + (wi-1)*tstep;
            phi = inst_phase(idx);
            A   = inst_amp(idx);

            % Bin amplitudes by phase
            A_mean = zeros(nbins,1);
            for k = 1:nbins
                inbin = phi >= edges(k) & phi < edges(k+1);
                A_mean(k) = mean(A(inbin));
            end
            P = A_mean / sum(A_mean);
            H = -sum(P .* log(P + eps));
            Hmax = log(nbins);
            MI = (Hmax - H) / Hmax;

            MI_all(ip, ia, wi) = MI;
            time_centers(wi) = (idx(1) + idx(end)) / 2 / fs;
        end
    end
end

% % Example: visualize PAC at a time point
% t_idx = round(nwin / 2);
% imagesc(f_amp, f_phase, squeeze(MI_all(:,:,t_idx)));
% xlabel('Amplitude Freq (Hz)');
% ylabel('Phase Freq (Hz)');
% title(sprintf('PAC at %.2f sec', time_centers(t_idx)));
% colorbar;
