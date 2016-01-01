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

%color 
default_solid_color=[1.0000    0.7031    0.3906];
curv_pos_color=[1 1 1].*0.4;
curv_neg_color=[1 1 1].*0.7;

bg_color='w'; %figure background color;
overlay_cmap=autumn(80); %overlay colormap;
overlay_cmap_neg=winter(80); %overlay colormap;
overlay_cmap_neg(:,3)=1;

%overlay
overlay_value=[];
overlay_stc=[];
overlay_stc_hemi=[];
overlay_stc_lim=[];
overlay_stc_timeVec=[];
overlay_stc_timeVec_idx=[];
overlay_vertex=[];
overlay_smooth=5;
overlay_threshold=[];
overlay_value_flag_pos=0;
overlay_value_flag_neg=0;
overlay_regrid_flag=1;

overlay_exclude_fstem='';
overlay_exclude=[];

%cluster file
cluster_file={};

%etc
alpha=1;
view_angle=[]; 

flag_redraw=0;
flag_camlight=1;

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
        case 'flag_curv'
            flag_curv=option_value;
        case 'default_solid_color'
            default_solid_color=option_value;
        case 'curv_pos_color'
            curv_pos_color=option_value;
        case 'curv_neg_color'
            curv_neg_color=option_value;
        case 'overlay_value'
            overlay_value=option_value;
        case 'overlay_stc'
            overlay_stc=option_value;
        case 'overlay_exclude'
            overlay_exclude=option_value;
        case 'overlay_exclude_fstem'
            overlay_exclude_fstem=option_value;
        case 'overlay_stc_lim'
            overlay_stc_lim=option_value;
        case 'overlay_stc_timevec'
            overlay_stc_timeVec=option_value;
        case 'overlay_vertex'
            overlay_vertex=option_value;
        case 'overlay_smooth'
            overlay_smooth=option_value;
        case 'overlay_regrid_flag'
            overlay_regrid_flag=option_value;
        case 'overlay_threshold'
            overlay_threshold=option_value;
        case 'overlay_cmap'
            overlay_cmap=option_value;
        case 'cluster_file'
            cluster_file=option_value;
        case 'alpha'
            alpha=option_value;
        case 'flag_redraw'
            flag_redraw=option_value;
        case 'flag_camlight'
            flag_camlight=option_value;
        case 'view_angle'
            view_angle=option_value;
        otherwise
            fprintf('unknown option [%s]...\n',option);
            return;
    end;
end

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
    fprintf('rendering [%s]...\n',file_surf);

    [vertex_coords, faces] = read_surf(file_surf);
    
    vertex_coords_hemi=vertex_coords;
    faces_hemi=faces;
else
    vertex_coords=[]; faces=[];
    for h_idx=1:length(hemi)
        file_surf=sprintf('%s/%s/surf/%s.%s',subjects_dir,subject,hemi{h_idx},surf);
        fprintf('rendering [%s]...\n',file_surf);
        
        [vv, ff] = read_surf(file_surf);
        vertex_coords_hemi{h_idx}=vv;
        faces_hemi{h_idx}=ff;
        
        faces=cat(1,faces,ff+size(vertex_coords,1));
        
        vv(:,1)=vv(:,1)+(-1).^(h_idx).*50;
        
        vertex_coords=cat(1,vertex_coords,vv);
    end;
end;


%excluding labels
if(~isempty(overlay_exclude_fstem))
    if(~iscell(hemi))
        overlay_exclude_tmp=inverse_read_label(sprintf('%s',overlay_exclude_fstem));
        %[dummy,overlay_exclude]=intersect(vertex_coords,overlay_exclude_tmp);
        overlay_exclude=overlay_exclude_tmp+1;
    else
        for i=1:length(hemi)
            overlay_exclude_tmp{i}=inverse_read_label(sprintf('%s-%s.label',overlay_exclude_fstem,hemi{i}));
            %[dummy,overlay_exclude{i}]=intersect(vertex_coords_hemi{i},overlay_exclude_tmp{i});
            overlay_exclude{i}=overlay_exclude_tmp{i}+1;
        end;
    end;
else
    if(~iscell(hemi))
        overlay_exclude=[];
    else
        for i=1:length(hemi)
            overlay_exclude{i}=[];
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

