function [predBehavior, corrVal, pVal] = etc_cbpm_singleNetwork_NPM(connectivity_matrices, behavior, k, pThreshold)
% CBPM_SINGLENETWORK_NPM 
% Demonstration of connectome-based predictive modeling (CBPM) using only
% one network, adapted for data shaped [N x P x M].
%
%   INPUTS:
%       connectivity_matrices : [N x P x M] 
%           - N = # of ROIs
%           - P = # of network features per ROI (e.g., sub-network measures)
%           - M = # of subjects
%       behavior : [M x 1] vector, the behavioral/clinical target
%       k        : scalar, number of cross-validation folds
%       pThreshold: scalar, p-value threshold for feature selection
%
%   OUTPUTS:
%       predBehavior : [M x 1] predicted behavior for each subject
%       corrVal      : Pearson correlation between predicted and actual behavior
%       pVal         : p-value associated with corrVal
%
% Example usage:
%   [predVals, rVal, pVal] = cbpm_singleNetwork_NPM(connectivity_matrices, behavior, 5, 0.01);
%
% Author: (Your Name), 2025

%% 1) Check Dimensions
[N, P, M_subj] = size(connectivity_matrices);
if M_subj ~= length(behavior)
    error('Mismatch: 3rd dimension (M_subj) must match length of behavior.');
end

fprintf('CBPM (single network) for [N x P x M] = [%d x %d x %d].\n', N, P, M_subj);
fprintf('Number of features per subject = %d.\n', N*P);

%% 2) Cross-validation Setup
cvIndices = crossvalind('Kfold', M_subj, k);
predBehavior = nan(M_subj, 1);

%% 3) Main Cross-Validation Loop
for fold = 1:k
    % Identify training vs. test sets
    trainInd = (cvIndices ~= fold);
    testInd  = (cvIndices == fold);

    beh_train = behavior(trainInd);
    beh_test  = behavior(testInd);

    % Number of training subjects
    nTrain = sum(trainInd);
    nTest  = sum(testInd);

    % Pre-allocate feature matrices
    % We'll create a [#features x #trainSubjects] matrix for the training fold
    % Flatten each subject's [N x P] into [N*P, 1]
    X_train = zeros(N*P, nTrain);

    % Fill X_train
    trainCount = 1;
    for s = find(trainInd)'
        matNP = connectivity_matrices(:,:,s);  % [N x P]
        X_train(:, trainCount) = reshape(matNP, [N*P, 1]);  % flatten
        trainCount = trainCount + 1;
    end

    %% (a) Feature Selection
    % We want to correlate each feature (row) with the training behaviors
    % That means we want corr(X_train(row, :), beh_train)
    % But MATLAB's 'corr' is typically data in columns => we transpose X_train
    [rVals, pVals] = corr(X_train', beh_train, 'type', 'Pearson');
    % rVals/pVals are 1D arrays of length (N*P)

    % Single network approach: keep all features p < pThreshold, regardless of sign
    featureMask = (pVals < pThreshold);

    %% (b) Summation => "Network Strength"
    % For each training subject, sum the selected features
    netStrengthTrain = sum(X_train(featureMask, :), 1)';  % result is [nTrain x 1]

    %% (c) Fit Model
    % A simple linear model: behavior ~ beta0 + beta1 * netStrength
    LM = fitlm(netStrengthTrain, beh_train);

    %% (d) Apply to Test Set
    X_test = zeros(N*P, nTest);
    testCount = 1;
    for s = find(testInd)'
        matNP = connectivity_matrices(:,:,s); % [N x P]
        X_test(:, testCount) = reshape(matNP, [N*P, 1]);
        testCount = testCount + 1;
    end

    netStrengthTest = sum(X_test(featureMask, :), 1)';  % [nTest x 1]
    predFold = predict(LM, netStrengthTest);

    % Store predictions for these test subjects
    predBehavior(testInd) = predFold;
end

%% 4) Evaluate Overall Performance
[r, p] = corrcoef(predBehavior, behavior, 'Rows', 'complete');
corrVal = r(2);
pVal = p(2);

fprintf('Overall prediction: r = %.3f, p = %.3g\n', corrVal, pVal);

end
