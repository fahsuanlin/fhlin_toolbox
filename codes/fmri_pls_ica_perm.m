function [p_brainlv_perm,p_sv_perm]=fmri_pls_ica_perm(datamat,contrast,PERMUTATION,datamat_struct,perm_flag,fname)
%fmri_pls_ica_perm 		permutation test of the PLS analysis of functional data using ICA
%
%[brainlv_perm,sv_perm]=fmri_pls_ica_perm(datamat,contrast,perm,datamat_struct,perm_flag,fname)
%datamat: the datamat for PLS
%contrast: the contrast matrix for PLS
%perm: number of permutation iteration (suggesting 500)
%datamat_struct: the 2D M*N array containing time points for task M (row), and subject N (col.).
%perm_flag: string either '001','010','100','011','101','110' or '111'; permutation across tasks, subjects and/or temporal profile
%fname: the prefix file name to store the reults. if fname=XXXX, 'XXXX_pls_perm.mat' will be saved.
%
%brianlv_perm: the probability of brainlv voxels whose value are over the orginial brainlv in permutation
%sv_perm: the probability of sv whose value are over the orginial sv in permutation
%
%written by fhlin@aug. 24 1999

%permutation test
str=sprintf('permutation test...');
disp(str);

str=sprintf('total permutation: %d', PERMUTATION);
disp(str);

[brainlv,sv,designlv]=fmri_pls_core(datamat,contrast);

perm_contrast=zeros(size(contrast));
contrast_total=sum(contrast,2);

sv_counter=zeros(size(sv));
brainlv_counter=zeros(size(brainlv));

for i=1:PERMUTATION
	str=sprintf('permuation[%d|%d]',i,PERMUTATION);
	disp(str);

	fprintf('getting permutation sequence...\n');

	switch(perm_flag)
	case '001'
		para2=fmri_pls_perm_001(datamat_struct);
	case '010'
		para2=fmri_pls_perm_010(datamat_struct);
	case '011'
		para2=fmri_pls_perm_011(datamat_struct);
	case '100'
		para2=fmri_pls_perm_100(datamat_struct);
	case '101'
		para2=fmri_pls_perm_101(datamat_struct);
	case '110'
		para2=fmri_pls_perm_110(datamat_struct);
	case '111'
		para2=fmri_pls_perm_111(datamat_struct);
	end;
	
	fprintf('permutation sequence done!\n\n');
	
        fprintf('permutation contrast matrix\n');
        for j=1:size(contrast,1)
		perm_contrast(j,:)=contrast(para2(j),:);
	end;
	fprintf('contrast matrix permuted!\n\n');
	
	fprintf('starting ICA...\n');
	[perm_brainlv,perm_sv,perm_designlv,perm_brain_score,perm_design_score]=fmri_pls_ica(datamat,perm_contrast);
	fprintf('end of ICA\n\n');
	
	%save result
	perm_brainlv=perm_brainlv*(perm_sv);
	brainlv=brainlv*(sv);
	sv_counter=sv_counter+(perm_sv>sv);
	brainlv_counter=brainlv_counter+(abs(perm_brainlv)>abs(brainlv));
end;
	
		
p_sv_perm=sv_counter/PERMUTATION;
p_brainlv_perm=brainlv_counter/PERMUTATION;
if(~isempty(fname))
	fn=sprintf('%s_pls_perm',fname);
	save(fn,'p_sv_perm','p_brainlv_perm');
end;
disp('permutation test done!');



