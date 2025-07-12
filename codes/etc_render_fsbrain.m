function etc_render_fsbrain=etc_render_fsbrain(varargin)
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

flag_display=0;

%fundamental anatomy geometry
subjects_dir=getenv('SUBJECTS_DIR');
subject='fsaverage';
surf='orig';
flag_curv=1;
hemi='lh'; %hemi={'lh','rh'}; for showing both hemispheres;
curv=[];
vol=[]; 
vol_reg=eye(4);
vol_A=[];
vol_vox=[];
vol_ribbon=[];
vol_pre_xfm=eye(4);
talxfm=[];

lut=[];

pt=[];

%color 
default_solid_color=[1.0000    0.7031    0.3906];
curv_pos_color=[1 1 1].*0.4;
curv_neg_color=[1 1 1].*0.7;

bg_color=[1 1 1]; %figure background color;
overlay_cmap=autumn(80); %overlay colormap;
overlay_cmap_neg=winter(80); %overlay colormap;
overlay_cmap_neg(:,3)=1;

%overlay
overlay_source=[]; %1: value; 2: stc; 3: vol_stc; 4: vol
overlay_vol=[];
overlay_aux_vol=[];
overlay_vol_stc=[];
overlay_aux_vol_stc=[];
overlay_value=[];
overlay_vol_value=[];
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
overlay_vol_flag_render=1;
overlay_fixval_flag=0;
overlay_Ds=[];
overlay_vol_xfm=[];

overlay_buffer=[];
overlay_buffer_idx=[];
overlay_buffer_main_idx=[];

overlay_truncate_pos=0;
overlay_truncate_neg=0;

overlay_exclude_fstem='';
overlay_exclude=[];

overlay_include_fstem='';
overlay_include=[];

overlay_vol_mask_alpha=0.5;
overlay_vol_mask=[];
overlay_flag_vol_mask=1;

overlay_flag_paint_on_cortex=1;

flag_orthogonal_slice_ax=0;
flag_orthogonal_slice_sag=0;
flag_orthogonal_slice_cor=0;

topo_label={};

topo_aux_point_coords=[];
topo_aux_point_coords_h=[];
topo_aux_point_name={};
topo_aux_point_name_h=[];
topo_aux_point_color=[0.39 0.83 0.07];
topo_aux_point_size=2;
topo_aux_point_label_flag=1;
topo_aux_point_text_color=[0.39 0.83 0.07];
topo_aux_point_text_size=20;

topo_aux2_point_coords=[];
topo_aux2_point_coords_h=[];
selected_electrode_coords_h=[];
selected_contact_coords_h=[];
topo_aux2_point_name={};
topo_aux2_point_name_h=[];
topo_aux2_point_color=[0 1  0];
aux2_point_individual_color=[0    0.4471    0.7412];
topo_aux2_point_color=[0    0.4471    0.7412];
topo_aux2_point_size=44;
topo_aux2_point_color_e=[0.3984    0.5977         0];
topo_aux2_point_size_e=44;
topo_aux2_point_color_c=[0.3984    0.5977         0];
topo_aux2_point_size_c=44;

selected_electrode_size=44;
selected_electrode_flag=1;
selected_electrode_color=[0 0 1];

selected_contact_size=44;
selected_contact_flag=1;
selected_contact_color=[0 1 1];

all_electrode_flag=1;

%external object
object=[];
object_xfm=[];

%electrode
electrode=[];
electrode_idx=1; %first electrode
electrode_contact_idx=1; %first contact

%label (annotation)
label_vertex=[];
label_value=[];
label_ctab=[];
label_file_annot='';

%ROI label
cort_label_filename='';
cort_label_colororder=[];
flag_show_cort_label=1; %show solid labels
flag_show_cort_label_boundary=1; %show label boundary
cort_label_boundary_color=[0 0 1]; %label boundary color

%ribbon
cort_ribbon_idx={};

%stc time course
flag_hold_fig_stc_timecourse=0;

%cluster file
cluster_file={};

%etc
alpha=1;
view_angle=[]; 
lim=[];
camposition_l=[];

flag_redraw=0;
flag_camlight=1;
flag_colorbar=0;
flag_colorbar_vol=0;
show_nearest_brain_surface_location_flag=1;
show_brain_surface_location_flag=1;
show_contact_names_flag=1;
show_all_contacts_mri_flag=1;
show_all_contacts_mri_depth=2;
show_all_contacts_brain_surface_flag=1;
electrode_update_contact_view_flag=1;

click_point_size=28;
click_point_color=[1 0 1];

click_vertex_point_size=24;
click_vertex_point_color=[0 1 1];


flag_mirror=0;

tmp_set_vol=0; %flag to read cortical ribbon volume

file_brain_gii=''; %brain geometry in gii (bigbrain)

vertex_coords=[];
faces=[];
curv=[];

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'flag_display'
            flag_display=option_value;
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
            tmp_set_vol=1;
        case 'vol_reg'
            vol_reg=option_value;
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
        case 'overlay_aux_vol'
            overlay_aux_vol=option_value;
        case 'overlay_vol'
            overlay_vol=option_value;
            overlay_source=4;
        case 'overlay_vol_stc'
            overlay_vol_stc=option_value;
            overlay_source=3;
        case 'overlay_flag_render'
            overlay_flag_render=option_value;
        case 'overlay_vol_flag_render'
            overlay_vol_flag_render=option_value;
        case 'overlay_value'
            overlay_value=option_value;
            overlay_source=1;
        case 'overlay_stc'
            overlay_stc=option_value;
            overlay_source=2;
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
        case 'overlay_stc_timevec_idx'
            overlay_stc_timeVec_idx=option_value;
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
        case 'overlay_truncate_pos'
            overlay_truncate_pos=option_value;
        case 'overlay_truncate_neg'
            overlay_truncate_neg=option_value;
        case 'overlay_vol_mask_alpha'
            overlay_vol_mask_alpha=option_value;
        case 'overlay_vol_mask'
            overlay_vol_mask=option_value;
        case 'overlay_flag_vol_mask'
            overlay_flag_vol_mask=option_value;
        case 'overlay_vol_xfm'
            overlay_vol_xfm=option_value;
        case 'overlay_flag_paint_on_cortex'
            overlay_flag_paint_on_cortex=option_value;
        case 'cluster_file'
            cluster_file=option_value;
        case 'alpha'
            alpha=option_value;
        case 'flag_mirror'
            flag_mirror=option_value;
        case 'lut'
            lut=option_value;
        case 'flag_redraw'
            flag_redraw=option_value;
        case 'flag_camlight'
            flag_camlight=option_value;
        case 'flag_colorbar'
            flag_colorbar=option_value;
        case 'flag_colorbar_vol'
            flag_colorbar_vol=option_value;
        case 'flag_hold_fig_stc_timecourse'
            flag_hold_fig_stc_timecourse=option_value;
        case 'show_nearest_brain_surface_location_flag'
            show_nearest_brain_surface_location_flag=option_value;
        case 'show_brain_surface_location_flag'
            show_brain_surface_location_flag=option_value;
        case 'show_contact_names_flag'
            show_contact_names_flag=option_value;
        case 'show_all_contacts_mri_flag'
            show_all_contacts_mri_flag=option_value;
        case 'show_all_contacts_mri_depth'
            show_all_contacts_mri_depth=option_value;
        case 'show_all_contacts_brain_surface_flag'
            show_all_contacts_brain_surface_flag=option_value;
        case 'electrode_update_contact_view_flag'
            electrode_update_contact_view_flag=option_value;
        case 'view_angle'
            view_angle=option_value;
        case 'lim'
            lim=option_value;
        case 'camposition_l'
            camposition_l=option_value;
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
        case 'cort_label_filename'
            cort_label_filename=option_value;
        case 'cort_label_colororder'
            cort_label_colororder=option_value;
        case 'cort_label_boundary_color'
            cort_label_boundary_color=option_value;
        case 'flag_show_cort_label';
            flag_show_cort_label=option_value;
        case 'flag_show_cort_label_boundary'
            flag_show_cort_label_boundary=option_value;
        case 'label_file_annot'
            label_file_annot=option_value;
        case 'electrode'
            electrode=option_value;
        case 'electrode_idx'
            electrode_idx=option_value;
        case 'electrode_contact_idx'
            electrode_contact_idx=option_value;
        case 'object'
            object=option_value;
        case'object_xfm'
            object_xfm=option_value;
        case 'click_point_size'
            click_point_size=option_value;
        case 'click_point_color'
            click_point_color=option_value;
        case 'click_vertex_point_size'
            click_vertex_point_size=option_value;
        case 'click_vertex_point_color'
            click_vertex_point_color=option_value;
        case 'selected_electrode_flag'
            selected_electrode_flag=option_value;
        case 'selected_contact_flag'
            selected_contact_flag=option_value;
        case 'aux2_point_individual_color'
            aux2_point_individual_color=option_value;
        case 'pt'
            pt=option_value;
        case 'file_brain_gii'
            file_brain_gii=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end
