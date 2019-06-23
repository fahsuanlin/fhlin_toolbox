function h=etc_render_fsbrain(varargin)
%
% etc_render_fsbrain    rendering the anatomy and overlay of a freesurfer brain
%
% h = etc_render_fsbrain([option1 option1_value, ...]);
%
% h: the handle of the patch object
%
% fhlin@aug.12 2014
% fhlin@dec.25 2014
%

h=[];

%fundamental anatomy geometry
subjects_dir=getenv('SUBJECTS_DIR');
subject='fsaverage';
surf='inflated';
flag_curv=1;
hemi='lh'; %hemi={'lh','rh'}; for showing both hemispheres;
curv=[];
vol=[];
vol_A=[];
vol_vox=[];
vol_pre_xfm=eye(4);
talxfm=[];

%color 
default_solid_color=[1.0000    0.7031    0.3906];
curv_pos_color=[1 1 1].*0.4;
curv_neg_color=[1 1 1].*0.7;

bg_color=[1 1 1]; %figure background color;
overlay_cmap=autumn(80); %overlay colormap;
overlay_cmap_neg=winter(80); %overlay colormap;
overlay_cmap_neg(:,3)=1;

%overlay
overlay_vol=[];
overlay_vol_stc=[];
overlay_value=[];
overlay_stc=[];
overlay_aux_stc=[];
overlay_stc_hemi=[];
overlay_stc_lim=[];
overlay_stc_timeVec=[];
overlay_stc_timeVec_unit='';
overlay_stc_timeVec_idx=[];
overlay_vertex=[];
orig_overlay_vertex=[];
overlay_smooth=5;
overlay_threshold=[];
overlay_value_flag_pos=0;
overlay_value_flag_neg=0;
overlay_regrid_flag=0;
overlay_regrid_zero_flag=0;
overlay_flag_render=1;
overlay_fixval_flag=0;
overlay_Ds=[];

overlay_exclude_fstem='';
overlay_exclude=[];

overlay_include_fstem='';
overlay_include=[];

topo_label={};

topo_aux_point_coords=[];
topo_aux_point_coords_h=[];
topo_aux_point_name={};
topo_aux_point_name_h=[];
topo_aux_point_color=[1 0 0];
topo_aux_point_size=0.005;
topo_aux_point_label_flag=1;

topo_aux2_point_coords=[];
topo_aux2_point_coords_h=[];
topo_aux2_point_name={};
topo_aux2_point_name_h=[];
topo_aux2_point_color=[0.3984    0.5977         0];
topo_aux2_point_size=44;

%electrode
electrode=[];

%label (annotation)
label_vertex=[];
label_value=[];
label_ctab=[];
file_annot='';

%stc time course
flag_hold_fig_stc_timecourse=0;

%cluster file
cluster_file={};

%etc
alpha=1;
view_angle=[]; 

flag_redraw=0;
flag_camlight=1;
flag_colorbar=0;
show_nearest_brain_surface_location_flag=1;
show_contact_names_flag=1;
show_all_contacts_mri_flag=1;
electrode_update_contact_view_flag=0;

click_point_size=28;
click_point_color=[1 0 1];

click_vertex_point_size=24;
click_vertex_point_color=[0 1 1];


