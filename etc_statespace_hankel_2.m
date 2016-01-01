function [A,B,C,E,opt_order]=etc_statespace_hankel_2(data,lag,varargin)
%
% calculate the state space matrices from a hankel matrix of the data given a delay
%
% [A,B,C,Gm,E,opt_order]=etc_statespace_hankel_2(data,lag);
%
% data: [n_time, n_var] matrix of n_time time points and n_var variables
% lag: the lag for the Hankel matrix; lag must be equal or larger than 1
%
% A, B, C, Gm, E are output matrics of state space model
% opt_order: the optimal order of the state space from BIC
%
% fhlin@aug. 9 2007
%
flag_display=1;
A=[];
B=[];
C=[];
E=[];

opt_order=[];

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
        case 'opt_order'
            opt_order=option_value;
        otherwise
            fprintf('unknown option [%s]...!\nerror!\n',option);
            return;
    end;
end;

if(lag<0) 
    fprintf('error! the lag must be >=0!\n');
    return;
end;

if(flag_display)
    fprintf('calculating state space matrices of lag [%d]...\n',lag);
end;

[A,B,C,E,opt_order]=etc_hankel_2(data,lag,'flag_display',flag_display,'opt_order',opt_order);



return;