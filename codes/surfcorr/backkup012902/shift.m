function [y] = shift(x,n,delay)
%function [y] = shift(x,n,delay)
% delay along the n-th dimension of x

% $Id: shift.m 1.1 2001/08/20 20:17:49 yrchen Exp yrchen $

x = shiftdim(x, n-1);

%cmd = sprintf('y = x([end-delay+1:end, 1:end-delay ]');

delay = mod(delay,size(x,1));
cmd = sprintf('y = x([delay+1:end 1:delay ]');

for k=1:ndims(x)-1
   cmd = strcat(cmd, ',:');
end
cmd = strcat(cmd, ');');
eval(cmd);

y = shiftdim(y, ndims(x) - (n-1));

return;
