function [pval_fe,tstat_fe]=etc_fixed_effect(condition_A, condition_B)
%
% condition_A is a 2D matrix of size n_a-by-m_a, representing n_a measurements (trials) from m_a repeats (subjects)
% condition_B is a 2D matrix of size n_b-by-m_b, representing n_b measurements (trials) from m_b repeats (subjects)
%



%a direct t-test across groups
[pval_fe,tstat_fe]=etc_ttest2(condition_A(:), condition_B(:));



return;