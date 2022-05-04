function output=cir_waverec(input,l,f0,f1)
%CIR_WAVEREC Multilevel M-D Periodic wavelet reconstruction.
%    CIR_WAVEREC performs a multilevel M-D periodic wavelet reconstruction
%    using either a specific wavelet ('wname', see WFILTERS) or
%    specific reconstruction filters (Lo_R and Hi_R).
%
%    X = CIR_WAVEREC(C,L,Lo_R,Hi_R) or
%    X = CIR_WAVEREC(C,L,'wname') reconstructs the signal X
%    based on the multilevel wavelet decomposition structure
%    [C,L] (see CIR_WAVEDEC).
%    
%    See also MYAPPCOEF, MYIDWT, CIR_WAVEDEC

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
% 2001/11/16: use MYIDWT.m with DWTMODE('per') .... yrchen@mit.edu

% $Id: cir_waverec.m,v 1.2 2001/11/16 21:01:51 yrchen Exp yrchen $

if ischar(f0)
    [f0,f1]=wfilters(f0, 'r');
end

output = myappcoef(input,l,f0,f1,0);