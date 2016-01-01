function [z_pls_bstp,se_pls_bstp,z2_pls_bstp,se2_pls_bstp]=fmri_pls_ica_bstp(datamat,contrast,BOOTSTRAP,datamat_struct,bstp_flag,fname)
%fmri_pls_ica_bstp		bootstrap for the PLS analysis of functional data using ICA
%
%[z_bstp,se_bstp]=fmri_pls_ica_bstp(datamat,contrast,parafile,bstp,datamat_struct,bstp_flag,fname)
%datamat: the datamat for PLS
%contrast: the contrast matrix for PLS
%bstp: number of bootstrap iteration (suggesting 100)
%datamat_struct: the 2D M*N array containing time points for task M (row), and subject N (col.).
%bstp_flag: string either '001','010','100','011','101','110' or '111'; bootstrap across tasks, subjects and/or temporal profile
%fname: the prefix file name to store the reults. if fname=XXXX, 'XXXX_pls_bstp.mat' will be saved.
%
%written by fhlin@aug. 24, 1999
%
%z_bstp: the z score from the boostrap by original brainlv over estimated standard error of the brainlv voxles
%se_bstp: the estimated standard error for the brainlv voxels by boostrap
%
% written by fhlin@nov. 25, 1999
%
%z2_bstp: the z score from the boostrap by original designlv over estimated standard error of the designlv
%se2_bstp: the estimated standard error for the designlv by boostrap
%
% written by fhlin@nov. 25, 1999

%bootstrap test
str=sprintf('bootstrap test...');
disp(str);

str=sprintf('total bootstrap: %d', BOOTSTRAP);
disp(str);

[brainlv,sv,designlv,brain_score,design_score]=fmri_pls_core(datamat,contrast);

bstp_contrast=zeros(size(contrast));
contrast_total=sum(contrast,2);

bstp_sum=zeros(size(datamat,2),size(contrast,2));
bstp_sqr=zeros(size(datamat,2),size(contrast,2));
bstp_sum2=zeros(size(datamat,1),size(contrast,2));
bstp_sqr2=zeros(size(datamat,1),size(contrast,2));

for i=1:BOOTSTRAP
	str=sprintf('bootstrap[%d|%d]',i,BOOTSTRAP);
	disp(str);
	
	
	switch(bstp_flag)
	case '001'
		para2=fmri_pls_bstp_001(datamat_struct);
	case '010'
		para2=fmri_pls_bstp_010(datamat_struct);
	case '011'
		para2=fmri_pls_bstp_011(datamat_struct);
	case '100'
		para2=fmri_pls_bstp_100(datamat_struct);
	case '101'
		para2=fmri_pls_bstp_101(datamat_struct);
	case '110'
		para2=fmri_pls_bstp_110(datamat_struct);
	case '111'
		para2=fmri_pls_bstp_111(datamat_struct);
	end;
	
        for j=1:size(contrast,1)
		bstp_contrast(j,:)=contrast(para2(j),:);
	end;

	[bstp_brainlv,bstp_sv,bstp_designlv,bstp_brain_score,bstp_design_score]=fmri_pls_ica(datamat,bstp_contrast);

	rescale=bstp_brainlv*bstp_sv;
	%rescale2=bstp_design_score;
	rescale2=bstp_design_score*sqrt(bstp_sv);
	
	%some bootstraps will make sign inverson for the rescaled brainlv
	sign_inversion_idx=find(diag(design_score'*bstp_design_score)<0); %get those brainlv's in bootstrap with sign inversion
	rescale(:,sign_inversion_idx)=-1.*rescale(:,sign_inversion_idx); %correct the sign inversion
	rescale2(:,sign_inversion_idx)=-1.*rescale2(:,sign_inversion_idx); %correct the sign inversion
	
	bstp_sum=bstp_sum+rescale;
	bstp_sqr=bstp_sqr+rescale.^2;
	bstp_sum2=bstp_sum2+rescale2;
	bstp_sqr2=bstp_sqr2+rescale2.^2;

end;	




s1=(bstp_sum.^2)./BOOTSTRAP;
se_pls_bstp=sqrt((bstp_sqr-s1)/(BOOTSTRAP-1));
idx0=find((se_pls_bstp==0)|imag(se_pls_bstp)~=0);
idx1=find((se_pls_bstp~=0)&imag(se_pls_bstp)==0);
num=brainlv*sv;
z_pls_bstp=zeros(size(num));
z_pls_bstp(idx1)=num(idx1)./se_pls_bstp(idx1);
z_pls_bstp(idx0)=50;	%assume Z-score=50 for voxels within zero estimated std.
se_pls_bstp(idx0)=0;	%assume zero std for voxels with zero estimated std.


s2=(bstp_sum2.^2)./BOOTSTRAP;
se2_pls_bstp=sqrt((bstp_sqr2-s2)/(BOOTSTRAP-1));
idx0=find((se2_pls_bstp==0)|imag(se2_pls_bstp)~=0);
idx1=find((se2_pls_bstp~=0)&imag(se2_pls_bstp)==0);
num2=design_score*sqrt(sv);
z2_pls_bstp=zeros(size(num2));
z2_pls_bstp(idx1)=num2(idx1)./se2_pls_bstp(idx1);
z2_pls_bstp(idx0)=50;	%assume Z-score=50 for voxels within zero estimated std.
se2_pls_bstp(idx0)=0;	%assume zero std for voxels with zero estimated std.

if(~isempty(fname))
	fn=sprintf('%s_pls_bstp',fname);
	save(fn,'se_pls_bstp','z_pls_bstp');
end;

str=sprintf('bootstrap done!');
disp(str);
