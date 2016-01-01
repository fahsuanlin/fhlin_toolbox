function [c,l] = mydwt_full(x, level, varargin)
%Full N-level dyadic wavelet decomposition 
%  along the 1st dimension of X
%  
%  [c,l] = MYDWT_FULL(X, N, h0, h1)
%  [c,l] = MYDWT_FULL(X, N, 'wname')
  
% $Id: mydwt_full.m,v 1.1 2002/01/30 01:37:41 yrchen Exp yrchen $ yrchen@mit.edu  
  
if ischar(varargin{1})
  wname = varargin{1};
  [h0,h1] = wfilters(wname);
else
  h0 = varargin{1};
  h1 = varargin{2};
end

if level == 0
  c = x;
  l = size(x,1);
else 
  [a,d] = mydwt(x, h0, h1);
  [ca,la] = mydwt_full(a, level-1, h0, h1);
  [cd,ld] = mydwt_full(d, level-1, h0, h1);
  l = {la ld size(x,1)};
  c = cat(1,ca,cd); 
end

