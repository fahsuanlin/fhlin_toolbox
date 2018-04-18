function h=etc_render_topo(varargin)
%
% etc_render_topo    rendering the topology of multi-electrode event-related fields/potentials.
% h = etc_render_topo([option1 option1_value, ...]);
%
% h: the handle of the patch object
%
% fhlin@dec 26 2016
%

h=[];

vol_vertex=[];
vol_face=[];
vol_vertex_hemi={};
vol_face_hemi={};

%color
default_solid_color=[256 180 100]./256;


bg_color=[1 1 1]; %figure background color;

tmp=jet(256);
topo_cmap=tmp(129:end,:);
% overlay_cmap=autumn(80); %overlay colormap;
%topo_cmap_neg=winter(80); %overlay colormap;
topo_cmap_neg=flipud(tmp(1:128,:));

%overlay
topo_value=[];
topo_stc=[];
topo_aux_stc=[];
topo_stc_hemi=[];
topo_stc_lim=[];
topo_stc_timeVec=[];
topo_stc_timeVec_unit='';
topo_stc_timeVec_idx=[];
topo_vertex=[];
topo_vertex_hemi=[];
topo_label={};

topo_smooth=5;
topo_threshold=[];
topo_value_flag_pos=0;
topo_value_flag_neg=0;
topo_regrid_flag=1;
topo_regrid_zero_flag=0;
topo_flag_render=0;

topo_aux_point_coords=[];
topo_aux_point_coords_h=[];
topo_aux_point_name={};
topo_aux_point_name_h=[];

topo_aux2_point_coords=[];
topo_aux2_point_coords_h=[];
topo_aux2_point_name={};
topo_aux2_point_name_h=[];

topo_exclude_fstem='';
topo_exclude=[];

topo_include_fstem='';
topo_include=[];

topo=[]; %topology structure; with "vertex", "face", "ch_names", "electrode_idx" 4 fields.

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

for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'vol_face'
            vol_face=option_value;
        case 'vol_face_hemi'
            vol_face_hemi=option_value;
        case 'vol_vertex'
            vol_vertex=option_value;
        case 'vol_vertex_hemi'
            vol_vertex_hemi=option_value;
        case 'topo'
            topo=option_value;
        case 'topo_vertex'
            topo_vertex=option_value;
        case 'topo_flag_render'
            topo_flag_render=option_value;
        case 'topo_value'
            topo_value=option_value;
        case 'topo_value_hemi'
            topo_value_hemi=option_value;
        case 'topo_smooth'
            topo_smooth=option_value;
        case 'topo_threshold'
            topo_threshold=option_value;
        case 'topo_cmap'
            topo_cmap=option_value;
        case 'topo_cmap_neg'
            topo_cmap_neg=option_value;
        case 'topo_regrid_flag'
            topo_regrid_flag=option_value;
        case 'topo_regrid_zero_flag'
            topo_regrid_zero_flag=option_value;
        case 'topo_exclude'
            topo_exclude=option_value;
        case 'topo_exclude_fstem'
            topo_exclude_fstem=option_value;
        case 'topo_include'
            topo_include=option_value;
        case 'topo_include_fstem'
            topo_include_fstem=option_value;
        case 'topo_stc'
            topo_stc=option_value;
        case 'topo_aux_stc'
            topo_aux_stc=option_value;
        case 'topo_stc_lim'
            topo_stc_lim=option_value;
        case 'topo_stc_timevec'
            topo_stc_timeVec=option_value;
        case 'topo_stc_timevec_unit'
            topo_stc_timeVec_unit=option_value;
        case 'topo_stc_timevec_idx'
            topo_stc_timeVec_idx=option_value;
        case 'topo_label'
            topo_label=option_value;
        case 'topo_aux_point_coords';
            topo_aux_point_coords=option_value;
        case 'topo_aux_point_name';
            topo_aux_point_name=option_value;
        case 'topo_aux2_point_coords';
            topo_aux2_point_coords=option_value;
        case 'topo_aux2_point_name';
            topo_aux2_point_name=option_value;
        case 'default_solid_color'
            default_solid_color=option_value;
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
        case 'view_angle'
            view_angle=option_value;
        case 'bg_color'
            bg_color=option_value;
        case 'label_vertex'
            label_vertex=option_value;
        case 'label_value'
            label_value=option_value;
        case 'label_ctab'
            label_ctab=option_value;
        case 'file_annot'
            file_annot=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end

