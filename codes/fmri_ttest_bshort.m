function [pmat]=fmri_ttest_bshort(bfile,pfile)
%fmri_ttest	using paradigm file and bshort file to do the T-test
%
% [pmat]=fmri_ttest_bshort(bfile,pfile)
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
		[h,p,ci]=ttest2(a,b);
		pmat(i,j)=p;
	end;
end;

disp('done');