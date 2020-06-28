function [output, varargout]=cir_waverec_packet(input,L,levels_pkt, h0,h1, varargin)
% [output, varargout]=CIR_WAVEREC_PACKET(INPUT,L,levels_pkt,h0,h1, WHICH_BAND [,WHICH_BAND,...])
% Performs "multiple level of DWT" on any of 
% the specified HL, LH, or HH bands at the L-th level.
% INPUT is supposed to be precomputed DWT coefficients based on (h0,h1).
% WHICH_BAND is a string composed of '0' or '1' signifying which half of
% the corresponding dimensions is to be decomposed. 
%   e.g. '01' means [0 pi/2] for the 1st dim, and [pi/2 pi] for the 2nd dim.

% fhlin@mit.edu, yrchen@bu.edu, 05/28/2001

output=[];

input_size=size(input);

%fprintf('Processing the %d-th level...\n',L);

%get sub-samples of input
for k=1:length(varargin)
   which_band = varargin{k};
   str=makestr_pkt(L,size(input),which_band,0);
%   fprintf('%s\t', str);
   eval(str);
   
   sub_input=cir_waverec_full(sub_input,levels_pkt,h0,h1);
   
   %restore sub-samples of DWT
   str=makestr_pkt(L,size(input),which_band,1);
%   fprintf('%s\n', str);
   
   eval(str);
   
   %imagesc(input);
   %pause;
   
end

output=input;

