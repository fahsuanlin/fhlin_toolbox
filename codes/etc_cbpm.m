function [predBehavior, corrVal, pVal] = etc_cbpm(connectivity_matrices, behavior, k, pThreshold)
% CBPM_EXAMPLE A simple demonstration of connectome-based predictive modeling in MATLAB.
%
%   INPUTS:
%       connectivity_matrices : [N x N x M] 3D array of connectivity data
%                               for M subjects (N = number of ROIs).
%       behavior              : [M x 1] vector of behavioral scores.
%       k                     : (scalar) number of cross-validation folds (e.g., 5).
%       pThreshold            : (scalar) p-value threshold for feature selection.
%
%   OUTPUTS:
%       predBehavior : [M x 1] predicted behavior for each subject (across all folds).
%       corrVal      : Pearson correlation between predicted and actual behavior.
%       pVal         : p-value for that correlation.
%
%   Author: (Your Name), 2025

%% Check input dimensions
[M_subj, ~] = size(behavior); % M_subj = number of subjects
[N1, N2, M_check] = size(connectivity_matrices);

if M_check ~= M_subj || N1 ~= N2
    error('Dimension mismatch: connectivity_matrices must be [N x N x M].');
end

fprintf('Running CBPM with %d subjects, %d ROIs, %d-fold cross-validation.\n', ...
    M_subj, N1, k);

%% Prepare cross-validation indices
cvIndices = crossvalind('Kfold', M_subj, k);

% Storage for predictions
predBehavior = nan(M_subj, 1);

%% Main cross-validation loop
for fold = 1:k
    % Identify training and test subjects in this fold
    trainInd = (cvIndices ~= fold);
    testInd  = (cvIndices == fold);

    % Extract training data
    conn_train = connectivity_matrices(:,:,trainInd);
    beh_train  = behavior(trainInd);

    % (1) Feature Selection on Training Set
    % Flatten upper triangle of each subject's connectivity matrix (or do i<j loops).
    % For convenience, let's gather all edges for each training subject into a matrix.
    % We'll vectorize the NxN matrix (upper triangle only to avoid redundancy).
    nTrain = sum(trainInd);
    upperTriMask = triu(true(N1, N2), 1);  % Boolean mask for upper triangle (excluding diagonal)
    nEdges = sum(upperTriMask(:));        % number of edges in the upper triangle
    
    % Build [nTrain x nEdges] matrix of connectivity values
    trainEdgeVals = zeros(nTrain, nEdges);
    for s = 1:nTrain
        cMat = conn_train(:,:,s);
        trainEdgeVals(s, :) = cMat(upperTriMask);
    end

    % Compute correlation of each edge with behavior across the training set
    [rVals, pVals] = corr(trainEdgeVals, beh_train, 'type', 'Pearson');

    % Positive edges: p < pThreshold & r > 0
    posEdgeMask = (pVals < pThreshold) & (rVals > 0);
    % Negative edges: p < pThreshold & r < 0
    negEdgeMask = (pVals < pThreshold) & (rVals < 0);

    % (2) Summarize network strength for each subject (Training)
    % Sum connectivity over positive edges and negative edges
    posTrain = sum(trainEdgeVals(:, posEdgeMask), 2);
    negTrain = sum(trainEdgeVals(:, negEdgeMask), 2);

    % (3) Build Predictive Model (linear regression with 2 predictors)
    % Model: behavior ~ alpha + beta1*(posStrength) + beta2*(negStrength)
    LM = fitlm([posTrain, negTrain], beh_train);

    %% Apply model to Test Set
    conn_test = connectivity_matrices(:,:,testInd);
    nTest = sum(testInd);

    testEdgeVals = zeros(nTest, nEdges);
    for s = 1:nTest
        cMat = conn_test(:,:,s);
        testEdgeVals(s, :) = cMat(upperTriMask);
    end

    % Compute pos/neg network strengths for test subjects (using selected edges from training)
    posTest = sum(testEdgeVals(:, posEdgeMask), 2);
    negTest = sum(testEdgeVals(:, negEdgeMask), 2);

    % Predict behavior
    predFold = predict(LM, [posTest, negTest]);

    % Store predictions
    predBehavior(testInd) = predFold;
end

%% Evaluate overall predictive accuracy
% Compare predicted and actual behavior across all subjects
[r, p] = corrcoef(predBehavior, behavior, 'Rows', 'complete');
corrVal = r(2);
pVal    = p(2);

fprintf('CBPM result: corr = %.3f, p = %.3g\n', corrVal, pVal);

end
