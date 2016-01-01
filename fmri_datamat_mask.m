function [datamat,coords]=fmri_datamat_mask(datamat,coords,mask)

[y,x,z]=size(mask);
mask=reshape(mask,[1,x*y*z]);
mask_idx=find(mask);

%get indices
disp('getting joint indices...');
joint_idx=intersect(coords,mask_idx);
diff_idx=setdiff(coords,mask_idx);

%masking
disp('masking the datamat...');
datamat(:,find(ismember(coords,diff_idx)))=[];
coords=coords(ismember(coords,joint_idx));
