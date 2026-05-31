function n_required=etc_samplesize(z,n_pilot,varargin)

n_required=[];

flag_display=1;
power=0.8;
for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'power'
            power=option_value;
        otherwise
            fprintf('unknown option [%s]! error!\n',option);
            return;
    end;
end;

% Parameters

% Calculate the mean shift (delta)
for idx=1:length(z)
    delta = z(idx) / sqrt(n_pilot);

    % sampsizepwr(test_type, null_params, alt_params, power)
    % We use [0 1] for the null mean and standard deviation
    n_required(idx) = sampsizepwr('z', [0 1], delta, power);
end;

if(flag_display)
    fprintf('The required sample size is: %s (power=%2.2f)\n', num2str(n_required,3),power);
end;