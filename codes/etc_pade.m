function [a, b, n, output, orig_output]=etc_pade(c,varargin)
% etc_pade      Create and estimate N/N Pade approximant from a given polynomial
% 
% [a,b,n,output,orig_output]=etc_pade(c, [para])
%
% c: the input polynomial coefficient from the x^0 term
% para: the input arguement for evaluation
% a: the numerator polynomial (length (n+1))
% b: the denominator polynomial (length (n+1));
% n: the order of the Pade approximant.
% output: the corresponding Pade estimates when an input argument is present
% orig_output: the corresponding original polynomial estimates when an input argument is present
%
% fhlin@mar. 17, 2002

output=[];
orig_output=[];
parr=[];

if(nargin==2)
    para=varargin{1};
end;

if(mod(length(c),2)==0)
    fprintf('Appending higher order polynomial term with coefficient equal to 0!\n');
    
    if(size(c,1)==1)
        c=[c,0];
    end;
    if(size(c,2)==1)
        c=[c;0];
    end;
end;

n=(length(c)-1)/2;
fprintf('[%d/%d] order Pade approximant...\n',n,n);

for k=1:n
    for m=1:n
        A(k,m)=c(n-m+k+1);
    end;
    y(k)=-1.*c(n+k+1);
end;
b=inv(A'*A)*A'*y';
%b=inv(A)*y';
b=[1;b];

for k=1:n+1
    sum=0;
    for m=0:k-1
        sum=sum+c(k-m)*b(m+1);
    end;
    a(k)=sum;
end;
a=a';
%a=[c(1);a'];


if(~isempty(para))
    if(size(para,1)==1)
        para=para';
    end;

    for ii=1:size(para,2)
        pp=para(:,ii);
        
        for i=0:n
            p(:,i+1)=pp.^(i);
        end;

        for i=1:length(c)
            p0(:,i)=pp.^(i-1);
        end;

	orig_output(:,ii)=p0*c;

        output(:,ii)=(p*a)./(p*b);

	%plot([1:length(orig_output(:,ii))],orig_output(:,ii),'b:',...
	%[1:length(output(:,ii))],output(:,ii),'b-');

	%title(sprintf('order [%s]',num2str(ii,'%02d')));
	%pause;
    end;
end;