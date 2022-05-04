function [pmat]=fmri_ttest(bfile,pfile)
%fmri_ttest	using paradigm file and bshort file to do the T-test
%
% [pmat]=fmri_ttest(bfile,pfile)
%
%bfile: the file name of the bshort file, including the full path
%pfile: the paradigm file
%pmat: a 2D matrix of the p_value
%
%written by fhlin@aug. 28, 1999

str=sprintf('loading [%s]...',bfile);
disp(str);
data=fmri_ldbfile(bfile);

str=sprintf('loading [%s]...',pfile);
disp(str);
para=fmri_ldpara(pfile);

%keep only the central part
%[y,x,timepoints]=size(data);
%data=data(:,x/4+1:x/4+x/2,:);


[y,x,timepoints]=size(data);

on_index=find(para>0);
off_index=find(para<0);

on_length=length(on_index);
off_length=length(off_index);

on=data(:,:,on_index);
off=data(:,:,off_index);

pmat=zeros(y,x);

disp('doing 2-sample T-test...');
for i=1:y
	for j=1:x
		str=sprintf('[%d %d]',i,j);
		disp(str);
		a=reshape(on(i,j,:),[on_length,1]);
		b=reshape(off(i,j,:),[off_length,1]);
		%[h,p,ci]=ttest2(a,b);
        p=myttest2(a,b);
		pmat(i,j)=p;
	end;
end;

disp('done');

return;


function [p]=myttest2(x,y)

mean_x=mean(x,1);
mean_y=mean(y,1);
nx=size(x,1);
ny=size(y,1);
var_x=var(x);
var_y=var(y);
sp=sqrt(((nx-1).*var_x+(ny-1).*var_y)./(nx+ny-2));
t=(mean_x-mean_y)./sp./sqrt(1/nx+1/ny);
p=1 - tcdf(t,nx+ny-2);

return;