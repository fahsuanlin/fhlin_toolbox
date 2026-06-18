function merged = eeg_merge_intervals(a, b)
% eeg_merge_intervals merge two matrices of intervals into one.
%
%  merged = eeg_merge_intervals(a, b)
%
% a: a nx2 matrix of n intervals; column 1 is the starting time. column 2
% is the ending time.
% b: a mx2 matrix of m intervals; column 1 is the starting time. column 2
% is the ending time.
%
% merged: a px2 matrix of p merged interval; column 1 is the starting time. column 2
% is the ending time.
%
% fhlin@June 18 2026
%


merged=[];


% Combine both matrices vertically
c = [a; b];

% Edge case: if both matrices are empty, return an empty array
if isempty(c)
    merged = [];
    return;
end

% Sort the combined matrix based on the starting times (column 1)
c = sortrows(c, 1);

% Initialize the merged matrix with the first sorted interval
merged = c(1, :);

% Iterate through the remaining intervals
for i = 2:size(c, 1)
    current_start = c(i, 1);
    current_end   = c(i, 2);

    % The end time of the last interval added to our merged list
    last_merged_end = merged(end, 2);

    % Check if the current interval overlaps with the last merged one
    if current_start <= last_merged_end
        % If they overlap, update the end time to the maximum of both
        merged(end, 2) = max(last_merged_end, current_end);
    else
        % If they do not overlap, append the current interval as a new row
        merged = [merged; current_start, current_end];
    end
end
