function y=pmri_cs_forward_h_func_defaul(x,pmri_cs_obj)
% pmri_cs_forward_h_func_defaul       default the adjoint of the forward solution of CS pMRI
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_cs_forward_h_func_defaul(x,pmri_cs_obj);
%
% x: n-dimensional input k-space across ch channels
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the adjoint forward solution of the CS pMRI (in image space)
%
% fhlin@sep 11 2009
%

y=[];

k_idx=find(pmri_cs_obj.k_space_sampling<1-eps);
for ch_idx=1:pmri_cs_obj.n_chan
    if(length(pmri_cs_obj.image_size)==2) %2D images
        xx=x(:,:,ch_idx);
    elseif(length(pmri_cs_obj.image_size)==3) %3D images
        xx=x(:,:,:,ch_idx);
    end;
    xx(k_idx)=0;
    
    %convert the data from k-space to image;
    yy=(ifftn(fftshift(xx.*sqrt(size(xx,1)*size(xx,2)))));
    
    %spatial modulation due to the complex conjugate of the sensitivity profile 
    yy=yy.*conj(pmri_cs_obj.sensitivity_profile{ch_idx});

    %concatenate across channels
    if(ch_idx==1)
        y=yy;
    else
        y=y+yy;
    end;
end;

return;