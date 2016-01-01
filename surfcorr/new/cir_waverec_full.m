function input=cir_waverec_full(input,l,f0,f1)
%CIR_WAVEREC_FULL Multilevel M-D Periodic FULL wavelet reconstruction.
%    CIR_WAVEREC_FULL performs a multilevel M-D periodic 
%    FULL wavelet reconstruction using either a specific 
%    wavelet ('wname', see WFILTERS) or
%    specific reconstruction filters (Lo_R and Hi_R).
%
%    X = CIR_WAVEREC_FULL(C,L,Lo_R,Hi_R) or
%    X = CIR_WAVEREC_FULL(C,L,'wname') reconstructs the signal X
%    based on the multilevel FULL wavelet decomposition structure
%    [C,L] (see CIR_WAVEDEC_FULL).
%    
%    See also MYIDWT_FULL, CIR_WAVEDEC_FULL

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
% 2001/11/16: use MYIDWT.m with DWTMODE('per') .... yrchen@mit.edu

% $Id: cir_waverec_full.m,v 1.1 2002/01/30 01:33:24 yrchen Exp yrchen $

if ischar(f0)
    [f0,f1]=wfilters(f0, 'r');
end

nd = ndims(input);

if nd ==2 & min(size(input))==1
    disp('[degeneracy] input is a vector. Check back for possible bugs');
end

for n=1:nd  % the n-th dim...
    input = shiftdim(input, n-1);
    input = myidwt_full(input, l{n}, f0, f1);
    input = shiftdim(input, nd-(n-1));
end

