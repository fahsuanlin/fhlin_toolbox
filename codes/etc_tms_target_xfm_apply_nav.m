function results = etc_tms_target_xfm_apply_nav(app, coil_center, coil_orientation, coil_up)
% etc_tms_target_xfm_apply_nav apply the transformation matrix to TMS coil
% objects
%
% etc_tms_target_xfm_apply_nav(app, coil_center, coil_orientation, coil_up)
%
% app: Matlab app of TMS coil navigation. This is required for accessing objects for visualization
% coil_center: 3x1 vector of TMS coil center (surface coordinate)
% coil_orientation: 3x1 vector of TMS coil axis (surface coordinate)
% coil_up: 3x1 vector of TMS coil up directional vector (surface
% coordinate)
%
% 
% Example: results = target_apply_xfm_nav(app, object_xfm(1:3,4).*1e3, -object_xfm(1:3,3), object_xfm(1:3,2));
%
% fhlin@May 30 2024
%


results=0;

%resettting tuning parameters
app.rotatedegSlider.Value=0;
app.offsetmmSlider.Value=0;
app.tilthorizdegSlider.Value=0;
app.tiltvertdegSlider.Value=0;

app.vertdegEditField.Value=0;
app.horizdegEditField.Value=0;
app.offsetmmEditField.Value=0;
app.rotatedegEditField.Value=0;

global etc_render_fsbrain;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TMS coil placement


%coil_center; % TMS coil center; in mm
%coil_orientation; %TMS coil axis; unit vector
%fprintf('distance between the target and coil center = %2.2f (mm)\n',norm(coil_orientation));
%app.TextArea.Value{end+1}=sprintf('distance between the target and coil center = %2.2f (mm)\n',norm(coil_orientation));

%coil_orientation=coil_orientation./norm(coil_orientation);
%scalp_orientation=surf_norm(min_idx,:);