%read gii brain/values for BigBrain

if(~isempty(file_brain_gii))
    try
        fprintf('reading brain gemoetry from gii [%s]...\n',file_brain_gii);
        brain=gifti(file_brain_gii);
        vertex_coords=double(brain.vertices);
        faces=double(brain.faces)-1; %gii is 1-based

        if(size(vertex_coords,1)==3) vertex_coords=vertex_coords'; end;
        if(size(faces,1)==3) faces=faces'; end;
        
        vertex_coords_hemi=vertex_coords;
        faces_hemi=faces;

        orig_vertex_coords=[];
        orig_faces=[];

        orig_vertex_coords_hemi=orig_vertex_coords;
        orig_faces_hemi=faces;

        %loading vertices/faces for both hemispheres.
        for hemi_idx=1:2
            switch hemi_idx
                case 1
                    hemi_str='lh';
                case 2
                    hemi_str='rh';
            end;

            hemi_vertex_coords{hemi_idx}=[];
            hemi_faces{hemi_idx}=[];

            hemi_orig_vertex_coords{hemi_idx}=[];
            hemi_orig_faces{hemi_idx}=[];
        end;
    catch
        fprintf('error in reading brain gemoetry from gii [%s]!\n',file_brain_gii);
        return;
    end;

    tmp_set_vol=1; %not reading ribbon

    curv=ones(size(vertex_coords,1),1);
end;


%read orig MRI volume and cortical ribbon volume
if(tmp_set_vol<0.5)
    vol=[];
    try
        if(ispc)
            if(exist(sprintf('%s\\%s\\mri\\orig.mgh',subjects_dir,subject)))
                vol=MRIread(sprintf('%s\\%s\\mri\\orig.mgh',subjects_dir,subject));
            else
                if(exist(sprintf('%s\\%s\\mri\\orig.mgz',subjects_dir,subject)))
                    fprintf('ERROR: At Windows, please decompress [orig.mgz] to [orig.mgh]!\n');
                else
                    fprintf('ERROR: cannot find [orig.mgz]\n');
                end;
            end;
        else
            vol=MRIread(sprintf('%s/%s/mri/orig.mgz',subjects_dir,subject));
        end;
    catch ME
    end;
    
    
    %cortical ribbon index setup
    cort_ribbon_idx{1}=[];
    cort_ribbon_idx{2}=[];
    ribbon_idx{1}=[];
    ribbon_idx{2}=[];
    try
        if(ispc)
            if(exist(sprintf('%s\\%s\\mri\\orig.mgh',subjects_dir,subject)))
                vol_ribbon=MRIread(sprintf('%s\\%s\\mri\\ribbon.mgh',subjects_dir,subject));
            else
                if(exist(sprintf('%s\\%s\\mri\\orig.mgz',subjects_dir,subject)))
                    fprintf('ERROR: At Windows, please decompress [ribbon.mgz] to [ribbon.mgh]!\n');
                else
                    fprintf('ERROR: cannot find [ribbon.mgz]!\n');
                end;
            end;
        else
            try
                vol_ribbon=MRIread(sprintf('%s/%s/mri/ribbon.mgz',subjects_dir,subject));
            catch
                vol_ribbon=[];
                fprintf('error in reading the ribbon volume [%s]...\n',sprintf('%s/%s/mri/ribbon.mgz',subjects_dir,subject));
            end;
        end;
        for hemi_idx=1:2
            switch hemi_idx
                case 1
                    ribbon_value=3; %left hemisphere cortical ribbon value
                case 2
                    ribbon_value=42; %right hemisphere cortical ribbon value
            end;
            
            [rr,cc,ss]=meshgrid([1:size(vol_ribbon.vol,1)],[1:size(vol_ribbon.vol,2)],[1:size(vol_ribbon.vol,3)]);
            
            X=cat(2,rr(:),cc(:),ss(:));

            global etc_render_fsbrain
            if(isfield(etc_render_fsbrain,'loc_vol_idx'))
                Xcort=X(etc_render_fsbrain.loc_vol_idx{hemi_idx},:);

                ribbon_idx{hemi_idx}=find(vol_ribbon.vol(:)==ribbon_value);

                Xribbon=X(ribbon_idx{hemi_idx},:);

                cort_ribbon_idx{hemi_idx}=knnsearch(Xcort,Xribbon);
            end;
            clear global etc_render_fsbrain;

        end;
    catch ME
    end;

    if(isempty(vol_A))
        if(iscell(hemi))
            %hemi={'lh','rh'};
            for hemi_idx=1:2
                file_surf=sprintf('%s/%s/surf/%s.%s',getenv('SUBJECTS_DIR'),subject,hemi{hemi_idx},'orig');
                [vol_A(hemi_idx).vertex_coords, vol_A(hemi_idx).faces] = read_surf(file_surf);
            end;
        else
            file_surf=sprintf('%s/%s/surf/%s.%s',getenv('SUBJECTS_DIR'),subject,hemi,'orig');
            [vol_A.vertex_coords, vol_A.faces] = read_surf(file_surf);
        end;
    end;
