function [strcoil, strcoil_xfm] = etc_tms_target_xfm_apply(strcoil, coil_center, coil_orientation, coil_up, tms_coil_xfm_before, tms_coil_xfm_after)
% etc_tms_target_xfm_apply apply the transformation matrix to TMS coil
% objects
%
% [strcoil strcoil_xfm] = etc_tms_target_xfm_apply(strcoil, coil_center, coil_orientation, coil_up)
%
% strcoil: a TMS object to be modeled with 'Pwire', 'Ewire','Swire' fields. 
% strcoil_xfm: 4x4 transformation matrix for strcoil *after* applying the specified transformation
%
% coil_center: 3x1 vector of TMS coil center (surface coordinate)
% coil_orientation: 3x1 vector of TMS coil axis (surface coordinate)
% coil_up: 3x1 vector of TMS coil up directional vector (surface
% coordinate)
% tms_coil_xfm_before: current 4x4 transformation matrix
% tms_coil_xfm_after: the target 4x4 transformation matrix
%
% 
% Example: [strcoil, strcoil_xfm] = target_apply_xfm(strcoil, object_xfm(1:3,4).*1e3, -object_xfm(1:3,3), object_xfm(1:3,2),tms_coil_xfm_before, tms_coil_xfm_after);
%
% fhlin@May 30 2024
%


results=0;
strcoil_xfm=[];


try
    tmp=strcoil.Pwire;
    tmp(:,end+1)=1;
    tmp=tmp';
    xfm=tms_coil_xfm_after;
    xfm_tmp=tms_coil_xfm_before;
    tmp=xfm*inv(xfm_tmp)*tmp;

    strcoil_xfm=xfm*inv(xfm_tmp)*tms_coil_xfm_before;

    strcoil.Pwire=tmp(1:3,:)'; %update

%     global etc_render_fsbrain;
%     figure(etc_render_fsbrain.fig_brain);
% 
%     global h1
%     if(~isempty(h1)) delete(h1); end;
%     h1=plot3(strcoil.Pwire(:,1).*1e3,strcoil.Pwire(:,2).*1e3,strcoil.Pwire(:,3).*1e3);

catch
    fprintf('Error in updating strcoil!\n');
end;

results=1;

