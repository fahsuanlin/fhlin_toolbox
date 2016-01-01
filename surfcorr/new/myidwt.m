function x = myidwt(a,d,varargin)
%MYIDWT Single-level inverse discrete M-D PERIODIC wavelet transform,
%   MYIDWT performs a single-level tensor-product M-D PERIODIC 
%   wavelet reconstruction with respect to either a particular wavelet
%   ('wname', see WFILTERS for more information) or particular wavelet
%   reconstruction filters (Lo_R and Hi_R) that you specify.
%
%   X = MYIDWT(CA,CD,'wname') returns the single-level
%   reconstructed M-D approximation coefficients array X
%   based on M-D approximation and detail coefficients
%   arrays CA and CD, and using the wavelet 'wname'.
%
%   X = MYIDWT(CA,CD,Lo_R,Hi_R) reconstructs as above,
%   using filters that you specify:
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%   Lo_R and Hi_R must be the same length.
%
%   X = MYIDWT(CA,CD,'wname',L) or X = MYIDWT(CA,CD,Lo_R,Hi_R,L)
%   returns the length-L central portion of the result
%   obtained using MYIDWT(CA,CD,'wname'). L must be less than LX.
%
%   X = MYIDWT(CA,[], ... ) returns the single-level
%   reconstructed approximation coefficients X
%   based on approximation coefficients CA.
%   
%   X = MYIDWT([],CD, ... ) returns the single-level
%   reconstructed detail coefficients X
%   based on detail coefficients CD.
% 

%   $Revision: 1.1 $  yrchen@mit.edu

% Check arguments.
if errargn(mfilename,nargin,[3:9],nargout,[0:1]), error('*'), end
if isempty(a) & isempty(d) , x = []; return; end

if isstr(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end

% imposing periodic extension...
tmp = dwtmode('get');
if ~isequal(tmp.extMode, 'per'), dwtmode('per'); end


% Default: Length, Shift and Extension.
lx      = [];
dwtATTR = dwtmode('get');

% Check arguments for Length, Shift and Extension.
k = next;
while k<=length(varargin)
    if isstr(varargin{k})
        switch varargin{k}
           case 'mode'  , dwtATTR.extMode = varargin{k+1};
           case 'shift' , dwtATTR.shift1D = mod(varargin{k+1},2);
        end
        k = k+2;
    else
        lx = varargin{k}; k = k+1;
    end
end


% so far only 1D filters are allowed...
if ndims(Lo_R) > 2 | ndims(Hi_R) > 2 | min(size(Lo_R)) > 1 | min(size(Hi_R)) > 1
    error('the wavelet filters should be 1D vector for now...');
end
Lo_R = Lo_R(:);
Hi_R = Hi_R(:);

% flipping the dims for row vectors
if ndims(a)==2 & size(a,1)==1
    isRowVec_a =1;
    a=a.';
else
    isRowVec_a=0; 
end

if ndims(d)==2 & size(d,1)==1
    isRowVec_d =1;
    d=d.';
else
    isRowVec_d=0; 
end

sa = size(a); sd = size(d);
if sa(1) ~= sd(1)
    error(sprintf('%s: sizes of a and d are not compatible', mfilename));
end

if xor(isRowVec_a, isRowVec_d) ~= 0 % different shape
    error('the shapes of CA and CD are not compatible');
end


% Reconstructed Approximation.
x = myupsaconv('1D',a,Lo_R,lx,dwtATTR)+ ...   % Approximation.
    myupsaconv('1D',d,Hi_R,lx,dwtATTR);       % Detail.


if (isRowVec_a & isRowVec_d)
    x = x.';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = myupsaconv(type,x,f,s,dwtATTR,shiFLAG)
%UPSACONV Upsample and convolution.
%
%   Y = UPSACONV('1D',X,F_R) returns the one step dyadic
%   interpolation (upsample and convolution) of vector X
%   using filter F_R.
%
%   Y = UPSACONV('1D',X,F_R,L) returns the length-L central 
%   portion of the result obtained using Y = UPSACONV('1D',X,F_R).
%
% 
%   Y = UPSACONV('1D',X,F_R,DWTATTR) returns the one step
%   interpolation of vector X using filter F_R where the upsample 
%   and convolution attributes are described by DWTATTR.
%
%   Y = UPSACONV('1D',X,F_R,L,DWTATTR) combines the two 
%   other usages.
%

% Special case.
if isempty(x) , y = 0; return; end

% Check arguments.
% if errargn(mfilename,nargin,[3:6],nargout,[0:1]), error('*'), end

y = x;
if nargin<4 , sizFLAG = 1; else , sizFLAG = isempty(s); end
if nargin<5 , dwtATTR = dwtmode('get'); end
if nargin<6 , shiFLAG = 1; end
dumFLAG = ~isstruct(dwtATTR);
if ~dumFLAG , perFLAG = isequal(dwtATTR.extMode,'per'); else , perFLAG = 0; end
shiFLAG = shiFLAG & ~dumFLAG;


%ly = length(y);
ly = size(y,1);
lf = length(f);
if sizFLAG
    if ~perFLAG , s = 2*ly-lf+2; else , s = 2*ly; end
end
if shiFLAG , shift = dwtATTR.shift1D; else , shift = 0; end
shift = mod(shift,2);
if ~perFLAG
    error('*')
    if sizFLAG , s = 2*ly-lf+2; end
    y = wconv('1D',dyadup(y,0),f);
    y = wkeep(y,s,'c',shift);
else
    if sizFLAG , s = 2*ly; end
%    [ly,lf,s]
    y = mydyadup(y); %', y=y'; %dyadup(y,0,1);
    y = mywextend(y,lf/2,lf); %', y=y'; %wextend('1D','per',y,lf/2);
    y = filter(f, 1, y); %', y=y'; %wconv('1D',y,f);
    y = mywkeep(y,2*ly,lf); %wkeep(y,2*ly,lf);
    y = mywshift(y,shift); % wshift('1D',y,shift);
    y = mywkeep(y,s,1);
end


%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%
function y = mydyadup(x)
s = size(x);
s(1) = s(1)*2;

y = zeros(s);

cmd = 'y(1:2:end';
for k=1:ndims(x)-1
    cmd = strcat(cmd, ',:');
end
cmd = strcat(cmd, ') = x;');
eval(cmd);
