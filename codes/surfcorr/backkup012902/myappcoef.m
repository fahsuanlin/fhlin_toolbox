function a = myappcoef(c,l,varargin)
%MYAPPCOEF Extract M-D approximation coefficients along the 1st dimension
%   MYAPPCOEF computes the approximation coefficients of a
%   multi-dimensional signal.
%
%   A = MYAPPCOEF(C,L,'wname',N) computes the approximation
%   coefficients at level N using the wavelet decomposition
%   structure [C,L] (see CIR_WAVEDEC).
%   'wname' is a string containing the wavelet name.
%   Level N must be an integer such that 0 <= N <= min(size(L))-2. 
%
%   A = MYAPPCOEF(C,L,'wname') extracts the approximation
%   coefficients at the last level length(L)-2.
%
%   Instead of giving the wavelet name, you can give the filters.
%   For A = MYAPPCOEF(C,L,Lo_R,Hi_R) or
%   A = MYAPPCOEF(C,L,Lo_R,Hi_R,N),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%   
%   See also MYDETCOEF, CIR_WAVEDEC.

% $Revision: 1.1 $

if length(l) ~= ndims(c)
    error(sprintf('%s: c and l are not compatible', mfilename'));
end

% Check arguments.
if errargn(mfilename,nargin,[3:5],nargout,[0:1]), error('*'), end

for k=1:ndims(c)
    rmax(k) = length(l{k});
    nmax(k) = rmax(k)-2;
end

if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(2+next) , n = varargin{next}; else, n = nmax; end

if any(n < 0) | any(n > nmax) | any(n ~= fix(n))
    errargt(mfilename,'invalid level value','msg'); error('*');
end


% Iterated reconstruction.
nd = ndims(c);
for k=1:nd
    
    c = shiftdim(c, k-1);  % the k-th dim

    % Initialization.
    cmd = 'a = c(1:l{k}(1)'; for kk=2:ndims(c); cmd = [cmd, ',:']; end
    cmd = [cmd, ');']; eval(cmd);  
    
    imax = rmax(k)+1;
    for p = nmax(k):-1:n+1
        d = mydetcoef(c,l{k},p);                % extract detail
        a = myidwt(a,d,Lo_R,Hi_R,l{k}(imax-p));
    end    
    a = shiftdim(a, nd-(k-1));
    c = a;
end




