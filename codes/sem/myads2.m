function [x, fmax, nf] = myads2(fun, x, stopit, savit, P, P1, P2, P3, P4,P5,P6,P7,P8,P9,P10,P11,P12)
%MYADS2  [x, fmax, nf] = MYADS2(fun, x, STOPIT, SAVIT, P, P1, P2, P3, P4,P5,P6,P7,P8,P9,P10,P11,P12) 
%        attempts to
%        maximize the function specified by the string f, using the starting
%        vector x0.  The alternating directions direct search method is used.
%        Output arguments:
%               x    = vector yielding largest function value found,
%               fmax = function value at x,
%               nf   = number of function evaluations.
%        The iteration is terminated when either
%               - the relative increase in function value between successive
%                 iterations is <= STOPIT(1) (default 1e-3),
%               - STOPIT(2) function evaluations have been performed
%                 (default inf, i.e., no limit), or
%               - a function value equals or exceeds STOPIT(3)
%                 (default inf, i.e., no test on function values).
%        Progress of the iteration is not shown if STOPIT(5) = 0 (default 1).
%        If a non-empty fourth parameter string SAVIT is present, then
%        `SAVE SAVIT x fmax nf' is executed after each inner iteration.
%        By default, the search directions are the co-ordinate directions.
%        The columns of a fifth parameter matrix P specify alternative search
%        directions (P = EYE is the default).
%        NB: x0 can be a matrix.  In the output argument, in SAVIT saves,
%            and in function calls, x has the same shape as x0.

% Reference:
%     N.J. Higham, Optimization by direct search in matrix computations,
%     Numerical Analysis Report No. 197, University of Manchester, UK, 1991;
%     to appear in SIAM J. Matrix Anal. Appl, 14 (2), April 1993.

% By Nick Higham, Department of Mathematics, University of Manchester, UK.
%                 na.nhigham@na-net.ornl.gov
% July 27, 1991.
%-----------------------------------------------------------------------------
% Modified by Christian Buechel Jan. 9, 1997.




n = prod(size(x));
x0 = x(:);  % Work with column vector internally.

mu = 1e-4;  % Initial percentage change in components.
nstep = 25; % Max number of times to double or decrease h.

% Set up convergence parameters.
if nargin < 3, stopit(1) = 1e-3; end
tol = stopit(1); % Required rel. increase in function value over one iteration.
if max(size(stopit)) == 1, stopit(2) = inf; end  % Max no. of f-evaluations.
if max(size(stopit)) == 2, stopit(3) = inf; end  % Default target for f-values.
if max(size(stopit)) <  5, stopit(5) = 1; end    % Default: show progress.
trace  = stopit(5);
if nargin < 4, savit = []; end                   % File name for snapshots.

if nargin < 5 | isempty(P)
   P = eye(n);             % Matrix of search directions.
else
   if any (size(P)-[n n])  % Check for common error.
      error('P must be of dimension the number of elements in x0.')
   end
end

evalstr = [fun];
if ~any(fun<48)
    evalstr=[evalstr, '(x'];
    for i=1:nargin - 5
        evalstr = [evalstr,',P',int2str(i)];
    end
    evalstr = [evalstr, ')'];
end

x(:) = x0; fmax = eval(evalstr); nf = 1;
if trace
 fprintf('f(x0) = %9.4e\n', fmax);
 spm_chi2_plot('Set',fmax);
end

steps = zeros(n,1);
it = 0; y = x0;

while 1    % Outer loop.
it = it+1;
if trace
 fprintf('Iter %2.0f  (nf = %2.0f)  fmax = %9.4e\n', it, nf, fmax);
 spm_chi2_plot('Set',fmax)
end
fmax_old = fmax;

for i=1:n  % Loop over search directions.

    pi = P(:,i);
    flast = fmax;
    yi = y;
    h = sign(pi'*yi)*norm(pi.*yi)*mu;   % Initial step size.
    if h == 0, h = max(norm(yi,inf),1)*mu; end
    y = yi + h*pi;
    x(:) = y; fnew = eval(evalstr); nf = nf + 1;
    if fnew > fmax
       fmax = fnew;
       h = 2*h; lim = nstep; k = 1;
    else
       h = -h; lim = nstep+1; k = 0;
    end

    for j=1:lim
        y = yi + h*pi;
        x(:) = y; fnew = eval(evalstr); nf = nf + 1;
        if fnew <= fmax, break, end
        fmax = fnew; k = k + 1;
        h = 2*h;
   end

   steps(i) = k;
   y = yi + 0.5*h*pi;
   if k == 0, y = yi; end

   if nf >= stopit(2)
      if trace
         fprintf('Max no. of function evaluations exceeded...quitting\n')
      end
      x(:) = y; return
   end

   if fmax > flast & ~isempty(savit)
      x(:) = y;
      eval(['save ' savit ' x fmax nf'])
   end

end  % Loop over components.

if norm(steps-zeros(n,1)) == 0
   if trace, fprintf('Stagnated...quitting\n'), end
   x(:) = y; return
end

if fmax-fmax_old <= tol*abs(fmax_old)
   if trace, fprintf('Function values ''converged''...quitting\n'), end
   x(:) = y; return
end

end %%%%%% Of outer loop.
