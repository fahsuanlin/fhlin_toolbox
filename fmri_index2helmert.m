function [basis]=fmri_index2helmert(index,varargin)
%fmri_index2helmert 	make Helmert contrast for a given index matrix
%
%[basis]=fmri_index2helmert(P)
%
%P: the index matrix
%
%basis: the output basis
%
%
%Ref: "Applied Multivariate Techniques", Subhash Sharma, Wiley, 1996
%
%written by fhlin@Mar. 05, 2000

basis=zeros(size(index,2),size(index,1)-1);

for i=1:size(index,1)-1
	a=find(index(i,:));
	mat=sum(index(i+1:size(index,1),:),1);
	b=find(mat);
	
	la=length(a);
	lb=length(b);
	
	v=zeros(1,size(a,2));
	v(a)=(1./la);
	v(b)=(1./lb).*(-1);
	
	basis(:,i)=v';
end;

tt=repmat(sqrt(diag(basis'*basis))',[size(index,2),1]);
basis=basis./tt;

