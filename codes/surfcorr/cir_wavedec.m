function [output, l]=cir_wavedec(input,level,h0,h1)
%CIR_WAVEDEC Multi-level multi-dimensional Periodic wavelet decomposition
%    CIR_WAVEDEC performs a multilevel multidimensional periodic wavelet 
%    analysis using either a specific wavelet 'wname' or a specific set 
%    of wavelet decomposition filters (see WFILTERS).
%
%    [C,L] = CIR_WAVEDEC(X,N,Lo_D,Hi_D) or 
%    [C,L] = CIR_WAVEDEC(X,N,'wname')
%    returns the wavelet decomposition of the M-D signal X 
%    at level N for all its dimensions, using {Lo_D,Hi_D} or 'wname' 
%
%    The result in C is a multidimensional tensor product wavelet decomposition.
%    L is a cell array. L{k} is the length bookkeeping info along the k-th dim.
% 

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
% 2001/11/16: use MYDWT.m with DWTMODE('per') .... yrchen@mit.edu
  
% $Id: cir_wavedec.m,v 1.5 2001/11/16 21:04:22 yrchen Exp yrchen $  

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
for n=1:nd  % the n-th dim...
    input = shiftdim(input, n-1);
    l{n}=size(input,1);
    output=[];
    for i=1:level
        [input, d] = mydwt(input, h0, h1);
        output = cat(1, d, output);
        l{n} = [size(d,1), l{n}];
    end
    output = cat(1, input, output);
    l{n} = [size(input,1), l{n}];
    input = shiftdim(output, nd-(n-1));
end
output = input;




