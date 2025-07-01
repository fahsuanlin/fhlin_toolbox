function [predBehavior, corrVal, pVal] = etc_cbpm_singleNetwork_NPM2(connectivity_matrices, behavior, k, pThreshold, varargin)
% CBPM_SINGLENETWORK_NPM2 
% Demonstration of connectome-based predictive modeling (CBPM) using only
% one network, adapted for data shaped [N x P x M], now with:
%   • Noise rejection (low-variance feature removal)
%   • Feature selection (edge–behavior correlation)
%   • Dimension reduction (network-strength summary or PCA)
%
%   INPUTS:
%       connectivity_matrices : [N x P x M]  
%           - N = # of ROIs
%           - P = # of network features per ROI
%           - M = # of subjects
%       behavior : [M x 1] vector, the behavioral/clinical target
%       k        : scalar, number of cross-validation folds
%       pThreshold : scalar, p-value threshold for feature selection
%   Name-Value Optional Parameters:
%       'VarThreshold'  : near-zero variance cutoff (default 1e-3)
%       'UsePCA'        : true to use PCA instead of network strength (default false)
%       'NumComponents' : # PCA components if UsePCA (default 1)
%
%   OUTPUTS:
%       predBehavior : [M x 1] predicted behavior for each subject
%       corrVal      : Pearson correlation between predicted and actual behavior
%       pVal         : p-value associated with corrVal
%
% Example usage:
%   [predVals, rVal, pVal] = etc_cbpm_singleNetwork_NPM(mat, beh, 5, 0.01, ...
%                      'VarThreshold',1e-4,'UsePCA',true,'NumComponents',3);
%
% Author: (Your Name), 2025

%% 1) Parse optional parameters
p = inputParser;
p.addParameter('VarThreshold',1e-3,@(x)isnumeric(x)&&x>=0);
p.addParameter('UsePCA',false,@islogical);
p.addParameter('NumComponents',1,@(x)isnumeric(x)&&x>=1);
p.parse(varargin{:});
varThreshold = p.Results.VarThreshold;
usePCA       = p.Results.UsePCA;
numPCs       = p.Results.NumComponents;

%% 2) Check Dimensions
[N, P, M_subj] = size(connectivity_matrices);
if M_subj ~= length(behavior)
    error('Mismatch: 3rd dim (M_subj) must match length of behavior.');
end

%% 3) Cross-validation Setup
cvIndices = crossvalind('Kfold', M_subj, k);
predBehavior = nan(M_subj, 1);

%% 4) Main CV Loop
for fold = 1:k
    trainInd = (cvIndices ~= fold);
    testInd  = (cvIndices == fold);

    beh_train = behavior(trainInd);
    beh_test  = behavior(testInd);
    nTrain    = sum(trainInd);
    nTest     = sum(testInd);

    %--- Assemble feature matrices
    X_train = reshape(connectivity_matrices(:,:,trainInd), [], nTrain);
    X_test  = reshape(connectivity_matrices(:,:,testInd),  [], nTest);

    %% a) Noise Rejection: remove near-zero variance features
    featVar   = var(X_train, 0, 2);              % variance per feature
    noiseMask = (featVar > varThreshold);       % keep only features above threshold

    %% b) Feature Selection: correlate remaining features with behavior
    [~, pVals] = corr(X_train(noiseMask,:)', beh_train, 'Type','Pearson');
    selMask_rel = (pVals < pThreshold);         % logical mask for correlated edges
    % Expand to full feature-space mask
    featMask_full = false(size(noiseMask));
    featMask_full(noiseMask) = selMask_rel;

    %% c) Dimension Reduction & Model Fitting
    if usePCA
        % PCA on selected edges
        [coeff, ~, ~, ~, explained] = pca(X_train(featMask_full,:)', 'NumComponents', numPCs);
        scoresTrain = X_train(featMask_full,:)' * coeff;
        LM = fitlm(scoresTrain, beh_train);
    else
        % Network-strength summary: sum over selected edges
        netStrengthTrain = sum(X_train(featMask_full,:), 1)';
        LM = fitlm(netStrengthTrain, beh_train);
    end

    %% d) Apply Model to Test Set
    if usePCA
        scoresTest = X_test(featMask_full,:)' * coeff;
        predFold   = predict(LM, scoresTest);
    else
        netStrengthTest = sum(X_test(featMask_full,:), 1)';
        predFold        = predict(LM, netStrengthTest);
    end

    predBehavior(testInd) = predFold;
end

%% 5) Evaluate Overall Performance
[R, Pmat] = corrcoef(predBehavior, behavior, 'Rows','complete');
corrVal = R(2);
pVal     = Pmat(2);
fprintf('Overall prediction → r = %.3f, p = %.3g\n', corrVal, pVal);
end