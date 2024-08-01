function [tms_coil_xfm, tms_coil_xfm_mm]=etc_tms_target_xfm_goto(target, head_surf, tms_coil_origin, tms_coil_axis, tms_coil_up, tms_coil_xfm,varargin)
% etc_tms_target_xfm_goto update the transformation matrix of a TMS coil 
%
% [tms_coil_xfm,
% tms_coil_xfm_mm]=etc_tms_target_xfm_goto(target, head_surf, tms_coil_origin, tms_coil_axis, tms_coil_xfm, [option, option_value,...]);
%
% target: (x,y,z) of TMS target in surface coordinate
% head_surf: head (scalp) surface structure. It includes 'surf_norm' and 'surf_center' fields.
% tms_coil_origin: TMS coil origin vector.  
% tms_coil_axis: TMS coil axis vector.
% tms_coil_up: TMS coil up directional vector.
%
% tms_coil_xfm: a [4x4] TMS coil transformation matrix;
% option:
%     tms_coil_xfm_mm: a [4x4] TMS coil transformation matrix (in mm);
%
% fhlin@May 30 2024
%

move_v=[]; %move along "Up" direction in meter
move_h=[]; %move along "horizontal" direction (cross-product of coil axis and "Up") in meter

tms_coil_xfm_mm=[];

flag_display=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};
    switch(lower(option))
        case 'tms_coil_xfm_mm'
            tms_coil_xfm_mm=option_value;
        case 'move_v'
            move_v=option_value;
        case 'move_h'
            move_h=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown [%s] option! error!\n',option)
            return;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS coil placement

surf_center=head_surf.surf_center;
surf_norm=head_surf.surf_norm;

%calculate target-coil distance
dist=sqrt(sum(bsxfun(@minus,surf_center,target).^2,2));
[min_dist,min_idx]=min(dist);

%show coil position with the minimal distance
%cc=get(gca,'colororder');
%hq=quiver3(surf_center(min_idx,1),surf_center(min_idx,2),surf_center(min_idx,3),surf_norm(min_idx,1),surf_norm(min_idx,2),surf_norm(min_idx,3),15,'color','r');

coil_center=surf_center(min_idx,:); % in mm
coil_orientation=target-coil_center;
if(flag_display)    
    fprintf('distance between the target and coil center = %2.2f (mm)\n',norm(coil_orientation));
end;

coil_orientation=coil_orientation./norm(coil_orientation);
scalp_orientation=surf_norm(min_idx,:);