%get the overlay value from STC at the largest power instant, if it is not specified.
if(isempty(topo_value)&~isempty(topo_stc))
    if(isempty(topo_stc_timeVec_idx))
        [tmp,topo_stc_timeVec_idx]=max(sum(topo_stc.^2,1));
        topo_value=topo_stc(:,topo_stc_timeVec_idx);
    end;
end;


%0: solid color
fvdata=repmat(default_solid_color,[size(vol_vertex,1),1]);

topo_flag_render=0;
%2: curvature and overlay color
if(~isempty(topo_value))
    if(~iscell(topo_value))
        ov=zeros(size(vol_vertex,1),1);
        ov(topo_vertex+1)=topo_value;
        
        topo_exclude=find(vol_vertex(:,3)<min(vol_vertex(topo_vertex+1,3)));
        
        if(~isempty(topo_smooth))
            %ovs=inverse_smooth('','value',ov,'step',topo_smooth,'face',vol_face','vertex',vol_vertex','flag_fixval',1);
            ovs=inverse_smooth('','vertex',vol_vertex','face',vol_face','value',ov,'step',topo_smooth,'flag_fixval',0,'exc_vertex',topo_exclude,'inc_vertex',topo_include,'flag_regrid',topo_regrid_flag,'flag_regrid_zero',topo_regrid_zero_flag);
        else
            ovs=ov;
        end;
        
        topo_flag_render=1;
        
        if(~isempty(find(topo_value(:)>0))) topo_value_flag_pos=1; end;
        if(~isempty(find(topo_value(:)<0))) topo_value_flag_neg=1; end;
    else
        ovs=[];
        for h_idx=1:length(topo_value)
            ov=zeros(size(vol_vertex_hemi{h_idx},1),1);
            ov(topo_vertex{h_idx}+1)=topo_value{h_idx};
            
            if(~isempty(overlay_smooth))
                %                ovs=cat(1,ovs,inverse_smooth('','vertex',vertex_coords_hemi{h_idx}','face',faces_hemi{h_idx}','value',ov,'step',overlay_smooth,'flag_fixval',0,'exc_vertex',overlay_exclude{h_idx},'inc_vertex',overlay_include{h_idx},'flag_regrid',overlay_regrid_flag,'flag_regrid_zero',overlay_regrid_zero_flag));
                val=zeros(size(vol_vertex,1),1);
                val(topo_vertex)=topo_value;
                
                ovs=inverse_smooth('','value',val,'step',topo_smooth,'face',vol_face','vertex',vol_vertex','flag_fixval',1);
            else
                ovs=cat(1,ovs,ov);
            end;
        end;
        
        topo_flag_render=1;
        
        if(~isempty(find(topo_value(:)>0))) topo_value_flag_pos=1; end;
        if(~isempty(find(topo_value(:)<0))) topo_value_flag_neg=1; end;
    end;
    
    if(isempty(topo_threshold))
        tmp=sort(ovs(:));
        topo_threshold=[tmp(round(length(tmp)*0.5)) tmp(round(length(tmp)*0.9))];
    end;
    c_idx=find(ovs(:)>=min(topo_threshold));
    
    fvdata(c_idx,:)=inverse_get_color(topo_cmap,ovs(c_idx),max(topo_threshold),min(topo_threshold));
    
    c_idx=find(ovs(:)<=-min(topo_threshold));
    
    fvdata(c_idx,:)=inverse_get_color(topo_cmap_neg,ovs(c_idx),-max(topo_threshold),-min(topo_threshold));
end;


h=patch('Faces',vol_face+1,'Vertices',vol_vertex,'FaceVertexCData',fvdata,'facealpha',alpha,'CDataMapping','direct','facecolor','interp','edgecolor','none');
material dull;

axis off vis3d equal;

if(~isempty(topo_threshold))
    set(gca,'climmode','manual','clim',topo_threshold);
end;
set(gcf,'color',bg_color);

if(isempty(view_angle))
    
    view_angle=[-135 20];
end;
view(view_angle(1), view_angle(2));

