function etc_render_fsbrain_tms_nav_notify(app, event,varargin)
    global etc_render_fsbrain;


    if(isempty(event))


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

        value = app.VecNormCheckBox.Value;

        if(value)
            set(app.norm_obj,'visible','on');
        else
            set(app.norm_obj,'visible','off');
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

        value = app.VecUpCheckBox.Value;

        if(value)
            set(app.up_obj,'visible','on');
        else
            set(app.up_obj,'visible','off');
        end;

        %automatically update strcoil
        if(app.StrcoilAutoCheckBox.Value)
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

                tmp=app.strcoil_obj.Vertices./1e3;
                assignin('base','tmp',tmp);
                evalin('base','strcoil.Pwire=tmp;');
                fprintf('variable [strcoil] update at the workspace.\n');
                app.TextArea.Value{end+1}='variable [strcoil] updated at the workspace.';
                app.StrcoilLamp.Color='g';
                app.StrcoilShowCheckBox.Value=1;
            catch
                fprintf('Error in updating strcoil!\n');
                app.TextArea.Value{end+1}='Error in updating strcoil!\n';
            end;
        end;

        return;
    end;

    switch event.Source
        case app.vertexindexEditField; % Execution code related to vertexindexEditField
            
            app.vertexindexEditField.Value=num2str(varargin{1}(:)','%1.0f ');
        case app.XYZEditField; % Execution code related to XYZEditField
            
            app.XYZEditField.Value=num2str(varargin{1}(:)','%1.1f ');

        case app.CRSEditField; % Execution code related to CRSEditField
            
            app.CRSEditField.Value=num2str(varargin{1}(:)','%1.0f ');

        case app.MNIEditField; % Execution code related to MNIEditField
            
            app.MNIEditField.Value=num2str(varargin{1}(:)','%1.0f ');

        case app.ScannerEditField; % Execution code related to MNIEditField
            
            app.ScannerEditField.Value=num2str(varargin{1}(:)','%1.0f ');
        case app.DefModelLamp; % Execution code related to DefModelLamp
            app.DefModelLamp.Color=varargin{1};
            app.PrepModelLamp.Color=varargin{2};

        case app.PrepModelLamp; % Execution code related to PrepModelLamp
            app.PrepModelLamp.Color=varargin{1};

            app.file_tissue_index=varargin{2};

        case app.EfieldCalclLamp; % Execution code related to EfieldCalclLamp
            app.EfieldCalclLamp.Color=varargin{1};
        
        case app.SurfaceDropDown; % Execution code related to SurfaceDropDown
            app.SurfaceDropDown.Items={};
            for idx=1:length(etc_render_fsbrain.surf_obj)
                [pp,ff]=fileparts(etc_render_fsbrain.surf_obj(idx).filename);
                app.SurfaceDropDown.Items{idx}=ff;
                app.SurfaceDropDown.Value=ff;
            end;
            if(isempty(app.SurfaceDropDown.Items))
                app.ShowscalpCheckBox.Enable='off';
            else
                app.ShowscalpCheckBox.Enable='on';
                app.ShowscalpCheckBox.Value=1;
            end;
    end
return;