function [p0, mu0, cov0] = gmm_yrchen(y, M, TOL_or_iters, varargin)
% GMM Computes GMM parameters using the EM algorithm
%  
%    [P, MU, S] = GMM(Y, M, TOL_or_iters)
%    [P, MU, S] = GMM(Y, M, TOL_or_iters, Wy, initMU)
%    [P, MU, S] = GMM(Y, M, TOL_or_iters, Wy)
%    [P, MU, S] = GMM(Y, M, TOL_or_iters, [], initMU)
%  
%    Each COLUMN of Y is an observation, i.e.,
%      Y = [y1 y2 ... yN].
%  
%    M = # mixtures  
%    TOL_or_iters = error tolerance (if less than 1)
%                   # iterations (if integer)
%    Wy = [w1 w2 ... wN] relative weights for yk above.  
%  
%    The pdf of Y takes the following form
%        f_Y(y) = \sum_{i=1}^{M} P_i N(y; MU_i, S_i),    
%    where \sum_{i=1}^{M} P_i = 1.  
  
% $Id$  

if size(y,2) == 1  % column vector
  is_col = 1;
  disp([mfilename ': data is column vector. Transposing...']);
  y = y';
else
  is_col = 0;
end

if TOL_or_iters <=0
  error(sprintf('%s: TOL_or_iters must be > 0', mfilename))
elseif TOL_or_iters<1 & TOL_or_iters>0
  TOL = TOL_or_iters;
  iters_max = inf;
else
  TOL = -inf;
  iters_max = TOL_or_iters;
end

[dim_y, N] = size(y);  
fprintf('%s: %d observations\n', mfilename, N);
P_hat_ij = zeros(M,N);  

if nargin>=4 & ~isempty(varargin{1})
  Wy = varargin{1};  % should be just a length-N vector
  fprintf('%s: using user-supplied weights vector...\n', mfilename);
  geo_mean = exp(mean(log(Wy)));
  Wy = Wy/geo_mean; 
  Wy = sparse(1:N,1:N,Wy);
else
  Wy = speye(N)/N;
end


if nargin>=5 &  ~isempty(varargin{2})
  initMU = varargin{2};
  fprintf('%s: using user-supplied initial mean vector...\n', mfilename);
else
  initMU = rand(dim_y, M);
end


% initialization...
p0 = ones(M,1)/M;
mu0 = initMU; %rand(dim_y, M); %repmat(mean(y,2), [1, M])
cov0_est = cov(y');
for i=1:M
  cov0(:,:,i) = cov0_est;
end

iters = 1;
% main loop
fprintf('%s:.', mfilename);
while (1)
  
  for i=1:M
    P_hat_ij(i,:) = norm_dist(y, mu0(:,i), cov0(:,:,i)) * p0(i);
  end
  
  
  %normalization
  P_hat_ij = P_hat_ij * sparse(1:N,1:N,1./sum(P_hat_ij,1));

  % weighting
  P_hat_ij = P_hat_ij *Wy;
  
  % update
  p0_new = mean(P_hat_ij, 2);
  mu0_new = y * P_hat_ij' * diag(1/N./p0_new); %diag(1./sum(P_hat_ij,2)) %
  for i=1:M
    dy = y - repmat(mu0_new(:,i), [1,N]);  
    cov0_new(:,:,i) = dy * sparse(1:N,1:N,P_hat_ij(i,:)) * dy.' /N/p0_new(i);
  end
  
  err_percent = [norm(p0_new - p0)/norm(p0), ...
 		 norm(mu0_new(:) - mu0(:))/norm(mu0(:)),...
 		 norm(cov0_new(:) - cov0(:))/norm(cov0(:))];
  
  p0 = p0_new;
  mu0 = mu0_new;
  cov0 = cov0_new;
  
  if all(err_percent < TOL) | iters >= iters_max
    break;
  end
  
  iters = iters + 1;
  fprintf('.');
end  % end of while (1)
disp('');
disp([mfilename ': #iters = ' num2str(iters)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = norm_dist(y, m, s)
% y = [y1 y2 ... yk]  
% m = some mean vector (\mu_i)
% s = some cov matrix  (\Sigma_i)
  
% this computes the vectorized normal distributions.
  
%sanity check
dim_y = size(y,1);
dim_m = length(m);

if (dim_y ~= dim_m)
  error('dim(y) and dim(m) not compatible!')
end

dy = y - repmat(m, [1 size(y,2)]);
inv_s = inv(s);
p = exp(-sum(dy .* (inv_s * dy),1)/2) / sqrt(det(s) * (2*pi)^dim_y);





