function MI=etc_pac(x,sf,lf,hf,varargin);
%
% etc_pac     phase-amplitude coupling
%
% index=etc_pac(x,sf,lf,hf,[option1, option_value1,...]);
%
% x: 1D time series
% sf: the sampling frequency (Hz)
% lf: the frequency of the phase time series (Hz)
% hf: the frequency of the amplitude time series (Hz)
%
% hf > lf
%
%

MI=[];


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    opiton_value=varargin{i*2};
    
    switch lower(option)
        case ''
        otherwise
            fprintf('unknown option [%s]!error!\n',option);
            return;
    end;
end;

N=4; %4-th order filter
[B,A] = butter(N,Wn);

analytic_signal = hilbert(x);

phase = phase(analytic_signal);

amplitude = abs(analytic_signal).
