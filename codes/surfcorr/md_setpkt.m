function C = md_setpkt(C, L, N, which_band, sub_input)
% C = MD_SETPKT(C, L, N, WHICH_BAND, sub_input)
%   N is the level at which the extracted subband denoted by WHICH_BAND
%   will be restored. {C,L} is the DWT structure returned by CIR_WAVEDEC.M.
%   WHICH_BAND is a string consisting of '0' or '1' signifying which half of
%   the corresponding dimensions is to be decomposed. 
%     e.g. '01' means [0 pi/2] for the 1st dim, and [pi/2 pi] for the 2nd dim.


% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001
% $Id: md_setpkt.m,v 1.1 2002/01/30 01:37:41 yrchen Exp yrchen $ yrchen@mit.edu

cmd=sprintf('C(%s', myappdet_idxstr(L{1},N, which_band(1)));
   
for i=2:ndims(C)
  cmd=strcat(cmd,sprintf(',%s', myappdet_idxstr(L{i},N, which_band(i))));
end

cmd=strcat(cmd,') = sub_input;');

eval(cmd)







