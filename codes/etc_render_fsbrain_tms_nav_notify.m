function etc_render_fsbrain_tms_nav_notify(app, event,varargin)
    global etc_render_fsbrain;

    switch event.Source
        case app.vertexindexEditField; % Execution code related to vertexindexEditField
            
            app.vertexindexEditField.Value=num2str(varargin{1}(:)','%1.0f ');
        case app.XYZEditField; % Execution code related to XYZEditField
            
            app.XYZEditField.Value=num2str(varargin{1}(:)','%1.1f ');

        case app.CRSEditField; % Execution code related to CRSEditField
            
            app.CRSEditField.Value=num2str(varargin{1}(:)','%1.0f ');

        case app.MNIEditField; % Execution code related to MNIEditField
            
            app.MNIEditField.Value=num2str(varargin{1}(:)','%1.0f ');


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