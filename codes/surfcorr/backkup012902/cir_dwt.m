function y = cir_dwt(x,h0, h1,varargin)
% y = cir_dwt(x,h0,h1,varargin)

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

%normalize filter energy
%h0=h0./sum(h0);
%h1=h1./sum(h1);

if nargin==3
   n = 1;
else
   n = varargin{1};
end


%generate the synthesis filter bank  from analysis filter bank
f0=((-1).^([1:length(h1)]).*(-1)).*h1;
f1=((-1).^([1:length(h0)])).*h0;

%detect phase shift of the filter bank (both analysis and synthesis) before analysis filter bank
phase_delay=(length(conv(f0,h0))-1)/2;
phase_delay = ceil(phase_delay/2);
x=shift(x,n,phase_delay);

%fprintf('cir_dwt ...');

y = cat(n, down_n(cir_conv(x,h0,n),n), down_n(cir_conv(x,h1,n),n));
%fprintf('DONE!\n');

%%%%%%%%%%%%%%%%%%%
function y = down_n(x,n)

x = shiftdim(x, n-1);
siz_x = size(x);
siz_x(1) = siz_x(1)/2;
x = x([1:2:end]);
x = reshape(x, siz_x);

y = shiftdim(x, ndims(x) - (n-1));

