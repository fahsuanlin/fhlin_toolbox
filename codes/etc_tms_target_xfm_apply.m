function strcoil = etc_tms_target_xfm_apply(strcoil, coil_center, coil_orientation, coil_up, tms_coil_xfm_before, tms_coil_xfm_after)
% etc_tms_target_xfm_apply apply the transformation matrix to TMS coil
% objects
%
% strcoil = etc_tms_target_xfm_apply(strcoil, coil_center, coil_orientation, coil_up)
%
% strcoil: a TMS object to be modeled with 'Pwire', 'Ewire','Swire' fields. 
% coil_center: 3x1 vector of TMS coil center (surface coordinate)
% coil_orientation: 3x1 vector of TMS coil axis (surface coordinate)
% coil_up: 3x1 vector of TMS coil up directional vector (surface
% coordinate)
%
% 
% Example: strcoil = target_apply_xfm(strcoil, object_xfm(1:3,4).*1e3, -object_xfm(1:3,3), object_xfm(1:3,2));
%
% fhlin@May 30 2024
%


results=0;



try
    tmp=strcoil.Pwire;
    tmp(:,end+1)=1;
    tmp=tmp';
    xfm=tms_coil_xfm_after;
    xfm_tmp=tms_coil_xfm_before;
    tmp=xfm*inv(xfm_tmp)*tmp;

    strcoil.Pwire=tmp(1:3,:)'; %update

catch
    fprintf('Error in updating strcoil!\n');
end;

results=1;

