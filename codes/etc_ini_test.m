function [ref_data, ini_data, error, error_ch]=etc_ini_test(dir_ref,dir_ini,n_chan,ini_time)
%	etc_ini_test		test the matching between reference scan and accelerated scan of ini acquisition
%
% [ref_data, ini_data]=etc_ini_test(dir_ref,dir_ini,n_chan,ini_time)
%	dir_ref: the file path for reference scan where bfloat files are stored
%	dir_ini: the file path for accelerated scan where bfloat files are stored
% n_chan: the number of channel
% ini_time: the time point index for ini accelerated scan to calculate the matching
%
% ref_data: reference ini data
% ini_data: accelerated ini data
% error: total percentage error of the mismatching bewteen the reference and accelerated scan
% error_ch: percentage error of the mismatching bewteen the reference and accelerated scan in each channel
%
%
% fhlin@oct 25 2007
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% testing values
%close all; clear all;
%
%dir_ref='c:\users\fhlin\desktop\ref_01';
%dir_ini='c:\users\fhlin\desktop\acc_01';
%n_chan=8;
%ini_time=10; %the time point for ini acquisition to be compared with simulated ini (created from reference)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdir=pwd;
cd(dir_ref);
[ref_data,d1]=ice_show(dir_ref);

cd(dir_ini);
for ch=1:n_chan
    fprintf('loading ini channel [%d] (%d channels in total)\r',ch, n_chan);
    dre=fmri_ldbfile(sprintf('meas_slice001_chan%03d_re.bfloat',ch));
    dim=fmri_ldbfile(sprintf('meas_slice001_chan%03d_im.bfloat',ch));
    ini(:,:,ch,:)=dre+sqrt(-1).*dim;
end;
fprintf('\n');

%simulated ini acqusition from reference
ini_sim=flipdim(squeeze(mean(ref_data,2)),2);

cd(pdir);

%output as graphics
subplot(221)
fmri_mont(real(ini_sim)); colorbar;
subplot(222)
fmri_mont(imag(ini_sim)); colorbar;
subplot(223)
fmri_mont(real(ini(:,:,:,ini_time))); colorbar;
subplot(224)
fmri_mont(imag(ini(:,:,:,ini_time))); colorbar;

ini_data=squeeze(ini(:,:,:,ini_time));

diff=(ini_data-ini_sim);
for ch=1:n_chan
    tmp0=diff(:,:,ch);
    tmp1=ini_sim(:,:,ch);
    error_ch(ch)=sum(abs(tmp0(:)).^2).*100./sum(abs(tmp1(:)).^2);
    fprintf('channel [%d] error =%2.2f%%\n',ch,error_ch(ch));
end;
error=sum(abs(diff(:)).^2).*100./sum(abs(ini_sim(:)).^2);
fprintf('total error=%2.2f%%\n',sum(abs(diff(:)).^2).*100./sum(abs(ini_sim(:)).^2));

return;