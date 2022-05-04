function TE=etc_te_prob(prob_joint)
%
%   etc_te_prob      calculates the transfer entropy (or transient transfer
%   entropy) from a given joint probability distribution
%
%   TE=etc_te_prob(prob_joint)
%   prob_joint: the joint probability of x(t+1), x(t), and y(t) when
%   evaluating the transfer entropy from y(t) to x(t)
%   prob_joint is a 3D matrix of [n, n, n], where n is the number of bin in
%   the frequency calculation. The 3 dimensions represent the joint
%   probablity of [x(t+1), x(t), y(t)]
%
%   TE: the output transfer entropy
%
%   fhlin@feb. 28 2009
%

TE=[];

prob_12=sum(prob_joint,3); %marginal prob. of (1,2)
%p(1|2,3)
tmp=repmat(sum(prob_joint,1),[size(prob_joint,1),1,1]);
num=zeros(size(prob_joint));
idx=find(tmp(:));
num(idx)=prob_joint(idx)./tmp(idx);

%p(1|2)
prob_120=repmat(sum(prob_joint,3),[1 1 size(prob_joint,3)]);
tmp=repmat(sum(prob_120,1),[size(prob_joint,1),1,1]);
den=zeros(size(prob_joint));
idx=find(tmp(:));
den(idx)=prob_120(idx)./tmp(idx);

idx=find((den(:)>0)&(num(:)>0));
xx=log(num(idx)./den(idx)).*prob_joint(idx);
TE=sum(xx(:));

return;