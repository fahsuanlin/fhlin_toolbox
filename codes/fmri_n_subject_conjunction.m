function n=fmri_n_subject_conjunction(alpha, beta, gamma, prob)
% n=fmri_n_subject_conjunction      estimate the required number of subject to show a
% "typicality", quantative expression of a trait in population, based on
% fixed-effect conjunction analysis at a specified sensitivity (beta) and
% specificity (alpha)
%
% n=fmri_n_subject_conjunction(alpha, beta, gamma, prob)
%
% alpha: pre-defined specificity of the test (default: alpha=0.05); 0<=alpha<=1
% beta: pre-defined sensitiivity (power) of the test (default: beta=1) 0<=beta<=1
% gamma: pre-defined populational "typicality" (i.e., the percentage of the population
% expressing the traited to be tested will considered "typical") (default:
% gamma ranges between 0 and 1)
% prob: pre-defined acceptable probability of the typicality (default:
% 0.05)
%
% prob=(alpha.*(1-gamma)+beta.*(gamma)).^(n)
%
% from Friston (1999) "How many subjects constitutes a study?", NeuroImage
% (10): 1-5
% 
% fhlin@july 2 2007
%

n=log(prob)./log(alpha.*(1-gamma)+beta.*gamma);

return;