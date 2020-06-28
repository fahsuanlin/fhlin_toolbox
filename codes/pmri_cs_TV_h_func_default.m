function y=pmri_cs_TV_h_func_defaul(x,pmri_cs_obj)
% pmri_cs_TV_h_func_defaul       default the adjoint of the TV transformation in CS pMRI
% given input image x and CS pMRI object pmri_cs_obj
%
% y=pmri_cs_TV d_h_func_defaul(x,pmri_cs_obj);
%
% x: n-dimensional input image
% pmri_cs_obj: the object including all CS pMRI parameters
%
% y: the adjoint TV transformed coefficients in the CS pMRI
%
% fhlin@sep 11 2009
%

y=[];

y=gradient(x);

return;