for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'subject'
            subject=option_value;
        case 'subjects_dir'
            subjects_dir=option_value;
        case 'hemi'
            hemi=option_value;
        case 'surf'
            surf=option_value;
        case 'vol'
            vol=option_value;
        case 'vol_a'
            vol_A=option_value;
        case 'vol_pre_xfm'
            vol_pre_xfm=option_value;
        case 'talxfm'
            talxfm=option_value;
        case 'flag_curv'
            flag_curv=option_value;
        case 'default_solid_color'
            default_solid_color=option_value;
        case 'curv_pos_color'
            curv_pos_color=option_value;
        case 'curv_neg_color'
            curv_neg_color=option_value;
        case 'overlay_vol'
            overlay_vol=option_value;
        case 'overlay_vol_stc'
            overlay_vol_stc=option_value;
        case 'overlay_flag_render'
            overlay_flag_render=option_value;
        case 'overlay_value'
            overlay_value=option_value;
        case 'overlay_stc'
            overlay_stc=option_value;
        case 'overlay_aux_stc'
            overlay_aux_stc=option_value;
        case 'overlay_exclude'
            overlay_exclude=option_value;
        case 'overlay_exclude_fstem'
            overlay_exclude_fstem=option_value;
        case 'overlay_include'
            overlay_include=option_value;
        case 'overlay_include_fstem'
            overlay_include_fstem=option_value;
        case 'overlay_stc_lim'
            overlay_stc_lim=option_value;
        case 'overlay_stc_timevec'
            overlay_stc_timeVec=option_value;
        case 'overlay_stc_timevec_unit'
            overlay_stc_timeVec_unit=option_value;
        case 'overlay_vertex'
            overlay_vertex=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'overlay_ds'
            overlay_Ds=option_value;
        case 'overlay_regrid_flag'
            overlay_regrid_flag=option_value;
        case 'overlay_regrid_zero_flag'
            overlay_regrid_zero_flag=option_value;
        case 'overlay_fixval_flag'
            overlay_fixval_flag=option_value;
        case 'overlay_threshold'
            overlay_threshold=option_value;
        case 'overlay_cmap'
            overlay_cmap=option_value;
        case 'overlay_cmap_neg'
            overlay_cmap_neg=option_value;
        case 'cluster_file'
            cluster_file=option_value;
        case 'alpha'
            alpha=option_value;
        case 'flag_redraw'
            flag_redraw=option_value;
        case 'flag_camlight'
            flag_camlight=option_value;
        case 'flag_colorbar'
            flag_colorbar=option_value;
        case 'flag_hold_fig_stc_timecourse'
            flag_hold_fig_stc_timecourse=option_value;
        case 'show_nearest_brain_surface_location_flag'
            show_nearest_brain_surface_location_flag=option_value;
        case 'show_contact_names_flag'
            show_contact_names_flag=option_value;
        case 'show_all_contacts_mri_flag'
            show_all_contacts_mri_flag=option_value;
        case 'electrode_update_contact_view_flag'
            electrode_update_contact_view_flag=option_value;
        case 'view_angle'
            view_angle=option_value;
        case 'bg_color'
            bg_color=option_value;
        case 'topo_label'
            topo_label=option_value;
        case 'topo_aux_point_coords';
            topo_aux_point_coords=option_value;
        case 'topo_aux_point_name';
            topo_aux_point_name=option_value;
        case 'topo_aux_point_color'
            topo_aux_point_color=option_value;
        case 'topo_aux_point_size'
            topo_aux_point_size=option_value;
        case 'topo_aux_point_label_flag'
            topo_aux_point_label_flag=option_value;
        case 'topo_aux2_point_coords';
            topo_aux2_point_coords=option_value;
        case 'topo_aux2_point_name';
            topo_aux2_point_name=option_value;
        case 'topo_aux2_point_color'
            topo_aux2_point_color=option_value;
        case 'topo_aux2_point_size'
            topo_aux2_point_size=option_value;
        case 'label_vertex'
            label_vertex=option_value;
        case 'label_value'
            label_value=option_value;
        case 'label_ctab'
            label_ctab=option_value;
        case 'file_annot'
            file_annot=option_value;
        case 'electrode'
            electrode=option_value;
        case 'click_point_size'
            click_point_size=option_value;
        case 'click_point_color'
            click_point_color=option_value;
        case 'click_vertex_point_size'
            click_vertex_point_size=option_value;
        case 'click_vertex_point_color'
            click_vertex_point_color=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end

