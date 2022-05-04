function [xrt]=etc_makechip(f1,f2,t2,duration,fn)
%
% etc_makechirp     making linear chirp clicks
%
% [xrt]=etc_makechip(f1,f2,t2,duration,fn)
%
% f1: the starting frequency (Hz)
% f2: the ending frequency (Hz)
% t2: the ending time (second)
% duration: the length of the chirp (second)
% fn: the output WAV file name (XXX.wav)
%
% fhlin@sep. 1, 2004
%

%f1=30;
%f2=50;
%t2=1.0;
fs=44.1e3;
%duration=0.5;

%fn='chirp_30_50_500ms.wav';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=f1;
b=(f2-f1)/t2.^2;

k=[0:(a+b.*duration)*duration-1];
if(f1~=f2)
    t=(sqrt(a^2+4.*k.*b)-a)./2./b;
else
    t=k./a;
end;

rt=round(t.*fs);
xrt(rt+1)=1;

%adding some zeros at the beginning and the ending of the clicks to avoid artifacts
xrt=[0 0 0, xrt, 0 0 0];

soundsc(xrt,fs);
stem(xrt);

if(~isempty(fn))
    if(strcmp(fn(end-1:end),'.wav'))
    else
        fn=strcat(fn,'.wav');
    end;
    fprintf('writing WAV file [%s]...\n',fn);
    wavwrite(xrt,fs,16,fn);
end;