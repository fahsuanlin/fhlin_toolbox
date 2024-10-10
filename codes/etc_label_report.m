function result=etc_label_report(vidx,varargin) 

result=[];

subject='fsaverage';
hemi='lh';
overlay=[];
overlay_vertex=[];
flag_display=1;


for idx=1:length(varargin)/2
    option=varargin{idx*2-1};
    option_value=varargin{idx*2};
    switch lower(option)
        case 'hemi'
            hemi=option_value;
        case 'subject'
            subject=option_value;
        case 'overlay'
            overlay=option_value;
        case 'overlay_vertex'
            overlay_vertex=option_value;
        case 'flag_display'
            flag_display=option_value;
        otherwise
            fprintf('unknown option [%s]!\nerror!\n',option)
            return;
    end;
end;


fig=figure('visible','off');

%clear global etc_render_fsbrain;

if(~isempty(overlay)&~isempty(overlay_vertex))
    feval('etc_render_fsbrain','subject',subject,'hemi',hemi,'surf','orig','overlay_value',overlay,'overlay_vertex',overlay_vertex);
else
    feval('etc_render_fsbrain','subject',subject,'hemi',hemi,'surf','orig');
end;
global etc_render_fsbrain;

face_in_label_counter=sum(ismember(etc_render_fsbrain.faces,vidx),2);
face_in_label_idx=find(face_in_label_counter==3); %mesh triangulation indices for all three vertices included by a label
v1=etc_render_fsbrain.faces(face_in_label_idx,1);
v2=etc_render_fsbrain.faces(face_in_label_idx,2);
v3=etc_render_fsbrain.faces(face_in_label_idx,3);

P1=etc_render_fsbrain.orig_vertex_coords(v1+1,:);
P2=etc_render_fsbrain.orig_vertex_coords(v2+1,:);
P3=etc_render_fsbrain.orig_vertex_coords(v3+1,:);
area_within_label=.5*sum(sqrt(sum(cross(P2-P1,P3-P1).^2,2)));

if(flag_display)
    fprintf('label area =%2.1f (mm^2)\n',area_within_label);
end;
result.area_within_label=area_within_label;

%overlay
if(~isempty(etc_render_fsbrain.ovs))
    %fprintf('[%s] overlay = %2.2f +/- %2.2f \n',etc_render_fsbrain.label_ctab.struct_names{ss}, mean(etc_render_fsbrain.ovs(vidx)),std(etc_render_fsbrain.ovs(vidx)));
    if(flag_display)
        fprintf('overlay = %2.2f +/- %2.2f \n',mean(etc_render_fsbrain.ovs(vidx)),std(etc_render_fsbrain.ovs(vidx)));
    end;
    result.overlay_avg=mean(etc_render_fsbrain.ovs(vidx));
    result.overlay_std=std(etc_render_fsbrain.ovs(vidx));
    

    %overlay center-of-mass
    ww=etc_render_fsbrain.ovs(vidx);
    vv=etc_render_fsbrain.vertex_coords(vidx,:);
    com_surf=sum(vv.*repmat(ww,[1 3]),1)./sum(ww);

    ww=etc_render_fsbrain.ovs(vidx);
    vv=etc_render_fsbrain.orig_vertex_coords(vidx,:);
    com_orig_surf=sum(vv.*repmat(ww,[1 3]),1)./sum(ww);

    click_vertex_vox=inv(etc_render_fsbrain.vol.tkrvox2ras)*[com_orig_surf(:); 1];

    com_surf_tal=etc_render_fsbrain.talxfm*etc_render_fsbrain.vol_pre_xfm*etc_render_fsbrain.vol.vox2ras*click_vertex_vox;
    com_surf_tal=com_surf_tal(1:3)';
    if(flag_display)
        fprintf('center of mass coordinates: surface: %s; orig. surface: %s; MNI: %s\n',mat2str(com_surf, 2), mat2str(com_orig_surf, 2), mat2str(com_surf_tal, 2));
    end;

    result.com_orig_surf=com_orig_surf;
    result.com_surf_tal=com_surf_tal;
end;


return;