%get the surface overlay values from volumetric STC.
if(~isempty(overlay_vol_stc)&~isempty(vol_A))
    for hemi_idx=1:2
        n_dip(hemi_idx)=size(vol_A(hemi_idx).A,2);
        n_source(hemi_idx)=n_dip(hemi_idx)/3;
        switch hemi_idx
            case 1
                offset=0;
            case 2
                offset=n_source(1);
        end;
        X_hemi_cort{hemi_idx}=overlay_vol_stc(offset+1:offset+length(vol_A(hemi_idx).v_idx),:);
        X_hemi_subcort{hemi_idx}=overlay_vol_stc(offset+length(vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:);
    end;
    if(strcmp('hemi','lh'))    
        overlay_stc=X_hemi_cort{1};
        overlay_vertex=vol_A(1).v_idx;
    else
        overlay_stc=X_hemi_cort{2};
        overlay_vertex=vol_A(2).v_idx;
    end;
end;

%get the overlay value from STC at the largest power instant, if it is not specified.
if(isempty(overlay_value)&~isempty(overlay_stc))
    if(iscell(overlay_stc))
        tmp=[];
        for h_idx=1:length(overlay_stc)
            tmp=cat(1,tmp,overlay_stc{h_idx});
        end;
        tmp=sum(tmp.^2,1);
        [dummy,overlay_stc_timeVec_idx]=max(tmp);
        
        for h_idx=1:length(overlay_stc)
            overlay_value{h_idx}=overlay_stc{h_idx}(:,overlay_stc_timeVec_idx);
        end;
        overlay_stc_hemi=overlay_stc;
        overlay_stc=[];
        for h_idx=1:length(overlay_stc_hemi)
            overlay_stc=cat(1,overlay_stc,overlay_stc_hemi{h_idx});
        end;
    else
        [tmp,overlay_stc_timeVec_idx]=max(sum(overlay_stc.^2,1));
        overlay_value=overlay_stc(:,overlay_stc_timeVec_idx);
        overlay_stc_hemi=overlay_stc;
    end;
end;


if(isempty(view_angle))
    if(strcmp('hemi','lh'))    
        view_angle=[-90 0]; %lateral view for left hemisphere;  
    else
        view_angle=[90 0]; %lateral view for right hemisphere;
    end;    
end;

if(~iscell(hemi))
    file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,surf);
    fprintf('reading [%s]...\n',file_surf);

    [vertex_coords, faces] = read_surf(file_surf);
    
    vertex_coords_hemi=vertex_coords;
    faces_hemi=faces;

    file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,'orig');
    fprintf('reading orig [%s]...\n',file_orig_surf);

    [orig_vertex_coords, orig_faces] = read_surf(file_orig_surf);
    
    orig_vertex_coords_hemi=orig_vertex_coords;
    orig_faces_hemi=faces;
else
    vertex_coords=[]; faces=[]; ovelay_vertex_tmp=[];
    orig_vertex_coords=[]; orig_faces=[]; orig_ovelay_vertex_tmp=[];
    for h_idx=1:length(hemi)
        file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi{h_idx},surf);
        fprintf('rendering [%s]...\n',file_surf);
        
        [vv, ff] = read_surf(file_surf);
        vertex_coords_hemi{h_idx}=vv;
        faces_hemi{h_idx}=ff;
        
        faces=cat(1,faces,ff+size(vertex_coords,1));
        
        if(iscell(overlay_vertex))
            ovelay_vertex_tmp=cat(1,ovelay_vertex_tmp,overlay_vertex{h_idx}+size(vertex_coords,1));
        end;
        
        %vv(:,1)=vv(:,1)+(-1).^(h_idx).*50;
        
        vertex_coords=cat(1,vertex_coords,vv);

        
        file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi{h_idx},'orig');
        fprintf('reading [%s]...\n',file_orig_surf);
        
        [vv, ff] = read_surf(file_orig_surf);
        orig_vertex_coords_hemi{h_idx}=vv;
        orig_faces_hemi{h_idx}=ff;
        
        orig_faces=cat(1,orig_faces,ff+size(orig_vertex_coords,1));
        
        if(iscell(orig_overlay_vertex))
            orig_ovelay_vertex_tmp=cat(1,orig_ovelay_vertex_tmp,orig_overlay_vertex{h_idx}+size(orig_vertex_coords,1));
        end;
        
        %vv(:,1)=vv(:,1)+(-1).^(h_idx).*50;
        
        orig_vertex_coords=cat(1,orig_vertex_coords,vv);
    end;
    
    if(iscell(overlay_vertex))
        ovelay_vertex=ovelay_vertex_tmp;
        orig_ovelay_vertex=orig_ovelay_vertex_tmp;
    end;
