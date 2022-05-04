function basis=wavelet_dbbasis(support,order,varargin)
dwtmode('per');
res_enhance=0;
if(nargin==3)
    res_enhance=varargin{1};
end;

wname='bior4.4';

[c,l]=wavedec([1:support*2^res_enhance]',order+res_enhance,wname);

basis=[];

% low-pass: scaling function
for i=1:l(1)
    b=waverec([1:length(c)]==i,l,wname);
    basis=[basis,b'];
end;


% high-pass: wavelet function
for i=1:l(2)
    b=waverec([1:length(c)]==i+l(1),l,wname);
    basis=[basis,b'];
end;

return;