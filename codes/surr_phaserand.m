function [s]=surr_phaserand(time_series)
% function [sur_time_series,sur_time_series_o,time_series,sort_time_series]=surr_ft_algotithm(time_series,mode)


k=fft(time_series);
amp=abs(k);
phase=angle(k);
if(mod(length(k),2)==0) %even length
    phase_rand=phase(2:length(phase)/2);
    phase0=phase(1);
    phaseend=phase(length(phase)/2+1);
    idx=randperm(length(phase_rand));
    phase_rand=phase_rand(idx);
    %
    %phase_rand=rand(size(phase_rand)).*2.*pi-pi;
    %
    phase_r=[phase0; phase_rand(:); phaseend; -1.*flipud(phase_rand(:))];
else %odd length
    phase_rand=phase(2:(length(phase)+1)/2);
    phase0=phase(1);
    idx=randperm(length(phase_rand));
    phase_rand=phase_rand(idx);
    %
    %phase_rand=rand(size(phase_rand)).*2.*pi-pi;
    %
    phase_r=[phase0; phase_rand(:); -1.*flipud(phase_rand(:))];  
end;

s=amp(:).*exp(sqrt(-1).*phase_r(:));
s=reshape(real(ifft(s)),size(time_series));

return;