function [status, tms_coil_origin, tms_coil_axis, tms_coil_up, tms_coil_xfm ] = etc_tms_init_nav(app, strcoil, P, t, varargin)

tms_coil_origin=[];
tms_coil_axis=[];
tms_coil_up=[];
tms_coil_xfm=[];

subject='';

status=0;

flag_display=1;
flag_save=1;

for i=1:length(varargin)/2
    option=varargin{i*2-1};
    option_value=varargin{i*2};

    switch lower(option)
        case 'tms_coil_origin'
            tms_coil_origin=option_value;
        case 'tms_coil_axis'
            tms_coil_axis=option_value;
        case 'tms_coil_up'
            tms_coil_up=option_value;
        case 'tms_coil_xfm'
            tms_coil_xfm=option_value;
        case 'flag_display'
            flag_display=option_value;
        case 'flag_save'
            flag_display=option_value;
        case 'subject'
            subject=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option);
            return;
    end;
end;

global etc_render_fsbrain;

if(isempty(app))
    if(~isempty(subject)) %initialize etc_render_fsbrain window
        etc_render_fsbrain_init('subject',subject); 
        etc_render_fsbrain_handle('kb','cc','n');

        app=etc_render_fsbrain.app_tms_nav;
    else
        fprintf('Error! No etc_render_fsbrain enabled for this subject!\n');
        return;
    end;
end;

%initiating coil for visualization
try
    %if(isfield(Coil,'P')&isfield(Coil,'t')) app.CoilLamp.Color='g'; else return; end;
    if(~isempty(P)&~isempty(t)) app.CoilLamp.Color='g'; else return; end;

    P=P.*1e3; %in mm
    figure(etc_render_fsbrain.fig_brain);
    coil_patch=patch('vertices',P,'faces',t,'edgecolor','none','facecolor',[ 0.9294    0.6941    0.1255]);
    if(isempty(tms_coil_origin))
        coil_patch.UserData.Origin=[0 0 0]'; %origin of the coil at +z = 0 mm
    else
        coil_patch.UserData.Origin=tms_coil_origin(:);
    end;
    tms_coil_origin = coil_patch.UserData.Origin;


    if(isempty(tms_coil_axis))
        coil_patch.UserData.Axis=[0 0 -1]'; %directional vector; coil plane normal
    else
        coil_patch.UserData.Axis=tms_coil_axis(:);
    end;
    tms_coil_axis = coil_patch.UserData.Axis;


    if(isempty(tms_coil_up))
        coil_patch.UserData.Up=[0 1 0]'; %directional vector; coil upward
    else
        coil_patch.UserData.Up=tms_coil_up(:);
    end;
    tms_coil_up = coil_patch.UserData.Up;

    if(isfield(etc_render_fsbrain,'object'))
        if(~isempty(etc_render_fsbrain.object))
            try
                delete(etc_render_fsbrain.object);
            catch
            end;

            etc_render_fsbrain.object=[];
            etc_render_fsbrain.object_xfm=[];
        end;
    end;

    etc_render_fsbrain.object=coil_patch;

    if(~isempty(coil_patch))
        etc_render_fsbrain.object_Vertices_orig=etc_render_fsbrain.object.Vertices;
        %if(~isempty(object_xfm))
        %    etc_render_fsbrain.object_xfm=object_xfm;
        %else

        if(isempty(tms_coil_xfm))
            etc_render_fsbrain.object_xfm=eye(4);
        else
            etc_render_fsbrain.object_xfm=tms_coil_xfm;
        end;
        tms_coil_xfm = etc_render_fsbrain.object_xfm;
        %end;

        if(isfield(etc_render_fsbrain.object.UserData,'Origin'))
            etc_render_fsbrain.object.UserData.Origin_orig=etc_render_fsbrain.object.UserData.Origin;
        end;
        if(isfield(etc_render_fsbrain.object.UserData,'Axis'))
            etc_render_fsbrain.object.UserData.Axis_orig=etc_render_fsbrain.object.UserData.Axis;
        end;
        if(isfield(etc_render_fsbrain.object.UserData,'Up'))
            etc_render_fsbrain.object.UserData.Up_orig=etc_render_fsbrain.object.UserData.Up;
        end;


        if(isempty(app.up_obj))
        else
            delete(app.up_obj);
        end;
        X1=etc_render_fsbrain.object.UserData.Origin(1);
        Y1=etc_render_fsbrain.object.UserData.Origin(2);
        Z1=etc_render_fsbrain.object.UserData.Origin(3);

        X2=etc_render_fsbrain.object.UserData.Origin(1)+etc_render_fsbrain.object.UserData.Up(1).*100; %100 mm line
        Y2=etc_render_fsbrain.object.UserData.Origin(2)+etc_render_fsbrain.object.UserData.Up(2).*100; %100 mm line
        Z2=etc_render_fsbrain.object.UserData.Origin(3)+etc_render_fsbrain.object.UserData.Up(3).*100; %100 mm line
        object_line=[X1 X2; Y1 Y2; Z1 Z2]';

        app.up_obj=plot3(object_line(:, 1), object_line(:, 2), object_line(:, 3), '-g', 'lineWidth', 2);

        flag_show_up=1;
        app.VecUpCheckBox.Value=1;

        if(isempty(app.norm_obj))
        else
            delete(app.norm_obj);
        end;
        X1=etc_render_fsbrain.object.UserData.Origin(1);
        Y1=etc_render_fsbrain.object.UserData.Origin(2);
        Z1=etc_render_fsbrain.object.UserData.Origin(3);

        X2=etc_render_fsbrain.object.UserData.Origin(1)+etc_render_fsbrain.object.UserData.Axis(1).*100; %100 mm line
        Y2=etc_render_fsbrain.object.UserData.Origin(2)+etc_render_fsbrain.object.UserData.Axis(2).*100; %100 mm line
        Z2=etc_render_fsbrain.object.UserData.Origin(3)+etc_render_fsbrain.object.UserData.Axis(3).*100; %100 mm line
        object_line=[X1 X2; Y1 Y2; Z1 Z2]';

        app.norm_obj=plot3(object_line(:, 1), object_line(:, 2), object_line(:, 3), '-m', 'lineWidth', 5);

        flag_show_norm=1;
        app.VecNormCheckBox.Value=1;


        app.CoilShowCheckBox.Value=1;

    else
        etc_render_fsbrain.object_xfm=[];
        if(isfield(etc_render_fsbrain.object.UserData,'Origin'))
            etc_render_fsbrain.object.UserData.Origin_orig=etc_render_fsbrain.object.UserData.Origin;
        end;
        if(isfield(etc_render_fsbrain.object.UserData,'Axis'))
            etc_render_fsbrain.object.UserData.Axis_orig=etc_render_fsbrain.object.UserData.Axis;
        end;
        if(isfield(etc_render_fsbrain.object.UserData,'Up'))
            etc_render_fsbrain.object.UserData.Up_orig=etc_render_fsbrain.object.UserData.Up;
        end;
    end;

    %resettting tuning parameters
    app.rotatedegSlider.Value=0;
    app.offsetmmSlider.Value=0;
    app.tilthorizdegSlider.Value=0;
    app.tiltvertdegSlider.Value=0;

    app.vertdegEditField.Value=0;
    app.horizdegEditField.Value=0;
    app.offsetmmEditField.Value=0;
    app.rotatedegEditField.Value=0;

    app.coil_center_no_tune=etc_render_fsbrain.object.UserData.Origin;

    app.TextArea.Value{end+1}=sprintf('Variable Coil successfully loaded!\n');

