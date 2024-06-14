function [object_xfm]=etc_tms_target_xfm_tune(target, head_surf, tms_coil_origin, tms_coil_axis, tms_coil_up, object_xfm, tune_index, tune_value,varargin)
% etc_tms_target_xfm_tune Tune the transformation matrix of a TMS coil
%
% [tms_coil_xfm]=etc_tms_target_xfm_tune(target, head_surf, tms_coil_origin, tms_coil_axis, [option, option_value,...]);
%
% target: (x,y,z) of TMS target in surface coordinate
% head_surf: head (scalp) surface structure. It includes 'surf_norm' and 'surf_center' fields.
% tms_coil_origin: TMS coil origin vector.
% tms_coil_axis: TMS coil axis vector.
% tms_coil_up: TMS coil up directional vector.
% object_xfm: a 4x4 transformation matrix to be updated.
% tune_index:
%   1: vertical rotation
%   2: horizontal rotation
%   3: in/out coil plane offset
%   4: around-axis rotation
%
% tune_value: rotation (degree) or translation (mm)
%
%
% fhlin@May 30 2024
%


for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        otherwise
            fprintf('unknown [%s] option! error!\n',option)
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS coil tuning
switch(tune_index)
    case 1 %vertical rotation

        R_c=eye(4);
        R_c_mm=eye(4);
        R_c(1:3,4)=-target(1:3)./1e3;
        R_c_mm(1:3,4)=-target(1:3);

        coil_axis=cross(tms_coil_axis(:),tms_coil_up(:));
        tmp=coil_axis./norm(coil_axis);
        x=tmp(1);
        y=tmp(2);
        z=tmp(3);

        if(isempty(tms_coil_origin)) return; end; %taget not first defined by default

        v1=tms_coil_origin(:)-target(:);
        v2=tms_coil_origin(:)-target(:);

        deg = atan2(norm(cross(v2,v1)), dot(v2,v1));
        if(dot(coil_axis,cross(v1,v2))>0) deg=-deg; end;
        %fprintf('coil now is %1.0f (deg) away from untuned orientation.\n',deg*180/pi);

        %determine the rotation between two vectors;
        theta=tune_value./180*pi-deg;
        %theta=tune_value.*pi./180-deg;
        %fprintf('additional %1.0f (deg) rotation from untuned orientation is requested.\n',theta*180/pi);

        r_rotz=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
            y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
            z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
        %https://en.wikipedia.org/wiki/Rotation_matrix
        R_rotz=eye(4);
        R_rotz(1:3,1:3)=r_rotz;


        object_xfm=inv(R_c)*inv(R_rotz)*(R_c)*object_xfm;


        %transform data
        tmp=((inv(R_c_mm)*inv(R_rotz)*R_c_mm)*[tms_coil_origin(:)' 1]')';
        tms_coil_origin=tmp(1:3);

        tmp=(inv(R_rotz)*[tms_coil_axis(:)' 1]')';
        tms_coil_axis=tmp(1:3);

        tmp=(inv(R_rotz)*[tms_coil_up(:)' 1]')';
        tms_coil_up=tmp(1:3);

    case 2 %horizontal rotation
        R_c=eye(4);
        R_c_mm=eye(4);
        R_c(1:3,4)=-target(1:3)./1e3;
        R_c_mm(1:3,4)=-target(1:3);

        coil_axis=tms_coil_up(:);
        tmp=coil_axis./norm(coil_axis);
        x=tmp(1);
        y=tmp(2);
        z=tmp(3);


        if(isempty(tms_coil_origin)) return; end; %taget not first defined by default

        v1=tms_coil_origin(:)-target(:);
        v2=tms_coil_origin(:)-target(:);

        deg = atan2(norm(cross(v2,v1)), dot(v2,v1));
        if(dot(coil_axis,cross(v1,v2))>0) deg=-deg; end;
        %fprintf('coil now is %1.0f (deg) away from untuned orientation.\n',deg*180/pi);

        %determine the rotation between two vectors;
        theta=tune_value./180*pi-deg;
        %theta=tune_value.*pi./180-deg;
        %fprintf('additional %1.0f (deg) rotation from untuned orientation is requested.\n',theta*180/pi);

        r_rotz=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
            y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
            z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
        %https://en.wikipedia.org/wiki/Rotation_matrix
        R_rotz=eye(4);
        R_rotz(1:3,1:3)=r_rotz;


        object_xfm=inv(R_c)*inv(R_rotz)*(R_c)*object_xfm;


        %transform data
        tmp=((inv(R_c_mm)*inv(R_rotz)*R_c_mm)*[tms_coil_origin(:)' 1]')';
        tms_coil_origin=tmp(1:3);

        tmp=(inv(R_rotz)*[tms_coil_axis(:)' 1]')';
        tms_coil_axis=tmp(1:3);

        tmp=(inv(R_rotz)*[tms_coil_up(:)' 1]')';
        tms_coil_up=tmp(1:3);


    case 3 %in/out coil plane offset
        R_c=eye(4);
        R_c_mm=eye(4);
        R_c(1:3,4)=-target(1:3);
        R_c_mm(1:3,4)=-target(1:3).*1e3;

        coil_axis=tms_coil_axis(:).';
        tmp=coil_axis./norm(coil_axis);
        desired_vec=-tune_value./1e3.*tmp(:);
        now_vec=tms_coil_origin(:)./1e3-target(:);

        diff_vec=desired_vec-now_vec;
        tmp=diff_vec;

        R_offset=eye(4);
        R_offset_mm=eye(4);
        R_offset(1:3,4)=tmp(:);
        R_offset_mm(1:3,4)=tmp(:).*1e3

        object_xfm=R_offset*object_xfm;

        %transform data
        tmp=(R_offset_mm*[tms_coil_origin(:)' 1]')';
        tms_coil_origin=tmp(1:3);

        tmp=(eye(4)*[tms_coil_axis(:)' 1]')';
        tms_coil_axis=tmp(1:3);

        tmp=(eye(4)*[tms_coil_up(:)' 1]')';
        tms_coil_up=tmp(1:3);
    case 4 %around-axis rotation
        coil_center=tms_coil_origin(:);
        R_c_mm=eye(4);
        R_c=eye(4);
        R_c_mm(1:3,4)=-coil_center(1:3);
        R_c(1:3,4)=-coil_center(1:3)./1e3;

        coil_axis=tms_coil_axis(:).';
        tmp=coil_axis./norm(coil_axis);
        x=tmp(1);
        y=tmp(2);
        z=tmp(3);

        vtop=tms_coil_up(:); %% important! always refer to the rotation with respect to the "untued" orientation
        vtop_perp=vtop(:)-sum(vtop(:).*tmp(:)).*tmp(:);

        vup=tms_coil_up(:);


        %determine the rotation between two vectors;
        xx = cross(vtop_perp,vup);
        c = sign(dot(xx,tms_coil_axis)) * norm(xx);
        deg = atan2d(c,dot(vtop_perp,vup)).*pi./180;
        theta=(deg-tune_value./180*pi);

        r_rotz=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
            y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
            z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
        %https://en.wikipedia.org/wiki/Rotation_matrix
        R_rotz=eye(4);
        R_rotz(1:3,1:3)=r_rotz;



        object_xfm=inv(R_c)*inv(R_rotz)*(R_c)*object_xfm;

        %transform data
        tmp=((inv(R_c_mm)*inv(R_rotz)*R_c_mm)*[tms_coil_origin(:)' 1]')';
        tms_coil_origin=tmp(1:3);

        tmp=(inv(R_rotz)*[tms_coil_axis(:)' 1]')';
        tms_coil_axis=tmp(1:3);

        tmp=(inv(R_rotz)*[tms_coil_up(:)' 1]')';
        tms_coil_up=tmp(1:3);

end;
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