end;

%provide volume? if so, try to load talairach transformation matrix
if(~isempty(vol))
    if(isempty(talxfm))
        file_talxfm=sprintf('%s/%s/mri/transforms/talairach.xfm',subjects_dir,subject);
        fprintf('reading Talairach (MNI305) transformation matrix [%s]...\n',file_talxfm);
        if(exist(file_talxfm, 'file') == 2)
            fid = fopen(file_talxfm,'r');
            gotit = 0;
            for i=1:20 % read up to 20 lines, no more
                temp = fgetl(fid);
                if strmatch('Linear_Transform',temp),
                    gotit = 1;
                    break;
                end
            end
            
            if gotit,
                % Read the transformation matrix (3x4).
                talxfm = fscanf(fid,'%f',[4,3])';
                talxfm(4,:) = [0 0 0 1];
                fclose(fid);
                fprintf('Talairach transformation matrix loaded.\n');
            else
                talxfm=[];
                fclose(fid);
                fprintf('failed to find ''Linear_Transform'' string in first 20 lines of xfm file.\n');
            end
        else
            fprintf('no Talairach transformation!\n');
            talxfm=[];
        end;
        
    else
        fprintf('Talairach trasformation already...\n');
    end;
    
    %voxel coordinates
    right_column = [ ones( size(orig_vertex_coords,1), 1 ); 0 ];
    SurfVertices = [ [orig_vertex_coords; 0 0 0]  right_column ];
    %convert the surface coordinate (x,y,z) into CRS of the volume!
    vol_vox=(inv(vol.tkrvox2ras)*(SurfVertices.')).';
    
    %vol_vox=(inv(vol.vox2ras)*(SurfVertices.')).';
    vol_vox = vol_vox(1:size(orig_vertex_coords,1),1:3);
    
end;

%exclusive/inclusive labels
if(~isempty(overlay_exclude_fstem))
    if(~iscell(hemi))
        overlay_exclude_tmp=inverse_read_label(sprintf('%s',overlay_exclude_fstem));
        overlay_exclude=overlay_exclude_tmp+1;
    else
        for i=1:length(hemi)
            overlay_exclude_tmp{i}=inverse_read_label(sprintf('%s-%s.label',overlay_exclude_fstem,hemi{i}));
            overlay_exclude{i}=overlay_exclude_tmp{i}+1;
        end;
    end;
elseif(~isempty(overlay_include_fstem))
    if(~iscell(hemi))
        overlay_include_tmp=inverse_read_label(sprintf('%s',overlay_include_fstem));
        overlay_include=overlay_include_tmp+1;
    else
        for i=1:length(hemi)
            overlay_include_tmp{i}=inverse_read_label(sprintf('%s-%s.label',overlay_include_fstem,hemi{i}));
            overlay_include{i}=overlay_include_tmp{i}+1;
        end;
    end;
else
    if(~iscell(hemi))
        overlay_exclude=[];
        overlay_include=[];
    else
        for i=1:length(hemi)
            overlay_exclude{i}=[];
            overlay_include{i}=[];
        end;
    end;
end;

%cortex curvature
if(~iscell(hemi))
    if(flag_curv)
        file_curv=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,'curv');
        [curv]=read_curv(file_curv);
        
        curv_hemi=curv;
    else
        curv_hemi=[];
    end;
else
    if(flag_curv)
        curv=[];
        for h_idx=1:length(hemi)
            file_curv=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi{h_idx},'curv');
            cc=read_curv(file_curv);
            curv_hemi{h_idx}=cc;
            curv=cat(1,curv,cc);
        end;
    else
        curv_hemi=[];
    end;
end;
%0: solid color
fvdata=repmat(default_solid_color,[size(vertex_coords,1),1]);

%1: curvature color
if(~isempty(curv))
    fvdata=ones(size(fvdata));
    idx=find(curv>0);
    fvdata(idx,:)=repmat(curv_pos_color,[length(idx),1]);
    idx=find(curv<0);
    fvdata(idx,:)=repmat(curv_neg_color,[length(idx),1]);
end;

overlay_flag_render=0;
%2: curvature and overlay color
if(~isempty(overlay_value))
    if(~iscell(overlay_value))
        ov=zeros(size(vertex_coords,1),1); 
        ov(overlay_vertex+1)=overlay_value;
        
        if(~isempty(overlay_smooth))
            [ovs,dd0,dd1,overlay_Ds]=inverse_smooth('','vertex',vertex_coords','face',faces','value_idx',overlay_vertex+1,'value',ov,'step',overlay_smooth,'flag_fixval',overlay_fixval_flag,'exc_vertex',overlay_exclude,'inc_vertex',overlay_include,'flag_regrid',overlay_regrid_flag,'flag_regrid_zero',overlay_regrid_zero_flag,'Ds',overlay_Ds,'n_ratio',length(ov)/length(overlay_value));
        else
            ovs=ov;
        end;
        %%update the overlay value by the smoothed one
        %overlay_value=ovs;
        
        overlay_flag_render=1;
        if(~isempty(find(overlay_value>0))) overlay_value_flag_pos=1; end;
        if(~isempty(find(overlay_value<0))) overlay_value_flag_neg=1; end;
    else
        ovs=[];
        for h_idx=1:length(overlay_value)
            ov=zeros(size(vertex_coords_hemi{h_idx},1),1);
            ov(overlay_vertex{h_idx}+1)=overlay_value{h_idx};

            if(~isempty(overlay_smooth))
                [tmp,dd0,dd1,overlay_Ds]=inverse_smooth('','vertex',vertex_coords_hemi{h_idx}','face',faces_hemi{h_idx}','value_idx',overlay_vertex+1,'value',ov,'step',overlay_smooth,'flag_fixval',overlay_fixval_flag,'exc_vertex',overlay_exclude{h_idx},'inc_vertex',overlay_include{h_idx},'flag_regrid',overlay_regrid_flag,'flag_regrid_zero',overlay_regrid_zero_flag,'Ds',overlay_Ds,'n_ratio',length(ov)/length(overlay_value));
                ovs=cat(1,ovs,tmp);
            else
                ovs=cat(1,ovs,ov);
            end;
            
            %%update the overlay value by the smoothed ones
            %overlay_value{h_idx}=ovs;
        end;
        
        overlay_flag_render=1;
        if(~isempty(find(overlay_value{h_idx}>0))) overlay_value_flag_pos=1; end;
        if(~isempty(find(overlay_value{h_idx}<0))) overlay_value_flag_neg=1; end;
    end;
    
    if(isempty(overlay_threshold))
        tmp=sort(ovs(:));
        overlay_threshold=[tmp(round(length(tmp)*0.5)) tmp(round(length(tmp)*0.9))];
    end;
    c_idx=find(ovs(:)>=min(overlay_threshold));
    
    fvdata(c_idx,:)=inverse_get_color(overlay_cmap,ovs(c_idx),max(overlay_threshold),min(overlay_threshold));

    c_idx=find(ovs(:)<=-min(overlay_threshold));
    
    fvdata(c_idx,:)=inverse_get_color(overlay_cmap_neg,-ovs(c_idx),max(overlay_threshold),min(overlay_threshold));

    colormap(overlay_cmap);
end;


%%%%%%%%%%%%%%%%%%%%%%%%
% main routine for rendering...
%%%%%%%%%%%%%%%%%%%%%%%%
h=patch('Faces',faces+1,'Vertices',vertex_coords,'FaceVertexCData',fvdata,'facealpha',alpha,'CDataMapping','direct','facecolor','interp','edgecolor','none');   

if(~flag_redraw)
    xmin=min(vertex_coords(:,1));
    xmax=max(vertex_coords(:,1));
    ymin=min(vertex_coords(:,2));
    ymax=max(vertex_coords(:,2));
    zmin=min(vertex_coords(:,3));
    zmax=max(vertex_coords(:,3));
    set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax]);
    axis off vis3d equal tight;
    if(~isempty(overlay_threshold))
        set(gca,'climmode','manual','clim',overlay_threshold);
    end;
    set(gcf,'color',bg_color);
    
    view(view_angle(1), view_angle(2));
    
    cp=campos;
    cp=cp./norm(cp);
    
    campos(1300.*cp);
    
    material dull;
    if(flag_camlight)
       camlight(-90,0);
       camlight(90,0);    
       camlight(0,0);
       camlight(180,0);    
    end;
