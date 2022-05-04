function [s, Fs]=etc_makeclicks(freq,duration,varargin)
% etc_makeclicks         generate click sounds 
%
% [s, Fs]=etc_makeclicks(freq,duration,[option_name,option_value],...)
%
% freq: click frequency (Hz)
% duration: the length of the sound (sec)
% option:
%       'fs': sampling frequency (Hz)
%       'onset_ramp': linear ramp up time (sec); default: 5 msec
%       'offset_ramp': linear ramp down time (sec); default: 5 msec
%
% fhlin@oct. 8, 2002

%defaults;
Fs=8192*2;
onset_ramp=0.005;
offset_ramp=0.005;

flag_norm_amp=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
        
    case 'fs'
        Fs=option_value;
        
    case 'onset_ramp'
        onset_ramp=option_value;
        
    case 'offset_ramp'
        offset_ramp=option_value;
                     
    case 'flag_norm_amp'
        flag_norm_amp=option_value;
        
    otherwise
        fprintf('unknown option [%s]!\n error!\n',option);
        return;
    end;
end;

fprintf('duration=[%2.2f] sec\n',duration);
fprintf('sampling frequency=[%2.2f] Hz\n',Fs);
fprintf('onset_ramp=[%2.2f] msec\n',onset_ramp*1000);
fprintf('offset_ramp=[%2.2f] msec\n',offset_ramp*1000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s=zeros(round(duration*Fs),1);

t=[0:1/Fs:duration-1/Fs];

s(1:round(Fs/freq):end)=1;

s=fmri_scale(s,1,0);
power_s=sum(abs(s).^2);
if(flag_norm_amp)
    s=s./sqrt(power_s).*5;
end;

onset_idx=[1:round(Fs*onset_ramp)];
offset_idx=[length(s)-round(Fs*onset_ramp):length(s)];

s(onset_idx)=s(onset_idx).*[0:length(onset_idx)-1]'./length(onset_idx);
s(offset_idx)=s(offset_idx).*(length(offset_idx)-1-[0:length(offset_idx)-1]')./(length(offset_idx)-1);


%plot(s);

%Snd('Play',repmat(s,[1 2])',Fs);
return;

