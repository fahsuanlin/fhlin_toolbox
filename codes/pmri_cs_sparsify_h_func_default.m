function y=pmri_cs_sparsify_h_func_defaul(x,pmri_cs_obj)
% pmri_cs_sparsify_h_func_defaul       default the adjoint of the sparse transformation in CS pMRI
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_cs_sparsify d_h_func_defaul(x,pmri_cs_obj);
%
% x: n-dimensional input image
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the adjoint sparse transformed coefficients in the CS pMRI
%
% fhlin@sep 11 2009
%

y=[];

if(length(pmri_cs_obj.image_size)==2)
    dwtmode('per','nodisp');
    [y] =waverec2(x,pmri_cs_obj.s_dwt,pmri_cs_obj.wavename);
    y=reshape(y,pmri_cs_obj.image_size);
else
    fprintf('DWT other than 2D was not implemented yet!\n');
    return;
end;

return;