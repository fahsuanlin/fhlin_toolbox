clear

load sublena
x = sublena;
x(257,259)=0;

wname = 'bior4.4'

[c,l]=cir_wavedec(x,1,wname);
[cc,ll]=cir_wpdec(c,l,wname, 1, 2, {'11','10'});

% processing of the packet-subbands...
cc{1} = cc{1}*0;
cc{2} = cc{2} * 0;

% processing of the DWT coefs {c,l}
% omitted...

%return;
[ct,lt]=cir_wprec(c,l,1,cc,ll,wname,{'11','10'});
xx = cir_waverec(ct,lt,wname);

norm(x-xx,inf)
