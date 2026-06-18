function [bad_intervals, bad_trigger, detail] = eeg_bad_time_detect(eeg, fs, params)
% Detect bad intervals from multichannel EEG using robust windowed features.
%
% Inputs
%   eeg    : channels x time
%   fs     : sampling rate (Hz)
%   params : struct with optional fields
%            win_sec, step_sec, score_th, consensus_th, consensus_z_th,
%            merge_gap_sec, min_dur_sec
%
% Outputs
%   bad_intervals : Nx2 [start_sec end_sec]
%   detail        : struct with score/consensus/time vectors
bad_trigger=[];
detail=[];
bad_intervals=[];

if nargin < 3 || isempty(params), params = struct(); end
params = fill_defaults(params);

eeg = double(eeg);
n = size(eeg, 2);
nc = size(eeg, 1);

win = max(2, round(params.win_sec * fs)); %window length; 0.5 s
step = max(1, round(params.step_sec * fs)); %window step; 0.1 s
starts = 1:step:max(1, n - win + 1);
nw = numel(starts);

%features within a window
rmsv = zeros(nw, nc); %rms of ampltidue 
llv = zeros(nw, nc); %line length (sum-of-absolute values of differences) rate
jumpv = zeros(nw, nc);%jump; the largest difference between neighboring samples
zcrv = zeros(nw, nc); %zero crossing rate

for w = 1:nw
    ii = starts(w):(starts(w) + win - 1);
    x = eeg(:, ii);
    dx = diff(x, 1, 2);
    rmsv(w, :) = sqrt(mean(x .^ 2, 2));
    llv(w, :) = sum(abs(dx), 2) ./ params.win_sec;
    jumpv(w, :) = max(abs(dx), [], 2);
    zcrv(w, :) = sum((x(:, 1:end-1) .* x(:, 2:end)) < 0, 2) ./ params.win_sec;
end

%convert feature to robust Z-score;
z_rms = robust_z(rmsv);
z_ll = robust_z(llv);
z_jump = robust_z(jumpv);
z_zcr = robust_z(zcrv);

%aggregate four features
z_ch = max(0, z_rms) + max(0, z_ll) + max(0, z_jump) + 0.5 .* max(0, z_zcr);

%bad interval depends on 1) the median of summary score > threshold or 2)
%at least two channels have the summary score > threshold.
score = median(z_ch, 2);
consensus = sum(z_ch > params.consensus_z_th, 2); 
bad = (score > params.score_th) & (consensus >= params.consensus_th);

bad_intervals = mask_to_intervals(bad, starts, win, fs);
bad_intervals = merge_intervals(bad_intervals, params.merge_gap_sec);
bad_intervals = drop_short(bad_intervals, params.min_dur_sec);

for idx=1:length(bad_intervals)

    bad_trigger.time(idx)=round(bad_intervals(idx,1)*fs); %onset time in sample
    bad_trigger.event{idx}='bad'; %category name
    bad_trigger.duration(idx)=bad_intervals(idx,2)-bad_intervals(idx,1); %duration in s
    bad_trigger.ch{idx}='unspecified';
end;

detail = struct( ...
    'score', score, ...
    'consensus', consensus, ...
    'starts_sec', ((starts - 1) ./ fs).', ...
    'params', params);
end


%--------------------------------------------
function params = fill_defaults(params)
if ~isfield(params, 'win_sec'), params.win_sec = 0.5; end
if ~isfield(params, 'step_sec'), params.step_sec = 0.1; end
if ~isfield(params, 'score_th'), params.score_th = 7; end
if ~isfield(params, 'consensus_th'), params.consensus_th = 2; end
if ~isfield(params, 'consensus_z_th'), params.consensus_z_th = 8; end
if ~isfield(params, 'merge_gap_sec'), params.merge_gap_sec = 0.5; end
if ~isfield(params, 'min_dur_sec'), params.min_dur_sec = 1.0; end
end

function z = robust_z(x)
m = median(x, 1, 'omitnan');
mad0 = median(abs(x - m), 1, 'omitnan');
scale = 1.4826 .* mad0;
scale(scale < eps) = 1;
z = (x - m) ./ scale;
end

function ints = mask_to_intervals(mask, starts, win, fs)
ints = [];
if isempty(mask), return; end
dm = [false; mask(:); false];
on = find(diff(dm) == 1);
off = find(diff(dm) == -1) - 1;
for k = 1:numel(on)
    s_idx = starts(on(k));
    e_idx = starts(off(k)) + win - 1;
    ints(end + 1, :) = [(s_idx - 1) ./ fs, e_idx ./ fs]; %#ok<AGROW>
end
end

function ints = merge_intervals(ints, gap_sec)
if isempty(ints), return; end
out = ints(1, :);
for i = 2:size(ints, 1)
    if ints(i, 1) - out(end, 2) <= gap_sec
        out(end, 2) = max(out(end, 2), ints(i, 2));
    else
        out = [out; ints(i, :)]; %#ok<AGROW>
    end
end
ints = out;
end

function ints = drop_short(ints, min_dur_sec)
if isempty(ints), return; end
dur = ints(:, 2) - ints(:, 1);
ints = ints(dur >= min_dur_sec, :);
end
