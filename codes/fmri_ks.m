function [p]=fmri_ks(d,para)
%	fmri_ks		Kolmogorov-Smirnov Test (non-parametric test) for data
%	
%	prob=fmri_ks(data,para)
%	data: either N*1 or N*M raw data, N oberservation; M variables
%	para: N*1 vector, containing either -1 or +1, indicating the category of the data
%	prob: the return probability value of two samples are of the same PDF.
% 
%	written by fhlin@jan. 14. 00


if length(para)~=size(d,1)
	str=sprintf('data size : [%s]\npara size : [%s]\nsize error!',num2str(size(d)),num2str(size(para)));
	disp(str);
	return;
end;



d1=sort(d(find(para>0),:));
d2=sort(d(find(para<0),:));
n1=size(d1,1);
n2=size(d2,1);

for i=1:size(d,2)
	j1=1;j2=1;
	diff=0;
	en1=n1;
	en2=n2;
	fn1=0;
	fn2=0;
	while(j1<=n1 & j2<=n2)
		dd1=d1(j1,i);
		dd2=d2(j2,i);
		if(dd1<=dd2)
			fn1=(j1)/en1;
			j1=j1+1;
		end;
		if(dd2<=dd2)
			fn2=(j2)/en2;
			j2=j2+1;
		end;
	
		dt=abs(fn2-fn1);
		if(dt>diff)
			diff=dt;
		end;
   end;
   p(i)=KSq(sqrt(en1*en2/(en1+en2))*diff);	
   %str=sprintf('[%d]: diff=%f param=%f KSq=%f',i,diff,sqrt(en1*en2/(en1+en2))*diff,p(i));
   %disp(str);

end;



return;




function [sum]=KSq(lambda)
fac=2;
sum=0;
term=0;
termbf=0;
for i=1:100
	term=fac*exp(-2.0*lambda*lambda*i*i);
	sum=sum+term;
	if(abs(term)<1e-12*termbf| abs(term)<=1e-20*sum)
		return;
	end;
	fac=-1*fac;
	termbf=abs(term);
end
return;