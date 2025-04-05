function [fconn_grad] = etc_fconn_grad(C, k)
% etc_fconn_grad A simple demonstration of calculating the gradient of a
% connectivity matrix
%
%   INPUTS:
%       C                     : [N x N ] 2D array of connectivity data
%                               for N ROIs.
%       k                     : Number of gradients to be calculated. k <= N
%
%   OUTPUTS:
%       fconn_grad : [N x k] k-top gradients
%
%   Author: (Your Name), 2025



% Suppose 'C' is an N-by-N connectivity matrix (e.g., correlation).
% If you have correlation data in [-1,1], you can convert it to distance using:
dist = sqrt(2 * (1 - C));  % NxN distance matrix

% If your matrix is already some form of distance, skip/adjust as needed.

%% Step 2: Convert distance to an affinity (similarity) matrix
% Here we use a Gaussian kernel with sigma as the median of upper-triangular distances.
temp = dist(triu(true(size(dist)),1));  % upper triangle of dist
temp = temp(temp > 0);  % remove zero entries if any
sigma = median(temp);

% Build the kernel (affinity) matrix
K = exp(-dist.^2 / (2 * sigma^2));

%% Step 3: Markov normalization
% Make each row sum to 1
rowSums = sum(K, 2);  % sum across columns
M = K ./ rowSums;     % row-stochastic matrix
idx=find(isnan(M(:)));
M(idx)=randn(size(idx)).*eps;

% (Note: M may not be strictly symmetric. Some pipelines symmetrize or use
% different normalization schemes. Adjust per your chosen approach.)

%% Step 4: Eigen decomposition
% We'll solve M*v = lambda*v. For a row-stochastic matrix, the largest eigenvalue
% is typically 1. The associated eigenvector may be "trivial" (all-positive).
[V, D] = eigs(M,k+1);

% Extract eigenvalues in a vector
eigenvals = diag(D);

% Sort in descending order by eigenvalue
[~, idx]  = sort(eigenvals, 'descend');
eigenvals = eigenvals(idx);
V         = V(:, idx);

% The principal gradient is the 2nd eigenvector (column 2 of V),
% because the 1st eigenvector (largest eigenvalue) is often the trivial one.
fconn_grad = V(:,2:k+1);
