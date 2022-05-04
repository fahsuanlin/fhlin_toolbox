function [pmat]=fmri_ttest_datamat(datamat,pfile)
%fmri_ttest	using paradigm file and bshort file to do the T-test
%
% [pdatamat]=fmri_ttest_datamat(datamat,pfile)
%
%datamat: 2D datamat; t*v matrix, t is # of timepoint, v is # of voxel
%pfile: the paradigm file
%pdatamat: a 2D datamat of the p_value
%
%written by fhlin@aug. 28, 1999


str=sprintf('loading [%s]...',pfile);
disp(str);
para=fmri_ldpara(pfile);



[timepoints, voxel]=size(datamat);

on_index=find(para>0);
off_index=find(para<0);

on_length=length(on_index);
off_length=length(off_index);

on=datamat(on_index,:);
off=datamat(off_index,:);

pmat=zeros(1,voxel);

disp('doing 2-sample T-test...');
pause(2);
for i=1:voxel
	%str=sprintf('[%d %d]',i,j);
	%disp(str);
	a=reshape(on(:,i),[on_length,1]);
	b=reshape(off(:,i),[off_length,1]);
	[h,p,ci]=ttest2(a,b);
	pmat(1,i)=p;
end;

disp('done');