function [scrambled]=etc_phasescramble(x)
% etc_phasescramble scramble the phase of a 1-D signal
%
% [scrambled]=etc_phasescramble(x)
%
% x: input 1-D signal
% scrambled: output 1-D signal after phase scrambling
%
% fhlin@Mar 21 2018
%

[nl,nc]=size(x);
x=x(:);
fx=fft(x);
fscrambled=fx;

if(mod(length(x),2)==1)
    a=angle(fscrambled(2:(length(x)+1)/2));
    tmp=randperm(length(a));
    a=a(tmp); %randmized phase
    b=-flipud(a);
    fscrambled(2:end)=abs(fscrambled(2:end)).*exp(sqrt(-1).*[a(:); b(:)]);
else
    a=angle(fscrambled(2:length(x)/2));
    tmp=randperm(length(a));
    a=a(tmp); %randmized phase
    c=angle(fscrambled(length(x)/2+1));
    b=-flipud(a);
    fscrambled(2:end)=abs(fscrambled(2:end)).*exp(sqrt(-1).*[a(:); c; b(:)]);

end;

scrambled=(ifft(fscrambled));
scrambled=reshape(scrambled,[nl,nc]);
    
    
return;
    