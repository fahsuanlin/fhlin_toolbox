function [brainlv,sv,designlv,brain_score,design_score]=fmri_pls_core(datamat,contrast,varargin)
%fmri_pls_core 	do SVD in PLS analysis of functional data
%
%[brainlv,sv,designlv,brain_score,design_score]=fmri_pls_core(datamat,contrast,type)
%
%datamat: the datamat from the raw data
%contrast: the contrast matrix
%type:
%	type=='task': cross product will be done to generate effect space (contrast'*datamat), (default).
%	type=='behavior': correlation coeff. will be calculated as effect space entries. 
%	
%	
%NOTE: 	1. the results will be saved in pls.mat in current directory.
%	2. datamat must be arranged in time_points-subjects-tasks in rows
%	3. datamat must be arranged in y-x-slices in cols.
%	4. contrast must be arranged in time_points-subjects-tasks in rows
%	5. contrast must be arranged in y-x-slices in cols.
%
%
%written by fhlin@aug. 26, 1999
%
%----------------------------------------------------------------------
ddd=pwd;
str=sprintf('current directory: [%s]',ddd);
disp(str);

if(nargin==2)
	type=1;
end;

if(nargin==3)
	switch varargin{1}
   case 'task' 
      type=1;
   case 'behavior' 
      type=2;
	end;
end;

%
%SVD preparation
%
[dummy1,m]=size(contrast);
[dummy2,n]=size(datamat);
if(dummy1~=dummy2)
	disp('size of contrast and datamat not fit!');
	str=sprintf('size of datamat : %s', mat2str(size(datamat)));
	disp(str);
	str=sprintf('size of contrast : %s', mat2str(size(contrast)));
	disp(str);
	return;
end;

%
%calculate corr coef. between contrast and datamat
%

if(type==1)
	inpmat=contrast'*datamat;
end;

if(type==2)
	inpmat=[];
	for i=1:size(contrast,2)
		idx=find(contrast(:,i));
		cc=contrast(idx,i);
		dd=datamat(idx,:);
		[covv,corr]=etc_covcor(cc,dd);
		inpmat=[inpmat;corr];
	end;
end;

%
%SVD process
%
str=sprintf('SVD...');
disp(str);	
[brainlv,sv,designlv]=svd(inpmat',0);


str=sprintf('getting brain scores...');
disp(str);
brain_score=datamat*brainlv;      

str=sprintf('getting design scores...');
disp(str);
design_score=contrast*designlv;

disp('SVD in PLS done!');




