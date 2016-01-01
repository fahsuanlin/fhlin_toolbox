function [cov,cor,p]=etc_covcor(a,b)
%etc_covcor	calculate the covariance and correlation coeff. of two matrices
%
%[cov,cor,p]=etc_covcor(a,b)
%a: matrix 1
%b: matrix 2
%	a and b must have the same number of rows. the number of column can be different.
%
%cov: covariance matrix
%cor: correlation coeff. matrix
%p: p-value matrix
%
%written by fhlin@feb.24, 2000

l1=size(a,1);
l2=size(b,1);

if(l1~=l2)
	disp('two matrices mush have same number of rows!');
	return;
end;

%remove mean
a=a-repmat(mean(a),l1,1);
b=b-repmat(mean(b),l2,1);

cov=a'*b./(l1-1);

sa=sum(a.*a)./(l1-1);
sb=sum(b.*b)./(l1-1);

den=sqrt(sa'*sb);

cor=zeros(size(cov));
idx0=find(den==0);
idx1=find(den~=0);


cor(idx1)=cov(idx1)./den(idx1);
cor(idx0)=0;


%get p-value 
% Ref: Numerical Recipe p. 504
%
N=size(a,1);
idx0=find(abs(cor)==1);
T(idx0)=0;
idx1=find(abs(cor)~=1);
T(idx1)=cor(idx1).*sqrt(N-2./(1-cor(idx1).^2));
idx_plus=find(T>0);
idx_minus=find(T<0);

p=zeros(size(T));
if ~isempty(idx_plus)
	p(idx_plus)=2-2*tcdf(T(idx_plus),N-2);
end;
if ~isempty(idx_minus)
	p(idx_minus)=2*tcdf(T(idx_minus),N-2);
end;
