function y = cir_idwt(x,h0,h1,varargin)
% y = cir_idwt(x,f0,f1[,n])
% we can calculate synthesis filter bank directly from analysis filter bank...
%

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

%normalize filter energy
%h0=h0./sqrt(h0*h0');
%h1=h1./sqrt(h1*h1');


%generate the synthesis filter bank  from analysis filter bank
f0=((-1).^([1:length(h1)]).*(-1)).*h1;
f1=((-1).^([1:length(h0)])).*h0;




if nargin==3
   n = 1;
else
   n = varargin{1};
end

%%%%
[lp,hp]=dog(x,n);
%%%

phase_delay=(length(conv(f0,h0))-1)/2;
phase_delay = floor(phase_delay/2);

y1 = cir_conv(up_n(lp,n),f0,n);
y2 = cir_conv(up_n(hp,n),f1,n);

y=y1+y2;

y=shift(y,n,phase_delay);

%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%
function [lp,hp] = dog(x,n)
% splitting lp and hp for the n-th dim

% rotate the n-th dim to the 1st...
x = shiftdim(x, n-1);

cmd_lp = sprintf('lp = x(1:end/2');
cmd_hp = sprintf('hp = x(1+end/2:end');

for k=1:ndims(x)-1
   cmd_lp = strcat(cmd_lp, ',:');
   cmd_hp = strcat(cmd_hp, ',:');   
end
cmd_lp = strcat(cmd_lp, ');');
cmd_hp = strcat(cmd_hp, ');');
eval(cmd_lp);
eval(cmd_hp);

lp = shiftdim(lp, ndims(x) - (n-1));
hp = shiftdim(hp, ndims(x) - (n-1));

return;

%%%%%%%%%%%%%%%%%%%
function y = up_n(x,n)

x = shiftdim(x, n-1);
siz_x = size(x);
siz_x(1) = siz_x(1)*2;

y=zeros(1,prod(size(x))*2);
y([1:2:end]) = x(1:end);
x = reshape(y, siz_x);

y = shiftdim(x, ndims(x) - (n-1));