end;


%label annotation
if(~isempty(file_annot))
    [label_vertex label_value label_ctab] = read_annotation(file_annot);
    fprintf('annotated label loaded from [%s]...\n',file_annot);

end;
if(~isempty(label_vertex)&&~isempty(label_value)&&~isempty(label_ctab))
    fprintf('annotated label loaded...\n');
    
end;
    
%%%%%%%%%%%%%%%%%%%%%%%%
%setup global object
%%%%%%%%%%%%%%%%%%%%%%%%
global etc_render_fsbrain;

etc_render_fsbrain.brain_axis=gca;


etc_render_fsbrain.vol=vol;
etc_render_fsbrain.vol_A=vol_A;
etc_render_fsbrain.vol_vox=vol_vox;
etc_render_fsbrain.vol_pre_xfm=vol_pre_xfm;
etc_render_fsbrain.talxfm=talxfm;
etc_render_fsbrain.faces=faces;
etc_render_fsbrain.vertex_coords=vertex_coords;
etc_render_fsbrain.faces_hemi=faces_hemi;
etc_render_fsbrain.vertex_coords_hemi=vertex_coords_hemi;
etc_render_fsbrain.orig_vertex_coords=orig_vertex_coords;
etc_render_fsbrain.orig_vertex_coords_hemi=orig_vertex_coords_hemi;
etc_render_fsbrain.fvdata=fvdata;
etc_render_fsbrain.curv=curv;
%etc_render_fsbrain.curv_hemi=curv_hemi;

