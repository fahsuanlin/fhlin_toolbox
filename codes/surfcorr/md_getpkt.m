function sub_input=md_getpkt(C, L, N, which_band)
% sub_input=MD_GETPKT(C, L, N, WHICH_BAND)
%   N is the level at which the subband denoted by WHICH_BAND is extracted.  
%   {C,L} is the DWT structure returned by CIR_WAVEDEC.M.
%   WHICH_BAND is a string consisting of '0' or '1' signifying which half of
%   the corresponding dimensions is to be decomposed. 
%     e.g. '01' means [0 pi/2] for the 1st dim, and [pi/2 pi] for the 2nd dim.


% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
% $Id: md_getpkt.m,v 1.1 2002/01/30 01:37:29 yrchen Exp $ yrchen@mit.edu

cmd=sprintf('sub_input=C(%s', myappdet_idxstr(L{1},N, which_band(1)));
   
for i=2:ndims(C)
  cmd=strcat(cmd,sprintf(',%s', myappdet_idxstr(L{i},N, which_band(i))));
end

cmd=strcat(cmd,');');

eval(cmd)