end;

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
    if(~iscell(hemi))
        if(strcmp(hemi,'lh'))
            overlay_stc=X_hemi_cort{1};
            overlay_vertex=vol_A(1).v_idx;
        else
            overlay_stc=X_hemi_cort{2};
            overlay_vertex=vol_A(2).v_idx;
        end;
    else
        overlay_stc=[];
        overlay_vertex=[];
        for ii=1:length(hemi)
            if(strcmp(hemi{ii},'lh'))
                overlay_stc_now=X_hemi_cort{1};
                overlay_vertex_now=vol_A(1).v_idx;
            else
                overlay_stc_now=X_hemi_cort{2};
                overlay_vertex_now=vol_A(2).v_idx;
            end;
            
            overlay_stc=cat(1,overlay_stc,overlay_stc_now);
            overlay_vertex=cat(1,overlay_vertex,overlay_vertex_now);
        end;
    end;
    
    if(isempty(overlay_stc_timeVec))
        overlay_stc_timeVec=[1:size(overlay_stc,2)];
    end;
elseif(~isempty(overlay_stc))
    if(isempty(overlay_stc_timeVec))
        overlay_stc_timeVec=[1:size(overlay_stc,2)];
    end;
elseif(~isempty(overlay_vol))
    if(isempty(overlay_stc_timeVec))
        if(ndims(overlay_vol.vol)==4)
            overlay_stc_timeVec=[1:size(overlay_vol.vol,4)];
        else
            overlay_stc_timeVec=[1];
        end;
    end;
end;

%get the timing that shows the max overlay value from STC, if it is not specified.
if(isempty(overlay_value)&~isempty(overlay_stc))
    if(iscell(overlay_stc))
        if(isempty(overlay_stc_timeVec_idx))
            tmp=[];
            for h_idx=1:length(overlay_stc)
                tmp=cat(1,tmp,overlay_stc{h_idx});
            end;
            tmp=sum(tmp.^2,1);
            [dummy,overlay_stc_timeVec_idx]=max(tmp);
        end;
        
        for h_idx=1:length(overlay_stc)
            overlay_value{h_idx}=overlay_stc{h_idx}(:,overlay_stc_timeVec_idx);
        end;
        overlay_stc_hemi=overlay_stc;
        overlay_stc=[];
        for h_idx=1:length(overlay_stc_hemi)
            overlay_stc=cat(1,overlay_stc,overlay_stc_hemi{h_idx});
        end;
    else
        if(isempty(overlay_stc_timeVec_idx))
            [tmp,overlay_stc_timeVec_idx]=max(sum(overlay_stc.^2,1));
        end;
        overlay_value=overlay_stc(:,overlay_stc_timeVec_idx);
        overlay_stc_hemi=overlay_stc;
    end;
elseif(~isempty(overlay_vol))
    sz=size(overlay_vol.vol);
    if(ndims(overlay_vol.vol)==4)
        tmp=reshape(overlay_vol.vol,[sz(1)*sz(2)*sz(3),sz(4)]);
        [dd,overlay_stc_timeVec_idx]=max(sum(tmp.^2,1),[],2);
    else
        overlay_stc_timeVec_idx=1;
    end;
end;


if(isempty(view_angle))
    if(~iscell(hemi))
        if(strcmp(hemi,'lh'))
            view_angle=[-90 0]; %lateral view for left hemisphere;
        else
            view_angle=[90 0]; %lateral view for right hemisphere;
        end;
    else
        view_angle=[-90 0]; %lateral view for left hemisphere;
    end;
end;

if(isempty(vertex_coords)) %brain geometry not read yet...
if(~iscell(hemi))
    file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,surf);
    if(flag_display) fprintf('reading [%s]...\n',file_surf); end;

    [vertex_coords, faces] = read_surf(file_surf);
    
    if(flag_mirror)
        vertex_coords(:,1)=-vertex_coords(:,1);
    end;
    
    vertex_coords_hemi=vertex_coords;
    faces_hemi=faces;

    file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,'orig');
    if(flag_display) fprintf('reading orig [%s]...\n',file_orig_surf); end;

    [orig_vertex_coords, orig_faces] = read_surf(file_orig_surf);
    if(flag_mirror)
        orig_vertex_coords(:,1)=-orig_vertex_coords(:,1);
    end;
    
    orig_vertex_coords_hemi=orig_vertex_coords;
    orig_faces_hemi=faces;
    
    %loading vertices/faces for both hemispheres.
    for hemi_idx=1:2
        switch hemi_idx
            case 1
                hemi_str='lh';
            case 2
                hemi_str='rh';
        end;
        
        file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi_str,surf);
        %fprintf('reading [%s]...\n',file_surf);
        [hemi_vertex_coords{hemi_idx}, hemi_faces{hemi_idx}] = read_surf(file_surf);
        if(flag_mirror)
            hemi_vertex_coords{hemi_idx}(:,1)=-hemi_vertex_coords{hemi_idx}(:,1);
        end;
    
        file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi_str,'orig');
        %fprintf('reading orig [%s]...\n',file_orig_surf);
        [hemi_orig_vertex_coords{hemi_idx}, hemi_orig_faces{hemi_idx}] = read_surf(file_orig_surf);
        if(flag_mirror)
            hemi_orig_vertex_coords{hemi_idx}(:,1)=-hemi_orig_vertex_coords{hemi_idx}(:,1);
        end;
    end;

else
    vertex_coords=[]; faces=[]; ovelay_vertex_tmp=[];
    orig_vertex_coords=[]; orig_faces=[]; orig_ovelay_vertex_tmp=[];
    for h_idx=1:length(hemi)
        file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi{h_idx},surf);
        if(flag_display) fprintf('rendering [%s]...\n',file_surf); end;
        
        [vv, ff] = read_surf(file_surf);
        if(flag_mirror)
            vv(:,1)=-vv(:,1);
        end;
        vertex_coords_hemi{h_idx}=vv;
        faces_hemi{h_idx}=ff;
        
        faces=cat(1,faces,ff+size(vertex_coords,1));
        
        if(iscell(overlay_vertex))
            ovelay_vertex_tmp=cat(1,ovelay_vertex_tmp,overlay_vertex{h_idx}+size(vertex_coords,1));
        end;
        
        %vv(:,1)=vv(:,1)+(-1).^(h_idx).*50;
        
        vertex_coords=cat(1,vertex_coords,vv);

        
        file_orig_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi{h_idx},'orig');
        if(flag_display) fprintf('reading [%s]...\n',file_orig_surf); end;
        
        [vv, ff] = read_surf(file_orig_surf);
        if(flag_mirror)
            vv(:,1)=-vv(:,1);
        end;
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
end;