etc_render_fsbrain.view_angle=view_angle;
etc_render_fsbrain.bg_color=bg_color;
etc_render_fsbrain.curv_pos_color=curv_pos_color;
etc_render_fsbrain.curv_neg_color=curv_neg_color;
etc_render_fsbrain.default_solid_color=default_solid_color;
etc_render_fsbrain.alpha=alpha;

etc_render_fsbrain.fig_brain=gcf;
etc_render_fsbrain.fig_stc=[];
etc_render_fsbrain.fig_gui=[];
etc_render_fsbrain.fig_vol=[];
etc_render_fsbrain.fig_coord_gui=[];
etc_render_fsbrain.fig_label_gui=[];
etc_render_fsbrain.show_nearest_brain_surface_location_flag=show_nearest_brain_surface_location_flag;
etc_render_fsbrain.show_contact_names_flag=show_contact_names_flag;
etc_render_fsbrain.electrode_update_contact_view_flag=electrode_update_contact_view_flag;
etc_render_fsbrain.show_all_contacts_mri_flag=show_all_contacts_mri_flag;

etc_render_fsbrain.overlay_vol=overlay_vol;
etc_render_fsbrain.overlay_vol_stc=overlay_vol_stc;
etc_render_fsbrain.overlay_value=overlay_value;
etc_render_fsbrain.overlay_stc=overlay_stc;
etc_render_fsbrain.overlay_aux_stc=overlay_aux_stc;
etc_render_fsbrain.overlay_stc_hemi=overlay_stc_hemi;
etc_render_fsbrain.overlay_stc_timeVec=overlay_stc_timeVec;
etc_render_fsbrain.overlay_stc_timeVec_unit=overlay_stc_timeVec_unit;
etc_render_fsbrain.overlay_stc_timeVec_idx=overlay_stc_timeVec_idx;
etc_render_fsbrain.overlay_stc_timeVec_idx_line=[];
etc_render_fsbrain.overlay_stc_lim=overlay_stc_lim;
etc_render_fsbrain.overlay_vertex=overlay_vertex;
etc_render_fsbrain.overlay_smooth=overlay_smooth;
etc_render_fsbrain.overlay_threshold=overlay_threshold;
etc_render_fsbrain.overlay_cmap=overlay_cmap;
etc_render_fsbrain.overlay_cmap_neg=overlay_cmap_neg;
etc_render_fsbrain.overlay_value_flag_pos=overlay_value_flag_pos;
etc_render_fsbrain.overlay_value_flag_neg=overlay_value_flag_neg;
etc_render_fsbrain.overlay_exclude=overlay_exclude;
etc_render_fsbrain.overlay_include=overlay_include;
etc_render_fsbrain.overlay_flag_render=overlay_flag_render;
etc_render_fsbrain.overlay_fixval_flag=overlay_fixval_flag;
etc_render_fsbrain.overlay_regrid_flag=overlay_regrid_flag;
etc_render_fsbrain.overlay_regrid_zero_flag=overlay_regrid_zero_flag;
etc_render_fsbrain.overlay_Ds=overlay_Ds;


