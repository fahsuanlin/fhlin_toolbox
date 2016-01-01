


fname = 'meas.out';
fid = fopen(fname, 'r', 'l');
nNavs = 3; 
meas_out_start_offset = fread(fid, 1, 'long'); 
fseek(fid, meas_out_start_offset, 'bof'); 
pos1=ftell(fid);

[adc_data, mdh] = read_mdh_adc(fid);
nADCsamples = mdh.SamplesInScan;
fseek(fid, meas_out_start_offset, 'bof'); 
pos2=ftell(fid);
navs = zeros(nNavs, nADCsamples);

   for rr = 1:nNavs

  [adc_data, mdh] = read_mdh_adc(fid);

  if mdh.EvalInfoMask(25)  % MDH_REFLECT
   %adc_data = fliplr(adc_data);
   %adc_data = adc_data([end 1:end-1]);
   navs(rr, :) = adc_data;
else
    navs(rr, :) = adc_data;
    
 end
  
end
   
    figure;
imagesc(abs(navs(:,:)));
figure;subplot(311);
plot(abs(navs(1,:)));
subplot(312);plot(abs(navs(2,:)));
subplot(313);plot(abs(navs(3,:)));

figure
plot(abs(navs(1,:)))
hold on
plot(abs(navs(2,:)),'r')
plot(abs(navs(3,:)),'g')

