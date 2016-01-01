function x = myidwt_full(c, l, varargin)
%Full (N-level) dyadic wavelet reconstruction
%  in the 1st dimension of X  
%  
%   X = MYIDWT_FULL(C, L, F0, F1)
%   X = MYIDWT_FULL(C, L, 'wname')
%
% The number of levels, N, is implicit in [C,L] structure.
%
% See also: MYDWT_FULL.M 

% $Id: myidwt_full.m,v 1.1 2002/01/30 01:37:41 yrchen Exp yrchen $ yrchen@mit.edu  

if ischar(varargin{1})
  wname = varargin{1};
  [f0, f1] = wfilters(wname, 'r');
else
  f0 = varargin{1};
  f1 = varargin{2};
  wname = -1;
end

if length(l)==1 & l(1)==size(c,1)
  x = c;
elseif isnumeric(l{1}) & isnumeric(l{2}) % # levels = 1
  CA = md_get_portion(c,1,'1:end/2');
  CD = md_get_portion(c,1,'end/2+1:end');

  if ischar(wname)
    x = myidwt(CA, CD, wname, l{3});
  else
    x = myidwt(CA, CD, f0, f1, l{3});
  end
  
else
  la = l{1};
  ld = l{2};
  CA = md_get_portion(c,1, '1:end/2');
  CD = md_get_portion(c,1, 'end/2+1:end');

  
  if ischar(wname)
    x = myidwt(myidwt_full(CA, la, wname),...
	       myidwt_full(CD, ld, wname),...
	       wname, l{3});
  else
    x = myidwt(myidwt_full(CA, la, f0, f1),...
	       myidwt_full(CD, ld, f0, f1),...
	       f0, f1, l{3});
  end
end