%2: curvature and overlay color
if(~isempty(overlay_value))
    if(~iscell(overlay_value))
        ov=zeros(size(vertex_coords,1),1);
        ov(overlay_vertex+1)=overlay_value;
        
        if(~isempty(overlay_smooth))
            ovs=inverse_smooth('','vertex',vertex_coords','face',faces','value',ov,'step',overlay_smooth,'flag_fixval',0,'exc_vertex',overlay_exclude,'flag_regrid',overlay_regrid_flag);
        else
            ovs=ov;
        end;
        
        
        if(~isempty(find(overlay_value>0))) overlay_value_flag_pos=1; end;
        if(~isempty(find(overlay_value<0))) overlay_value_flag_neg=1; end;
    else
        ovs=[];
        for h_idx=1:length(overlay_value)
            ov=zeros(size(vertex_coords_hemi{h_idx},1),1);
            ov(overlay_vertex{h_idx}+1)=overlay_value{h_idx};
            
            if(~isempty(overlay_smooth))
                ovs=cat(1,ovs,inverse_smooth('','vertex',vertex_coords_hemi{h_idx}','face',faces_hemi{h_idx}','value',ov,'step',overlay_smooth,'flag_fixval',0,'exc_vertex',overlay_exclude{h_idx},'flag_regrid',overlay_regrid_flag));
            else
                ovs=cat(1,ovs,ov);
            end;
        end;
        
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
    
    fvdata(c_idx,:)=inverse_get_color(overlay_cmap_neg,ovs(c_idx),-max(overlay_threshold),-min(overlay_threshold));

    colormap(overlay_cmap);
end;


%%%%%%%%%%%%%%%%%%%%%%%%
% main routine for rendering...
%%%%%%%%%%%%%%%%%%%%%%%%
h=patch('Faces',faces+1,'Vertices',vertex_coords,'FaceVertexCData',fvdata,'facealpha',alpha,'CDataMapping','direct','facecolor','interp','edgecolor','none');   

if(~flag_redraw)
    axis off vis3d equal;
    if(~isempty(overlay_threshold))
        set(gca,'climmode','manual','clim',overlay_threshold);
    end;
    set(gcf,'color',bg_color);
    
    view(view_angle(1), view_angle(2));
    material dull;
    if(flag_camlight)
       camlight(-90,0);
       camlight(90,0);    
       camlight(0,0);
       camlight(180,0);    
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%
%setup global object
%%%%%%%%%%%%%%%%%%%%%%%%
global etc_render_fsbrain;

etc_render_fsbrain.brain_axis=gca;


etc_render_fsbrain.faces=faces;
etc_render_fsbrain.vertex_coords=vertex_coords;
etc_render_fsbrain.faces_hemi=faces_hemi;
etc_render_fsbrain.vertex_coords_hemi=vertex_coords_hemi;
etc_render_fsbrain.fvdata=fvdata;
etc_render_fsbrain.curv=curv;
%etc_render_fsbrain.curv_hemi=curv_hemi;
etc_render_fsbrain.overlay_value=overlay_value;

etc_render_fsbrain.view_angle=view_angle;
etc_render_fsbrain.bg_color=bg_color;
etc_render_fsbrain.curv_pos_color=curv_pos_color;
etc_render_fsbrain.curv_neg_color=curv_neg_color;
etc_render_fsbrain.default_solid_color=default_solid_color;
etc_render_fsbrain.alpha=alpha;

etc_render_fsbrain.fig_brain=gcf;
etc_render_fsbrain.fig_stc=[];

etc_render_fsbrain.overlay_value=overlay_value;
etc_render_fsbrain.overlay_stc=overlay_stc;
etc_render_fsbrain.overlay_stc_hemi=overlay_stc_hemi;
etc_render_fsbrain.overlay_stc_timeVec=overlay_stc_timeVec;
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

etc_render_fsbrain.h=h;
etc_render_fsbrain.click_point=[];
etc_render_fsbrain.click_vertex=[];
etc_render_fsbrain.click_vertex_point=[];
etc_render_fsbrain.click_overlay_vertex=[];
etc_render_fsbrain.click_overlay_vertex_point=[];
etc_render_fsbrain.roi_radius=[];

etc_render_fsbrain.cluster_file=cluster_file;

%%%%%%%%%%%%%%%%%%%%%%%%
%setup call-back function
%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf,'WindowButtonDownFcn','etc_render_fsbrain_handle(''bd'')');
set(gcf,'KeyPressFcn','etc_render_fsbrain_handle(''kb'')');

hold on;
return;
    