function y = mywkeep(x,L,first)
%function y = mywkeep(x,L [,first])
%WKEEP  Keep CENTRAL part (length-L) of the 1st dim of x

if nargin==2
    first = 1 + floor((size(x,1) - L)/2);
end

cmd = 'y = x(first:first+L-1';
for k = 1:ndims(x)-1
    cmd = strcat(cmd, ',:');
end

cmd = strcat(cmd, ');');
eval(cmd);
