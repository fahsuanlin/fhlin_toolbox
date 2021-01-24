function y = cir_conv(x,h,varargin)
% y = cir_conv(x, h [,N])
%
% Circular convolution along the Nth dim.
% x: multi-dim. array
% h: 1D kernel, wrapped around if longer than the N-th dim of x.

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

shift_idx=0;

if nargin==2
   n = 1;  % the dim. along which cir. conv is applied.
elseif nargin==3
   n = varargin{1};
elseif nargin==4
   n = varargin{1};
	shift_idx=varargin{2};
end

% problem if length(h) > size(x,n)
% therefore, need to wrap around the filter if shorter than x.
h = wrap_around(h, size(x,n)); 

L = max([size(x,n) length(h)]);
fx=shiftdim(fft(x,L,n), (n-1));

%fprintf('FFT...');

fh=fft(h(:),L,1);  


size_fx = size(fx);

y = shiftdim(real(ifft(fx .* repmat(fh, [1 size_fx(2:end)]),[],1)), ndims(x)-(n-1));

%fprintf('end of FFT...');