% derive the rotation matrix between two vectors (from, to)
% https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d
ssc = @(v) [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
RU = @(A,B) eye(3) + ssc(cross(A,B)) + ssc(cross(A,B))^2*(1-dot(A,B))/(norm(cross(A,B))^2);

%fprintf('before moving: coil origin: %s \n',mat2str(etc_render_fsbrain.object.UserData.Origin(:).',3));
%fprintf('before moving: coil origin target: %s \n',mat2str(coil_center(:).',3));

%etc_render_fsbrain.object.UserData.Axis(:).'

coil_shift=-etc_render_fsbrain.object.UserData.Origin(:)+coil_center(:);
n=norm(etc_render_fsbrain.object.UserData.Axis(:)'-coil_orientation);
if(n>eps)
    RR=RU(etc_render_fsbrain.object.UserData.Axis(:)',coil_orientation(:)');
else
    RR=eye(3);
end;
if(find(isnan(RR(:)))) keyboard; end;
if(find(isnan(coil_shift(:)))) keyboard; end;

% update object_xfm matrix
R=eye(4);
R(1:3,4)=etc_render_fsbrain.object.UserData.Origin(:);
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

if(isempty(etc_render_fsbrain.object_xfm))
    etc_render_fsbrain.object_xfm=R_trans*R_tx_now*inv(R_rot)*inv(R_tx_now);
else
    etc_render_fsbrain.object_xfm=R_trans*R_tx_now*inv(R_rot)*inv(R_tx_now)*etc_render_fsbrain.object_xfm;
end;
%transform object in visualiation
vv=etc_render_fsbrain.object.Vertices;
vv(:,4)=1;
vv=(R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm)*vv')';
etc_render_fsbrain.object.Vertices=vv(:,1:3);




if(~isempty(app.norm_obj))
    tmp=[app.norm_obj.XData; app.norm_obj.YData; app.norm_obj.ZData; ones(size(app.norm_obj.XData))];
    tmp=(R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm)*tmp);
    %tmp=((inv(R_c)*inv(R_rotz)*R_c)*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*tmp);
    app.norm_obj.XData=tmp(1,:);
    app.norm_obj.YData=tmp(2,:);
    app.norm_obj.ZData=tmp(3,:);
end;

if(~isempty(app.up_obj))
    tmp=[app.up_obj.XData; app.up_obj.YData; app.up_obj.ZData; ones(size(app.up_obj.XData))];
    tmp=(R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm)*tmp);
    %tmp=((inv(R_c)*inv(R_rotz)*R_c)*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*tmp);
    app.up_obj.XData=tmp(1,:);
    app.up_obj.YData=tmp(2,:);
    app.up_obj.ZData=tmp(3,:);
end;



%transform data
tmp=(R_trans_mm*R_tx_now_mm*inv(R_rot)*inv(R_tx_now_mm)*[etc_render_fsbrain.object.UserData.Origin(:)' 1]')';
%tmp=((inv(R_c)*inv(R_rotz)*(R_c))*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*[etc_render_fsbrain.object.UserData.Origin(:)' 1]')';
etc_render_fsbrain.object.UserData.Origin=tmp(1:3);

tmp=(inv(R_rot)*[etc_render_fsbrain.object.UserData.Axis(:)' 1]')';
%tmp=((inv(R_c)*inv(R_rotz)*(R_c))*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*[etc_render_fsbrain.object.UserData.Axis(:)' 1]')';
etc_render_fsbrain.object.UserData.Axis=tmp(1:3);
etc_render_fsbrain.object.UserData.Axis(:)';

norm_dir=[app.norm_obj.XData; app.norm_obj.YData; app.norm_obj.ZData]; norm_dir=diff(norm_dir,1,2); norm_dir=norm_dir./norm(norm_dir);
etc_render_fsbrain.object.UserData.Axis=norm_dir(:);
etc_render_fsbrain.object.UserData.Axis(:)';

tmp=(inv(R_rot)*[etc_render_fsbrain.object.UserData.Up(:)' 1]')';
%tmp=((inv(R_c)*inv(R_rotz)*(R_c))*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*[etc_render_fsbrain.object.UserData.Up(:)' 1]')';
etc_render_fsbrain.object.UserData.Up=tmp(1:3);
etc_render_fsbrain.object.UserData.Up(:)';


up_dir=[app.up_obj.XData; app.up_obj.YData; app.up_obj.ZData]; up_dir=diff(up_dir,1,2); up_dir=up_dir./norm(up_dir);
etc_render_fsbrain.object.UserData.Up=up_dir(:);
etc_render_fsbrain.object.UserData.Up(:)';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%aligning UP toward coil_up

coil_center=etc_render_fsbrain.object.UserData.Origin(:);
R_c_mm=eye(4);
R_c_mm(1:3,4)=-coil_center(1:3);
R_c=R_c_mm;
R_c(1:3,4)=R_c(1:3,4)./1e3;

coil_axis=etc_render_fsbrain.object.UserData.Axis(:).';
tmp=coil_axis./norm(coil_axis);
x=tmp(1);
y=tmp(2);
z=tmp(3);

%X1=etc_render_fsbrain.object.UserData.Origin(1);
%Y1=etc_render_fsbrain.object.UserData.Origin(2);
%Z1=etc_render_fsbrain.object.UserData.Origin(3);

%X2=0;
%Y2=0;
%Z2=100;
%vtop=[X2-X1; Y2-Y1; Z2-Z1]';
vtop=coil_up(:);
vtop_perp=vtop(:)-sum(vtop(:).*tmp(:)).*tmp(:);

vup=etc_render_fsbrain.object.UserData.Up;


%determine the rotation between two vectors;
xx = cross(vtop_perp,vup);
c = sign(dot(xx,etc_render_fsbrain.object.UserData.Axis)) * norm(xx);
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



etc_render_fsbrain.object_xfm=inv(R_c)*inv(R_rotz)*(R_c)*etc_render_fsbrain.object_xfm;

%transform object in visualiation

vv=etc_render_fsbrain.object.Vertices;
vv(:,4)=1;
vv=(inv(R_c_mm)*inv(R_rotz)*(R_c_mm)*vv')';
etc_render_fsbrain.object.Vertices=vv(:,1:3);



if(~isempty(app.norm_obj))
    tmp=[app.norm_obj.XData; app.norm_obj.YData; app.norm_obj.ZData; ones(size(app.norm_obj.XData))];
    tmp=((inv(R_c_mm)*inv(R_rotz)*R_c_mm)*tmp);
    %tmp=((inv(R_c)*inv(R_rotz)*R_c)*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*tmp);
    app.norm_obj.XData=tmp(1,:);
    app.norm_obj.YData=tmp(2,:);
    app.norm_obj.ZData=tmp(3,:);
end;

if(~isempty(app.up_obj))
    tmp=[app.up_obj.XData; app.up_obj.YData; app.up_obj.ZData; ones(size(app.up_obj.XData))];
    tmp=((inv(R_c_mm)*inv(R_rotz)*R_c_mm)*tmp);
    %tmp=((inv(R_c)*inv(R_rotz)*R_c)*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*tmp);
    app.up_obj.XData=tmp(1,:);
    app.up_obj.YData=tmp(2,:);
    app.up_obj.ZData=tmp(3,:);
end;


%transform data
tmp=((inv(R_c_mm)*inv(R_rotz)*R_c_mm)*[etc_render_fsbrain.object.UserData.Origin(:)' 1]')';
%tmp=((inv(R_c)*inv(R_rotz)*(R_c))*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*[etc_render_fsbrain.object.UserData.Origin(:)' 1]')';
etc_render_fsbrain.object.UserData.Origin=tmp(1:3);

tmp=(inv(R_rotz)*[etc_render_fsbrain.object.UserData.Axis(:)' 1]')';
%tmp=((inv(R_c)*inv(R_rotz)*(R_c))*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*[etc_render_fsbrain.object.UserData.Axis(:)' 1]')';
etc_render_fsbrain.object.UserData.Axis=tmp(1:3);
etc_render_fsbrain.object.UserData.Axis(:)';
norm_dir=[app.norm_obj.XData; app.norm_obj.YData; app.norm_obj.ZData]; norm_dir=diff(norm_dir,1,2); norm_dir=norm_dir./norm(norm_dir);
etc_render_fsbrain.object.UserData.Axis=norm_dir(:);
etc_render_fsbrain.object.UserData.Axis(:)';

etc_render_fsbrain.object.UserData.Axis_orig=etc_render_fsbrain.object.UserData.Axis;

tmp=(inv(R_rotz)*[etc_render_fsbrain.object.UserData.Up(:)' 1]')';
%tmp=((inv(R_c)*inv(R_rotz)*(R_c))*R_trans_mm*R_tx_now*inv(R_rot)*inv(R_tx_now)*[etc_render_fsbrain.object.UserData.Up(:)' 1]')';
etc_render_fsbrain.object.UserData.Up=tmp(1:3);
etc_render_fsbrain.object.UserData.Up(:)';
up_dir=[app.up_obj.XData; app.up_obj.YData; app.up_obj.ZData]; up_dir=diff(up_dir,1,2); up_dir=up_dir./norm(up_dir);
etc_render_fsbrain.object.UserData.Up=up_dir(:);
etc_render_fsbrain.object.UserData.Up(:)';

etc_render_fsbrain.object.UserData.Up_orig=etc_render_fsbrain.object.UserData.Up;

%end of aligning UP toward coil_up
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

app.rotatedegSlider.Value=0;
app.offsetmmSlider.Value=0;
app.tilthorizdegSlider.Value=0;
app.tiltvertdegSlider.Value=0;

app.EfieldCalclLamp.Color='r';

app.coil_center_no_tune=etc_render_fsbrain.object.UserData.Origin;

app.target_vertex_index=etc_render_fsbrain.click_coord;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%updating strcoil
if(~isempty(app.strcoil_obj))

    try
        tmp=app.strcoil_obj.Vertices;
        tmp(:,end+1)=1;
        tmp=tmp';
        xfm=etc_render_fsbrain.object_xfm;
        xfm(1:3,4)=xfm(1:3,4).*1e3; %into mm
        xfm_tmp=app.strcoil_obj_xfm;
        xfm_tmp(1:3,4)=xfm_tmp(1:3,4)*1e3; %into mm
        tmp=xfm*inv(xfm_tmp)*tmp;

        app.strcoil_obj.Vertices=tmp(1:3,:)'; %update
        app.strcoil_obj_xfm=etc_render_fsbrain.object_xfm;

%         tmp=app.strcoil_obj.Vertices./1e3;
%         assignin('base','tmp',tmp);
%         evalin('base','strcoil.Pwire=tmp;');
%         fprintf('variable [strcoil] update at the workspace.\n');
%         app.TextArea.Value{end+1}='variable [strcoil] updated at the workspace.';
        app.StrcoilLamp.Color='g';
        app.StrcoilShowCheckBox.Value=1;

    catch
        fprintf('Error in updating strcoil!\n');
        app.TextArea.Value{end+1}='Error in updating strcoil!\n';
    end;
end;

app.EfieldCalclLamp.Color='r';

results=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