catch
    fprintf('Error in initiating TMS navigation (coil part)!\n');

    app.TextArea.Value{end+1}=sprintf('Error in initiating TMS navigation (coil part)!\n');
end;



%initiating strcoil for modeling

try
    tmp=strcoil.Pwire.*1e3;
    tmp(:,end+1)=1;
    tmp=tmp';
    xfm=etc_render_fsbrain.object_xfm;
    xfm(1:3,4)=xfm(1:3,4).*1e3; %into mm
    tmp=xfm*tmp;

    %remember this to be used for updating later
    app.strcoil_obj_xfm=etc_render_fsbrain.object_xfm;

    if(~isempty(app.strcoil_obj))
        if(isvalid(app.strcoil_obj))
            try
                delete(app.strcoil_obj);
            catch
            end;
        end;
    end;
    app.strcoil_obj=patch('faces', strcoil.Ewire, 'vertices', tmp(1:3,:)', 'EdgeColor', 'g', 'FaceColor','b');


    %                     assignin('base','strcoil',strcoil);
    %
    %                     tmp=app.strcoil_obj.Vertices./1e3;
    %                     assignin('base','tmp',tmp);
    %                     evalin('base','strcoil.Pwire=tmp;');
    %
    %                     fprintf('variable [strcoil] loaded to the workspace.\n');
    %                     app.TextArea.Value{end+1}='variable [strcoil] loaded to the workspace.';
    app.StrcoilLamp.Color='g';
    app.StrcoilShowCheckBox.Value=1;

    app.StrcoilAutoCheckBox.Value=1;

catch
    fprintf('Error in initiating TMS navigation (strcoil part)!\n');

    app.TextArea.Value{end+1}=sprintf('Error in initiating TMS navigation (strcoil part)!\n');
end;
