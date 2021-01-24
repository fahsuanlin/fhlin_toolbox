function y = mywshift(x,p)
%WSHIFT Shift Vector or Matrix.
%   Y = myWSHIFT(X,P) 
%   performs a P-circular shift of the FIRST dim of X.
%   The shift P must be an integer, positive for right to left
%   shift and negative for left to right shift.
%
%
%   Example 1D:
%     x = [1 2 3 4 5]
%     wshift('1D',x,1)  = [2 3 4 5 1]
%     wshift('1D',x,-1) = [5 1 2 3 4]

if isempty(x) | all(p==0) , y = x; return; end

if nargin<2 , p = 1; end

L = size(x,1); %length(x);
p = rem(p,L);

if p<0 , p = L+p; end

cmd = 'y = x([p+1:L,1:p]';
for k=2:ndims(x)
    cmd = strcat(cmd, ',:');
end

cmd = strcat(cmd, ');');
eval(cmd);

