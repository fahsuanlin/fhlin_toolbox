function Y=inverse_filter(X,band_pass_freq,band_pass_width,sfreq,varargin)
% inverse_filter : fitler the data with specified band pass filter
%
% Y=inverse_filter(X,band_pass_freq,band_pass_width,sfreq,[ripple])
%
% Create a band-pass filter or a low-pass filter  and apply the filter
%
% X: input 1D vector or 2D data matrix. If it is 2D, it will filter row by row (not parallelized).
% band_pass_freq: n element vector specified the cut-off frequencies (in Hz) of the band-pass/low-pass filter. 
%               band-pass fileter if length(band_pass_freq)=2;
%               low-pass fileter if length(band_pass_freq)=1;
% band_pass_width: n element vector specified the width of cut-off frequencies (in Hz)
% sfreq: sample frequency of the data (in Hz)
% ripple: the rippole allowed in pass-bands; default is 0.1;
%
% fhlin@Aug. 28, 2001

ripple=0.1;        % pass-band ans stop-band ripple
if(nargin==5)
    ripple=varargin{1};
end;
fprintf('Pass band ripple is set to [%f]\n',ripple);

filter_dim=2;		% filter applied to different rows of the matrix X
flag_show_freqz=0;	% flag to show the frequency response.

min_f=min(band_pass_freq);
max_f=max(band_pass_freq);

hp_freq=[min_f.*0.9,min_f.*1.1];
lp_freq=[max_f.*0.9,max_f.*1.1];
ff=[];
for i=1:length(band_pass_freq)
    ff=[ff,band_pass_freq(i)-band_pass_width(i)./2,band_pass_freq(i)+band_pass_width(i)./2];
end;

if(length(band_pass_freq)==2) %bandpass
    % help KAISERORD at matlab for detailed info
    [n,Wn,beta,typ]=kaiserord(ff,[0 1 0],repmat(ripple,[1,3]),sfreq);
elseif(length(band_pass_freq)==1) %lowpass
    % help KAISERORD at matlab for detailed info
    [n,Wn,beta,typ]=kaiserord(ff,[1 0],repmat(ripple,[1,2]),sfreq);
end;

b=fir1(n, Wn, typ, kaiser(n+1,beta), 'noscale');
fprintf('The length of FIR filter is [%d]\n',length(b));

if(flag_show_freqz)
    [h,w]=freqz(b,1,128,'whole');
    freqzplot(h,w);
end;   

Y=zeros(size(X));
for i=1:size(X,1)
    Y(i,:)=filtfilt(b,1,X(i,:));
end;

return;

