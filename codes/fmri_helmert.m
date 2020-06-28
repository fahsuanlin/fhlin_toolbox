function [basis]=fmri_helmert(order,varargin)
%fmri_helmert 	make Helmert contrast for a given order P
%
%[basis]=fmri_helmert(P,E)
%
%P: the order of the Helmert basis
%E: to expand each entry of the helmert basis entry E times. (default: E=1)
%
%basis: the output basis
%
%For a P-order input, the output will be P*(P-1) matrix
%
%Ref: "Applied Multivariate Techniques", Subhash Sharma, Wiley, 1996
%
%written by fhlin@Mar. 05, 2000

basis=zeros(order, order-1);

for i=1: order -1
	basis(i,i)=1;
	basis(i+1:order,i)=-1./(order-i);
end;

if(nargin>1)
	E=varargin{1};
else
	E=1;
end;

if(E>1)
	bb=zeros(size(basis,1)*E,size(basis,2));
	
	for i=1:size(basis,2)
		t=basis(:,i);
		t=repmat(t,[1,E])';
		t=reshape(t,[size(basis,1)*E,1]);
		bb(:,i)=t;
	end;
	basis=bb;
end;
	
tt=repmat(sqrt(diag(basis'*basis))',[size(basis,1),1]);
basis=basis./tt;
	
		