% derive the rotation matrix between two vectors (from, to)
% https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
ssc = @(v) [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
RU = @(A,B) eye(3) + ssc(cross(A,B)) + ssc(cross(A,B))^2*(1-dot(A,B))/(norm(cross(A,B))^2);

%fprintf('before moving: coil origin: %s \n',mat2str(tms_coil_origin(:).',3));
%fprintf('before moving: coil origin target: %s \n',mat2str(coil_center(:).',3));

%tms_coil_axis(:).'

coil_shift=-tms_coil_origin(:)+coil_center(:);
n=norm(tms_coil_axis(:)'-coil_orientation);
if(n>eps)
    RR=RU(tms_coil_axis(:)',coil_orientation(:)');
else
    RR=eye(3);
end;
if(find(isnan(RR(:)))) keyboard; end;
if(find(isnan(coil_shift(:)))) keyboard; end;

% update tms_coil_xfm matrix
R=eye(4);
R(1:3,4)=tms_coil_origin(:);
R_tx_now_mm=R;
R_tx_now=R_tx_now_mm;
R_tx_now(1:3,4)=R_tx_now(1:3,4)./1e3;


R=eye(4);
R(1:3,1:3)=RR;
R_rot=R';

R=eye(4);
R(1:3,4)=coil_shift(:)./1e3; %in m
R_trans=R;

R=eye(4);
R(1:3,4)=coil_shift(:); %in mm
R_trans_mm=R;

if(isempty(tms_coil_xfm))
    tms_coil_xfm=R_trans*R_tx_now*inv(R_rot)*inv(R_tx_now);
else
    tms_coil_xfm=R_trans*R_tx_now*inv(R_rot)*inv(R_tx_now)*tms_coil_xfm;
end;


if(isempty(tms_coil_xfm_mm))
    tms_coil_xfm_mm=R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm);
else
    tms_coil_xfm_mm=R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm)*tms_coil_xfm_mm;
end;


%transform data
tmp=(R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm)*[tms_coil_origin(:)' 1]')';
tms_coil_origin=tmp(1:3);
if(flag_display)
    fprintf('after moving: coil origin: %s \n',mat2str(tms_coil_origin(:).',3));
end;

tmp=(inv(R_rot)*[tms_coil_axis(:)' 1]')';
tms_coil_axis=tmp(1:3);


tmp=(inv(R_rot)*[tms_coil_up(:)' 1]')';
tms_coil_up=tmp(1:3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%aligning UP toward +z

coil_center=tms_coil_origin(:);
R_c_mm=eye(4);
R_c_mm(1:3,4)=-coil_center(1:3);
R_c=R_c_mm;
R_c(1:3,4)=R_c(1:3,4)./1e3;

coil_axis=tms_coil_axis(:).';
tmp=coil_axis./norm(coil_axis);
x=tmp(1);
y=tmp(2);
z=tmp(3);

X1=tms_coil_origin(1);
Y1=tms_coil_origin(2);
Z1=tms_coil_origin(3);

X2=0;
Y2=0;
Z2=100;
vtop=[X2-X1; Y2-Y1; Z2-Z1]';
vtop_perp=vtop-sum(vtop.*tmp).*tmp;

vup=tms_coil_up;


%determine the rotation between two vectors;
xx = cross(vtop_perp,vup);
c = sign(dot(xx,tms_coil_axis)) * norm(xx);
deg = atan2d(c,dot(vtop_perp,vup)).*pi./180;

%[azimuth,elevation,r] = cart2sph(x,y,z);
%deg=azimuth;
theta=(deg);
r_rotz=[cos(theta)+x*x*(1-cos(theta)), x*y*(1-cos(theta))-z*sin(theta), x*z*(1-cos(theta))+y*sin(theta);
    y*x*(1-cos(theta))+z*sin(theta) cos(theta)+y*y*(1-cos(theta)) y*z*(1-cos(theta))-x*sin(theta);
    z*x*(1-cos(theta))-y*sin(theta) z*y*(1-cos(theta))+x*sin(theta) cos(theta)+z*z*(1-cos(theta))];
%https://en.wikipedia.org/wiki/Rotation_matrix
R_rotz=eye(4);
R_rotz(1:3,1:3)=r_rotz;


tms_coil_xfm=inv(R_c)*inv(R_rotz)*(R_c)*tms_coil_xfm;
tms_coil_xfm_mm=inv(R_c_mm)*inv(R_rotz)*(R_c_mm)*tms_coil_xfm_mm;

if(~isempty(move_v))
    displacement=tms_coil_up./norm(tms_coil_up).*(-move_v);
    displacement_mm=tms_coil_up./norm(tms_coil_up).*(-move_v).*1e3;
    
    tms_coil_xfm(1:3,4)=    tms_coil_xfm(1:3,4)+displacement(:);
    tms_coil_xfm_mm(1:3,4)=    tms_coil_xfm_mm(1:3,4)+displacement_mm(:);
end;

if(~isempty(move_h))
    h_axis=cross(tms_coil_axis,tms_coil_up);
    displacement=h_axis./norm(h_axis).*move_h;
    displacement_mm=h_axis./norm(h_axis).*move_h.*1e3;
    
    tms_coil_xfm(1:3,4)=    tms_coil_xfm(1:3,4)+displacement(:);
    tms_coil_xfm_mm(1:3,4)=    tms_coil_xfm_mm(1:3,4)+displacement_mm(:);
end;

return;
