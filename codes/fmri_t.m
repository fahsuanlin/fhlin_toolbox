function [t,p]=fmri_t(d,para)
%	fmri_t		Two-Sample T-Test (parametric test) for data
%	
%	[t,prob]=fmri_t(data,para)
%	data: either N*1 or N*M raw data, N oberservation; M variables
%	para: N*1 vector, containing either -1 or +1, indicating the category of the data
%	t: the T value for the test
%	prob: the return probability value of two samples are of the same PDF.
% 
%	written by fhlin@jan. 14. 00

if length(para)~=size(d,1)
	str=sprintf('data size : [%s]\npara size : [%s]\nsize error!',num2str(size(d)),num2str(size(para)));
	disp(str);
	return;
end;


d1=d(find(para>0),:);
d2=d(find(para<0),:);
n1=size(d1,1);
n2=size(d2,1);
v1=n1-1;
v2=n2-1;
x1=mean(d1,1);
x2=mean(d2,1);
ss1=var(d1).*v1;
ss2=var(d2).*v2;

sp=(ss1+ss2)./(v1+v2);
mdiff=x1-x2;
sdiff=sqrt(sp./n1+sp./n2);
t=(x1-x2)./sdiff;
idx_plus=find(t>0);
idx_minus=find(t<0);

p=zeros(size(t));
if ~isempty(idx_plus)
	p(idx_plus)=2-2*tcdf(t(idx_plus),v1+v2);
end;
if ~isempty(idx_minus)
	p(idx_minus)=2*tcdf(t(idx_minus),v1+v2);
end;
