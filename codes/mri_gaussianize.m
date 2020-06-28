function output=mri_gaussianize(data)

data=imresize(data,[256,256]);

%do block variance calculation
output=blkproc(data,[8,8],'mri_varnorm');
imagesc(output(1:8+128,1:8+128));
pause;

return;
