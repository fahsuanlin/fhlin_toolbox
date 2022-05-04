function [a,d] = mydwt(x,varargin)
%DWT Single-level discrete 1-D wavelet transform. ASSUME PERIODIC EXTENSION...
%   DWT performs a single-level 1-D wavelet decomposition
%   with respect to either a particular wavelet ('wname',
%   see WFILTERS for more information) or particular wavelet filters
%   (Lo_D and Hi_D) that you specify.
%
%   [CA,CD] = DWT(X,'wname') computes the approximation
%   coefficients vector CA and detail coefficients vector CD,
%   obtained by a wavelet decomposition of the vector X.
%   'wname' is a string containing the wavelet name.
%
%   [CA,CD] = DWT(X,Lo_D,Hi_D) computes the wavelet decomposition
%   as above given these filters as input:
%   Lo_D is the decomposition low-pass filter.
%   Hi_D is the decomposition high-pass filter.
%   Lo_D and Hi_D must be the same length.
%
%   Let LX = length(X) and LF = the length of filters; then
%   length(CA) = length(CD) = LA where LA = CEIL(LX/2),
%   if the DWT extension mode is set to periodization.
%   LA = FLOOR((LX+LF-1)/2) for the other extension modes.  
%   For the different signal extension modes, see DWTMODE. 
%
%   [CA,CD] = DWT(...,'mode',MODE) computes the wavelet 
%   decomposition with the extension mode MODE you specify.
%   MODE is a string containing the extension mode.
%   Example: 
%     [ca,cd] = dwt(x,'db1','mode','sym');
%
%   See also DWTMODE, IDWT, WAVEDEC, WAVEINFO.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision 16-Sep-1999.
%   Copyright 1995-2000 The MathWorks, Inc.
%   $Revision: 1.12 $

% Check arguments.
if errargn(mfilename,nargin,[2:7],nargout,[0:2]), error('*'), end

if isstr(varargin{1})
    [Lo_D,Hi_D] = wfilters(varargin{1},'d'); next = 2;
else
    Lo_D = varargin{1}; Hi_D = varargin{2};  next = 3;
end

% imposing periodic extension...
tmp = dwtmode('get');
if ~isequal(tmp.extMode, 'per'), dwtmode('per'); end

% Default: Shift and Extension.
dwtATTR = dwtmode('get');
shift   = dwtATTR.shift1D;
dwtEXTM = dwtATTR.extMode;

% Check arguments for Extension and Shift.
for k = next:2:nargin-1
    switch varargin{k}
      case 'mode'  , dwtEXTM = varargin{k+1};
      case 'shift' , shift   = mod(varargin{k+1},2);
    end
end

% so far only 1D filters are allowed...
if ndims(Lo_D) > 2 | ndims(Hi_D) > 2 | min(size(Lo_D)) > 1 | min(size(Hi_D)) > 1
    error('the wavelet filters should be 1D vector for now...');
end
Lo_D = Lo_D(:);
Hi_D = Hi_D(:);


% flipping the dims for row vectors
if ndims(x)==2 & size(x,1)==1
    isRowVec =1;
    x=x.';
else
    isRowVec=0;
end



% Compute sizes.
lf = length(Lo_D);
%lx = length(x);
lx = size(x,1);

% DEBUG...
%dwtEXTM, shift, lf,lx




% Extend, Decompose &  Extract coefficients.
flagPer = isequal(dwtEXTM,'per');
if ~flagPer
    lenEXT = lf-1; lenKEPT = lx+lf-1;
else
    lenEXT = lf/2; lenKEPT = 2*ceil(lx/2);
end

%y = mywextend('1D',dwtEXTM,x,lenEXT);
y = mywextend(x, lenEXT, lf);


a = myconvdown(y,Lo_D,lenKEPT,shift);
d = myconvdown(y,Hi_D,lenKEPT,shift);

if isRowVec
    a = a.';
    d = d.';
end

%-----------------------------------------------------%
% Internal Function(s)
%-----------------------------------------------------%
%-----------------------------------------------------%
function y = myconvdown(x,f,lenKEPT,shift)

y = filter(f,1,x); %wconv('1D',x,f);
y = mywkeep(y,lenKEPT);
y = mydyaddown(y,shift);

%-----------------------------------------------------%
function x=mydyaddown(x,shift)
if rem(shift,2)==0
    cmd = 'x = x(2:2:end';
else
    cmd = 'x = x(1:2:end';
end

for k=1:ndims(x)-1
    cmd = strcat(cmd, ',:');        
end

cmd = strcat(cmd, ');');
eval(cmd);

%-----------------------------------------------------%

