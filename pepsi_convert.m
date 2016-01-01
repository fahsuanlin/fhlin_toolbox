function pepsi_convert(data,fn,flag_ft_spatial)

if(flag_ft_spatial)
    fprintf('applying 1D fft from spectrum to time...\n');
    kx_ky_t=ifft(fftshift(data,1),[],1);
else
    kx_ky_t=data;
end;

fprintf('writing output file...\n');
fp=fopen(fn,'w');
data_real=real(kx_ky_t);
data_real=data_real(:);
data_imag=imag(kx_ky_t);
data_imag=data_imag(:);
data_1d=zeros(length(data_real)*2,1);
data_1d(1:2:end)=data_real;
data_1d(2:2:end)=data_imag;
fwrite(fp,data_1d , 'single');
fclose(fp);