etc_render_fsbrain.label_vertex=label_vertex;
etc_render_fsbrain.label_value=label_value;
etc_render_fsbrain.label_ctab=label_ctab;
etc_render_fsbrain.label_h=[]; %handle to the label points on the cortical surface
etc_render_fsbrain.label_select_idx=-1; %the index to the selected label

etc_render_fsbrain.flag_hold_fig_stc_timecourse=flag_hold_fig_stc_timecourse;
etc_render_fsbrain.handle_fig_stc_timecourse=[];
etc_render_fsbrain.handle_fig_stc_aux_timecourse=[];

etc_render_fsbrain.h=h;
etc_render_fsbrain.click_point=[];
etc_render_fsbrain.click_vertex=[];
etc_render_fsbrain.click_vertex_point=[];
etc_render_fsbrain.click_overlay_vertex=[];
etc_render_fsbrain.click_overlay_vertex_point=[];
etc_render_fsbrain.roi_radius=[];

etc_render_fsbrain.cluster_file=cluster_file;

etc_render_fsbrain.fig_register=[];

etc_render_fsbrain.aux(1).data=topo_label;
etc_render_fsbrain.aux(1).tag='topo_label';
etc_render_fsbrain.aux_point_coords=topo_aux_point_coords;
etc_render_fsbrain.aux_point_coords_h=topo_aux_point_coords_h;
etc_render_fsbrain.aux_point_name=topo_aux_point_name;
etc_render_fsbrain.aux_point_name_h=topo_aux_point_name_h;
etc_render_fsbrain.aux_point_color=topo_aux_point_color;
etc_render_fsbrain.aux_point_size=topo_aux_point_size;
etc_render_fsbrain.aux_point_label_flag=topo_aux_point_label_flag;

etc_render_fsbrain.aux2_point_coords=topo_aux2_point_coords;
etc_render_fsbrain.aux2_point_coords_h=topo_aux2_point_coords_h;
etc_render_fsbrain.aux2_point_name=topo_aux2_point_name;
etc_render_fsbrain.aux2_point_name_h=topo_aux2_point_name_h;
etc_render_fsbrain.aux2_point_color=topo_aux2_point_color;
etc_render_fsbrain.aux2_point_size=topo_aux2_point_size;

etc_render_fsbrain.register_rotate_angle=3; %default: 3 degrees
etc_render_fsbrain.register_translate_dist=1e-3; %default: 1 mm

etc_render_fsbrain.click_point_color=click_point_color;
etc_render_fsbrain.click_point_size=click_point_size;
etc_render_fsbrain.click_vertex_point_color=click_vertex_point_color;
etc_render_fsbrain.click_vertex_point_size=click_vertex_point_size;

etc_render_fsbrain.electrode=electrode;

%%%%%%%%%%%%%%%%%%%%%%%%
%setup call-back function
%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
set(gcf,'DeleteFcn','etc_render_fsbrain_handle(''del'')');
set(gcf,'CloseRequestFcn','etc_render_fsbrain_handle(''del'')'); 

%set(gcf,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
set(gcf,'KeyPressFcn',@etc_render_fsbrain_kbhandle);
set(gcf,'invert','off');

hold on;


if(flag_colorbar)
    etc_render_fsbrain_handle('kb','c0','c0');
end;
return;
    