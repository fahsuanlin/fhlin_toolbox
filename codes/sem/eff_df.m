function df = eff_df(df, RT);

% Estimation of the effective degrees of freedom
% SYNTAX [df] = eff_df(df, RT);
%
% RT    - repetition time, RT == 0 indicates independent observations 
% df    - original degrees of freedom
%_______________________________________________________________________
%
% eff_df estimates the effective degrees of freediom assuming temporal
% smoothing with a Gaussian kernel of 4 seconds
%
% ref: Worsley KJ & Friston KJ (1995) NeuroImage 2:173-181
%
%_______________________________________________________________________

if RT == 0
   return
end;

smooth = 4;
sigma  = smooth/sqrt(8*log(2))/RT;

% temporal convolution kernel
%-------------------------------------------------------------------
K      = spm_sptop(sigma,df);
V      = K*K';

% traces
%--------------------------------------------------------------------
trV    = trace(V);
trVV   = sum(sum(V.*V));

% the [effective] degrees of freedom
%-------------------------------------------------------------------
df = full(trV^2/trVV);










%ize