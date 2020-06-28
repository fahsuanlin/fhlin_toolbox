function [cc, ll] = cir_wpdec(C, L, wname, N, L_p, which_bands)
% [CC, LL] = CIR_WPDEC(C, L, wname, N, L_p, WHICH_BANDS)
%
% Performs L_p levels of Full-DWT on any of 
% the specified HL, LH, or HH bands at the N-th level.  
% {C,L} is the DWT structure returned by CIR_WAVEDEC.M.
%  
% WHICH_BANDS is a cell of strings composed of '0' or '1' signifying 
% which half of the corresponding dimensions is to be decomposed. 
%   e.g. WHICH_BANDS = {'01', '11'} in a 2-D case means 
%          [0 pi/2] for the 1st dim, and [pi/2 pi] for the 2nd dim;
%     and [pi/2 pi] for the 1st dim, and [pi/2 pi] for the 2nd dim.
%

% $Id: cir_wpdec.m,v 1.1 2002/01/30 01:34:14 yrchen Exp yrchen $ yrchen@mit.edu  

nd = ndims(C);
if ischar(which_bands)
  which_bands = {which_bands};
end

%length(which_bands)

for i = 1:length(which_bands) % loops through WHICH_BANDS(:)
  if nd ~= length(which_bands{i})
    error('CIR_WPDEC.M: Length of WHICH_BANDS(i) is not equal to NDIMS(C).');
  end
  curr_band = which_bands{i};
  
  % Get sub_input from C based on curr_band...
  sub_input = md_getpkt(C, L, N, curr_band);
  [cc{i}, ll{i}] = cir_wavedec_full(sub_input, L_p, wname);
  
end