hold on;
[sx,sy,sz] = sphere(8);
sr=0.005;

% for idx=1:size(topo_aux_point_coords,1)
%     topo_aux_point_coords_h(idx)=surf(sx.*sr+topo_aux_point_coords(idx,1),sy.*sr+topo_aux_point_coords(idx,2),sz.*sr+topo_aux_point_coords(idx,3));
%     set(topo_aux_point_coords_h(idx),'facecolor','r','edgecolor','none');
%     if(~isempty(topo_aux_point_name))
%         topo_aux_point_name_h(idx)=text(topo_aux_point_coords(idx,1),topo_aux_point_coords(idx,2),topo_aux_point_coords(idx,3),topo_aux_point_name{idx}); hold on;
%     end;
% end;

xx=[]; yy=[]; zz=[];
for idx=1:size(topo_aux_point_coords,1)
    xx=cat(1,xx,sx.*sr+topo_aux_point_coords(idx,1));
    yy=cat(1,yy,sy.*sr+topo_aux_point_coords(idx,2));
    zz=cat(1,zz,sz.*sr+topo_aux_point_coords(idx,3));
    if(~isempty(topo_aux_point_name))
        topo_aux_point_name_h(idx)=text(topo_aux_point_coords(idx,1),topo_aux_point_coords(idx,2),topo_aux_point_coords(idx,3),topo_aux_point_name{idx}); hold on;
    end;
end;
topo_aux_point_coords_h(1)=surf(xx,yy,zz);
set(topo_aux_point_coords_h(1),'facecolor','r','edgecolor','none');


xx=[]; yy=[]; zz=[];
for idx=1:size(topo_aux2_point_coords,1)
    xx=cat(1,xx,topo_aux2_point_coords(idx,1));
    yy=cat(1,yy,topo_aux2_point_coords(idx,2));
    zz=cat(1,zz,topo_aux2_point_coords(idx,3));
    if(~isempty(topo_aux2_point_name))
        topo_aux2_point_name_h(idx)=text(topo_aux2_point_coords(idx,1),topo_aux2_point_coords(idx,2),topo_aux2_point_coords(idx,3),topo_aux2_point_name{idx}); hold on;
    end;
end;
topo_aux2_point_coords_h=plot3(xx,yy,zz,'r.');
set(topo_aux2_point_coords_h,'color',[1 0 0].*0.5);

% for idx=1:size(topo_aux_point_coords,1)
%     topo_aux_point_coords_h(idx)=plot3(topo_aux_point_coords(idx,1),topo_aux_point_coords(idx,2),topo_aux_point_coords(idx,3));
%     %set(topo_aux_point_coords_h(idx),'facecolor','r','edgecolor','none');
%     set(topo_aux_point_coords_h(idx),'color','r','MarkerSize',10,'Marker','+');
%     if(~isempty(topo_aux_point_name))
%         topo_aux_point_name_h(idx)=text(topo_aux_point_coords(idx,1),topo_aux_point_coords(idx,2),topo_aux_point_coords(idx,3),topo_aux_point_name{idx}); hold on;
%         set(topo_aux_point_name_h(idx),'hori','center');
%     end;
% end;

%
% cp=campos;
% cp=cp./norm(cp);
%
% campos(1300.*cp);

if(flag_camlight)
    camlight(-90,0);
    camlight(90,0);
    camlight(0,0);
    camlight(180,0);
end;


%%%%%%%%%%%%%%%%%%%%%%%%
%setup global object
%%%%%%%%%%%%%%%%%%%%%%%%
global etc_render_fsbrain;

etc_render_fsbrain.brain_axis=gca;

etc_render_fsbrain.faces=vol_face;
etc_render_fsbrain.vertex_coords=vol_vertex;
etc_render_fsbrain.faces_hemi=vol_face;
etc_render_fsbrain.vertex_coords_hemi=vol_vertex;
etc_render_fsbrain.fvdata=fvdata;
etc_render_fsbrain.curv=[];
%etc_render_fsbrain.curv_hemi=curv_hemi;
etc_render_fsbrain.overlay_value=topo_value;

etc_render_fsbrain.view_angle=view_angle;
etc_render_fsbrain.bg_color=bg_color;
etc_render_fsbrain.curv_pos_color=[];
etc_render_fsbrain.curv_neg_color=[];
etc_render_fsbrain.default_solid_color=default_solid_color;
etc_render_fsbrain.alpha=alpha;

