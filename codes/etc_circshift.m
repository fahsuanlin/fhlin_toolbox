function y = etc_circshift(x,s)
% etc_circshift Fractional circular shift
%   Syntax:
%
%       >> y = etc_circshift(x,s)
%
%   etc_circshift circularly shifts the elements of vector x by a (possibly
%   non-integer) number of elements s. etc_circshift works by applying a linear
%   phase in the spectrum domain and is equivalent to CIRCSHIFT for integer
%   values of argument s (to machine precision).


needtr = 0; if size(x,1) == 1; x = x(:); needtr = 1; end;
N = size(x,1); 
r = floor(N/2)+1; f = ((1:N)-r)/(N/2); 
p = exp(-j*s*pi*f)'; 
y = ifft(fft(x).*ifftshift(p)); if isreal(x); y = real(y); end;
if needtr; y = y.'; end;