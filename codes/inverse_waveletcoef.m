function Y = inverse_waveletcoef(f,s,Fs,width,varargin)
% function y = inverse_waveletcoef(f,s,Fs,width)
%
% Return a vector containing the wavelet coefficients as a
% function of time for frequency f. The energy
% is calculated using Morlet's wavelets.
% s : signal
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
%
%

flag_normalize=0;

flag_causal=0; %only data *before* the current measurement
flag_anticausal=0; %only data *after* the current measurement

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_normalize'
            flag_normalize=option_value;
        case 'flag_causal'
            flag_causal=option_value;
        case 'flag_anticausal'
            flag_anticausal=option_value;
        otherwise
            fprintf('unknown option [%s].\n',option);
            return;
    end;
end;


for i=1:length(f)
    dt = 1/Fs;
    sf = f(i)/width;
    st = 1/(2*pi*sf);
    
    t=-3.5*st:dt:3.5*st;

    if(flag_causal)
        t=t(find(t<0));
    end;
    if(flag_anticausal)
        t=t(find(t>0));
    end;
    
    [m, amp] = morlet(f(i),t,width);
    if(flag_normalize)
        m=m./abs(amp);
    end;
    %plot(t,real(m),'r'); hold on;
    %plot(t,imag(m),'b'); hold on;
    
%    y = conv2(1,m,s,'same');
    
    
    M=repmat([m,zeros(1,size(s,2)-length(m))],[size(s,1),1]);
%    %using FFT for circular convolution
%    y=ifft(fft(s,[],2).*fft(M,[],2),[],2);


	y=fft_conv2(s,m,'symm','same','conv');
    %plot(s,'r'); hold on;
    %plot(abs(y),'b'); hold on;
    %keyboard;
    
	%y=fft_conv2(s,m,'symm','same','fft');

%    if(min(size(y))>1)
%        y = y(:,ceil(length(m)/2):size(y,2)-floor(length(m)/2));
%    else
%        y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));
%    end;
    
    Y(i,:,:)=y;
    
end;

Y=squeeze(Y);

return;


function [y, amp] = morlet(f,t,width)
% function y = morlet(f,t,width)
%
% Morlet's wavelet for frequency f and time t.
% The wavelet will be normalized so the total energy is 1.
% width defines the ``width'' of the wavelet.
% A value >= 5 is suggested.
%
% Ref: Tallon-Baudry et al., J. Neurosci. 15, 722-734 (1997)
%
%
% Ole Jensen, August 1998

sf = f/width;
st = 1/(2*pi*sf);
A = 1/sqrt(st*sqrt(pi));
y = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);
amp=A;