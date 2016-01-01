function [contrast]=fmri_helmert_ext(order,varargin)
%fmri_helmert_ext 	make Helmert contrast for a given order P (extension version)
%
%[basis]=fmri_helmert_ext(P,E)
%
%P: the order of the Helmert basis
%E: to expand each entry of the helmert basis entry based on E vector times. (default: E=ones(1,P))
%
%basis: the output basis
%
%
%Ref: "Applied Multivariate Techniques", Subhash Sharma, Wiley, 1996
%
%written by fhlin@Nov. 21, 2000

if(nargin>1)
	rep=varargin{1};
else
	rep=ones(1,order);
end;

contrast=zeros(order, order-1);

for i=1: order -1
	contrast(i,i)=1/rep(i);
	contrast(i+1:order,i)=-1./(sum(rep(i+1:length(rep))));
end;

for i=1:size(contrast,2)
		t=contrast(:,i);
		offset=0;
		for j=1:length(rep)
			for k=1:rep(j)
				tt(offset+k)=t(j);
			end;
			offset=offset+rep(j);
		end;
		bb(:,i)=tt';
end;
contrast=bb;

tt=repmat(sqrt(diag(contrast'*contrast))',[size(contrast,1),1]);
contrast=contrast./tt;
