function [pval_re,tstat_re]=etc_random_effect(condition_A, condition_B)
%
% condition_A is a 2D matrix of size n_a-by-m_a, representing n_a measurements (trials) from m_a repeats (subjects)
% condition_B is a 2D matrix of size n_b-by-m_b, representing n_b measurements (trials) from m_b repeats (subjects)
%

%get effects of condition A; ignoring the variance across trials
effect_A=mean(condition_A, 1);

%get effects of condition B; ignoring the variance across trials
effect_B=mean(condition_B, 1);

[pval_re,tstat_re]=etc_ttest2(effect_A', effect_B');



return;