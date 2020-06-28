function [s, Fs]=etc_makesound(cf,duration,varargin)
% etc_makesound         generate sound singal
%
% [s, Fs]=etc_makesound(cf,duration,[option_name,option_value],...)
%
% cf: central frequency (Hz)
% duration: the length of the sound (sec)
% option:
%       'bw': bandwidth of the sound (Hz); default: [] (monotonic no bandwidth)
%       'fs': sampling frequency (Hz); default: 16384Hz
%       'onset_ramp': linear ramp up time (sec); default: 5 msec
%       'offset_ramp': linear ramp down time (sec); default: 5 msec
%
% fhlin@oct. 8, 2002

%defaults;
Fs=8192*2;
onset_ramp=0.005;
offset_ramp=0.005;
bw=[];

flag_norm_amp=0;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    
    switch lower(option)
    case 'bw'
        bw=option_value;
        
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

fprintf('Center frequency=[%2.2f] Hz\n',cf);
fprintf('Bandwidth=[%2.2f] Hz\n',bw);
fprintf('duration=[%2.2f] sec\n',duration);
fprintf('sampling frequency=[%2.2f] Hz\n',Fs);
fprintf('onset_ramp=[%2.2f] msec\n',onset_ramp*1000);
fprintf('offset_ramp=[%2.2f] msec\n',offset_ramp*1000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x=[0:1/(Fs-1):duration*3];

if(isempty(bw))
%     fprintf('monotonic sound: CF=[%2.2f] Hz\n', cf);
    s=sin(2*pi*x*cf);   
else
%     fprintf('composite sound: CF=[%2.2f] Hz, BW=[%2.2f] Hz\n', cf,bw);
    
    df=100; 
    
    x=repmat(x,[df,1]);
    phase=repmat(rand(df,1),[1,size(x,2)]);
    %CF=[cf-bw/2:bw/(df-1):cf+bw/2]';
    CF=cf-bw/2+rand(1,df)'.*bw;
    x=x.*repmat(CF,[1,size(x,2)])+phase;
    
    s=sin(2*pi*x); 
    
    s=mean(s,1);
        
end;

s=s(round(Fs.*duration)+1:round(Fs.*duration*2));


onset_idx=[1:round(Fs*onset_ramp)];
offset_idx=[length(s)-round(Fs*onset_ramp):length(s)];

s(onset_idx)=s(onset_idx).*[0:length(onset_idx)-1]./length(onset_idx);
s(offset_idx)=s(offset_idx).*(length(offset_idx)-1-[0:length(offset_idx)-1])./(length(offset_idx)-1);

s=fmri_scale(s,1,0)-0.5;
power_s=sum(abs(s).^2);
if(flag_norm_amp)
    s=s./sqrt(power_s).*5;
end;

return;
