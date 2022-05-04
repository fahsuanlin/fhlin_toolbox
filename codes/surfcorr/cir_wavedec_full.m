function [output, l]=cir_wavedec_full(input,level,h0,h1)
%CIR_WAVEDEC_FULL 
%    Multi-level multi-dimensional Periodic FULL wavelet decomposition
%    CIR_WAVEDEC_FULL performs a multilevel multidimensional full 
%    periodic wavelet analysis using either a specific wavelet 'wname' 
%    or a specific set of wavelet decomposition filters (see WFILTERS).
%
%    [C,L] = CIR_WAVEDEC_FULL(X,N,Lo_D,Hi_D) or 
%    [C,L] = CIR_WAVEDEC_FULL(X,N,'wname')
%    returns the FULL wavelet decomposition of the M-D signal X 
%    at level N for all its dimensions, using {Lo_D,Hi_D} or 'wname' 
%
%    The result in C is a multidimensional tensor product 
%    FULL wavelet decomposition.
%    L is a cell array. L{k} is the length bookkeeping info in the k-th dim.
% 

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
% 2001/11/16: use MYDWT.m with DWTMODE('per') .... yrchen@mit.edu
  
% $Id: cir_wavedec_full.m,v 1.1 2002/01/30 01:33:24 yrchen Exp yrchen $  

if nargout <2
    error(sprintf('%s requires at least 2 output arguments', mfilename))
end

if ischar(h0)
    [h0,h1]=wfilters(h0);
end

input_size=size(input);
max_level=floor(log(input_size(1))./log(2));
if(level>max_level)
   fprintf('specified level (%d) exceeds the maximal level (%d) in wavelet decomposition\n',level,max_level);
   return;
end;

nd = ndims(input);

if nd ==2 & min(size(input))==1
    disp('[degeneracy] input is a vector. Check back for possible bugs');
end

for n=1:nd  % the n-th dim...
    input = shiftdim(input, n-1);

    [input, l{n}] = mydwt_full(input, level, h0, h1);

    input = shiftdim(input, nd-(n-1));
end
output = input;










