function fmri_pls(datafile,parafile,tasks,subjects,slices,threshold,PERMUTATION,BOOTSTRAP,resultfile,flag,varargin)
%fmri_pls 	PLS analysis of functional data
%
%fmri_pls(datafiles,parafiles,tasks,subjects,slices,threshold,resfile,d_flag,varargin)
%
%datafiles: raw data files in string cells, including path.
%parafiles: paradigm files in string cells, including path.
%tasks: number of tasks
%subjects: number of subjects
%slices: number of slices
%threshold: the threshold set to disgard raw data. set threshold to 0 using default, 1/7 of the maximal value
%perm: number of permutation test iteration
%bstp: number of bootstrap test iteration
%resfile: the file name for the results. this will be appended '.mat' by the end
%d_flag: 1D control flag for datamat
%	flag(1)==1	linearly detrending
%	flag(2)==1	linearly scaling row by row
%	flag(3)==1	linearly scaling col by col
%	flag(4)==1	removing mean row by row
%	flag(5)==1	removing mean col by col
%	flag(6)==1	normalize slice of the same timepoint within subject across tasks
%varargin: varialble argin
%	varargin(1): the option to make differential contrast matrix
%		if c_flag=='none', NO differential contrast matrix is made.
%		if c_flag~='none', differential contrast matrix is made.
%
%NOTE: the results will be saved in pls.mat in current directory.
%
%written by fhlin@aug. 26, 1999
%
%----------------------------------------------------------------------
ddd=pwd;
str=sprintf('current directory: [%s]',ddd);
disp(str);

%
%loading the raw data into datamat 
%
str=sprintf('generating datamat...');
disp(str);
[datamat,coords,x,y]=fmri_pls_datamat(datafile,tasks,subjects,slices,threshold,flag);
timepoints=size(datamat,1)/subjects;

%
%loading the contrast matrix
%
c_option='';
if size(varargin,2)>=1
	c_option=char(varargin(1));
end;
[contrast]=fmri_pls_contrast(parafile,tasks,subjects,slices,c_option);

%
%doing SVD in PLS
%
disp('doing SVD...');
[brainlv,sv,designlv,brain_score,design_score]=fmri_pls_core(datamat,contrast);


str=sprintf('saving resulting to [%s.mat]...',resultfile);
disp(str);
save(resultfile,'brainlv','sv','designlv','brain_score','design_score','coords','contrast','x','y','tasks','subjects','slices','timepoints');


disp('next is permutation test and bootstrap test...');
%disp('press any key to continue');
pause(1);

%permutation test
if(PERMUTATION>0)
	fmri_pls_perm(datamat,contrast,PERMUTATION,resultfile);
end;



%bootstrap test
if(BOOTSTRAP>0)
	fmri_pls_bstp(datamat,contrast,BOOTSTRAP,resultfile);
end;


str=sprintf('PLS done!');
disp(str);
