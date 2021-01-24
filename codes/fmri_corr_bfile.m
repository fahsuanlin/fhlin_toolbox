function status=fmri_corr_bfile(datafile,contrast,idx,threshold)
%fmri_corr_bfile	Display the correlation coefficent map associated with the functional data in bshort/bfloat format
%
%status=fmri_corr_bfile(datafile,contrast,idx,threshold)
%
%status: output flag. 1: successul; 0: otherwise
%
%datafile: the file name of the functional image (bshort or bfloat only)
%contrast: 1-D column vector coding the experiment paradigm
%idx: a string specifying output mode
%	idx='>': voxels of overlay greater or equal to threshold will be shown
%	idx='<': voxels of overlay smaller or equal to threshold will be shown
%	idx='~': voxels of overlay between 2 thresholds will be shown
%threshold: the threshold for overlay, a 2-element vector
%	idx='>': threshold(1) is the minimal value to be shown.
%		 (threshold(2) is an option; all voxels >=threshold(2) will be set as threshold(2).)
%	idx='<': threshold(1) is the maximal value to be shown.
%		 (threshold(2) is an option; all voxels <=threshold(2) will be set as threshold(2).)
%	idx='~': voxels between threshold(1) and threshold(2) will be shown.
%
% written by fhlin@Jun 09, 2000

%loading functional data
fprintf('loading [%s]...\n',datafile);
d=fmri_ldbfile(datafile);
sz=size(d);

%reshaping the functional data
fprintf('preparing correlation coeff calculation...\n');
func=zeros(sz(3),sz(1)*sz(2));
for t=1:sz(3)
	func(t,:)=reshape(d(:,:,t),[1,sz(1)*sz(2)]);
end;

%calculating cov and corr
fprintf('calculating correlation coeff...\n');
[covv,corr]=etc_covcor(func,contrast);
covv=reshape(covv,[sz(1),sz(2)]);
corr=reshape(corr,[sz(1),sz(2)]);

%generating the structural underaly by the 1st image
fprintf('generating pseudo structural underlay...\n');
struct=d(:,:,1);

%display the result
fprintf('display result...\n');
[d1,d2,status]=fmri_overlay(struct,corr,idx,threshold,threshold);



