function [contrast,sel_mask]=fmri_pls_seedcontrast(datamat,coords,y,x,slices,brainlv,p_brainlv,threshold,flag,selects,lv_idx)
%fmri_pls_seedcontrast 		generate the contrast matrix for  seed pls based on the results of permutation test
%
%[contrast]=fmri_pls_seedcontrast(datamat,coords,y,x,slices,brainlv,p_brainlv,threshold,flag,selects,lv_index)
%
%datamat: the datamat for PLS
%coords: the coordinate vector from datamat generation
%y: dimension of y
%x: dimension of x
%slices: number of slices
%brainlv: the brainlv from the PLS to be selected as seeds
%p_brainlv: the p_value of brainlv from permutation test to mask the brainlv
%threshold: the threshold to screen the p_value of p_brainlv
%flag: if flag==0, all voxels in p_brainlv >= threshold will be used as mask to screen the brainlv..
%      if flag==0, all voxels in p_brainlv <= threshold will be used as mask to screen the brainlv
%selects: number of voxels to be used in seed pls for each contrast
%lv_index: the row vector with entries as indices of which brainlv is/are selected
%
%written by fhlin@aug. 26,1999
%---------------------------------------------------------

brainlv=brainlv'; %do the transpose for conventional matrix orientation

brainlv=brainlv(lv_idx,:);
p_brainlv=p_brainlv(:,lv_idx);


%get the index of those voxels survived after masking
mask=zeros(size(p_brainlv));
ii=find(p_brainlv<=threshold);
mask(ii)=1;
mask=mask';

%using the mask to screen the brainlv in PLS
masked_brainlv=brainlv.*mask;


%
%selecting...based on the maximal of each row of brainlv after p_value masking.
%

sel_mask=zeros(size(brainlv));

for i=1:size(brainlv,1)
	count=0;
	gmin=min(masked_brainlv(i,:));
	while count<selects
		[maxx,idx]=max(abs(masked_brainlv(i,:)));
		count=count+1;
		index(i,count)=idx;
		sel_mask(i,idx)=1;
		masked_brainlv(i,idx)=0;
	end;
end;

%
%generate the contrast based on the selected index
%
contrast=zeros(size(datamat,1),selects*size(brainlv,1));
for i=1:size(brainlv,1)
	for j=1:selects
		contrast(:,(i-1)*selects+j)=datamat(:,index(i,j));
	end;
end;

disp('showing all the selection masks...');


disp_buffer=ones(size(sel_mask)).*2;
disp_buffer(find(sel_mask))=4;
find(sel_mask);
for i=1:size(brainlv,1)
	disp_datamat(disp_buffer(i,:),coords,y,x,slices);
	str=sprintf('selection mask for lv [%d]',lv_idx(i));
	title(str);
end;

%add a DC contrast
%[m n]=size(contrast);
%contrast(:,n+1)=ones(m,1);


figure;
imagesc(contrast);
title('seed contrast');
pause(1);

disp('seed contrast done!');
