 function n=fmri_n_subject(alpha, beta, effect_size)
% n=fmri_n_subject      estimate the required number of subject with a
% specified sensitivity (beta), specificity (alpha), and effect size
%
% n=fmri_n_subject(alpha, beta, effect_size)
%
% alpha: pre-defined specificity of the test (default: alpha=0.05); 0<=alpha<=1
% beta: pre-defined sensitiivity (power) of the test (default: beta=0.8) 0<=beta<=1
% effect_size: effect size defined by Cohen; small, mediumm, and large effect sizes are 0.2, 0.5, and 0.8 respectively
%
% Cohen, J. (1988). Statistical power analysis for the behavioral sciences
% (2nd ed.). Hillsdale, NJ: Erlbaum
% Cohen, J. (1992). A power primer. Psychological Bulletin, 112 (1),
% 155-159.
%
% fhlin@july 2 2007
%

n=((norminv(1-alpha,0,1)+norminv(1-beta,0,1))./(effect_size)).^2;

return;