function index_range_str = myappdet_idxstr(L, N, app_or_det)
% index_range_str = myappdet_idxstr(L, N, app_or_det)
% MYAPPDET_IDXSTR Extract detail coefficients from MYMDWT

% $Id: myappdet_idxstr.m,v 1.1 2002/01/30 01:37:41 yrchen Exp yrchen $ yrchen@mit.edu


%% detail coefs
longs = L;
first = cumsum(longs)+1;
first = first(end-2:-1:1);
longs = longs(end-1:-1:2);
last  = first+longs-1;

index_range_str = sprintf('[%d:%d]', first(N), last(N));
  
if app_or_det == '0'  % app coefs
  index_range_str = sprintf('[%d:%d]', 1, last(N)/2);
elseif app_or_det ~= '1'
  error(sprintf('invalid value for app_or_det = %g', app_or_det))
end
