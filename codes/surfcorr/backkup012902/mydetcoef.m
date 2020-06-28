function varargout = mydetcoef(coefs,longs,levels)
%MYDETCOEF Extract detail coefficients from MYMDWT
%    D = MYDETCOEF(C,L,N) extracts the detail coefficients
%    at level N from the wavelet decomposition structure [C,L].
%    C is an n-dim data whose 1st dimension, when combined with L (a vector),
%    is the result returned by 
%       [C, LL] = CIR_WAVEDEC(X,N,'wname'), 
%    where L = LL{1}.
%    Namely, L describes how C is structured in its 1st dimension
%       C      = CAT(1, [app. coef.(N)], [det. coef.(N)], ... ,[det. coef.(1)])
%       L(1)   = SIZE([app. coef.(N)], 1)
%       L(i)   = SIZE([det. coef.(N-i+2)], 1) for i = 2,...,N+1
%       L(N+2) = size(X,1).

% $Id: mydetcoef.m,v 1.1 2001/11/16 20:17:25 yrchen Exp $ yrchen@mit.edu

first = cumsum(longs)+1;
first = first(end-2:-1:1);
longs = longs(end-1:-1:2);
last  = first+longs-1;
nblev = length(levels);
tmp   = cell(1,nblev);
for j = 1:nblev
    k = levels(j);
    cmd = 'tmp{j} = coefs(first(k):last(k)';
    for n=2:ndims(coefs), cmd = [cmd ',:']; end
    cmd = [cmd, ');'];
    eval(cmd);
end

if nargout>0
   if (nargout==1 & nblev>1) 
       varargout{1} = tmp;
   else
       varargout = tmp;
   end
end





