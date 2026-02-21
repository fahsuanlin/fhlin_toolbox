function [fconn_grad] = etc_fconn_grad(C, k, varargin)
% etc_fconn_grad Calculate connectivity gradients from an ROI x ROI matrix.
%
%   INPUTS:
%       C               : [N x N] connectivity matrix
%       k               : number of gradients to return (1 <= k <= N-1)
%
%   OPTIONS (varargin as key/value pairs):
%       'affinity_method'  : 'diffusion' (default), 'pearson', 'cosine'
%       'sigma'            : Gaussian kernel width for 'diffusion'
%                            (default: median nonzero pairwise distance)
%       'regularization_eps': small positive constant for numeric stability
%                            (default: 1e-12)
%
%   OUTPUT:
%       fconn_grad      : [N x k] top-k non-trivial gradients

affinity_method = 'diffusion';
sigma = [];
regularization_eps = 1e-12;

if(mod(length(varargin), 2) ~= 0)
    error('Options must be provided as key/value pairs.');
end

for i = 1:length(varargin)/2
    option = varargin{i*2-1};
    option_value = varargin{i*2};
    switch lower(option)
        case 'affinity_method'
            affinity_method = lower(option_value);
        case 'sigma'
            sigma = option_value;
        case 'regularization_eps'
            regularization_eps = option_value;
        otherwise
            error('Unknown option [%s].', option);
    end
end

if(~ismatrix(C) || size(C,1) ~= size(C,2))
    error('Input C must be a square matrix.');
end
if(~isnumeric(C) || ~isreal(C))
    error('Input C must be a real numeric matrix.');
end
if(any(~isfinite(C(:))))
    error('Input C contains NaN or Inf values.');
end
if(~isscalar(k) || ~isfinite(k))
    error('Input k must be a finite scalar.');
end
if(~isscalar(regularization_eps) || regularization_eps <= 0)
    error('regularization_eps must be a positive scalar.');
end

N = size(C,1);
k = round(k);
if(k < 1 || k > N-1)
    error('k must satisfy 1 <= k <= N-1 (k=%d, N=%d).', k, N);
end

% Enforce symmetry on connectivity and remove trivial self-connections.
C = (C + C.') ./ 2;

clip_eps = 1e-7;
switch affinity_method
    case 'pearson'
        C_safe = min(max(C, -1 + clip_eps), 1 - clip_eps);
        Z = atanh(C_safe);
        Z(1:N+1:end) = 0;

        % Correlation between ROI connectivity profiles.
        K = corr(Z.');
        K(~isfinite(K)) = 0;
        K = (K + 1) ./ 2;

    case 'diffusion'
        C_safe = min(max(C, -1), 1);
        dist2 = max(0, 2 .* (1 - C_safe));
        dist = sqrt(dist2);

        temp = dist(triu(true(size(dist)), 1));
        temp = temp(temp > 0 & isfinite(temp));
        if(isempty(sigma))
            sigma_use = median(temp);
        else
            sigma_use = sigma;
        end
        if(~isscalar(sigma_use) || ~isfinite(sigma_use) || sigma_use <= 0)
            if(isempty(temp))
                sigma_use = 1;
            else
                sigma_use = median(temp);
            end
            if(~isfinite(sigma_use) || sigma_use <= 0)
                sigma_use = 1;
            end
        end

        K = exp(-dist2 ./ (2 .* sigma_use.^2));

    case 'cosine'
        C_safe = min(max(C, -1 + clip_eps), 1 - clip_eps);
        Z = atanh(C_safe);
        Z(1:N+1:end) = 0;

        normZ = sqrt(sum(Z.^2, 2));
        normZ(normZ < regularization_eps) = 1;
        sim = (Z * Z.') ./ (normZ * normZ.');
        sim(~isfinite(sim)) = 0;

        K = (sim + 1) ./ 2;

    otherwise
        error('Unknown affinity_method [%s].', affinity_method);
end

% Affinity cleanup.
K(~isfinite(K)) = 0;
K = max(K, 0);
K = (K + K.') ./ 2;
K(1:N+1:end) = 0;

% Symmetric normalization to keep eigendecomposition real and stable.
d = sum(K, 2);
d(d < regularization_eps | ~isfinite(d)) = regularization_eps;
D_inv_sqrt = diag(1 ./ sqrt(d));
M = D_inv_sqrt * K * D_inv_sqrt;
M = (M + M.') ./ 2;

% Eigen decomposition: skip first trivial mode.
num_modes = k + 1;
if(num_modes >= N)
    [V_full, D_full] = eig(full(M), 'vector');
    [~, idx] = sort(real(D_full), 'descend');
    V = V_full(:, idx);
else
    [V, D] = eigs(M, num_modes, 'la'); %#ok<ASGLU>
    eigenvals = diag(D);
    [~, idx] = sort(real(eigenvals), 'descend');
    V = V(:, idx);
end

fconn_grad = V(:, 2:k+1);

% Numerical guard: convert tiny imaginary residuals to real.
if(~isreal(fconn_grad))
    imag_max = max(abs(imag(fconn_grad(:))));
    if(imag_max < 1e-8)
        fconn_grad = real(fconn_grad);
    else
        error('Complex gradients detected (max imaginary part = %g).', imag_max);
    end
end

% Deterministic sign convention across runs.
for ii = 1:size(fconn_grad,2)
    [~, idx_max] = max(abs(fconn_grad(:,ii)));
    if(fconn_grad(idx_max,ii) < 0)
        fconn_grad(:,ii) = -fconn_grad(:,ii);
    end
end
