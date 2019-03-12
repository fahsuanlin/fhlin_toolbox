function etc_save_nii(data,template,filename)


template.hdr.dime.dim(5)=size(data,4); %the 4th dimension is "time point"
template.img=single(data);
save_untouch_nii(template, filename)

return;