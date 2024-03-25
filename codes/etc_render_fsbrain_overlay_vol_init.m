function etc_render_fsbrain_overlay_vol_init(varargin)

global etc_render_fsbrain

hemi=etc_render_fsbrain.hemi;

%if(isempty(etc_render_fsbrain.overlay_vol_stc))
    %paint STC to Vol
    if((~isempty(etc_render_fsbrain.overlay_stc)|~isempty(etc_render_fsbrain.overlay_value))&~isempty(etc_render_fsbrain.overlay_vertex))
        vv=etc_render_fsbrain.overlay_vertex;
        switch(hemi)
            case 'lh'
                etc_render_fsbrain.vol_A(1).loc=etc_render_fsbrain.orig_vertex_coords(vv+1,:);
                if(isempty(etc_render_fsbrain.overlay_vol_stc))
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
                etc_render_fsbrain.vol_A(2).loc=[];
                etc_render_fsbrain.vol_A(2).wb_loc=[];
                etc_render_fsbrain.vol_A(2).v_idx=[];
                etc_render_fsbrain.vol_A(2).vertex_coords=[];
                etc_render_fsbrain.vol_A(2).faces=[];
                etc_render_fsbrain.vol_A(2).src_wb_idx=[];

            case 'rh'
                etc_render_fsbrain.vol_A(1).loc=[];
                etc_render_fsbrain.vol_A(1).wb_loc=[];
                etc_render_fsbrain.vol_A(1).v_idx=[];
                etc_render_fsbrain.vol_A(1).vertex_coords=[];
                etc_render_fsbrain.vol_A(1).faces=[];
                etc_render_fsbrain.vol_A(1).src_wb_idx=[];

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
        if(isempty(etc_render_fsbrain.overlay_vol_stc))
            if(~isempty(etc_render_fsbrain.overlay_stc))
                etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_stc;
            end;
            if(~isempty(etc_render_fsbrain.overlay_value))
                etc_render_fsbrain.overlay_vol_stc=etc_render_fsbrain.overlay_value(:);
            end;
        end;
    end;
%end;