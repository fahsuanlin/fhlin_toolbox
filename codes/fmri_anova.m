function [F,p,ss_w,df_w,ss_b,df_b]=fmri_anova(data)
%fmri_anova	ANOVA to test equal mean between treatments
%
%[F,p,ss_w,df_w,ss_b,df_b]=fmri_anova(data)
%
%data: the n*p data; each row is an observation; each column is a treatment
%F: F statistic
%p: p-value associated with the F statistic
%ss_w: sum of squar within treatment
%df_w: degree of freedom within treatment
%ss_b: sum of squar between treatment
%df_b: degree of freedom between treatment
%
%written by fhlin@mar. 11, 2000

m=mean(data)
gmean=mean(mean(data))
ss_w=sum(sum((data-repmat(m,[size(data,1),1])).^2));
ss_b=size(data,1)*sum((m-mean(m)).^2);
df_w=size(data,2)*(size(data,1)-1);
df_b=size(data,2)-1;
F=(ss_b/df_b)/(ss_w/df_w);
p=1-fcdf(F,df_b,df_w);