%provide volume? if so, try to load talairach transformation matrix
if(~isempty(vol))
    if(isempty(talxfm))
        file_talxfm=sprintf('%s/%s/mri/transforms/talairach.xfm',subjects_dir,subject);
        if(flag_display) fprintf('reading Talairach (MNI305) transformation matrix [%s]...\n',file_talxfm); end;
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
                if(flag_display) fprintf('Talairach transformation matrix loaded.\n'); end;
            else
                talxfm=[];
                fclose(fid);
                if(flag_display) fprintf('failed to find ''Linear_Transform'' string in first 20 lines of xfm file.\n'); end;
            end
        else
            if(flag_display) fprintf('no Talairach transformation!\n'); end;
            talxfm=[];
            talxfm=eye(4).*nan;
        end;
        
    else
        if(flag_display) fprintf('Talairach trasformation already...\n'); end;
    end;
    
    %voxel coordinates
    right_column = [ ones( size(orig_vertex_coords,1), 1 ); 0 ];
    SurfVertices = [ [orig_vertex_coords; 0 0 0]  right_column ];
    %convert the surface coordinate (x,y,z) into CRS of the volume!
    
    if(~isempty(vol))
        SurfVertices=((vol_reg)*SurfVertices.').';
    end;
    %"SurfVertices" is now for volume "vol".
    
    %get the CRS
    vol_vox=(inv(vol.tkrvox2ras)*(SurfVertices.')).';
    
    %vol_vox=(inv(vol.vox2ras)*(SurfVertices.')).';
    vol_vox = vol_vox(1:size(orig_vertex_coords,1),1:3);
    
end;


%prepare mapping overlay values from "overlay_vol" 
if(~isempty(overlay_vol))
    flag_overlay_vol2surf=1;
    offset=0;
    for hemi_idx=1:2
        
        %choose 10,242 sources arbitrarily for cortical soruces
        %vol_A(hemi_idx).v_idx=[1:10242]-1;
        vol_A(hemi_idx).v_idx=[1:1:size(orig_vertex_coords,1)]-1;
        
        vol_A(hemi_idx).vertex_coords=vertex_coords;
        vol_A(hemi_idx).faces=faces;
        vol_A(hemi_idx).orig_vertex_coords=orig_vertex_coords;
        %vol_A(hemi_idx).vertex_coords=hemi_vertex_coords{hemi_idx};
        %vol_A(hemi_idx).faces=hemi_faces{hemi_idx};
        %vol_A(hemi_idx).orig_vertex_coords=hemi_orig_vertex_coords{hemi_idx};
        
        SurfVertices=cat(2,vol_A(hemi_idx).orig_vertex_coords(vol_A(hemi_idx).v_idx+1,:),ones(length(vol_A(hemi_idx).v_idx),1));
                
        vol_vox_tmp=(inv(vol.tkrvox2ras)*(vol_reg)*(SurfVertices.')).';
        vol_vox_tmp=round(vol_vox_tmp(:,1:3));
        
        %separate data into "cort_idx" and "non_cort_idx" entries; the
        %former ones are for cortical locations (defined for ONLY one selected
        %hemisphere. the latter ones are for non-cortical locations (may
        %include the cortical locations of the other non-selected
        %hemisphere).
        all_idx=[1:prod(overlay_vol.volsize(1:3))];
        %[cort_idx,ii]=unique(sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3)));
        
        
        for ii=1:size(vol_vox_tmp,2)
            vol_vox_tmp(find(vol_vox_tmp(:,ii)<1),ii)=nan;
            vol_vox_tmp(find(vol_vox_tmp(:,ii)>overlay_vol.volsize(ii)),ii)=nan;
        end;
        tmp=mean(vol_vox_tmp,2);
        vol_vox_tmp(find(isnan(tmp)),:)=[];
        vol_A(hemi_idx).v_idx(find(isnan(tmp)))=[];
        
        cort_idx=sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3));
        ii=[1:length(cort_idx)];
        vol_A(hemi_idx).v_idx=vol_A(hemi_idx).v_idx(ii);
        non_cort_idx=setdiff(all_idx,cort_idx);
        
        n_source(hemi_idx)=length(non_cort_idx)+length(cort_idx);
        n_dip(hemi_idx)=n_source(hemi_idx)*3;
        
        
        [C,R,S] = meshgrid([1:size(overlay_vol.vol,2)],[1:size(overlay_vol.vol,1)],[1:size(overlay_vol.vol,3)]);
        CRS=[C(:) R(:) S(:)];
        CRS=cat(2,CRS,ones(size(CRS,1),1))';
        
        all_coords=inv(vol_reg)*vol.tkrvox2ras*CRS;
        all_coords=all_coords(1:3,:)';
        vol_A(hemi_idx).loc=all_coords(cort_idx,:);
        vol_A(hemi_idx).wb_loc=all_coords(non_cort_idx,:)./1e3;
                
        tmp_value=overlay_vol.vol;
        %tmp_value=permute(tmp_value,[2 1 3 4]);
        overlay_vol_value=reshape(tmp_value,[size(overlay_vol.vol,1)*size(overlay_vol.vol,2)*size(overlay_vol.vol,3), size(overlay_vol.vol,4)]);
        
        midx=[cort_idx(:)' non_cort_idx(:)'];
        overlay_vol_stc(offset+1:offset+length(vol_A(hemi_idx).v_idx),:)=overlay_vol_value(midx(1:length(cort_idx)),:);
        overlay_vol_stc(offset+length(vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:)=overlay_vol_value(midx(length(cort_idx)+1:end),:);
        
        overlay_aux_vol_value=[];
        for vv_idx=1:length(overlay_aux_vol)
            overlay_aux_vol_value(:,:,vv_idx)=reshape(overlay_aux_vol(vv_idx).vol,[size(overlay_aux_vol(vv_idx).vol,1)*size(overlay_aux_vol(vv_idx).vol,2)*size(overlay_aux_vol(vv_idx).vol,3), size(overlay_aux_vol(vv_idx).vol,4)]);
            overlay_aux_vol_stc(offset+1:offset+length(vol_A(hemi_idx).v_idx),:,vv_idx)=overlay_aux_vol_value(midx(1:length(cort_idx)),:,vv_idx);
            overlay_aux_vol_stc(offset+length(vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:,vv_idx)=overlay_aux_vol_value(midx(length(cort_idx)+1:end),:,vv_idx);
        end;
        
        offset=offset+n_source(hemi_idx);
        
        X_hemi_cort{hemi_idx}=overlay_vol_value(cort_idx,:);
        X_hemi_subcort{hemi_idx}=overlay_vol_value(non_cort_idx,:);

        if(~isempty(overlay_aux_vol_value))
            aux_X_hemi_cort{hemi_idx}=overlay_aux_vol_value(cort_idx,:,:);
            aux_X_hemi_subcort{hemi_idx}=overlay_aux_vol_value(non_cort_idx,:,:);
        end;
    end;

    if(~iscell(hemi))
        if(strcmp(hemi,'lh'))
            overlay_stc=X_hemi_cort{1};
            overlay_vertex=vol_A(1).v_idx;
            if(~isempty(overlay_aux_vol_stc))
                overlay_aux_stc=aux_X_hemi_cort{1};
            end;
        else
            overlay_stc=X_hemi_cort{2};
            overlay_vertex=vol_A(2).v_idx;
            if(~isempty(overlay_aux_vol_stc))
                overlay_aux_stc=aux_X_hemi_cort{2};
            end;
        end;
    else
        overlay_stc=[];
        overlay_vertex=[];
        overlay_aux_stc=[];
        for ii=1:length(hemi)
            if(strcmp(hemi{ii},'lh'))
                overlay_stc_now=X_hemi_cort{1};
                overlay_vertex_now=vol_A(1).v_idx;
                if(~isempty(overlay_aux_vol_stc))
                    overlay_aux_stc_now=aux_X_hemi_cort{1};
                end;
            else
                overlay_stc_now=X_hemi_cort{2};
                overlay_vertex_now=vol_A(2).v_idx;
                if(~isempty(overlay_aux_vol_stc))
                    overlay_aux_stc_now=aux_X_hemi_cort{2};
                end;
            end;
            
            overlay_stc=cat(1,overlay_stc,overlay_stc_now);
            overlay_vertex=cat(1,overlay_vertex,overlay_vertex_now);
            overlay_aux_stc=cat(1,overlay_aux_stc,overlay_aux_stc_now);
        end;
    end;


    overlay_value=overlay_stc(:,overlay_stc_timeVec_idx);
    
    
    
    overlay_buffer=[];
    overlay_buffer_main_idx=1;
    overlay_buffer_idx=1;
    
    overlay_buffer(end+1).stc=overlay_stc;
    overlay_buffer(end).name='overlay_vol';
    if(strcmp(hemi,'lh'))
        overlay_buffer(end).vertex=vol_A(1).v_idx;
    else
        overlay_buffer(end).vertex=vol_A(2).v_idx;
    end;
    overlay_buffer(end).timeVec=overlay_stc_timeVec;
    overlay_buffer(end).hemi=hemi;
else
    flag_overlay_vol2surf=0;
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
%         overlay_exclude=[];
%         overlay_include=[];

        for i=1:length(hemi)
            overlay_exclude{i}=[];
            overlay_include{i}=[];
        end;
    end;
end;

if(isempty(curv))
%cortex curvature
if(~iscell(hemi))
    if(flag_curv)
        file_curv=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi,'curv');
        if(exist(file_curv))
            [curv]=read_curv(file_curv);
        else
            curv=[];
        end;
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

ovs=[];
overlay_flag_render=0;
%2: curvature and overlay color
if(~isempty(overlay_value))
    if(~iscell(overlay_value))
        ov=zeros(size(vertex_coords,1),1); 
        ov(overlay_vertex+1)=overlay_value;
        
        if(~isempty(overlay_smooth))
            if(iscell(overlay_include)) overlay_include=[]; end;
            if(iscell(overlay_exclude)) overlay_exclude=[]; end;
            
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
                [tmp,dd0,dd1,overlay_Ds]=inverse_smooth('','vertex',vertex_coords_hemi{h_idx}','face',faces_hemi{h_idx}','value_idx',overlay_vertex{h_idx}+1,'value',ov,'step',overlay_smooth,'flag_fixval',overlay_fixval_flag,'exc_vertex',overlay_exclude{h_idx},'inc_vertex',overlay_include{h_idx},'flag_regrid',overlay_regrid_flag,'flag_regrid_zero',overlay_regrid_zero_flag,'Ds',overlay_Ds,'n_ratio',length(ov)/length(overlay_value{h_idx}));
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
    
    
    %truncate positive value overlay
    if(overlay_truncate_pos)
        idx=find(ovs(:)>0);
        ovs(idx)=0;
    end;
    
    %truncate negative value overlay
    if(overlay_truncate_neg)
        idx=find(ovs(:)<0);
        ovs(idx)=0;
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
material dull;

axis off vis3d equal;

if(~flag_redraw)
    if(isempty(lim))
        xmin=min(vertex_coords(:,1));
        xmax=max(vertex_coords(:,1));
        ymin=min(vertex_coords(:,2));
        ymax=max(vertex_coords(:,2));
        zmin=min(vertex_coords(:,3));
        zmax=max(vertex_coords(:,3));
        xlim=[xmin xmax];
        ylim=[ymin ymax];
        zlim=[zmin zmax];
        lim=[xlim(:)' ylim(:)' zlim(:)'];
    else
        xlim=lim(1:2);
        ylim=lim(3:4);
        zlim=lim(5:6);
    end;
    set(gca,'xlim',[xmin xmax],'ylim',[ymin ymax],'zlim',[zmin zmax]);
    
    if(~isempty(overlay_threshold))
        set(gca,'climmode','manual','clim',overlay_threshold);
    end;
    set(gcf,'color',bg_color);
    
    view(view_angle(1), view_angle(2));
    
    if(isempty(camposition_l))
        cp=campos;
        cp=cp./norm(cp);
        
        campos(1300.*cp);
        camposition=1300.*cp;
    else
        
        cp=campos;
        cp=cp./norm(cp);
        
        camposition=camposition_l.*cp;
        campos(camposition);
%        campos(camposition);
    end;
    
    if(flag_camlight)
       camlight(-90,0);
       camlight(90,0);    
       camlight(0,0);
       camlight(180,0);    
       
       flag_camlight=0;
    end;
end;


%label annotation
if(~isempty(label_file_annot))
    [label_vertex label_value label_ctab] = read_annotation(label_file_annot);
    fprintf('annotated label loaded from [%s]...\n',label_file_annot);
else
    if(~iscell(hemi))
        %try loading annot automatically
        label_file_annot=sprintf('%s/%s/label/%s.aparc.annot',subjects_dir,subject,hemi);
    end;
end;
if(~isempty(label_vertex)&&~isempty(label_value)&&~isempty(label_ctab))
    fprintf('annotated label loaded...\n');
    
end;







%figure position
set(0,'units','pixels')  
Pix_SS = get(0,'screensize');
Pix_FF = get(gcf,'position');

set(gcf,'pos',[Pix_SS(3)/2-Pix_FF(3)/2, Pix_SS(4), Pix_FF(3), Pix_FF(4)])

%add exploration toolbar
addToolbarExplorationButtons(gcf);

% if(strcmp(hemi,'rh'))
%     hemi_idx=2;
% else
%     hemi_idx=1;
% end;
% hold on;
% h=plot3(vol_A(hemi_idx).vertex_coords(:,1), vol_A(hemi_idx).vertex_coords(:,2), vol_A(hemi_idx).vertex_coords(:,3), 'g.');
    
%%%%%%%%%%%%%%%%%%%%%%%%
%setup global object
%%%%%%%%%%%%%%%%%%%%%%%%
global etc_render_fsbrain;

etc_render_fsbrain.brain_axis=gca;

etc_render_fsbrain.subject=subject;
etc_render_fsbrain.surf=surf;
etc_render_fsbrain.vol_ribbon=vol_ribbon;
etc_render_fsbrain.vol=vol;
etc_render_fsbrain.vol_reg=vol_reg;
etc_render_fsbrain.vol_A=vol_A;
etc_render_fsbrain.vol_vox=vol_vox;
etc_render_fsbrain.vol_pre_xfm=vol_pre_xfm;
etc_render_fsbrain.talxfm=talxfm;
etc_render_fsbrain.faces=faces;
etc_render_fsbrain.hemi=hemi;
etc_render_fsbrain.vertex_coords=vertex_coords;
etc_render_fsbrain.faces_hemi=faces_hemi;
etc_render_fsbrain.vertex_coords_hemi=vertex_coords_hemi;
etc_render_fsbrain.orig_vertex_coords=orig_vertex_coords;
etc_render_fsbrain.orig_vertex_coords_hemi=orig_vertex_coords_hemi;
etc_render_fsbrain.fvdata=fvdata;
etc_render_fsbrain.curv=curv;
etc_render_fsbrain.ovs=ovs;
etc_render_fsbrain.cort_ribbon_idx=cort_ribbon_idx;

etc_render_fsbrain.view_angle=view_angle;
etc_render_fsbrain.lim=lim;
etc_render_fsbrain.camposition=camposition;
etc_render_fsbrain.bg_color=bg_color;
etc_render_fsbrain.curv_pos_color=curv_pos_color;
etc_render_fsbrain.curv_neg_color=curv_neg_color;
etc_render_fsbrain.default_solid_color=default_solid_color;
etc_render_fsbrain.alpha=alpha;
etc_render_fsbrain.flag_camlight=flag_camlight;

etc_render_fsbrain.fig_brain=gcf;
etc_render_fsbrain.fig_stc=[];
etc_render_fsbrain.fig_gui=[];
etc_render_fsbrain.fig_vol=[];
etc_render_fsbrain.fig_coord_gui=[];
etc_render_fsbrain.fig_label_gui=[];
etc_render_fsbrain.show_nearest_brain_surface_location_flag=show_nearest_brain_surface_location_flag;
etc_render_fsbrain.show_brain_surface_location_flag=show_brain_surface_location_flag;
etc_render_fsbrain.show_contact_names_flag=show_contact_names_flag;
etc_render_fsbrain.electrode_update_contact_view_flag=electrode_update_contact_view_flag;
etc_render_fsbrain.show_all_contacts_mri_flag=show_all_contacts_mri_flag;
etc_render_fsbrain.show_all_contacts_mri_depth=show_all_contacts_mri_depth;
etc_render_fsbrain.show_all_contacts_brain_surface_flag=show_all_contacts_brain_surface_flag;


etc_render_fsbrain.overlay_source=overlay_source;
etc_render_fsbrain.overlay_vol=overlay_vol;
etc_render_fsbrain.overlay_vol_stc=overlay_vol_stc;
etc_render_fsbrain.overlay_aux_vol=overlay_aux_vol;
etc_render_fsbrain.overlay_aux_vol_stc=overlay_aux_vol_stc;
etc_render_fsbrain.overlay_value=overlay_value;
etc_render_fsbrain.overlay_vol_value=overlay_vol_value;
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
etc_render_fsbrain.overlay_vol_flag_render=overlay_vol_flag_render;
etc_render_fsbrain.overlay_fixval_flag=overlay_fixval_flag;
etc_render_fsbrain.overlay_regrid_flag=overlay_regrid_flag;
etc_render_fsbrain.overlay_regrid_zero_flag=overlay_regrid_zero_flag;
etc_render_fsbrain.overlay_flag_paint_on_cortex=overlay_flag_paint_on_cortex;
etc_render_fsbrain.overlay_Ds=overlay_Ds;
etc_render_fsbrain.overlay_vol_xfm=overlay_vol_xfm;
etc_render_fsbrain.flag_overlay_truncate_pos=overlay_truncate_pos;
etc_render_fsbrain.flag_overlay_truncate_neg=overlay_truncate_neg;
etc_render_fsbrain.flag_overlay_vol2surf=flag_overlay_vol2surf;


etc_render_fsbrain.flag_orthogonal_slice_ax=flag_orthogonal_slice_ax;
etc_render_fsbrain.flag_orthogonal_slice_sag=flag_orthogonal_slice_sag;
etc_render_fsbrain.flag_orthogonal_slice_cor=flag_orthogonal_slice_cor;

etc_render_fsbrain.overlay_buffer=overlay_buffer;
etc_render_fsbrain.overlay_buffer_idx=overlay_buffer_idx;
etc_render_fsbrain.overlay_buffer_main_idx=overlay_buffer_main_idx;

etc_render_fsbrain.flag_colorbar=flag_colorbar;
etc_render_fsbrain.flag_colorbar_vol=flag_colorbar_vol;

etc_render_fsbrain.overlay_vol_mask_alpha=overlay_vol_mask_alpha;
etc_render_fsbrain.overlay_vol_mask=overlay_vol_mask;
etc_render_fsbrain.overlay_flag_vol_mask=overlay_flag_vol_mask;
etc_render_fsbrain.lut=lut;

etc_render_fsbrain.label_file_annot=label_file_annot;
etc_render_fsbrain.label_vertex=label_vertex;
etc_render_fsbrain.label_value=label_value;
etc_render_fsbrain.label_ctab=label_ctab;
etc_render_fsbrain.label_h=[]; %handle to the label points on the cortical surface
etc_render_fsbrain.label_select_idx=-1; %the index to the selected label
etc_render_fsbrain.flag_show_cort_label=flag_show_cort_label; %show solid labels
etc_render_fsbrain.flag_show_cort_label_boundary=flag_show_cort_label_boundary; %show label boundary
etc_render_fsbrain.cort_label_boundary_color=cort_label_boundary_color; %label boundary color

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
etc_render_fsbrain.aux_point_text_color=topo_aux_point_text_color;
etc_render_fsbrain.aux_point_text_size=topo_aux_point_text_size;

etc_render_fsbrain.aux2_point_coords=topo_aux2_point_coords;
etc_render_fsbrain.aux2_point_coords_h=topo_aux2_point_coords_h;
etc_render_fsbrain.selected_electrode_coords_h=selected_electrode_coords_h;
etc_render_fsbrain.selected_contact_coords_h=selected_contact_coords_h;
etc_render_fsbrain.aux2_point_name=topo_aux2_point_name;
etc_render_fsbrain.aux2_point_name_h=topo_aux2_point_name_h;
etc_render_fsbrain.aux2_point_color=topo_aux2_point_color;
etc_render_fsbrain.aux2_point_size=topo_aux2_point_size;
etc_render_fsbrain.aux2_point_color_e=topo_aux2_point_color_e;
etc_render_fsbrain.aux2_point_size_e=topo_aux2_point_size_e;
etc_render_fsbrain.aux2_point_color_c=topo_aux2_point_color_c;
etc_render_fsbrain.aux2_point_size_c=topo_aux2_point_size_c;
etc_render_fsbrain.aux2_point_individual_color=aux2_point_individual_color;

etc_render_fsbrain.selected_electrode_size=selected_electrode_size;
etc_render_fsbrain.selected_electrode_flag=selected_electrode_flag;
etc_render_fsbrain.selected_electrode_color=selected_electrode_color;

etc_render_fsbrain.selected_contact_size=selected_contact_size;
etc_render_fsbrain.selected_contact_flag=selected_contact_flag;
etc_render_fsbrain.selected_contact_color=selected_contact_color;

etc_render_fsbrain.all_electrode_flag=all_electrode_flag;

etc_render_fsbrain.register_rotate_angle=3; %default: 3 degrees
etc_render_fsbrain.register_translate_dist=1e-3; %default: 1 mm

etc_render_fsbrain.click_point_color=click_point_color;
etc_render_fsbrain.click_point_size=click_point_size;
etc_render_fsbrain.click_vertex_point_color=click_vertex_point_color;
etc_render_fsbrain.click_vertex_point_size=click_vertex_point_size;

etc_render_fsbrain.electrode=electrode;
etc_render_fsbrain.electrode_idx=electrode_idx;
etc_render_fsbrain.electrode_contact_idx=electrode_contact_idx;
etc_render_fsbrain.fig_electrode_gui=[];

etc_render_fsbrain.object=object;
if(~isempty(object))
    etc_render_fsbrain.object_Vertices_orig=etc_render_fsbrain.object.Vertices;
    if(~isempty(object_xfm))
        etc_render_fsbrain.object_xfm=object_xfm;
    else
        etc_render_fsbrain.object_xfm=eye(4);
    end;

    if(isfield(etc_render_fsbrain.object.UserData,'Origin'))
        etc_render_fsbrain.object.UserData.Origin_orig=etc_render_fsbrain.object.UserData.Origin;
    end;
    if(isfield(etc_render_fsbrain.object.UserData,'Axis'))
        etc_render_fsbrain.object.UserData.Axis_orig=etc_render_fsbrain.object.UserData.Axis;
    end;
else
    etc_render_fsbrain.object_xfm=[];
end;

etc_render_fsbrain.click_coord=[];
etc_render_fsbrain.surface_coord=[];
etc_render_fsbrain.click_vertex_vox=[];

etc_render_fsbrain.h_colorbar=[];
etc_render_fsbrain.h_colorbar_pos=[];
etc_render_fsbrain.h_colorbar_neg=[];
etc_render_fsbrain.h_colorbar_vol=[];
etc_render_fsbrain.h_colorbar_vol_pos=[];
etc_render_fsbrain.h_colorbar_vol_neg=[];
etc_render_fsbrain.brain_axis_pos=[];

etc_render_fsbrain.h_label_boundary={};


%label annotation
if(~isempty(etc_render_fsbrain.label_file_annot))
        etc_render_fsbrain_handle('kb','cc','l','cc_param','init');
end;

%ROI label
if(~isempty(cort_label_filename))

    if(~iscell(cort_label_filename))
        cort_label_filename_all{1}=cort_label_filename;
    else
        cort_label_filename_all=cort_label_filename;
    end;

    for c_idx=1:length(cort_label_filename_all)
        %file_label=sprintf('%s/%s','.',cort_label_filename);
        file_label=cort_label_filename_all{c_idx};
        [ii,d0,d1,d2, vv] = inverse_read_label(file_label);


        etc_render_fsbrain.label_vertex=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
        etc_render_fsbrain.label_vertex(ii+1)=1;
        if(c_idx==1)
            etc_render_fsbrain.label_value=zeros(size(etc_render_fsbrain.vertex_coords_hemi,1),1);
        end;
        etc_render_fsbrain.label_value(ii+1)=c_idx;
    end;
    s.numEntries=length(cort_label_filename_all);
    s.orig_tab='';
    s.struct_names=cort_label_filename_all;
    cc=colororder;
    for c_idx=1:length(cort_label_filename_all)
        if(isempty(cort_label_colororder))
           s.table(c_idx,1:3)=cc(mod(c_idx-1,7)+1,:).*256;
        else
           s.table(c_idx,1:3)=cc(cort_label_colororder(c_idx),:).*255;
        end;
        s.table(c_idx,5)=c_idx;
    end;
    
    
    etc_render_fsbrain.label_ctab=s;
        
    etc_render_fsbrain.label_register=ones(1,length(cort_label_filename_all));


    %create ROI boundary
    for ss=1:size(etc_render_fsbrain.label_ctab.table,1)
        %ss=size(etc_render_fsbrain.label_ctab.table,1);
        label_number=etc_render_fsbrain.label_ctab.table(ss,5);
        vidx=find((etc_render_fsbrain.label_value)==label_number);
        boundary_face_idx=find(sum(ismember(etc_render_fsbrain.faces,vidx-1),2)==2); %face indices at the boundary of the selected label; two vertices out of three are the selected label
        for b_idx=1:length(boundary_face_idx)
            boundary_face_vertex_idx=find(ismember(etc_render_fsbrain.faces(boundary_face_idx(b_idx),:),vidx-1)); %find vertices of a boundary face within a label
            etc_render_fsbrain.h_label_boundary{ss}(b_idx)=line(...
                etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,1)',...
                etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,2)',...
                etc_render_fsbrain.vertex_coords_hemi(etc_render_fsbrain.faces(boundary_face_idx(b_idx),boundary_face_vertex_idx)+1,3)');

            set(etc_render_fsbrain.h_label_boundary{ss}(b_idx),'linewidth',2,'color',etc_render_fsbrain.cort_label_boundary_color,'visible','off');
        end;
    end;

    etc_render_fsbrain_handle('update_label');
end;

if(isempty(etc_render_fsbrain.overlay_vol_stc))
    if(~isempty(etc_render_fsbrain.vol_A))
        %paint STC to Vol
        if((~isempty(etc_render_fsbrain.overlay_stc)|~isempty(etc_render_fsbrain.overlay_value))&~isempty(etc_render_fsbrain.overlay_vertex))
            for hemi_idx=1:2
                etc_render_fsbrain.vol_A(hemi_idx).loc=[];
                etc_render_fsbrain.vol_A(hemi_idx).wb_loc=[];
                etc_render_fsbrain.vol_A(hemi_idx).v_idx=[];
                etc_render_fsbrain.vol_A(hemi_idx).vertex_coords=[];
                etc_render_fsbrain.vol_A(hemi_idx).faces=[];
                etc_render_fsbrain.vol_A(hemi_idx).src_wb_idx=[];
            end;

            if(~iscell(hemi))
                vv=etc_render_fsbrain.overlay_vertex;
                switch(hemi)
                    case 'lh'
                        etc_render_fsbrain.vol_A(1).loc=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                        if(isempty(overlay_vol_stc))
                            etc_render_fsbrain.vol_A(1).wb_loc=[];
                        end;
                        etc_render_fsbrain.vol_A(1).v_idx=vv;
                        etc_render_fsbrain.vol_A(1).vertex_coords=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                        etc_render_fsbrain.vol_A(1).faces=etc_render_fsbrain.faces;

                        loc_surf=[etc_render_fsbrain.orig_vertex_coords(vv+1,:) ones(length(vv),1)]';
                        tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                        loc_vol=round(tmp(1:3,:))';


                        for ii=1:size(loc_vol,2)
                            loc_vol(find(loc_vol(:,ii)<1),ii)=nan;
                            loc_vol(find(loc_vol(:,ii)>etc_render_fsbrain.vol.volsize(ii)),ii)=nan;
                        end;
                        tmp=mean(loc_vol,2);
                        loc_vol(find(isnan(tmp)),:)=[];

                        etc_render_fsbrain.vol_A(1).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                    case 'rh'
                        etc_render_fsbrain.vol_A(2).loc=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                        if(isempty(overlay_vol_stc))
                            etc_render_fsbrain.vol_A(2).wb_loc=[];
                        end;
                        etc_render_fsbrain.vol_A(2).v_idx=vv;
                        etc_render_fsbrain.vol_A(2).vertex_coords=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                        etc_render_fsbrain.vol_A(2).faces=etc_render_fsbrain.faces;

                        loc_surf=[etc_render_fsbrain.orig_vertex_coords(vv+1,:) ones(length(vv),1)]';
                        tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                        loc_vol=round(tmp(1:3,:))';
                        for ii=1:size(loc_vol,2)
                            loc_vol(find(loc_vol(:,ii)<1),ii)=nan;
                            loc_vol(find(loc_vol(:,ii)>etc_render_fsbrain.vol.volsize(ii)),ii)=nan;
                        end;
                        tmp=mean(loc_vol,2);
                        loc_vol(find(isnan(tmp)),:)=[];

                        etc_render_fsbrain.vol_A(2).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                end;
            else
                for hemi_idx=1:length(hemi)
                    vv=etc_render_fsbrain.overlay_vertex{hemi_idx};
                    if(hemi_idx>1)
                        hemi_offset=size(etc_render_fsbrain.vertex_coords_hemi{hemi_idx-1},1);
                    else
                        hemi_offset=0;
                    end;

                    switch(hemi{hemi_idx})
                        case 'lh'
                            etc_render_fsbrain.vol_A(1).loc=etc_render_fsbrain.orig_vertex_coords(hemi_offset+vv+1,:);
                            if(isempty(overlay_vol_stc))
                                etc_render_fsbrain.vol_A(1).wb_loc=[];
                            end;
                            etc_render_fsbrain.vol_A(1).v_idx=vv;
                            etc_render_fsbrain.vol_A(1).vertex_coords=etc_render_fsbrain.orig_vertex_coords(hemi_offset+vv+1,:);
                            etc_render_fsbrain.vol_A(1).faces=etc_render_fsbrain.faces;

                            loc_surf=[etc_render_fsbrain.orig_vertex_coords(hemi_offset+vv+1,:) ones(length(vv),1)]';
                            tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                            loc_vol=round(tmp(1:3,:))';


                            for ii=1:size(loc_vol,2)
                                loc_vol(find(loc_vol(:,ii)<1),ii)=nan;
                                loc_vol(find(loc_vol(:,ii)>etc_render_fsbrain.vol.volsize(ii)),ii)=nan;
                            end;
                            tmp=mean(loc_vol,2);
                            loc_vol(find(isnan(tmp)),:)=[];

                            etc_render_fsbrain.vol_A(1).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                        case 'rh'
                            etc_render_fsbrain.vol_A(2).loc=etc_render_fsbrain.orig_vertex_coords(hemi_offset+vv+1,:);
                            if(isempty(overlay_vol_stc))
                                etc_render_fsbrain.vol_A(2).wb_loc=[];
                            end;
                            etc_render_fsbrain.vol_A(2).v_idx=vv;
                            etc_render_fsbrain.vol_A(2).vertex_coords=etc_render_fsbrain.orig_vertex_coords(hemi_offset+vv+1,:);
                            etc_render_fsbrain.vol_A(2).faces=etc_render_fsbrain.faces;

                            loc_surf=[etc_render_fsbrain.orig_vertex_coords(hemi_offset+vv+1,:) ones(length(vv),1)]';
                            tmp=inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*loc_surf;
                            loc_vol=round(tmp(1:3,:))';
                            for ii=1:size(loc_vol,2)
                                loc_vol(find(loc_vol(:,ii)<1),ii)=nan;
                                loc_vol(find(loc_vol(:,ii)>etc_render_fsbrain.vol.volsize(ii)),ii)=nan;
                            end;
                            tmp=mean(loc_vol,2);
                            loc_vol(find(isnan(tmp)),:)=[];

                            etc_render_fsbrain.vol_A(2).src_wb_idx=sub2ind(size(etc_render_fsbrain.vol.vol),loc_vol(:,2),loc_vol(:,1),loc_vol(:,3));
                    end;
                end;
            end;

            if(isempty(etc_render_fsbrain.overlay_vol_stc))
                if(~isempty(etc_render_fsbrain.overlay_stc))
                    if(~iscell(etc_render_fsbrain.overlay_stc))
                        etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_stc;
                    else
                        for hemi_idx=1:length(etc_render_fsbrain.overlay_stc)
                            etc_render_fsbrain.overlay_vol_stc=cat(1,etc_render_fsbrain.overlay_vol_stc,etc_render_fsbrain.overlay_stc{hemi_idx});
                        end;
                    end;
                end;
                if(~isempty(etc_render_fsbrain.overlay_value))
                    if(isempty(etc_render_fsbrain.overlay_vol_stc))
                        if(~iscell(etc_render_fsbrain.overlay_value))
                            etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_value(:);
                        else
                            for hemi_idx=1:length(etc_render_fsbrain.overlay_value)
                                %n_dip(hemi_idx)=(size(etc_render_fsbrain.vol_A(hemi_idx).loc,1)+size(etc_render_fsbrain.vol_A(hemi_idx).wb_loc,1)).*3;
                                %n_source(hemi_idx)=n_dip(hemi_idx)/3;

                                etc_render_fsbrain.overlay_vol_stc=cat(1,etc_render_fsbrain.overlay_vol_stc,etc_render_fsbrain.overlay_value{hemi_idx}(:));
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

%enforce the mapping for vol_stc data to volume 
etc_render_fsbrain_handle('update_overlay_vol');

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


if(~isempty(pt))
    etc_render_fsbrain_handle('bd','pt',pt);
end;
return;
    