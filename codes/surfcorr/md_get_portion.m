function [y, cmd] = md_get_portion(x, nth_dim, varargin)
% y = md_get_portion(x, nth_dim, 'range_str')
% y = md_get_portion(x, nth_dim, 1, 20)
%
% e.g. y = md_get_portion(x, 1, '1:20')
%  or  y = md_get_portion(x, 1, 1, 20)
% evaluates the following command
%      y = x(1:20,:);

% $Id: md_get_portion.m,v 1.1 2002/01/30 01:37:41 yrchen Exp yrchen $ yrchen@mit.edu

nd = ndims(x);

if nth_dim > nd
  error('nth_dim exceeds ndims(x)')
end

if ischar(varargin{1})
  range_str = varargin{1};
else
  range_str = sprintf('%d:%d', varargin{1}, varargin{2});
end


cmd = 'y = x(';

for i=1:nth_dim-1
  cmd = strcat(cmd, ':,');
end

cmd = strcat(cmd, ['[',  range_str, ']']);

for i=nth_dim+1:nd
  cmd = strcat(cmd, ',:');  
end

cmd = strcat(cmd, ');');

eval(cmd)

































