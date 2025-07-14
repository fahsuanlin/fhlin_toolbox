function [embedding, eigenvalues, eigenvectors] = etc_diff_embedding(X, d, epsilon, num_eig, t)
% ETC_DIFF_EMBEDDING Computes a diffusion map embedding from data.
%
%   [embedding, eigenvalues, eigenvectors] = etc_diff_embedding(X, d, epsilon, num_eig, t)
%
%   INPUTS:
%     X         - A d x n data matrix (each column is a data point in R^d)
%     d         - (Optional) Target embedding dimension. Default: 2
%     epsilon   - (Optional) Gaussian kernel bandwidth. Default: median distance^2
%     num_eig   - (Optional) Number of eigenvectors to compute. Default: d + 3
%     t         - (Optional) Diffusion time. Default: 1
%
%   OUTPUTS:
%     embedding     - n x d matrix of diffusion map embedding (each row is a point in R^d)
%     eigenvalues   - num_eig x 1 vector of eigenvalues (sorted descending)
%     eigenvectors  - n x num_eig matrix of corresponding eigenvectors
%
%   Note:
%     The first eigenvector (constant) is usually skipped when building the embedding.

% Input checks and default assignments
if nargin < 2 || isempty(d)
    d = 2;
end

if nargin < 3 || isempty(epsilon)
    % Use median of pairwise squared distances as default epsilon
    pairwise_sq_dists = pdist(X', 'euclidean').^2;
    epsilon = median(pairwise_sq_dists);
end

if nargin < 4 || isempty(num_eig)
    num_eig = d + 3;  % a few extra eigenvectors to cover noise/trivial mode
end

if nargin < 5 || isempty(t)
    t = 1;
end

[n_dims, n_points] = size(X);
if num_eig <= d
    error('num_eig must be greater than target dimension d (to skip the first trivial eigenvector).');
end

% Step 1: Compute pairwise squared distances
D2 = squareform(pdist(X', 'euclidean').^2);

% Step 2: Gaussian kernel matrix
K = exp(-D2 / epsilon);

% Step 3: Row-normalize K to get stochastic matrix
row_sum = sum(K, 2);
D_inv_sqrt = diag(1 ./ sqrt(row_sum));
K_sym = D_inv_sqrt * K * D_inv_sqrt;

% Step 4: Eigendecomposition (K_sym is symmetric)
[U, S] = eigs(K_sym, num_eig);
lambda = diag(S);

% Step 5: Sort by descending eigenvalue
[lambda_sorted, idx] = sort(lambda, 'descend');
U_sorted = U(:, idx);

% Step 6: Construct embedding (skip first trivial eigenvector)
psi = U_sorted(:, 2:d+1);
lambda_t = lambda_sorted(2:d+1).^t;
embedding = psi .* lambda_t';  % scale by diffusion time

% Outputs
eigenvalues = lambda_sorted;
eigenvectors = U_sorted;
end



% % Example: 3D spiral dataset
% n = 1000;
% theta = linspace(0, 4*pi, n);
% z = linspace(-2, 2, n);
% x = cos(theta);
% y = sin(theta);
% X = [x; y; z];  % X is 3 x 1000
% 
% % Call diffusion embedding with defaults
% [embed2D, lambdas, eigvecs] = etc_diff_embedding(X);
% 
% % Plot results
% figure;
% scatter(embed2D(:,1), embed2D(:,2), 20, theta, 'filled');
% title('Diffusion Map Embedding');
% xlabel('\psi_1'); ylabel('\psi_2');
