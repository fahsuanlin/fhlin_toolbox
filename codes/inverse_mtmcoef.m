function Y = inverse_mtmcoef(f,s,Fs,width,varargin)
% function y = inverse_mtmcoef(f,s,Fs,width)
%
% Return a vector containing the coefficients as a
% function of time for frequency f. The energy
% is calculated using multitapers.
%
% s : signal
% Fs: sampling frequency
% width : width of Morlet wavelet (>= 5 suggested).
%
%

for i=1:length(f)
    dt = 1/Fs;
    sf = f(i)/width;
    st = 1/(2*pi*sf);

    t=-3.5*st:dt:3.5*st;

    NW=3;
    [dpss_E,dpss_V] = dpss(length(t),NW);
    for idx=1:size(dpss_E,2)
        m=dpss_E(:,idx)'.*exp(sqrt(-1)*2*pi*f(i).*t);
        m=m./sum(m(:))';

        M=repmat([m,zeros(1,size(s,2)-length(m))],[size(s,1),1]);
        %    %using FFT for circular convolution
        %    y=ifft(fft(s,[],2).*fft(M,[],2),[],2);
        Y(i,:,:,idx)=fft_conv2(s,m,'symm','same','conv');
    end;
end;

Y=squeeze(Y);

return;
