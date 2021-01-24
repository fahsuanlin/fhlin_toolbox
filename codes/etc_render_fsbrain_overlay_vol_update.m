function etc_render_fsbrain_overlay_vol_update(varargin)

global etc_render_fsbrain;

%prepare mapping overlay values from "overlay_vol"
if(~isempty(etc_render_fsbrain.overlay_vol))
    
    %fprintf('preparing volume overlay...');
    
    offset=0;
    etc_render_fsbrain.overlay_vol_stc=[];
    for hemi_idx=1:2
        
        %choose 10,242 sources arbitrarily for cortical soruces
        %etc_render_fsbrain.vol_A(hemi_idx).v_idx=[1:10242]-1;
        etc_render_fsbrain.vol_A(hemi_idx).v_idx=[1:10:size(etc_render_fsbrain.orig_vertex_coords,1)]-1;
        
        etc_render_fsbrain.vol_A(hemi_idx).vertex_coords=etc_render_fsbrain.vertex_coords;
        etc_render_fsbrain.vol_A(hemi_idx).faces=etc_render_fsbrain.faces;
        etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords=etc_render_fsbrain.orig_vertex_coords;
        
        SurfVertices=cat(2,etc_render_fsbrain.vol_A(hemi_idx).orig_vertex_coords(etc_render_fsbrain.vol_A(hemi_idx).v_idx+1,:),ones(length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),1));
        
        vol_vox_tmp=(inv(etc_render_fsbrain.vol.tkrvox2ras)*(etc_render_fsbrain.vol_reg)*(SurfVertices.')).';
        vol_vox_tmp=round(vol_vox_tmp(:,1:3));
        
        %separate data into "cort_idx" and "non_cort_idx" entries; the
        %former ones are for cortical locations (defined for ONLY one selected
        %hemisphere. the latter ones are for non-cortical locations (may
        %include the cortical locations of the other non-selected
        %hemisphere).
        all_idx=[1:prod(etc_render_fsbrain.overlay_vol.volsize(1:3))];
        %[cort_idx,ii]=unique(sub2ind(overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3)));
        
        cort_idx=sub2ind(etc_render_fsbrain.overlay_vol.volsize(1:3),vol_vox_tmp(:,2),vol_vox_tmp(:,1),vol_vox_tmp(:,3));
        ii=[1:length(cort_idx)];
        etc_render_fsbrain.vol_A(hemi_idx).v_idx=etc_render_fsbrain.vol_A(hemi_idx).v_idx(ii);
        non_cort_idx=setdiff(all_idx,cort_idx);
        
        n_source(hemi_idx)=length(non_cort_idx)+length(cort_idx);
        n_dip(hemi_idx)=n_source(hemi_idx)*3;
%         
%         
%         [C,R,S] = meshgrid([1:size(etc_render_fsbrain.overlay_vol.vol,2)],[1:size(etc_render_fsbrain.overlay_vol.vol,1)],[1:size(etc_render_fsbrain.overlay_vol.vol,3)]);
%         CRS=[C(:) R(:) S(:)];
%         CRS=cat(2,CRS,ones(size(CRS,1),1))';
%         
%         all_coords=inv(etc_render_fsbrain.vol_reg)*etc_render_fsbrain.vol.tkrvox2ras*CRS;
%         all_coords=all_coords(1:3,:)';
%         etc_render_fsbrain.vol_A(hemi_idx).loc=all_coords(cort_idx,:);
%         etc_render_fsbrain.vol_A(hemi_idx).wb_loc=all_coords(non_cort_idx,:)./1e3;
        
        etc_render_fsbrain.overlay_vol_value=reshape(etc_render_fsbrain.overlay_vol.vol,[size(etc_render_fsbrain.overlay_vol.vol,1)*size(etc_render_fsbrain.overlay_vol.vol,2)*size(etc_render_fsbrain.overlay_vol.vol,3), size(etc_render_fsbrain.overlay_vol.vol,4)]);
        
        midx=[cort_idx(:)' non_cort_idx(:)'];
        etc_render_fsbrain.overlay_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),:)=etc_render_fsbrain.overlay_vol_value(midx(1:length(cort_idx)),:);
        etc_render_fsbrain.overlay_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:)=etc_render_fsbrain.overlay_vol_value(midx(length(cort_idx)+1:end),:);
        
        etc_render_fsbrain.overlay_aux_vol_value=[];
        for vv_idx=1:length(etc_render_fsbrain.overlay_aux_vol)
            etc_render_fsbrain.overlay_aux_vol_value(:,:,vv_idx)=reshape(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,[size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,1)*size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,2)*size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,3), size(etc_render_fsbrain.overlay_aux_vol(vv_idx).vol,4)]);
            etc_render_fsbrain.overlay_aux_vol_stc(offset+1:offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx),:,vv_idx)=etc_render_fsbrain.overlay_aux_vol_value(midx(1:length(cort_idx)),:,vv_idx);
            etc_render_fsbrain.overlay_aux_vol_stc(offset+length(etc_render_fsbrain.vol_A(hemi_idx).v_idx)+1:offset+n_source(hemi_idx),:,vv_idx)=etc_render_fsbrain.overlay_aux_vol_value(midx(length(cort_idx)+1:end),:,vv_idx);
        end;
        
        offset=offset+n_source(hemi_idx);
        
        X_hemi_cort{hemi_idx}=etc_render_fsbrain.overlay_vol_value(cort_idx,:);
        X_hemi_subcort{hemi_idx}=etc_render_fsbrain.overlay_vol_value(non_cort_idx,:);
        
        if(~isempty(etc_render_fsbrain.overlay_aux_vol_value))
            aux_X_hemi_cort{hemi_idx}=etc_render_fsbrain.overlay_aux_vol_value(cort_idx,:,:);
            aux_X_hemi_subcort{hemi_idx}=oetc_render_fsbrain.verlay_aux_vol_value(non_cort_idx,:,:);
        end;
    end;
    
    
    if(strcmp(etc_render_fsbrain.hemi,'lh'))
        etc_render_fsbrain.overlay_stc=X_hemi_cort{1};
        etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.vol_A(1).v_idx;
        if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
            etc_render_fsbrain.overlay_aux_stc=aux_X_hemi_cort{1};
        end;
    else
        etc_render_fsbrain.overlay_stc=X_hemi_cort{2};
        etc_render_fsbrain.overlay_vertex=etc_render_fsbrain.vol_A(2).v_idx;
        if(~isempty(etc_render_fsbrain.overlay_aux_vol_stc))
            etc_render_fsbrain.overlay_aux_stc=aux_X_hemi_cort{2};
        end;
    end;
    etc_render_fsbrain.overlay_value=etc_render_fsbrain.overlay_stc(:,etc_render_fsbrain.overlay_stc_timeVec_idx);
    
    etc_render_fsbrain.overlay_stc_timeVec=[1:size(etc_render_fsbrain.overlay_stc,2)];
    
    etc_render_fsbrain.overlay_flag_render=1;
    
    fprintf('Done!\n');
end;
