function out=fmri_sph_gauss(x,mu,sigsq)
% fmri_sph_gauss	this subroutine returns (n,m) conditional probability matrix P(x|j)
%
% out=fmri_sph_gauss(x,mu,sigsq)
%
% x is n d-dimensional data, stored in (d,n) matrix
% where mu (d,m) matrix whos columns contain
% the means of the spherical gaussian clusters
% and sigsq is (1,m) vector of variances
% for the m clusters.
% covariance matrix is taken to be (sigsq)I 
% (sigma^2 times the d-dimensional identity matrix)
%
[d,n]=size(x);
[d,m]=size(mu);
out=zeros(n,m);
for j=1:m
   mumat=mu(:,j)*ones(1,n);
 
   if(d>1)
   	out(:,j)=(exp(-sum((x-mumat).^2)/(2.*sigsq(j)))/(2*pi.*sigsq(j))^(d/2))';
   else
   	out(:,j)=(exp(-1*((x-mumat).^2)/(2.*sigsq(j)))/(2*pi.*sigsq(j))^(d/2))';
   end;
   %idx=find(out>=1);
   %if(~isempty(idx))
   %	xx=x(idx(1))
   %	mmu=mu(:,j)
   %	sig2=sigsq(j)
   %	prob=(exp(-1*((xx-mmu).^2)/(2.*sigsq(j)))/(2*pi.*sigsq(j))^(d/2))'
   %	out(idx(1),j)
   %	pause;
   %end;
end;

