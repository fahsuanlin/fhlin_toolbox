function y=inverse_stim_waveform(x,varargin)
%
% inverse_stim_waveform     generate different waveforms with parameters
%
% y=inverse_stim_waveform(x,[option,option_value]...);
%
% x: 1D vector of indices
% y: the output waveform
% option
%   'mode': either 'gauss' or 'biphase' to generate Gaussian distribution or derivative of Gaussian for biphasic waveform
%           default is 'gauss'
%   'mean': mean value of Gaussian 
%           default sets to 0.
%   'std': standard deviation of Gaussian
%           defaults sets to 1.
%
% fhlin@nov. 13, 2001


%defaults
mode='gauss';
mn=0;
sig=1;
delay=0;

if(nargin>1)
    for i=1:length(varargin)/2
        option=varargin{i*2-1};
        option_value=varargin{i*2};
        
        switch lower(option)
        case 'mode'
            mode=option_value;
        case 'mean'
            mn=option_value;
        case 'std'
            sig=option_value;
        case 'delay'
            delay=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
        end;
    end;
end;
        
if(strcmp(mode,'gauss'))
    y=1./sqrt(2*pi*sig*sig).*exp(-(x-mn).^2./2./sig./sig);
end;
if(strcmp(mode,'biphase'))
    y=1./sqrt(2*pi*sig*sig).*exp(-(x-mn).^2./2./sig./sig).*(-2.*(x-mn)./2./sig./sig);
end;







