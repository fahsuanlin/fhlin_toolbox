function [T,pval]=etc_bartlett(si2,ni)
%
% etc_bartlett     Bartlett's test on equal variance
%
% etc_bartlett(si2,ni)
%
% si2: a vector of variance of different groups
% ni: a vector of number of samples of different groups
%
% ref: https://www.mathworks.com/help/stats/vartestn.html#btqw73e-group
% ref: https://en.wikipedia.org/wiki/Bartlett%27s_test
% 
% fhlin@jan. 29 2020
%

T=[];
pval=[];

if(length(ni)~=length(si2))
    fprintf('si2 and ni are of different lengths!\nerror!\n');
    return;
end;

if(~isempty(find(ni<=1)))
    fprintf('entry of ni is no larger than 1!\nerror!\n');
end;
    
N=sum(ni); %total sample number
k=length(ni); %number of groups

sp2=sum((ni-1).*si2./(N-k));
T_num=((N-k)*log(sp2)-sum((ni-1).*log(si2)));

tmp=sum(1./(ni-1))-1/(N-k);
T_den=1+(1/(3*(k-1))).*tmp;

T=T_num/T_den;

pval=1-chi2cdf(T,k-1);
