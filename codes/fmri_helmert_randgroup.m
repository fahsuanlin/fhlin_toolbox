function [contrast_matrix]=fmri_helmert_randgroup(p,g,varargin)
%
% fmri_helmert_randgroup	generating Helmert bases given the order of the Helmert basis and total number of random grouping
%
% function [contrast_matrix]=fmri_helmert_randgroup(p,g,[extt])
%
% p: the order of Helmert bases
% g: the number of random groups
% extt: the temporal extension
%
% contrast_matrix: Helmert bases
%
% written by fhlin@apr. 18,2001

extt=1;
if(nargin==3)
    extt=varargin{1};
end;

randgroup=fmri_randgroup(randperm(p),g);

cc=zeros(p,g-1);
constrast_matrix=zeros(p*extt,g-1);

for i=1:(g-1)

	idx_pos=randgroup{i};
	cc(idx_pos,i)=1./length(idx_pos);

	neg_count=0;
	for j=i+1:g
		idx_neg=randgroup{j};
		neg_count=neg_count+length(idx_neg);
		cc(idx_neg,i)=-1;
	end;
	idx=find(cc(:,i)<0);
	cc(idx,i)=cc(idx,i)./neg_count;
	

	cc(:,i)=cc(:,i)./sqrt(cc(:,i)'*cc(:,i));	
	
	
	contrast_matrix(:,i)=reshape(repmat(cc(:,i),[1,extt])',[p*extt,1]);
end;


contrast_matrix=contrast_matrix./sqrt(extt);