etc_render_fsbrain.fig_brain=gcf;
etc_render_fsbrain.fig_stc=[];
etc_render_fsbrain.fig_gui=[];
etc_render_fsbrain.fig_vol=[];

etc_render_fsbrain.vol_vox=[];

etc_render_fsbrain.overlay_value=topo_value;
etc_render_fsbrain.overlay_stc=topo_stc;
etc_render_fsbrain.overlay_aux_stc=topo_aux_stc;
etc_render_fsbrain.overlay_stc_hemi=topo_stc_hemi;
etc_render_fsbrain.overlay_stc_timeVec=topo_stc_timeVec;
etc_render_fsbrain.overlay_stc_timeVec_unit=topo_stc_timeVec_unit;
etc_render_fsbrain.overlay_stc_timeVec_idx=topo_stc_timeVec_idx;
etc_render_fsbrain.overlay_stc_timeVec_idx_line=[];
etc_render_fsbrain.overlay_stc_lim=topo_stc_lim;
etc_render_fsbrain.overlay_vertex=topo_vertex;
etc_render_fsbrain.overlay_smooth=topo_smooth;
etc_render_fsbrain.overlay_threshold=topo_threshold;
etc_render_fsbrain.overlay_cmap=topo_cmap;
etc_render_fsbrain.overlay_cmap_neg=topo_cmap_neg;
etc_render_fsbrain.overlay_value_flag_pos=topo_value_flag_pos;
etc_render_fsbrain.overlay_value_flag_neg=topo_value_flag_neg;
etc_render_fsbrain.overlay_exclude=topo_exclude;
etc_render_fsbrain.overlay_include=topo_include;
etc_render_fsbrain.flag_hold_fig_stc_timecourse=flag_hold_fig_stc_timecourse;
etc_render_fsbrain.handle_fig_stc_timecourse=[];
etc_render_fsbrain.handle_fig_stc_aux_timecourse=[];
etc_render_fsbrain.overlay_flag_render=topo_flag_render;

etc_render_fsbrain.label_vertex=label_vertex;
etc_render_fsbrain.label_value=label_value;
etc_render_fsbrain.label_ctab=label_ctab;
etc_render_fsbrain.label_h=[]; %handle to the label points on the cortical surface
etc_render_fsbrain.label_select_idx=-1; %the index to the selected label

etc_render_fsbrain.h=h;
etc_render_fsbrain.click_point=[];
etc_render_fsbrain.click_vertex=[];
etc_render_fsbrain.click_vertex_point=[];
etc_render_fsbrain.click_overlay_vertex=[];
etc_render_fsbrain.click_overlay_vertex_point=[];
etc_render_fsbrain.roi_radius=[];

etc_render_fsbrain.cluster_file=cluster_file;

etc_render_fsbrain.aux(1).data=topo_label;
etc_render_fsbrain.aux(1).tag='topo_label';
etc_render_fsbrain.aux_point_coords=topo_aux_point_coords;
etc_render_fsbrain.aux_point_coords_h=topo_aux_point_coords_h;
etc_render_fsbrain.aux_point_name=topo_aux_point_name;
etc_render_fsbrain.aux_point_name_h=topo_aux_point_name_h;

etc_render_fsbrain.aux2_point_coords=topo_aux2_point_coords;
etc_render_fsbrain.aux2_point_coords_h=topo_aux2_point_coords_h;
etc_render_fsbrain.aux2_point_name=topo_aux2_point_name;
etc_render_fsbrain.aux2_point_name_h=topo_aux2_point_name_h;

etc_render_fsbrain.register_rotate_angle=3; %default: 3 degrees
etc_render_fsbrain.register_translate_dist=1e-3; %default: 1 mm

etc_render_fsbrain.topo=topo;


%%%%%%%%%%%%%%%%%%%%%%%%
%setup call-back function
%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
set(gcf,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');
set(gcf,'invert','off');

hold on;

if(~isempty(view_angle))
    view(view_angle(1),view_angle(2));
end;

if(flag_colorbar)
    etc_render_fsbrain_handle('kb','c0','c0');
end;
return;