function y = wrap_around(h, L)
% y = wrap_around(h, L)
% wraps around the filter h if the length is larger than L

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

if length(h) <= L
   %disp('no need for wrap_around')
   y = h;
else
   %disp('wrapping around the filter...')
   h(ceil(length(h)/L)*L)=0;
   h = reshape(h, [L length(h)/L]);
   y = sum(h,2).';
end