function y=pmri_cs_forward_func_defaul(x,pmri_cs_obj)
% pmri_cs_forward_func_defaul       default forward solution of CS pMRI
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_cs_forward_func_defaul(x,pmri_cs_obj);
%
% x: n-dimensional input image
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the forward solution of the CS pMRI, including channle-wise 1) spatial
% modulation of coil sensitivity profile, 2) transform from image domain to
% k-space domain, and 3) k-space sub-sampling;
%
% fhlin@sep 11 2009
%

y=[];

k_idx=find(pmri_cs_obj.k_space_sampling<1-eps);
for ch_idx=1:pmri_cs_obj.n_chan
    %spatial modulation due to sensitivity profile 
    xx=reshape(x,pmri_cs_obj.image_size).*pmri_cs_obj.sensitivity_profile{ch_idx};

    %convert the data from image to k-space;
    yy=fftshift(fftn(xx))./sqrt(size(xx,1)*size(xx,2));

    %subsampling
    yy(k_idx)=0;

    %concatenate across channels
    y=cat(length(pmri_cs_obj.image_size)+1,y,yy);
end;

return;