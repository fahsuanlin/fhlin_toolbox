function [sur_time_series]=surr_ft_algorithm2(time_series)
% function [sur_time_series,sur_time_series_o,time_series,sort_time_series]=surr_ft_algotithm(time_series,mode)


fake_time_series=randn(length(time_series),1);


sort_fake=sort(fake_time_series);
[sort_time_series,Index] = sort(time_series);
time_series(Index)=sort_fake;




fft_time_series=fftshift(fft(time_series));
abs_fft_time_series=abs(fft_time_series);

if(mod(length(time_series),2)==1)
    phi = rand((length(time_series)-1)/2,1)*2*pi;
    feq_surr_time_series(1:(length(time_series)-1)/2,1)=abs_fft_time_series(1:(length(time_series)-1)/2,1).*exp(1i*phi);
    feq_surr_time_series((length(time_series)-1)/2+1,1)=abs_fft_time_series((length(time_series)-1)/2+1,1);
    feq_surr_time_series((length(time_series)-1)/2+2:length(time_series),1)=abs_fft_time_series((length(time_series)-1)/2+2:end,1).*exp(-1i*phi(end:-1:1));
else
    phi = rand(length(time_series)/2-1,1)*2*pi;
    feq_surr_time_series(1,1)=abs_fft_time_series(1,1);
    feq_surr_time_series(2:length(time_series)/2,1)=abs_fft_time_series(2:length(time_series)/2,1).*exp(1i*phi);
    feq_surr_time_series(length(time_series)/2+1,1)=abs_fft_time_series(length(time_series)/2+1,1);
    feq_surr_time_series(length(time_series)/2+2:length(time_series),1)=abs_fft_time_series(length(time_series)/2+2:end,1).*exp(-1i*phi(end:-1:1));

end;
sur_time_series=ifft(ifftshift(feq_surr_time_series));


[B,Index] = sort(sur_time_series);
sur_time_series(Index)=sort_time_series;
